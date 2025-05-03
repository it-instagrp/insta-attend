import 'package:flutter/material.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:get/get.dart';
import 'package:insta_attend/View/pages/homescreen.dart';
import 'package:insta_attend/View/pages/login_page.dart';
import 'package:insta_attend/View/pages/onboarding_one.dart';
import 'package:insta_attend/View/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
  final ApiClient apiClient = Get.find<ApiClient>();

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () async{
      final String userToken = await sharedPreferences.getString("token") ?? "";
      if(userToken.isNotEmpty){
        apiClient.updateHeader(userToken);
        Get.offAll(()=>Homescreen(), transition: Transition.fadeIn);
      } else {
        Get.offAll(()=>LoginPage(), transition: Transition.fadeIn);
      }
    });
    super.initState();
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
