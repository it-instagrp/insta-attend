import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_font.dart';

enum ButtonSize { sm, md, lg, xl, xxl }

enum ButtonType { disabled, normal }

class MainButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ButtonSize buttonSize;
  final ButtonType buttonType;
  const MainButton({
    super.key,
    this.buttonSize = ButtonSize.sm,
    this.buttonType = ButtonType.normal,
    required this.label,
    required this.onTap,
  });

  double _getHeight() {
    switch (buttonSize) {
      case ButtonSize.sm:
        return 36.0;
      case ButtonSize.md:
        return 40.0;
      case ButtonSize.lg:
        return 44.0;
      case ButtonSize.xl:
        return 48.0;
      case ButtonSize.xxl:
        return 52.0;
    }
  }

  List<Color> _getColors(){

    switch(buttonType){
      case ButtonType.disabled:
        return [
          Color(0xFFCAB3FF),
          Color(0xD06D3AF6)
        ];
      case ButtonType.normal:
        return [
          Color(0xFF8862F2),
          Color(0xFF7544FC),
          Color(0xFF5B2ED4)
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: _getHeight(),
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getColors(),
          ),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
      ),
    );
  }
}
