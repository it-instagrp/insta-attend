import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Component/Button/main_button.dart';
import 'package:insta_attend/View/pages/login_page.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Controller/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _permissionsData = [
    {
      "title": "Enable Location Access",
      "purpose": "InstaAttend uses your location to verify that you are within the office premises (Geofencing) during Clock-In and Clock-Out.",
      "image": "assets/Images/onboarding1.png", // Replace with a location-themed asset
      "permission": "location"
    },
    {
      "title": "Camera for Face ID",
      "purpose": "We require camera access to perform secure biometric verification and liveness detection during attendance marking.",
      "image": "assets/Images/onboarding2.png", // Replace with a camera-themed asset
      "permission": "camera"
    },
    {
      "title": "Stay Notified",
      "purpose": "Receive real-time alerts about your task deadlines, meeting schedules, and attendance status updates.",
      "image": "assets/Images/onboarding3.png", // Replace with a notification-themed asset
      "permission": "notification"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcPurple25, // Using kcPurple25 theme
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _permissionsData.length,
                itemBuilder: (context, index) => _buildPermissionPage(index),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionPage(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(_permissionsData[index]['image']!, height: 280),
          const SizedBox(height: 40),
          Text(_permissionsData[index]['title']!,
              style: kfHeadlineSmall.copyWith(color: kcPurple900), textAlign: TextAlign.center), // Using kfHeadlineSmall
          const SizedBox(height: 20),
          Text(_permissionsData[index]['purpose']!,
              style: kfBodyMedium.copyWith(color: kcGrey600), textAlign: TextAlign.center), // Using kfBodyMedium
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          MainButton(
            label: "Allow Access",
            onTap: _handlePermissionRequest,
            buttonSize: ButtonSize.xl, // Using standard xl button size
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => Get.offAll(() => LoginPage()),
            child: Text("Maybe Later", style: TextStyle(color: kcGrey500)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_permissionsData.length, (index) => _buildIndicator(index)),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePermissionRequest() async {
    final String type = _permissionsData[_currentPage]['permission']!;
    PermissionStatus status;

    if (type == "location") {
      status = await Permission.location.request();
    } else if (type == "camera") {
      status = await Permission.camera.request();
    } else {
      status = await Permission.notification.request();
    }

    if (_currentPage < _permissionsData.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      await Get.find<OnboardingController>().markComplete();
      Get.offAll(() => LoginPage());
    }
  }

  Widget _buildIndicator(int index) {
    return Container(
      height: 8, width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index ? kcPurple600 : kcPurple200, // Using kcPurple600 for active indicator
      ),
    );
  }
}