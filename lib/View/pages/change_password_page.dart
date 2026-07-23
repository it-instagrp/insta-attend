import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/main_button.dart' as main;
import 'package:insta_attend/Component/Fields/custom_password_field.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:get/get.dart';
import '../../Utils/bottom_sheet_helper.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final AuthController controller = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              if (_formKey.currentState!.validate()){
                showUpdateConfirmation(context);
              }
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
          child: Form(
            key: _formKey,
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
                CustomPasswordField(title: "New Password", hintText: "Enter New Password", controller: controller.confirmPasswordController, validator: controller.validateNewPassword, autovalidateMode: AutovalidateMode.onUserInteraction)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showUpdateConfirmation(BuildContext context) {
    showCustomBottomSheet(
      context: context,
      title: "Update Password",
      description: "Are you sure you want to update your password? To ensure your account safety we will send verification code to your email",
      topIconAsset: kaUpdatePasswordTop,
      primaryButton: Obx(
            () => controller.isLoading.value
            ? Center(
          child: CircularProgressIndicator(
            strokeCap: StrokeCap.round,
            color: kcPurple600,
          ),
        )
            : main.MainButton(
          label: "Yes, Update Password",
          onTap: () => controller.changePassword(context),
        ),
      ),
    );
  }
}
