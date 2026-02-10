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
    kaAttendanceHollow,
    kaTaskHollow,
    kaExpenseHollow,
    kaLeaveHollow
  ];

  final List<String> selectedIcons = [
    kaHomeFilled,
    kaAttendanceFilled,
    kaTaskFilled,
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
        if (isCorporate) 2,
        if (isCorporate) 3,
        4,
      ];

      return Container(
        height: 95,
        padding: const EdgeInsets.only(bottom: 20),
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
                },
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
  final VoidCallback onTap;
  final bool isSelected;
  final String iconPath;

  const BottomBarItem({
    super.key,
    required this.index,
    required this.onTap,
    required this.isSelected,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(iconPath, height: 25, width: 25),
          Container(
            height: 2,
            width: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isSelected ? Colors.white : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}