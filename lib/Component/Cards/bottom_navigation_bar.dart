import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import '../../Constant/constant_asset.dart';
import '../../Controller/homescreen_controller.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int index) onSelectIndex;
  final BuildContext context;

  CustomBottomNavigationBar({super.key, required this.onSelectIndex, required this.context});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final HomescreenController controller = Get.find<HomescreenController>();
  final authController = Get.find<AuthController>();

  final List<String> icons = [
    kaHomeHollow,
    // kaAttendanceHollow,
    // kaTaskHollow,
    kaExpenseHollow,
    kaLeaveHollow
  ];

  final List<String> selectedIcons = [
    kaHomeFilled,
    // kaAttendanceFilled,
    // kaTaskFilled,
    kaExpenseFilled,
    kaLeaveFilled
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = authController.currentUser.value;
      final bool isCorporate = user.department?.departmentName == "Corporate Office";

      final List<int> visibleIndexes = [
        0,
        1,
        // if (isCorporate) 2,
        // if (isCorporate) 3,
        if (isCorporate) 2,
      ];

      final List<String> titles = [
        "Home",
        // "Attendance",
        // "Tasks",
        "Expense",
        "Leave"
      ];

      return Container(
        height: 80,
        padding: const EdgeInsets.only(bottom: 12),
        width: MediaQuery.of(context).size.width,
        color: const Color(0xFF1C2020),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: visibleIndexes.map((index) {
            final isSelected = controller.selectedIndex.value == index;
            return GestureDetector(
              onTap: () {
                controller.selectedIndex.value = index;
                widget.onSelectIndex(index);
              },
              child: BottomBarItem(
                index: index,
                iconPath: isSelected ? selectedIcons[index] : icons[index],
                isSelected: isSelected,
                onTap: () {
                  controller.selectedIndex.value = index;
                  widget.onSelectIndex(index);
                }, title: titles[index],
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class BottomBarItem extends StatelessWidget {
  final int index;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final String iconPath;

  const BottomBarItem({
    super.key,
    required this.index,
    required this.onTap,
    required this.isSelected,
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,        // ← shrink-wraps the column
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(iconPath, height: 25, width: 25),
        const SizedBox(height: 4),           // ← fixed gap instead of spaceBetween
        Container(
          height: 2,
          width: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        const SizedBox(height: 4),           // ← fixed gap instead of spaceBetween
        Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}