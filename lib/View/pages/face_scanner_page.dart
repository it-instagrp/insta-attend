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

  late final Float32List _inputBuffer;
  late final List<List<double>> _outputBuffer;
  late final List<double> _cleanResultEmbedding;

  double? _openEyeBaseline;
  int _consecutiveClosedFrames = 0;
  int _frameCount = 0;

  Timer? _timeoutTimer;
  DateTime? _fallbackTimerStart;

  static const int frameThrottleInterval = 3;
  static const int inputSize = 112;
  static const int outputDimensions = 192;

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
    _outputBuffer = List.generate(
      1,
          (_) => List<double>.filled(outputDimensions, 0.0),
    );
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
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      if (enable) {
        const MethodChannel('plugins.flutter.io/sensors')
            .invokeMethod('keepOn', true)
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint("Wakelock error: $e");
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
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
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
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        Face face = faces.first;

        // Check face size is reasonable
        if (face.boundingBox.width < 60 || face.boundingBox.height < 60) {
          _isProcessing = false;
          return;
        }

        double? leftEye = face.leftEyeOpenProbability;
        double? rightEye = face.rightEyeOpenProbability;

        if (leftEye != null && rightEye != null) {
          // Set baseline on first detection
          if (_openEyeBaseline == null) {
            _openEyeBaseline = (leftEye + rightEye) / 2;
          }

          // Calculate eye closure threshold
          double threshold = (_openEyeBaseline! * 0.45).clamp(0.12, 0.28);
          bool isEyeClosed = leftEye < threshold || rightEye < threshold;

          if (isEyeClosed) {
            _consecutiveClosedFrames++;
          } else {
            if (leftEye > _openEyeBaseline!) {
              _openEyeBaseline = (leftEye + rightEye) / 2;
            }
            _consecutiveClosedFrames = 0;
          }

          // Check if blink detected or timeout reached
          bool fallbackTimeout = _fallbackTimerStart != null &&
              DateTime.now().difference(_fallbackTimerStart!).inSeconds >= 6;

          if (_consecutiveClosedFrames >= 1 || fallbackTimeout) {
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

        int x = face.boundingBox.left.toInt().clamp(0, fixedImage.width - 1);
        int y = face.boundingBox.top.toInt().clamp(0, fixedImage.height - 1);
        int w = face.boundingBox.width.toInt().clamp(1, fixedImage.width - x);
        int h = face.boundingBox.height.toInt().clamp(1, fixedImage.height - y);

        croppedFace = img.copyCrop(fixedImage, x: x, y: y, width: w, height: h);

        final embedding = _extractEmbeddingWithBufferReuse(croppedFace);
        if (mounted) Get.back(result: embedding);
      }
    } catch (e) {
      debugPrint("Embedding Extraction Error: $e");
      _isCaptured = false;
      _isProcessing = false;
      _fallbackTimerStart = DateTime.now();
      _cameraController?.startImageStream(_processCameraImage);
    } finally {
      capturedImage?.clear();
      fixedImage?.clear();
      croppedFace?.clear();
    }
  }

  List<double> _extractEmbeddingWithBufferReuse(img.Image faceImage) {
    img.Image resized = img.copyResize(
      faceImage,
      width: inputSize,
      height: inputSize,
    );

    // Fill input buffer with normalized RGB
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

    final Interpreter? interpreterInstance =
    _recognitionService.getInterpreter();
    if (interpreterInstance == null) {
      throw Exception("TFLite Interpreter uninitialized.");
    }

    // Run model inference
    interpreterInstance.run(
      _inputBuffer.reshape([1, inputSize, inputSize, 3]),
      _outputBuffer,
    );

    // L2 normalize the embedding
    double sumSq = 0.0;
    for (int i = 0; i < outputDimensions; i++) {
      double val = _outputBuffer[0][i];
      _cleanResultEmbedding[i] = val;
      sumSq += val * val;
    }
    double norm = sqrt(sumSq);

    for (int i = 0; i < outputDimensions; i++) {
      _cleanResultEmbedding[i] /= (norm == 0 ? 1.0 : norm);
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

      final int yRowStride = image.planes[0].bytesPerRow;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * yRowStride + x;
          final int uvIndex =
              (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;

          if (yIndex >= planeY.length ||
              uvIndex >= planeU.length ||
              uvIndex >= planeV.length) continue;

          final yp = planeY[yIndex];
          final up = planeU[uvIndex];
          final vp = planeV[uvIndex];

          int r = (yp + 1.370705 * (vp - 128)).round().clamp(0, 255);
          int g = (yp - 0.337633 * (up - 128) - 0.698001 * (vp - 128))
              .round()
              .clamp(0, 255);
          int b = (yp + 1.732446 * (up - 128)).round().clamp(0, 255);

          res.setPixelRgb(x, y, r, g, b);
        }
      }
      return res;
    } catch (e) {
      debugPrint("YUV Conversion Error: $e");
      return null;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;

      final Uint8List yPlane = image.planes[0].bytes;
      final Uint8List uPlane = image.planes[1].bytes;
      final Uint8List vPlane = image.planes[2].bytes;

      final int yStride = image.planes[0].bytesPerRow;
      final int uvStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      final int totalNV21Length =
          width * height + (2 * ((width + 1) ~/ 2) * ((height + 1) ~/ 2));
      final Uint8List nv21Buffer = Uint8List(totalNV21Length);

      // Copy Y plane
      int idY = 0;
      for (int y = 0; y < height; y++) {
        int rowStart = y * yStride;
        for (int x = 0; x < width; x++) {
          nv21Buffer[idY++] = yPlane[rowStart + x];
        }
      }

      // Copy UV planes in NV21 format
      int idUV = width * height;
      final int uvHeight = (height + 1) ~/ 2;
      final int uvWidth = (width + 1) ~/ 2;

      for (int y = 0; y < uvHeight; y++) {
        int uvRowStart = y * uvStride;
        for (int x = 0; x < uvWidth; x++) {
          int pixelOffset = x * uvPixelStride;
          nv21Buffer[idUV++] = vPlane[uvRowStart + pixelOffset];
          nv21Buffer[idUV++] = uPlane[uvRowStart + pixelOffset];
        }
      }

      return InputImage.fromBytes(
        bytes: nv21Buffer,
        metadata: InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: InputImageRotationValue.fromRawValue(
            _cameraController!.description.sensorOrientation,
          ) ??
              InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: width,
        ),
      );
    } catch (e) {
      debugPrint("MLKit Conversion Error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              "POSITION YOUR FACE & BLINK",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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