import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Component/Cards/attendance_history_card.dart';
// ============================================================
// OLD HOME SCREEN WEEKLY ATTENDANCE FEATURE
// COMMENTED OUT - KEPT FOR ROLLBACK/REFERENCE
// ============================================================
// import 'package:insta_attend/Component/Cards/weekly_attendance.dart';
import 'package:insta_attend/Controller/attendance_controller.dart';
import 'package:popover/popover.dart';
import '../../Component/Cards/attendance_status_card.dart';
import '../../Component/Cards/total_working_hour_card.dart';
import '../../Constant/constant_asset.dart';
import '../../Constant/constant_color.dart';
import '../../Constant/constant_font.dart';
import '../../Controller/auth_controller.dart';
import '../../View/pages/profile_page.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthController controller = Get.find<AuthController>();

  final AttendanceController attendanceController = Get.find<
      AttendanceController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ============================================================
      // OLD HOME SCREEN WEEKLY ATTENDANCE FEATURE
      // COMMENTED OUT - KEPT FOR ROLLBACK/REFERENCE
      // ============================================================
      // attendanceController.getMyWeekAttendance();
      attendanceController.getMyAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildProfileSection(context),
        _buildWorkSummarySection(),
        const SizedBox(height: 15),

        // ── Extracted: Attendance Status card ────────────────────────────────
        AttendanceStatusCard(),

        const SizedBox(height: 15.0),

        // ── Extracted: Total Working Hour + Check In/Out card ────────────────
        TotalWorkingHourCard(),

        const SizedBox(height: 15.0),

        // ============================================================
        // OLD HOME SCREEN WEEKLY ATTENDANCE FEATURE
        // COMMENTED OUT - KEPT FOR ROLLBACK/REFERENCE
        // Moved to AttendanceOverviewPage (new Attendance Details & Summary Screen)
        // ============================================================
        // Obx(()=>attendanceController.isWeeklyAttendanceLoading.value ? CircularProgressIndicator(strokeCap: StrokeCap.round,) : attendanceController.weeklyAttendance.value.isNotEmpty ? WeeklyAttendance(attendance: attendanceController.weeklyAttendance) : SizedBox()),
      ],
    );
  }

  // ─── Profile section ────────────────────────────────────────────────────────
  Widget _buildProfileSection(BuildContext context) {
    return SizedBox(
      height: 80,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () =>
                Get.to(() => ProfilePage(), transition: Transition.fade),
            child: CircleAvatar(
              backgroundColor: kcPurple200,
              radius: 25,
              child: ClipOval(child: Image.asset(kaProfile)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() =>
                    Text(
                      controller.currentUser.value.username ?? 'NA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      kfTitleMedium.copyWith(fontWeight: FontWeight.w600),
                    )),
                Obx(() =>
                    Text(
                      controller.currentUser.value.designation
                          ?.designationName ??
                          'User',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kfTitleSmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kcPurple800,
                      ),
                    )),
              ],
            ),
          ),
          _buildTopIcons(context),
        ],
      ),
    );
  }

  Widget _buildTopIcons(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (ctx) =>
              Stack(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showMessages(ctx),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(kaTopMessage),
                    ),
                  ),
                ],
              ),
        ),
        const SizedBox(width: 12),
        Builder(
          builder: (ctx) =>
              Stack(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showNotifications(ctx),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(kaTopNotification),
                    ),
                  ),
                  // Unread indicator dot
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: kcPurple800,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  // ─── Welcome banner ─────────────────────────────────────────────────────────
  Widget _buildWorkSummarySection() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: kcPurple800,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: 0,
            bottom: 0,
            child: Image.asset(kaExploreCamera, width: 120, height: 85),
          ),
          const Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Please check your status and update',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Popovers ────────────────────────────────────────────────────────────────
  void _showNotifications(BuildContext context) {
    _showMinimalCenterDialog(
      context: context,
      title: 'Notifications',
      svgPath: kaTopNotification,
      message: 'No new notifications right now',
    );
  }

  void _showMessages(BuildContext context) {
    _showMinimalCenterDialog(
      context: context,
      title: 'Messages',
      svgPath: kaTopMessage,
      message: 'No new messages right now',
    );
  }

  void _showMinimalCenterDialog({
    required BuildContext context,
    required String title,
    required String svgPath,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: kcPurple100, // Matched with your app header style
                  child: SvgPicture.asset(
                    svgPath, // Dynamically loads kaTopNotification or kaTopMessage
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // Simple dismiss button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: kcBaseWhite,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}