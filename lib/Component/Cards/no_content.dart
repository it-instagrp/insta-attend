import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Constant/constant_color.dart';


class NoContent extends StatelessWidget {
  final String icon, title, description;
  const NoContent({super.key, required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 175,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(icon, fit: BoxFit.scaleDown, height: 113,),
          SizedBox(
            height: 12,
          ),
          Text(title, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black
          ),),
          Text(description,
            textAlign: TextAlign.center,
            style: TextStyle(
            fontSize: 10,
            color: kcGrey300
          ),)
        ],
      ),
    );
  }
}
