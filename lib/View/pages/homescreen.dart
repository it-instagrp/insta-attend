import 'package:flutter/material.dart';
import 'package:insta_attend/Component/Button/custom_button.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CustomButton(label: "Next", onPressed: (){ }, size: ButtonSize.sm, state: ButtonState.focused, hierarchy: ButtonHierarchy.primary, destructive: true,),
      ),
    );
  }
}
