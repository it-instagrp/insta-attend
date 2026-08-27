import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/main_button.dart';
import 'package:insta_attend/Component/Fields/custom_password_field.dart';
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Utils/exit_confirmation_scope.dart';
import 'package:insta_attend/View/pages/register_page.dart';
import '../../Utils/bottom_sheet_helper.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthController controller = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ExitConfirmationScope(
      child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              SvgPicture.asset(
                kaLogo,
                fit: BoxFit.scaleDown,
                height: 55,
                width: 55,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "InstaAttend",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Register using your credentials",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kcGrey400,
                  ),
                ),
              ),
              SizedBox(height: 25),
              CustomTextField(
                title: "Email",
                hintText: "Enter your email",
                icon: kaEmail,
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
                onChanged: (_) => controller.checkLoginFormValidity(),
              ),
              SizedBox(height: 15),
              CustomPasswordField(
                title: "Password",
                hintText: "My Password",
                controller: controller.passwordController,
                validator: controller.validatePassword,
                onChanged: (_) => controller.checkLoginFormValidity(),
              ),
              SizedBox(height: 20),
              Obx(
                () =>
                    controller.isLoginPageLoading.value
                        ? Center(
                          child: CircularProgressIndicator(
                            strokeCap: StrokeCap.round,
                            color: kcPurple500,
                          ),
                        )
                        : Obx(
                          () => MainButton(
                            // WRAP in Obx
                            label: "Login",
                            buttonType:
                                controller.isLoginFormValid.value
                                    ? ButtonType.normal
                                    : ButtonType.disabled, // ADD
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                controller.login(context);
                              }
                            },
                            buttonSize: ButtonSize.xl,
                          ),
                        ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width * 0.3,
                    color: kcGrey400,
                  ),
                  Text("or", style: kfBodyMedium),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width * 0.3,
                    color: kcGrey400,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Don't Have Account? ", style: kfTitleSmall),
                  InkWell(
                    onTap: () {
                      controller.emailController.clear();
                      controller.passwordController.clear();
                      Get.to(() => RegisterPage());
                    },
                    child: Text(
                      "Sign up",
                      style: kfTitleSmall.copyWith(
                        color: kcPurple500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Forgot Password? ", style: kfTitleSmall),
                  InkWell(
                    onTap: () {
                      showForgotPasswordScreen(context: context);
                    },
                    child: Text(
                      "Click Here",
                      style: kfTitleSmall.copyWith(
                        color: kcPurple500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void showForgotPasswordScreen({required BuildContext context}) {
    showCustomBottomSheet(
      context: context,
      title: "Forgot Password",
      description:
          "A verification link will be sent to your email to reset your password.",
      topIconAsset: kaForgotPasswordTop,
      showSecondaryButton: false,
      additionalContent: Form(
        key: _forgotPasswordFormKey,
        child: CustomTextField(
          title: "Email",
          hintText: "My Email",
          icon: kaEmail,
          controller: controller.forgotPasswordEmailController,
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
        ),
      ),
      primaryButton: Obx(
        () =>
            controller.isForgotPasswordLoading.value
                ? Center(
                  child: CircularProgressIndicator(
                    strokeCap: StrokeCap.round,
                    color: kcPurple600,
                  ),
                )
                : MainButton(
                  label: "Send Email",
                  onTap: () {
                    if (_forgotPasswordFormKey.currentState!.validate()) {
                      controller.forgotPassword(context);
                    }
                  },
                  buttonSize: ButtonSize.lg,
                ),
      ),
    );
  }
}
