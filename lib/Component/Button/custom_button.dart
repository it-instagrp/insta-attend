import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_color.dart';

enum ButtonSize { sm, md, lg, xl, xxl }
enum ButtonHierarchy { primary, secondary }
enum ButtonState { defaultState, focused, hover, disabled }


class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  // Match Figma properties exactly
  final ButtonSize size;
  final ButtonHierarchy hierarchy;
  final ButtonState state;
  final bool icon;           // (instead of hasIcon)
  final bool destructive;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.md,
    this.hierarchy = ButtonHierarchy.primary,
    this.state = ButtonState.defaultState,
    this.icon = false,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = state == ButtonState.disabled;

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: _buildButtonStyle(),
      child: _buildChild(),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getTextColor(),
      side: _getBorder(),
      minimumSize: _getSize(),
      elevation: _getElevation(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  Widget _buildChild() {
    if (icon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle_outlined, size: _getIconSize(), color: _getTextColor()),
          SizedBox(width: 20),
          Text(label, style: TextStyle(fontSize: _getFontSize())),
        ],
      );
    }
    return Text(label, style: TextStyle(fontSize: _getFontSize(), fontWeight: FontWeight.w600));
  }

  Color _getBackgroundColor() {
    if (hierarchy == ButtonHierarchy.secondary) {
      return Colors.transparent;
    }

    if (!destructive) {
      switch (state) {
        case ButtonState.focused:
          return kcPurple600;
        case ButtonState.hover:
          return kcPurple500;
        case ButtonState.disabled:
          return kcPurple200;
        default:
          return kcPurple600;
      }
    } else {
      switch (state) {
        case ButtonState.focused:
          return kcError600;
        case ButtonState.hover:
          return kcError500;
        case ButtonState.disabled:
          return kcError200;
        default:
          return kcError600;
      }
    }
  }

  Color _getTextColor() {
    if (state == ButtonState.disabled) return Colors.grey.shade600;

    if (hierarchy == ButtonHierarchy.secondary) {
      if (destructive) return kcError600;
      return kcPurple600;
    }

    return Colors.white;
  }

  BorderSide? _getBorder() {
    if (hierarchy == ButtonHierarchy.secondary) {
      return BorderSide(
        color: destructive ? kcError600 : kcPurple600,
        width: 2,
      );
    }
    return null;
  }

  Size _getSize() {
    if(icon){
      switch (size) {
        case ButtonSize.sm:
          return Size(148, 36);
        case ButtonSize.md:
          return Size(148, 40);
        case ButtonSize.lg:
          return Size(148, 44);
        case ButtonSize.xl:
          return Size(275, 48);
        case ButtonSize.xxl:
          return Size(148, 60);
      }
    } else {
      switch (size) {
        case ButtonSize.sm:
          return Size(120, 36);
        case ButtonSize.md:
          return Size(120, 40);
        case ButtonSize.lg:
          return Size(120, 44);
        case ButtonSize.xl:
          return Size(120, 48);
        case ButtonSize.xxl:
          return Size(120, 60);
      }
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.sm:
        return 12;
      case ButtonSize.md:
        return 14;
      case ButtonSize.lg:
        return 16;
      case ButtonSize.xl:
        return 18;
      case ButtonSize.xxl:
        return 20;
    }
  }

  double _getIconSize() {
    return _getFontSize() + 4;
  }

  double _getElevation() {
    if(hierarchy == ButtonHierarchy.secondary){
      return 0;
    } else {
      switch (state) {
        case ButtonState.focused:
        case ButtonState.hover:
        case ButtonState.disabled:
          return 0;
        default:
          return 2;
      }
    }
  }
}
