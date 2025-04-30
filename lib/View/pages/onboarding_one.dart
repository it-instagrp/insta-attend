import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';

class OnboardingOne extends StatelessWidget {
  const OnboardingOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
            stops: [0, 1],
            colors: [
              kcPurple500,
              kcBaseWhite
            ]
        )
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(kaOnboardingOne, fit: BoxFit.scaleDown, height: 375, width: 315),
              Align(alignment: Alignment.center, child: Text("Welcome to Workmate!", style: kfHeadlineSmall.copyWith(color: Colors.black))),
              SizedBox(
                height: 20,
              ),
              Text("data")
            ],
          ),
        ),
      ),
    );
  }
}
