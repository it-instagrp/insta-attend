import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Constant/constant_color.dart';

class CustomTextField extends StatelessWidget {
  final String title, hintText, icon;
  final bool isDisabled;
  final VoidCallback? onTap;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  const CustomTextField({
    super.key,
    required this.title,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isDisabled = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.validator,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kcGrey600,
              ),
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            onTap: onTap,
            readOnly: isDisabled,
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            validator: validator,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: kcPurple400),
              ),
              prefixIcon: SvgPicture.asset(
                icon,
                fit: BoxFit.scaleDown,
                height: 20,
                width: 20,
                color: kcPurple400,
              ),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14, color: kcGrey400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: kcGrey400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
