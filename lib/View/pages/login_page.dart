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
import 'package:insta_attend/View/pages/register_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32),
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
            CustomTextfield(
              title: "Email",
              hintText: "Enter your email",
              icon: kaEmail,
              controller: controller.emailController,
            ),
            SizedBox(height: 15),
            CustomPasswordField(
              title: "Password",
              hintText: "My Password",
              controller: controller.passwordController,
            ),
            SizedBox(height: 20),
            Obx(
                  () =>
              controller.isLoading.value
                  ? Center(
                child: CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  color: kcPurple500,
                ),
              )
                  : MainButton(
                label: "Login",
                onTap: () {
                    controller.login(context);
                },
                buttonSize: ButtonSize.xl,
              ),
            ),
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width * 0.3,
                  color: kcGrey400,
                ),
                Text("or", style: kfBodyMedium,),
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width * 0.3,
                  color: kcGrey400,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Don't Have Account? ", style: kfTitleSmall,),
                InkWell(
                  onTap: ()
                  {
                    Get.off(() => RegisterPage());
                  },
                  child: Text("Sign up", style: kfTitleSmall.copyWith(color: kcPurple500, fontWeight: FontWeight.w600),),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Forgot Password? ", style: kfTitleSmall,),
                InkWell(
                  onTap: (){
                    showForgotPasswordScreen(context: context);
                  },
                  child: Text("Click Here", style: kfTitleSmall.copyWith(color: kcPurple500, fontWeight: FontWeight.w600),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showForgotPasswordScreen({required BuildContext context}){
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
                Text("Forgot Password", style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black
                ),),
                SizedBox(
                  height: 15,
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Text("A verification link will be sent to your email to reset your password.", style: kfBodyMedium.copyWith(color: kcGrey400),)),
                SizedBox(
                  height: 30,
                ),
                CustomTextfield(title: "Email", hintText: "My Email", icon: kaEmail, controller: controller.emailController),
                SizedBox(
                  height: 35,
                ),
                Obx(()=>controller.isLoading.value ? Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: kcPurple600,),) : MainButton(label: "Send Email", onTap: (){}, buttonSize: ButtonSize.lg,)),
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
              child: SvgPicture.asset(kaForgotPasswordTop))
        ],
      );
    });
  }
}
