import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  Interpreter? _interpreter;

  // Standard input for MobileFaceNet
  static const int inputSize = 112;

  // CORRECTED: Your specific model returns 192 dimensions, not 128
  static const int outputDimensions = 192;

  Future<void> loadModel() async {
    try {
      // Ensure the path matches your actual assets folder structure
      _interpreter = await Interpreter.fromAsset('assets/model/mobile_face_net.tflite');
      debugPrint("Face Recognition Model loaded successfully with $outputDimensions output dims");
    } catch (e) {
      debugPrint("Error loading face recognition model: $e");
    }
  }

  List<double> extractEmbedding(img.Image faceImage) {
    if (_interpreter == null) {
      debugPrint("Interpreter not initialized");
      return [];
    }

    // 1. Resize image to model requirements (112x112)
    img.Image resized = img.copyResize(faceImage, width: inputSize, height: inputSize);

    // 2. Convert to Float32 list and normalize (0-255 to -1 to 1)
    var input = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(input.buffer);

    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        var pixel = resized.getPixel(x, y);
        // Normalization: (Pixel - 127.5) / 128 maps 0..255 to roughly -1..1
        buffer[pixelIndex++] = (pixel.r - 127.5) / 128;
        buffer[pixelIndex++] = (pixel.g - 127.5) / 128;
        buffer[pixelIndex++] = (pixel.b - 127.5) / 128;
      }
    }

    // 3. Prepare output container matching the model's actual shape [1, 192]
    var output = List.filled(1 * outputDimensions, 0.0).reshape([1, outputDimensions]);

    // 4. Run Inference
    try {
      _interpreter?.run(input.reshape([1, inputSize, inputSize, 3]), output);
    } catch (e) {
      debugPrint("Inference Error: $e");
      return [];
    }

    return List<double>.from(output[0]);
  }

  void close() {
    _interpreter?.close();
  }
}