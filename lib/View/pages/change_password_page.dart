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
      backgroundColor: const Color(0xFFF1F3F8),
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomButton(context),
      body: Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildFormHeader(),
                _buildPasswordFields(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the app bar with back navigation.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leadingWidth: 50,
      leading: InkWell(
        onTap: Get.back,
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
      title: const Text(
        "Change Password",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
      ),
    );
  }

  // Displays the form title and description.
  Widget _buildFormHeader() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 0,
      title: const Text(
        "Change Password Form",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        "Fill information to change your password",
        style: TextStyle(
          fontSize: 12,
          color: kcGrey500,
        ),
      ),
    );
  }

  // Builds the password input fields.
  Widget _buildPasswordFields() {
    return Column(
      children: [
        CustomPasswordField(
          title: "Current Password",
          hintText: "Enter Current Password",
          controller: controller.passwordController,
        ),
        const SizedBox(height: 10),
        CustomPasswordField(
          title: "New Password",
          hintText: "Enter New Password",
          controller: controller.confirmPasswordController,
          validator: controller.validateNewPassword,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  // Builds the bottom action button for updating password.
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      padding: const EdgeInsets.all(15.0),
      child: Obx(
            () => controller.isLoading.value
            ? Center(
          child: CircularProgressIndicator(
            strokeCap: StrokeCap.round,
            color: kcPurple600,
          ),
        )
            : main.MainButton(
          label: "Update Password",
          onTap: () {
            if (_formKey.currentState!.validate()) {
              showUpdateConfirmation(context);
            }
          },
        ),
      ),
    );
  }

  // Shows a confirmation bottom sheet before updating the password.
  void showUpdateConfirmation(BuildContext context) {
    showCustomBottomSheet(
      context: context,
      title: "Update Password",
      description:
      "Are you sure you want to update your password? To ensure your account safety we will send verification code to your email",
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