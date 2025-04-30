import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:insta_attend/Constant/constant_color.dart';


class CustomDropDown extends StatelessWidget {
  final List<String> options;
  final String hintText, title;
  final bool isField;
  final Function(dynamic value) onChanged;
  const CustomDropDown({super.key, required this.options, required this.onChanged, required this.hintText, required this.title, this.isField = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if(isField)Align(
          alignment: Alignment.topLeft,
          child: Text(title, style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kcGrey600
          ),),
        ),
        if(isField)SizedBox(height: 5,),
        CustomDropdown.search(
          items: options,
          onChanged: onChanged,
        hintText: hintText,
        decoration: CustomDropdownDecoration(
          hintStyle: TextStyle(
              fontSize: 14,
              color: kcGrey400
          ),
          closedBorderRadius: BorderRadius.circular(8.0),
          closedBorder: Border.all(
            color: kcGrey400
          ),
          expandedBorderRadius: BorderRadius.circular(8.0),
          expandedBorder: Border.all(
            color: kcGrey400
          ),
        ),
      ),
      ]
    );
  }
}
