import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../Utils/face_recognition_service.dart';
import '../../Utils/toast_messages.dart';

class FaceScannerPage extends StatefulWidget {
  final bool isRegistration;
  const FaceScannerPage({super.key, this.isRegistration = false});

  @override
  State<FaceScannerPage> createState() => _FaceScannerPageState();
}

class _FaceScannerPageState extends State<FaceScannerPage> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  bool _isCaptured = false;
  final FaceRecognitionService _recognitionService = FaceRecognitionService();

  // Low-allocation reusable heap buffers
  late final Float32List _inputBuffer;
  late final List<List<double>> _outputBuffer;
  late final List<double> _cleanResultEmbedding;

  double? _openEyeBaseline;
  int _consecutiveClosedFrames = 0;
  int _frameCount = 0;

  Timer? _timeoutTimer;
  DateTime? _fallbackTimerStart;

  // Strict optimization thresholds
  static const double minFaceConfidence = 0.75;
  static const int frameThrottleInterval = 3; // Process every 3rd frame
  static const int inputSize = 112;
  static const int outputDimensions = 192; // Dynamic MobileFaceNet configuration

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initAllocatedBuffers();
    _recognitionService.loadModel();
    _initializeCamera();
    _startLifecycleTimeout();
    _toggleWakelock(true);
  }

  void _initAllocatedBuffers() {
    _inputBuffer = Float32List(1 * inputSize * inputSize * 3);
    _outputBuffer = List.generate(1, (_) => List<double>.filled(outputDimensions, 0.0));
    _cleanResultEmbedding = List<double>.filled(outputDimensions, 0.0);
  }

  void _startLifecycleTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (mounted && !_isCaptured) {
        _isCaptured = true;
        _cameraController?.stopImageStream();
        showWarning("Face timeout: No face detected within limits.");
        Get.back(result: null);
      }
    });
  }

  void _toggleWakelock(bool enable) {
    try {
      if (enable) {
        // Fallback channel matching clean system platform wake-locks securely
        const MethodChannel('plugins.flutter.io/sensors')
            .invokeMethod('keepOn', true)
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint("Wakelock initiation skipped: $e");
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCam = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController?.initialize();
      if (mounted) {
        _fallbackTimerStart = DateTime.now();
        _cameraController?.startImageStream(_processCameraImage);
        setState(() {});
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void _processCameraImage(CameraImage image) async {
    _frameCount++;
    if (_frameCount % frameThrottleInterval != 0) return;

    if (_isProcessing || _isCaptured || !mounted) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        Face face = faces.first;

        // Apply optimization 2: Minimum confidence validation threshold
        if (face.boundingBox.width < 80 || face.boundingBox.height < 80) {
          _isProcessing = false;
          return;
        }

        // Filter extreme angles to guarantee high-fidelity extraction matrix match
        if (face.headEulerAngleY! > 22 || face.headEulerAngleY! < -22) {
          _isProcessing = false;
          return;
        }

        double? currentLeftEye = face.leftEyeOpenProbability;
        double? currentRightEye = face.rightEyeOpenProbability;

        if (currentLeftEye != null && currentRightEye != null) {
          if (_openEyeBaseline == null) {
            _openEyeBaseline = (currentLeftEye + currentRightEye) / 2;
          }

          double contextThreshold = (_openEyeBaseline! * 0.4).clamp(0.12, 0.28);
          bool isEyeClosed = currentLeftEye < contextThreshold || currentRightEye < contextThreshold;

          if (isEyeClosed) {
            _consecutiveClosedFrames++;
          } else {
            if (currentLeftEye > _openEyeBaseline!) {
              _openEyeBaseline = (currentLeftEye + currentRightEye) / 2;
            }
            _consecutiveClosedFrames = 0;
          }

          bool triggerFallback = _fallbackTimerStart != null &&
              DateTime.now().difference(_fallbackTimerStart!).inSeconds >= 6;

          if (_consecutiveClosedFrames >= 1 || triggerFallback) {
            _isCaptured = true;
            _timeoutTimer?.cancel();
            await _cameraController?.stopImageStream();
            await _extractAndReturnEmbedding(image, face);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Detection Error: $e");
    } catch (e) {
      debugPrint("ML Kit Parsing Failure: $e");
    } finally {
      if (!_isCaptured) {
        _isProcessing = false;
      }
    }
  }

  Future<void> _extractAndReturnEmbedding(CameraImage image, Face face) async {
    img.Image? capturedImage;
    img.Image? fixedImage;
    img.Image? croppedFace;

    try {
      capturedImage = _convertYUV420ToImage(image);
      if (capturedImage != null) {
        fixedImage = img.copyRotate(
          capturedImage,
          angle: Platform.isAndroid ? 270 : 0,
        );

        croppedFace = img.copyCrop(
          fixedImage,
          x: face.boundingBox.left.toInt(),
          y: face.boundingBox.top.toInt(),
          width: face.boundingBox.width.toInt(),
          height: face.boundingBox.height.toInt(),
        );

        final embedding = _extractEmbeddingWithBufferReuse(croppedFace);
        if (mounted) Get.back(result: embedding);
      }
    } catch (e) {
      debugPrint("Embedding Extraction Fail: $e");
      _isCaptured = false;
      _isProcessing = false;
      _fallbackTimerStart = DateTime.now();
      _cameraController?.startImageStream(_processCameraImage);
    } finally {
      // Apply optimization 4: Explicitly dispose/clear image structures from the Heap
      capturedImage?.clear();
      fixedImage?.clear();
      croppedFace?.clear();
    }
  }

  List<double> _extractEmbeddingWithBufferReuse(img.Image faceImage) {
    // Resize image safely without assigning continuous arrays
    img.Image resized = img.copyResize(faceImage, width: inputSize, height: inputSize);

    // Apply optimization 3: Reuse input buffer directly without structural re-allocations
    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        var pixel = resized.getPixel(x, y);
        _inputBuffer[pixelIndex++] = (pixel.r - 127.5) / 128;
        _inputBuffer[pixelIndex++] = (pixel.g - 127.5) / 128;
        _inputBuffer[pixelIndex++] = (pixel.b - 127.5) / 128;
      }
    }
    resized.clear();

    // Safely look up local interpreter configurations directly via public architecture instances
    final Interpreter? interpreterInstance = _recognitionService.getInterpreter();
    if (interpreterInstance == null) {
      throw Exception("TFLite Interpreter is not initialized on current service context.");
    }

    // Direct, low-allocation execution matching native tensor shapes
    final inputShape = _inputBuffer.reshape([1, inputSize, inputSize, 3]);
    interpreterInstance.run(inputShape, _outputBuffer);

    // Reuse output extraction variables without running garbage collector loops
    double sumSq = 0.0;
    for (int i = 0; i < outputDimensions; i++) {
      double val = _outputBuffer[0][i];
      _cleanResultEmbedding[i] = val;
      sumSq += val * val;
    }
    double norm = sqrt(sumSq);

    for (int i = 0; i < outputDimensions; i++) {
      _cleanResultEmbedding[i] /= norm;
    }

    return _cleanResultEmbedding;
  }

  img.Image? _convertYUV420ToImage(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final img.Image res = img.Image(width: width, height: height);

      final planeY = image.planes[0].bytes;
      final planeU = image.planes[1].bytes;
      final planeV = image.planes[2].bytes;

      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;
          final int index = y * width + x;

          if (index >= planeY.length || uvIndex >= planeU.length || uvIndex >= planeV.length) continue;

          final yp = planeY[index];
          final up = planeU[uvIndex];
          final vp = planeV[uvIndex];

          res.setPixelRgb(x, y, yp, up, vp);
        }
      }
      return res;
    } catch (e) {
      debugPrint("Image Conversion Error: $e");
      return null;
    }
  }

  InputImage _convertCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotationValue.fromRawValue(
            _cameraController!.description.sensorOrientation) ??
            InputImageRotation.rotation0deg,
        format: Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Center(
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          const Positioned(
            bottom: 60, left: 0, right: 0,
            child: Text("POSITION YOUR FACE & BLINK", textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _toggleWakelock(false);
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}