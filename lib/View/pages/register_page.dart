import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:insta_attend/Component/Button/main_button.dart';
import 'package:insta_attend/Component/Fields/custom_drop_down.dart';
import 'package:insta_attend/Component/Fields/custom_password_field.dart';
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Model/department.dart';
import 'package:insta_attend/Model/designation.dart';
import 'package:insta_attend/View/pages/login_page.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final AuthController controller = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getDepartment();
      controller.getDesignation();
    });
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
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
                        title: "Full Name",
                        hintText: "Enter your name",
                        icon: kaPerson,
                        controller: controller.usernameController,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 15),
                      CustomTextField(
                        title: "Email",
                        hintText: "Enter your email",
                        icon: kaEmail,
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.validateEmail,
                      ),
                      SizedBox(height: 15),
                      CustomTextField(
                        title: "Phone Number",
                        hintText: "Enter your phone number",
                        icon: kaPhone,
                        controller: controller.phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value){
                          if(value == null || value.trim().isEmpty) {
                            return 'Phone Number is required';
                          }
                          if (value.length < 10) {
                            return 'Phone number must be exactly of 10 digits ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      // Department Dropdown Implementation
                      Obx(() => controller.isDropDownLoading.value
                          ? Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: kcPurple600))
                          : CustomDropDown(
                        options: controller.departmentList.value.map((dept) => dept.departmentName ?? '').toList(),
                        onChanged: (selectedName) {
                          final selectedDept = controller.departmentList.firstWhere(
                                (dept) => dept.departmentName == selectedName,
                            orElse: () => Department(id: '', departmentName: ''),
                          );
                          controller.selectedDepartment.value = selectedDept.id ?? '';
                        },
                        hintText: 'Select Department',
                        title: 'Department',
                        isField: true,
                        hasError: controller.selectedDepartment.value.isEmpty && controller.isLoading.value,
                      )),
                      const SizedBox(height: 15),

                      // Designation Dropdown Implementation
                      Obx(() => controller.isDropDownLoading.value
                          ? Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: kcPurple600))
                          : CustomDropDown(
                        options: controller.designationList.value.map((role) => role.designationName ?? '').toList(),
                        onChanged: (selectedName) {
                          final selectedRole = controller.designationList.firstWhere(
                                (role) => role.designationName == selectedName,
                            orElse: () => Designation(id: '', designationName: ''),
                          );
                          controller.selectedDesignation.value = selectedRole.id ?? '';
                        },
                        hintText: 'Select Designation',
                        title: 'Designation',
                        isField: true,
                        hasError: controller.selectedDesignation.value.isEmpty && controller.isLoading.value,
                      )),
                      SizedBox(height: 15),
                      CustomPasswordField(
                        title: "Password",
                        hintText: "My Password",
                        controller: controller.passwordController,
                      ),
                      SizedBox(height: 15),
                      CustomPasswordField(
                        title: "Confirm Password",
                        hintText: "Confirm My Password",
                        controller: controller.confirmPasswordController,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Obx(() => Checkbox(
                            value: controller.isConsentGiven.value,
                            onChanged: (value) => controller.isConsentGiven.value = !controller.isConsentGiven.value,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            activeColor: kcPurple500,
                            side: BorderSide(color: kcPurple400),
                          )),
                          Text(
                            "I agree with ",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "terms & conditions ",
                              style: TextStyle(
                                fontSize: 12,
                                color: kcPurple400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Obx(() => controller.isLoading.value
                          ? Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: kcPurple500))
                          : MainButton(
                        label: "Register",
                        onTap: () {
                          // Rule evaluation sequence correction
                          final isCustomFormValid = controller.validateRegisterForm(context);
                          final isInputFormValid = _formKey.currentState!.validate();

                          if (isCustomFormValid && isInputFormValid) {
                            controller.register(context);
                          }
                        },
                        buttonSize: ButtonSize.xl,
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 5,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.usernameController.clear();
                  controller.emailController.clear();
                  controller.phoneController.clear();
                  controller.passwordController.clear();
                  controller.confirmPasswordController.clear();
                  Get.offAll(() => LoginPage());
                  },
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.transparent, // makes full area tappable
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: SvgPicture.asset(
                      kaBackButton,
                      fit: BoxFit.scaleDown,
                      width: 10,
                      height: 10,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}