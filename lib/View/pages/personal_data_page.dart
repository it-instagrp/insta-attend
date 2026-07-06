import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/main_button.dart' as main;
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Utils/bottom_sheet_helper.dart';

import '../../Component/Button/custom_button.dart';
import '../../Constant/constant_font.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PersonalDataPage extends StatelessWidget {
  PersonalDataPage({super.key});

  final AuthController controller = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    setInitialValues();
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
                  // button now reflects live validity + change state
                  : main.MainButton(
                    label: "Update",
                    buttonType:
                        (controller.isProfileFormValid.value &&
                                controller.hasProfileChanges.value)
                            ? main.ButtonType.normal
                            : main.ButtonType.disabled,
                    onTap: () {
                      if (_formKey.currentState!.validate() &&
                          controller.hasProfileChanges.value) {
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
          "Personal Data",
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
                ),
                /**** Profile Picture ****/
                InkWell(
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
                              Obx(
                                () => Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                    color: kcPurple600,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child:
                                        controller.pickedProfileImage.value !=
                                                null
                                            ? Image.file(
                                              controller
                                                  .pickedProfileImage
                                                  .value!,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.asset(kaProfile),
                                  ),
                                ),
                              ),
                              Text(
                                "Upload Photo",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kcGrey600,
                                ),
                              ),
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
                            child: Center(
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                /**** Details ****/
                CustomTextField(
                  title: "First Name",
                  hintText: "Enter First Name",
                  icon: kaPerson,
                  controller: controller.firstNameController,
                  validator: controller.validateName,
                  onChanged: (_) => controller.checkProfileFromValidity(),
                ),
                SizedBox(height: 10.0),
                CustomTextField(
                  title: "Last Name",
                  hintText: "Enter Last Name",
                  icon: kaPerson,
                  controller: controller.lastNameController,
                  validator: controller.validateName,
                  onChanged: (_) => controller.checkProfileFromValidity(),
                ),
                SizedBox(height: 10.0),
                CustomTextField(
                  title: "Email",
                  hintText: "Enter Email",
                  icon: kaEmail,
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  onChanged: (_) => controller.checkProfileFromValidity(),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10.0),
                CustomTextField(
                  title: "Phone Number",
                  hintText: "Enter Phone",
                  icon: kaPhone,
                  controller: controller.phoneController,
                  validator: controller.validatePhone,
                  onChanged: (_) => controller.checkProfileFromValidity(),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setInitialValues() {
    controller.firstNameController.text =
        controller.currentUser.value.username?.split(" ")[0] ?? "";
    controller.lastNameController.text =
        controller.currentUser.value.username?.split(" ")[1] ?? "";
    controller.emailController.text = controller.currentUser.value.email ?? "";
    controller.phoneController.text =
        controller.currentUser.value.phoneNumber ?? "";
    controller.snapshotOriginalProfileData();
  }

  void showUpdateConfirmation(BuildContext context) {
    showCustomBottomSheet(context: context, title: "Update Profile", description: "Are you sure you want to update your profile? This will help us improve your experience and provide personalized features.", topIconAsset: kaUpdateTop, primaryButton: SizedBox(
      height: 45,
      width: MediaQuery.of(context).size.width,
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
          label: "Yes, Update Profile",
          onTap: () => controller.updateProfile(context),
        ),
      ),
    ));
  }

  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text(
                  "Upload Profile Photo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.camera_alt_rounded, color: kcPurple500),
                  title: Text("Take a photo"),
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
                SizedBox(height: 10),
              ],
            ),
          ),
    );
  }
}
