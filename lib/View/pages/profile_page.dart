import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:insta_attend/View/pages/change_password_page.dart';
import 'package:insta_attend/View/pages/office_asset_page.dart';
import 'package:insta_attend/View/pages/personal_data_page.dart';
import 'package:insta_attend/View/pages/versioning_page.dart';
import '../../Component/Button/custom_button.dart';
import '../../Component/Button/main_button.dart' as main;
import '../../Constant/constant_asset.dart';
import '../../Constant/constant_color.dart';
import '../../Constant/constant_font.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcPurple500,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          "My Profile",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.80,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                /**** Profile Content ****/
                Positioned(
                  top: 100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /**** CONTACT ****/
                        Text(
                          "CONTACT",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kcGrey600,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          width: MediaQuery.of(context).size.width - 30.0,
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: kcGrey100,
                          ),
                          child: Column(
                            children: [
                              /**** Email ****/
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    kaEmailIcon,
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 10.0),
                                  Text(
                                    controller.currentUser.value.email!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: kcGrey500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              /**** Department ****/
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    kaLocationTick,
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 10.0),
                                  Text(
                                    controller.currentUser.value.department?.departmentName ?? "NA",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: kcGrey500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        /**** ACCOUNT ****/
                        Text(
                          "ACCOUNT",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kcGrey600,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          width: MediaQuery.of(context).size.width - 30.0,
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: kcGrey100,
                          ),
                          child: Column(
                            children: [
                              /**** Personal Data ****/
                              InkWell(
                                onTap: () {
                                  Get.to(()=>PersonalDataPage(), transition: Transition.fadeIn);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      kaPersonalData,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      "Personal Data",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: kcGrey500,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_rounded, size: 15, color: kcGrey500)
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              /**** Office Assets ****/
                              InkWell(
                                onTap: () {
                                  Get.to(()=>OfficeAssetPage(), transition: Transition.fadeIn);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      kaOfficeAsset,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      "Office Assets",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: kcGrey500,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_rounded, size: 15, color: kcGrey500)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        /**** SETTINGS ****/
                        Text(
                          "SETTINGS",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kcGrey600,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          width: MediaQuery.of(context).size.width - 30.0,
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: kcGrey100,
                          ),
                          child: Column(
                            children: [
                              /**** Change Password ****/
                              InkWell(
                                onTap: () {
                                  Get.to(()=>ChangePasswordPage(), transition: Transition.fadeIn);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      kaChangePasswordIcon,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      "Change Password",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: kcGrey500,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_rounded, size: 15, color: kcGrey500)
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              /**** Versioning ****/
                              InkWell(
                                onTap: () {
                                  Get.to(()=>VersioningPage(), transition: Transition.fadeIn);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      kaVersioning,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      "Versioning",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: kcGrey500,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_rounded, size: 15, color: kcGrey500)
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              /**** FAQ and Help ****/
                              InkWell(
                                onTap: () => {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      kaFaq,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      "FAQ and Help",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: kcGrey500,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_rounded, size: 15, color: kcGrey500)
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              /**** Logout ****/
                              InkWell(
                                onTap: () {
                                  showLogoutConfirmation(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      kaLogout,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: kcGrey500,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios_rounded, size: 15, color: kcGrey500)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /**** Profile Picture ****/
                Positioned(
                    top: -50,
                    left: 0,
                    right: 0,
                    child: Align(
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
                                color: Colors.white
                              ),
                              color: kcPurple600
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(kaProfile)),
                          ),
                          Text(controller.currentUser.value.username ?? "NA", style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black
                          ),),
                          Text(controller.currentUser.value.designation?.designationName ?? "NA", style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500, color: kcPurple500
                          ),),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showLogoutConfirmation(BuildContext context){
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
                    Text("Are you sure?", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    SizedBox(
                      height: 15,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text("If you logout you have to login again with your credentials, make sure you remember your login credentials", style: kfBodyMedium.copyWith(color: kcGrey400),)),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        child: Obx(()=>controller.isLoading.value ? Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: kcPurple600,),) : CustomButton(label: "Yes, Logout", onPressed: ()=>controller.logout(context), destructive: true,))),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        child: CustomButton(label: "No, Keep me here", onPressed: ()=>Navigator.pop(context), hierarchy: ButtonHierarchy.secondary, destructive: true,)),
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
                  child: SvgPicture.asset(kaLogoutTop))
            ],
          );
        });
  }

}
