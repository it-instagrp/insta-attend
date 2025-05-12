import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Component/Cards/bottom_navigation_bar.dart';
import 'package:insta_attend/View/screens/attendance_screen.dart';
import 'package:insta_attend/View/screens/expense_screen.dart';
import 'package:insta_attend/View/screens/home.dart';
import 'package:insta_attend/View/screens/leave_screen.dart';
import 'package:insta_attend/View/screens/task_screen.dart';

class Homescreen extends StatelessWidget {
  Homescreen({super.key});

  RxInt selectedIndex = 0.obs;

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        bottomNavigationBar: CustomBottomNavigationBar(
          onSelectIndex: (index) {
            selectedIndex.value = index;
          },
          context: context,
        ),
        body: Container(
            color: Color(0xFFF1F3F8),
            child: Obx(()=>screens[selectedIndex.value])),
      ),
    );
  }
}

final List<Widget> screens = [
  Home(),
  AttendanceScreen(),
  TaskScreen(),
  ExpenseScreen(),
  LeaveScreen()
];
