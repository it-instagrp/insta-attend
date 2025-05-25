import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/main_button.dart' as main;
import 'package:insta_attend/Component/Fields/custom_password_field.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:get/get.dart';

import '../../Component/Button/custom_button.dart';
import '../../Constant/constant_font.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F3F8),
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.white,
        padding: const EdgeInsets.all(15.0),
        child: Obx(
              () =>
          controller.isLoading.value
              ? Center(
            child: CircularProgressIndicator(
              strokeCap: StrokeCap.round,
              color: kcPurple600,
            ),
          )
              : main.MainButton(
            label: "Update Password",
            onTap: () {
              showUpdateConfirmation(context);
            },
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 50,
        leading: InkWell(
          onTap: () => Get.back(),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: SvgPicture.asset(
                kaBackButton,
                fit: BoxFit.scaleDown,
                width: 10,
                height: 10,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Change Password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101828),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(15.0),
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /**** Page Title ****/
              ListTile(
                contentPadding: EdgeInsets.zero,
                isThreeLine: false,
                horizontalTitleGap: 0,
                title: Text(
                  "Change Password Form",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "Fill information to change your password",
                  style: TextStyle(fontSize: 12, color: kcGrey500),
                ),
              ),
              /**** Old Password ****/
              CustomPasswordField(title: "Current Password", hintText: "Enter Current Password", controller: controller.passwordController),
              SizedBox(height: 10.0),
              CustomPasswordField(title: "New Password", hintText: "Enter New Password", controller: controller.confirmPasswordController)
            ],
          ),
        ),
      ),
    );
  }

  void showUpdateConfirmation(BuildContext context){
    showModalBottomSheet(
        barrierColor: Colors.black.withAlpha(180),
        context: context,
        isScrollControlled: true,
        builder: (context){
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                    ),
                    Text("Update Password", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    SizedBox(
                      height: 15,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text("Are you sure you want to update your password? To ensure your account safety we will send verification code to your email", style: kfBodyMedium.copyWith(color: kcGrey400),)),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        child: Obx(()=>controller.isLoading.value ? Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: kcPurple600,),) : main.MainButton(label: "Yes, Update Password", onTap: ()=>controller.changePassword(context)))),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        child: CustomButton(label: "No, Let me check", onPressed: ()=>Navigator.pop(context), hierarchy: ButtonHierarchy.secondary,)),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
              Positioned(
                  left: 0,
                  right: 0,
                  top: -50,
                  child: SvgPicture.asset(kaUpdatePasswordTop))
            ],
          );
        });
  }
}
