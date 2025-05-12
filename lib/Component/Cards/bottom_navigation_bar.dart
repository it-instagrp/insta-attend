import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:insta_attend/View/pages/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constant/constant_asset.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int index) onSelectIndex;
  final BuildContext context;

  CustomBottomNavigationBar({super.key, required this.onSelectIndex, required this.context});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  final Homescreen homescreen = Homescreen();

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
    return Container(
      height: 95,
      padding: EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width,
      color: const Color(0xFF1C2020),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                homescreen.selectedIndex.value = index;
              });
              widget.onSelectIndex(index);
            },
            child: BottomBarItem(
              index: index,
              iconPath: homescreen.selectedIndex.value == index ? selectedIcons[index] : icons[index],
              isSelected: homescreen.selectedIndex.value == index,
              onTap: () {
                setState(() {
                  homescreen.selectedIndex.value = index;
                });
                widget.onSelectIndex(index);
              },
            ),
          );
        }),
      ),
    );
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

