import 'package:flutter/material.dart';


class OnboardingSubpage extends StatelessWidget {
  final String image, title, description;
  final VoidCallback onNext, onSkip;
  final int index;
  const OnboardingSubpage({super.key, required this.image, required this.title, required this.description, required this.onNext, required this.onSkip, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(image),

      ],
    );
  }
}

