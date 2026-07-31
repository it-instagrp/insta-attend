import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/main_button.dart' as main;
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Utils/bottom_sheet_helper.dart';
import 'package:image_picker/image_picker.dart';

class PersonalDataPage extends StatelessWidget {
  PersonalDataPage({super.key});

  final AuthController controller = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _setInitialValues();
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F8),
      appBar: _buildAppBar(),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  // App bar with back button and title
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leadingWidth: 50,
      leading: InkWell(
        onTap: () => Get.back(),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SvgPicture.asset(
            kaBackButton,
            fit: BoxFit.scaleDown,
            width: 10,
            height: 10,
          ),
        ),
      ),
      centerTitle: true,
      title: const Text(
        "Personal Data",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
      ),
    );
  }

  // Main scrollable body content
  Widget _buildBody(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPageHeader(),
              const SizedBox(height: 20),
              _buildProfilePicture(context),
              const SizedBox(height: 20),
              _buildFormFields(),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom action button (Update/Loading)
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Obx(
            () => controller.isUpdateProfileLoading.value
            ? _buildLoadingIndicator()
            : main.MainButton(
          label: "Update",
          buttonType: (controller.isProfileFormValid.value &&
              controller.hasProfileChanges.value)
              ? main.ButtonType.normal
              : main.ButtonType.disabled,
          onTap: () => _handleUpdateTap(context),
        ),
      ),
    );
  }

  // Loading indicator widget (reused in multiple places)
  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        strokeCap: StrokeCap.round,
        color: kcPurple600,
      ),
    );
  }

  // Page title section
  Widget _buildPageHeader() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "My Personal Data",
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        "Details about my personal data",
        style: TextStyle(fontSize: 12, color: kcGrey500),
      ),
    );
  }

  // Profile picture section with upload button
  Widget _buildProfilePicture(BuildContext context) {
    return InkWell(
      onTap: () => _showImageSourcePicker(context),
      child: SizedBox(
        width: 150,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  _buildProfileImageContainer(),
                  const SizedBox(height: 8),
                  Text(
                    "Upload Photo",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kcGrey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Format should be in .jpeg .png atleast 800x800px and less than 5MB",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: kcGrey500,
                    ),
                  ),
                ],
              ),
            ),
            // Edit icon
            Positioned(
              top: -10,
              right: 15,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kcPurple500,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Profile image display (either from file or asset)
  Widget _buildProfileImageContainer() {
    return Obx(
          () => Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 2, color: Colors.white),
          color: kcPurple600,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: controller.pickedProfileImage.value != null
              ? Image.file(
            controller.pickedProfileImage.value!,
            fit: BoxFit.cover,
          )
              : Image.asset(kaProfile),
        ),
      ),
    );
  }

  // Form input fields (First Name, Last Name, Email, Phone)
  Widget _buildFormFields() {
    return Column(
      children: [
        _buildCustomTextField(
          title: "First Name",
          hintText: "Enter First Name",
          icon: kaPerson,
          controller: controller.firstNameController,
          validator: controller.validateName,
        ),
        const SizedBox(height: 10),
        _buildCustomTextField(
          title: "Last Name",
          hintText: "Enter Last Name",
          icon: kaPerson,
          controller: controller.lastNameController,
          validator: controller.validateName,
        ),
        const SizedBox(height: 10),
        _buildCustomTextField(
          title: "Email",
          hintText: "Enter Email",
          icon: kaEmail,
          controller: controller.emailController,
          validator: controller.validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        _buildCustomTextField(
          title: "Phone Number",
          hintText: "Enter Phone",
          icon: kaPhone,
          controller: controller.phoneController,
          validator: controller.validatePhone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // Reusable custom text field with validation and change tracking
  Widget _buildCustomTextField({
    required String title,
    required String hintText,
    required String icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return CustomTextField(
      title: title,
      hintText: hintText,
      icon: icon,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      onChanged: (_) => this.controller.checkProfileFromValidity(),
    );
  }

  // Handle update button tap with form validation
  void _handleUpdateTap(BuildContext context) {
    if (_formKey.currentState!.validate() &&
        controller.hasProfileChanges.value) {
      _showUpdateConfirmation(context);
    }
  }

  // Set initial form values from current user data
  void _setInitialValues() {
    final username = controller.currentUser.value.username ?? "";
    final nameParts = username.split(" ");

    controller.firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : "";
    controller.lastNameController.text =
    nameParts.length > 1 ? nameParts[1] : "";
    controller.emailController.text = controller.currentUser.value.email ?? "";
    controller.phoneController.text =
        controller.currentUser.value.phoneNumber ?? "";
    controller.snapshotOriginalProfileData();
  }

  // Bottom sheet confirmation dialog before updating profile
  void _showUpdateConfirmation(BuildContext context) {
    showCustomBottomSheet(
      context: context,
      title: "Update Profile",
      description:
      "Are you sure you want to update your profile? This will help us improve your experience and provide personalized features.",
      topIconAsset: kaUpdateTop,
      primaryButton: SizedBox(
        height: 45,
        width: MediaQuery.of(context).size.width,
        child: Obx(
              () => controller.isUpdateProfileLoading.value
              ? _buildLoadingIndicator()
              : main.MainButton(
            label: "Yes, Update Profile",
            onTap: () => controller.updateProfile(context),
          ),
        ),
      ),
    );
  }

  // Image source picker - Camera or Gallery
  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Upload Profile Photo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: kcPurple500),
              title: const Text("Take a photo"),
              onTap: () {
                Navigator.pop(context);
                controller.pickProfilePhoto(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: kcPurple500),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                controller.pickProfilePhoto(context, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}