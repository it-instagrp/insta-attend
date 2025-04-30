import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';

class CustomPasswordField extends StatelessWidget {
  final String title, hintText;
  final TextEditingController controller;
  CustomPasswordField({super.key, required this.title, required this.hintText, required this.controller});

  RxBool isObscure = true.obs;

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
          Obx(()=>TextFormField(
            obscureText: isObscure.value,
            controller: controller,
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: kcPurple400)
                ),
                prefixIcon: SvgPicture.asset(kaPassword, fit: BoxFit.scaleDown, height: 20, width: 20, color: kcPurple400,),
                suffixIcon: Obx(()=>isObscure.value ? InkWell(onTap: ()=>isObscure.value = false, child: SvgPicture.asset(kaVisible, fit: BoxFit.scaleDown, width: 25, height: 25,)) : InkWell(onTap: ()=>isObscure.value = true, child: SvgPicture.asset(kaNotVisible, fit: BoxFit.scaleDown, width: 25, height: 25,))),
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
          ))
        ],
      ),
    );
  }
}
