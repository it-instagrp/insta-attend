import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  Interpreter? _interpreter;

  static const int inputSize = 112;
  static const int outputDimensions = 192;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/mobile_face_net.tflite',
      );
      debugPrint(
        "Face Recognition Model loaded successfully with $outputDimensions output dims",
      );
    } catch (e) {
      debugPrint("Error loading face recognition model: $e");
    }
  }

  /// Exposes the internal interpreter instance to allow buffer reuse across views
  Interpreter? getInterpreter() => _interpreter;

  /// Fallback extraction logic using internal single-use allocations if needed
  List<double> extractEmbedding(img.Image faceImage) {
    if (_interpreter == null) return [];

    img.Image resized = img.copyResize(
      faceImage,
      width: inputSize,
      height: inputSize,
    );
    var input = Float32List(1 * inputSize * inputSize * 3);

    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        var pixel = resized.getPixel(x, y);
        input[pixelIndex++] = (pixel.r - 127.5) / 128;
        input[pixelIndex++] = (pixel.g - 127.5) / 128;
        input[pixelIndex++] = (pixel.b - 127.5) / 128;
      }
    }
    resized.clear();

    var output = List.generate(
      1,
      (_) => List<double>.filled(outputDimensions, 0.0),
    );

    try {
      _interpreter?.run(input.reshape([1, inputSize, inputSize, 3]), output);
    } catch (e) {
      return [];
    }

    List<double> rawEmbedding = List<double>.from(output[0]);
    double sumSq = 0.0;
    for (double val in rawEmbedding) {
      sumSq += val * val;
    }
    double norm = sqrt(sumSq);

    return rawEmbedding.map((val) => val / norm).toList();
  }

  void close() {
    _interpreter?.close();
  }
}
