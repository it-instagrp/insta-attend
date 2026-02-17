import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:insta_attend/View/pages/homescreen.dart';
import 'package:insta_attend/View/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/onboarding_controller.dart';
import '../../Model/User.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
  final ApiClient apiClient = Get.find<ApiClient>();
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Register the new controller
    final OnboardingController onboardingController = Get.find<OnboardingController>();

    Future.delayed(const Duration(seconds: 3), () async {
      final String userToken = sharedPreferences.getString("token") ?? "";
      final String userJson = sharedPreferences.getString("user") ?? "";

      if (userToken.isNotEmpty && userJson.isNotEmpty) {
        apiClient.updateHeader(userToken);
        controller.currentUser.value = User.fromJson(jsonDecode(userJson));
        Get.offAll(() => Homescreen());
      } else {
        // Check if onboarding or permissions are required
        bool showOnboarding = await onboardingController.shouldShowOnboarding();
        if (showOnboarding) {
          Get.offAll(() => const OnboardingScreen());
        } else {
          Get.offAll(() => LoginPage());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text("InstaAttend", style: kfHeadlineLarge.copyWith(color: kcPurple500),),
      ),
    );
  }
}
