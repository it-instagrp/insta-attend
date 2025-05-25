import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/main_button.dart' as main;
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:get/get.dart';

import '../../Component/Button/custom_button.dart';
import '../../Constant/constant_font.dart';

class PersonalDataPage extends StatelessWidget {
  PersonalDataPage({super.key});

  final AuthController controller = Get.find<AuthController>();

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
                  : main.MainButton(
                    label: "Update",
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
                onTap: () {},
                child: SizedBox(
                  width: 150,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Container(
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
                                child: Image.asset(kaProfile),
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
                              style: TextStyle(fontSize: 10, color: kcGrey500),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: 15,
                        child: Align(
                          alignment: Alignment.center,
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
                      ),
                    ],
                  ),
                ),
              ),
              /**** Details ****/
              CustomTextfield(
                title: "First Name",
                hintText: "Enter First Name",
                icon: kaPerson,
                controller: controller.firstNameController,
              ),
              SizedBox(height: 10.0),
              CustomTextfield(
                title: "Last Name",
                hintText: "Enter Last Name",
                icon: kaPerson,
                controller: controller.lastNameController,
              ),
              SizedBox(height: 10.0),
              CustomTextfield(
                title: "Email",
                hintText: "Enter Email",
                icon: kaEmail,
                controller: controller.emailController,
              ),
              SizedBox(height: 10.0),
              CustomTextfield(
                title: "Phone Number",
                hintText: "Enter Phone",
                icon: kaPhone,
                controller: controller.phoneController,
              ),
            ],
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
                    Text("Update Profile", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    SizedBox(
                      height: 15,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text("Are you sure you want to update your profile? This will help us improve your experience and provide personalized features.", style: kfBodyMedium.copyWith(color: kcGrey400),)),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        child: Obx(()=>controller.isLoading.value ? Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: kcPurple600,),) : main.MainButton(label: "Yes, Update Profile", onTap: ()=>controller.updateProfile(context)))),
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
                  child: SvgPicture.asset(kaUpdateTop))
            ],
          );
        });
  }
}
