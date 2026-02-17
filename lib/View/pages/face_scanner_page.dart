import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import '../../Utils/face_recognition_service.dart';

class FaceScannerPage extends StatefulWidget {
  final bool isRegistration;
  const FaceScannerPage({super.key, this.isRegistration = false});

  @override
  State<FaceScannerPage> createState() => _FaceScannerPageState();
}

class _FaceScannerPageState extends State<FaceScannerPage> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  final FaceRecognitionService _recognitionService = FaceRecognitionService();

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast, // Faster mode for emulators
    ),
  );

  @override
  void initState() {
    super.initState();
    _recognitionService.loadModel();
    _initializeCamera();
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
        _cameraController?.startImageStream(_processCameraImage);
        setState(() {});
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing || !mounted) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        Face face = faces.first;

        // Liveness: Detect a blink (left eye probability < 0.15)
        if (face.leftEyeOpenProbability != null && face.leftEyeOpenProbability! < 0.15) {
          await _cameraController?.stopImageStream();

          // REAL DETECTION: Convert raw YUV to Image and crop face region
          final img.Image? capturedImage = _convertYUV420ToImage(image);

          if (capturedImage != null) {

            img.Image fixedImage = img.copyRotate(
                capturedImage,
                angle: Platform.isAndroid ? 270 : 0
            );

            final img.Image croppedFace = img.copyCrop(
              fixedImage,
              x: face.boundingBox.left.toInt(),
              y: face.boundingBox.top.toInt(),
              width: face.boundingBox.width.toInt(),
              height: face.boundingBox.height.toInt(),
            );
            final embedding = _recognitionService.extractEmbedding(croppedFace);
            if (mounted) Get.back(result: embedding);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Detection Error: $e");
    } finally {
      // Throttle processing to allow the UI to breathe and prevent ANRs
      await Future.delayed(const Duration(milliseconds: 300));
      _isProcessing = false;
    }
  }

  // Convert CameraImage format to Image package format
  img.Image? _convertYUV420ToImage(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final img.Image res = img.Image(width: width, height: height);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = (y >> 1) * (width >> 1) + (x >> 1);
          final int index = y * width + x;

          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];

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
                  border: Border.all(color: Colors.white, width: 2)
              ),
            ),
          ),
          const Positioned(
              bottom: 60, left: 0, right: 0,
              child: Text("POSITION YOUR FACE & BLINK", textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}