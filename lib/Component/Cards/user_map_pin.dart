import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_color.dart';

class UserMapPin extends StatelessWidget {
  final String image;
  const UserMapPin({super.key, this.image = "https://res.cloudinary.com/dvhvwp3wx/image/upload/v1745923554/user_ovfbv1.png"});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: 210,
      decoration: BoxDecoration(
        border: Border.all(
          color: kcPurple400,
          width: 2
        ),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: Color(0xFF6938EF).withOpacity(0.10),
        child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2.5,
                color: kcPurple400
              )
            ),
            child: ClipOval(child: Image.network(image, fit: BoxFit.scaleDown, width: 40, height: 40,))),
      ),
    );
  }
}
