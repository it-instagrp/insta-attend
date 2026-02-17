import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  final SharedPreferences prefs = Get.find<SharedPreferences>();

  Future<bool> shouldShowOnboarding() async {
    // Check if it's the first run
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) return true;

    // Check if critical permissions were previously denied
    bool hasLocation = await Permission.location.isGranted;
    bool hasCamera = await Permission.camera.isGranted;

    return !hasLocation || !hasCamera;
  }

  Future<void> markComplete() async {
    await prefs.setBool('isFirstTime', false);
  }
}