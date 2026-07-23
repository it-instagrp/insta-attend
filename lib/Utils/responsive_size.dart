import 'package:flutter/material.dart';

// converts fixed design sizes into values that scale per device screen.
class ResponsiveSize {
  //reference screen size used while designing the UI
  static const double _designWidth = 390;
  static const double _designHeight = 844;

  static late double screenWidth;
  static late double screenHeight;

  // call once at top of build() to the current device's screen size.
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenHeight = mediaQuery.size.height;
    screenWidth = mediaQuery.size.width;
  }

  //scales horizontal values (padding, width) to this device
  static double width(double designValue) {
    return (designValue / _designWidth) * screenWidth;
  }

  //scales vertical values (height, margin) to this device.
  static double height(double designValue) {
    return (designValue / _designHeight) * screenHeight;
  }

  //scales font size, capped so text isn't too small or too large
  static double font(double designValue) {
    final widthScale = screenWidth / _designWidth;
    final heightScale = screenHeight / _designHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;

    final clampedScale = scale.clamp(0.85, 1.25);
    return designValue * clampedScale;
  }
}

//shortcuts: use 20.rw, 140.rh, 16.rf directly on numbers.
extension ResponsiveNum on num {
  // Responsive width — for horizontal padding/margins/widths.
  double get rw => ResponsiveSize.width(toDouble());
  // Responsive height — for vertical padding/margins/heights.
  double get rh => ResponsiveSize.height(toDouble());
  // Responsive font — for all fontSize values.
  double get rf => ResponsiveSize.font(toDouble());
}
