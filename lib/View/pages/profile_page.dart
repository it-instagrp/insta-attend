import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:insta_attend/View/pages/change_password_page.dart';
import 'package:insta_attend/View/pages/office_asset_page.dart';
import 'package:insta_attend/View/pages/personal_data_page.dart';
import 'package:insta_attend/View/pages/versioning_page.dart';
import '../../Component/Button/custom_button.dart';
import '../../Constant/constant_asset.dart';
import '../../Constant/constant_color.dart';
import '../../Utils/bottom_sheet_helper.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcPurple500,
      appBar: _buildAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.80,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main scrollable content
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContactSection(context),
                        const SizedBox(height: 20),
                        _buildAccountSection(context),
                        const SizedBox(height: 20),
                        _buildSettingsSection(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Profile header (image, name, designation)
                _buildProfileHeader(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Contact section with email and department
  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("CONTACT"),
        const SizedBox(height: 10),
        _buildSectionContainer(
          context,
          Column(
            children: [
              _buildInfoRow(
                icon: kaEmailIcon,
                text: controller.currentUser.value.email ?? "NA",
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                icon: kaLocationTick,
                text: controller.currentUser.value.department?.departmentName ??
                    "NA",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Account section with menu items (Personal Data, Face ID, Office Assets)
  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("ACCOUNT"),
        const SizedBox(height: 10),
        _buildSectionContainer(
          context,
          Column(
            children: [
              _buildMenuRow(
                icon: kaPersonalData,
                label: "Personal Data",
                onTap: () => Get.to(
                      () => PersonalDataPage(),
                  transition: Transition.fade,
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuRow(
                label: "Register Face ID",
                customIcon: Icons.face_5_outlined,
                customIconColor: kcPurple500,
                onTap: () => controller.enrollUserFace(Get.context!),
              ),
              const SizedBox(height: 20),
              _buildMenuRow(
                icon: kaOfficeAsset,
                label: "Office Assets",
                onTap: () => Get.to(
                      () => OfficeAssetPage(),
                  transition: Transition.fade,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Settings section with Change Password, Versioning, FAQ, and Logout
  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("SETTINGS"),
        const SizedBox(height: 10),
        _buildSectionContainer(
          context,
          Column(
            children: [
              _buildMenuRow(
                icon: kaChangePasswordIcon,
                label: "Change Password",
                onTap: () => Get.to(
                      () => ChangePasswordPage(),
                  transition: Transition.fade,
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuRow(
                icon: kaVersioning,
                label: "Versioning",
                onTap: () => Get.to(
                      () => VersioningPage(),
                  transition: Transition.fade,
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuRow(
                icon: kaFaq,
                label: "FAQ and Help",
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _buildMenuRow(
                icon: kaLogout,
                label: "Logout",
                onTap: () => _showLogoutConfirmation(Get.context!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: Section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kcGrey600,
      ),
    );
  }

  // Helper: Styled container for sections
  Widget _buildSectionContainer(BuildContext context, Widget child) {
    return Container(
      width: MediaQuery.of(context).size.width - 30,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: kcGrey100,
      ),
      child: child,
    );
  }

  // Helper: Info row (email, department)
  Widget _buildInfoRow({required String icon, required String text}) {
    return Row(
      children: [
        SvgPicture.asset(icon, width: 20, height: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kcGrey500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper: Menu row (clickable items with arrow)
  // icon: SVG asset path (optional)
  // customIcon: Material icon (used if icon is null)
  // customIconColor: Color for material icon
  Widget _buildMenuRow({
    String? icon,
    required String label,
    required VoidCallback onTap,
    IconData? customIcon,
    Color? customIconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          // Icon - either SVG or Material icon
          if (icon != null)
            SvgPicture.asset(icon, width: 20, height: 20)
          else if (customIcon != null)
            Icon(
              customIcon,
              size: 20,
              color: customIconColor ?? kcGrey500,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kcGrey500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: kcGrey500,
          ),
        ],
      ),
    );
  }

  // Profile header with image, name, and designation
  Widget _buildProfileHeader() {
    return Positioned(
      top: -50,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            // Profile image
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 2, color: Colors.white),
                color: kcPurple600,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(kaProfile),
              ),
            ),
            const SizedBox(height: 8),
            // Username
            Text(
              controller.currentUser.value.username ?? "NA",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            // Designation
            Text(
              controller.currentUser.value.designation?.designationName ?? "NA",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kcPurple500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // App bar with back button
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
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
        "My Profile",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // Logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showCustomBottomSheet(
      context: context,
      title: "Are you sure?",
      description:
      "If you logout you have to login again with your credentials, make sure you remember your login credentials",
      topIconAsset: kaLogoutTop,
      primaryButton: Obx(
            () => controller.isLoading.value
            ? Center(
          child: CircularProgressIndicator(
            strokeCap: StrokeCap.round,
            color: kcPurple600,
          ),
        )
            : CustomButton(
          label: "Yes, Logout",
          onPressed: () => controller.logout(context),
          destructive: true,
        ),
      ),
      secondaryButtonLabel: "No, Keep me here",
      isSecondaryDestructive: true,
    );
  }
}