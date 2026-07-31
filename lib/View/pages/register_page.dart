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
            _buildMainContent(),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  // Main scrollable form content
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildNameField(),
              const SizedBox(height: 15),
              _buildEmailField(),
              const SizedBox(height: 15),
              _buildPhoneField(),
              const SizedBox(height: 15),
              _buildDepartmentDropdown(),
              const SizedBox(height: 15),
              _buildDesignationDropdown(),
              const SizedBox(height: 15),
              _buildPasswordField(),
              const SizedBox(height: 15),
              _buildConfirmPasswordField(),
              const SizedBox(height: 15),
              _buildTermsCheckbox(),
              const SizedBox(height: 20),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Header with logo, app name, and subtitle
  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        SvgPicture.asset(
          kaLogo,
          fit: BoxFit.scaleDown,
          height: 55,
          width: 55,
        ),
        const SizedBox(height: 10),
        const Text(
          "InstaAttend",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Register using your credentials",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: kcGrey400,
          ),
        ),
      ],
    );
  }

  // Full name input field
  Widget _buildNameField() {
    return CustomTextField(
      title: "Full Name",
      hintText: "Enter your name",
      icon: kaPerson,
      controller: controller.usernameController,
      keyboardType: TextInputType.text,
    );
  }

  // Email input field
  Widget _buildEmailField() {
    return CustomTextField(
      title: "Email",
      hintText: "Enter your email",
      icon: kaEmail,
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      validator: controller.validateEmail,
    );
  }

  // Phone number field with validation
  Widget _buildPhoneField() {
    return CustomTextField(
      title: "Phone Number",
      hintText: "Enter your phone number",
      icon: kaPhone,
      controller: controller.phoneController,
      keyboardType: TextInputType.number,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: _validatePhoneNumber,
    );
  }

  // Department dropdown with loading state
  Widget _buildDepartmentDropdown() {
    return Obx(
          () => controller.isDropDownLoading.value
          ? _buildLoadingIndicator()
          : CustomDropDown(
        options: controller.departmentList.value
            .map((dept) => dept.departmentName ?? '')
            .toList(),
        onChanged: (selectedName) {
          _handleDepartmentSelection(selectedName);
        },
        hintText: 'Select Department',
        title: 'Department',
        isField: true,
      ),
    );
  }

  // Designation dropdown with loading state
  Widget _buildDesignationDropdown() {
    return Obx(
          () => controller.isDropDownLoading.value
          ? _buildLoadingIndicator()
          : CustomDropDown(
        options: controller.designationList.value
            .map((role) => role.designationName ?? '')
            .toList(),
        onChanged: (selectedName) {
          _handleDesignationSelection(selectedName);
        },
        hintText: 'Select Designation',
        title: 'Designation',
        isField: true,
      ),
    );
  }

  // Password input field
  Widget _buildPasswordField() {
    return CustomPasswordField(
      title: "Password",
      hintText: "My Password",
      controller: controller.passwordController,
    );
  }

  // Confirm password input field
  Widget _buildConfirmPasswordField() {
    return CustomPasswordField(
      title: "Confirm Password",
      hintText: "Confirm My Password",
      controller: controller.confirmPasswordController,
    );
  }

  // Terms & conditions checkbox
  Widget _buildTermsCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
              () => Checkbox(
            value: controller.isConsentGiven.value,
            onChanged: (_) =>
            controller.isConsentGiven.value =
            !controller.isConsentGiven.value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: kcPurple500,
            side: BorderSide(color: kcPurple400),
          ),
        ),
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
    );
  }

  // Register button with loading state
  Widget _buildRegisterButton() {
    return Obx(
          () => controller.isRegisterPageLoading.value
          ? _buildLoadingIndicator()
          : MainButton(
        label: "Register",
        onTap: _handleRegisterTap,
        buttonSize: ButtonSize.xl,
      ),
    );
  }

  // Reusable loading indicator
  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        strokeCap: StrokeCap.round,
        color: kcPurple600,
      ),
    );
  }

  // Back button in top-left corner
  Widget _buildBackButton() {
    return Positioned(
      top: 10,
      left: 5,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleBackButton,
        child: Container(
          width: 40,
          height: 40,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SvgPicture.asset(
              kaBackButton,
              fit: BoxFit.scaleDown,
              width: 10,
              height: 10,
            ),
          ),
        ),
      ),
    );
  }

  // Handle department dropdown selection
  void _handleDepartmentSelection(String? selectedName) {
    if (selectedName == null) return;
    final selectedDept = controller.departmentList.firstWhere(
          (dept) => dept.departmentName == selectedName,
      orElse: () => Department(id: '', departmentName: ''),
    );
    controller.selectedDepartment.value = selectedDept.id ?? '';
  }

  // Handle designation dropdown selection
  void _handleDesignationSelection(String? selectedName) {
    if (selectedName == null) return;
    final selectedRole = controller.designationList.firstWhere(
          (role) => role.designationName == selectedName,
      orElse: () => Designation(id: '', designationName: ''),
    );
    controller.selectedDesignation.value = selectedRole.id ?? '';
  }

  // Handle register button tap with validation
  void _handleRegisterTap() {
    if (_formKey.currentState!.validate()) {
      if (controller.validateRegisterForm(Get.context!)) {
        controller.register(Get.context!);
      }
    }
  }

  // Handle back button - clear controllers and navigate to login
  void _handleBackButton() {
    _clearAllControllers();
    Get.offAll(() => LoginPage());
  }

  // Clear all form controllers
  void _clearAllControllers() {
    controller.usernameController.clear();
    controller.emailController.clear();
    controller.phoneController.clear();
    controller.passwordController.clear();
    controller.confirmPasswordController.clear();
  }

  // Validate phone number - must be 10 digits
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone Number is required';
    }
    if (value.length < 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }
}