import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Constant/constant_color.dart';

class CustomTextfield extends StatelessWidget {
  final String title, hintText, icon;
  final bool isDisabled;
  final VoidCallback? onTap;
  final TextEditingController controller;
  const CustomTextfield({super.key, required this.title, required this.hintText, required this.icon, required this.controller, this.isDisabled = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(title, style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kcGrey600
            ),),
          ),
          SizedBox(height: 5,),
          TextFormField(
            onTap: onTap,
            readOnly: isDisabled,
            controller: controller,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: kcPurple400)
              ),
              prefixIcon: SvgPicture.asset(icon, fit: BoxFit.scaleDown, height: 20, width: 20, color: kcPurple400,),
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14,
                color: kcGrey400
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: kcGrey400)
              )
            ),
          )
        ],
      ),
    );
  }
}
