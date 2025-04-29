import 'package:flutter/material.dart';
import 'package:insta_attend/Component/Cards/expense_card.dart';
import 'package:insta_attend/Component/Cards/leave_card.dart';
import 'package:insta_attend/Component/Cards/status_bar.dart';
import 'package:insta_attend/Component/Cards/task_card.dart';
import 'package:insta_attend/Component/Cards/user_map_pin.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: TaskCard(),
      ),
    );
  }
}
