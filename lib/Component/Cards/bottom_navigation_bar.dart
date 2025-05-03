import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';


class BottomNavigationBar extends StatefulWidget {
  final Function(int index) onSelectIndex;
  final BuildContext context;
  BottomNavigationBar({super.key, required this.onSelectIndex, required this.context});

  @override
  State<BottomNavigationBar> createState() => _BottomNavigationBarState();
}


class _BottomNavigationBarState extends State<BottomNavigationBar> {
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(context) {
    return Container(

    );
  }
}
