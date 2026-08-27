import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Component/Cards/bottom_navigation_bar.dart';
import 'package:insta_attend/Controller/homescreen_controller.dart';
import 'package:insta_attend/Utils/exit_confirmation_scope.dart';
import 'package:insta_attend/View/screens/expense_screen.dart';
import 'package:insta_attend/View/screens/home.dart';
import 'package:insta_attend/View/screens/leave_screen.dart';
import 'package:insta_attend/View/screens/attendance_overview_screen.dart';

class Homescreen extends StatelessWidget {
  Homescreen({super.key});

  final HomescreenController controller = Get.find<HomescreenController>();

  @override
  Widget build(BuildContext context) {
    return ExitConfirmationScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.white,
          bottomNavigationBar: CustomBottomNavigationBar(
            onSelectIndex: (index) {
              controller.selectedIndex.value = index;
            },
            context: context,
          ),
          body: Container(
            color: const Color(0xFFF1F3F8),
            child: Obx(() => screens[controller.selectedIndex.value]),
          ),
        ),
      ),
    );
  }
}

// Ensure this order matches the Bottom Navigation Bar items EXACTLY
final List<Widget> screens = [
  Home(),                          // Index 0: Home
  const AttendanceOverviewPage(),  // Index 1: Attendance Details
  ExpenseScreen(),                 // Index 2: Expense
  LeaveScreen(),                   // Index 3: Leave
];
