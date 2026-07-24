import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Component/Cards/attendance_history_card.dart';
import 'package:insta_attend/Component/Cards/weekly_attendance.dart';
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

  final AttendanceController attendanceController = Get.find<AttendanceController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      attendanceController.getMyWeekAttendance();
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

        // ── Extracted: Total Working Hour + Check In/Out card ────────────────
        Obx(()=>attendanceController.isWeeklyAttendanceLoading.value ? CircularProgressIndicator(strokeCap: StrokeCap.round,) : attendanceController.weeklyAttendance.value.isNotEmpty ? WeeklyAttendance(attendance: attendanceController.weeklyAttendance) : SizedBox()),
      ],
    );
  }

  // ─── Profile section ────────────────────────────────────────────────────────
  Widget _buildProfileSection(BuildContext context) {
    return SizedBox(
      height: 80,
      width: MediaQuery.of(context).size.width,
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
                Obx(() => Text(
                  controller.currentUser.value.username ?? 'NA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                  kfTitleMedium.copyWith(fontWeight: FontWeight.w600),
                )),
                Obx(() => Text(
                  controller.currentUser.value.designation
                      ?.designationName ??
                      'User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kfTitleSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6E62FF),
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
          builder: (ctx) => InkWell(
            onTap: () => _showMessages(ctx),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: kcPurple100,
              child: SvgPicture.asset(kaTopMessage),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Builder(
          builder: (ctx) => InkWell(
            onTap: () => _showNotifications(ctx),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: kcPurple100,
              child: SvgPicture.asset(kaTopNotification),
            ),
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
        color: const Color(0xFF795FFC),
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
    showPopover(
      arrowHeight: 0,
      arrowWidth: 0,
      context: context,
      bodyBuilder: (_) => const SizedBox(
        height: 100,
        width: 200,
        child: Center(child: Text('No new notifications')),
      ),
    );
  }

  void _showMessages(BuildContext context) {
    showPopover(
      arrowHeight: 0,
      arrowWidth: 0,
      context: context,
      bodyBuilder: (_) => const SizedBox(
        height: 100,
        width: 200,
        child: Center(child: Text('No new messages')),
      ),
    );
  }
}