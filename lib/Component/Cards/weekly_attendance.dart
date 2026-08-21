import 'package:flutter/material.dart';
import 'package:insta_attend/Model/attendance_for_week.dart';
import 'package:insta_attend/View/pages/attendance_details.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../Constant/constant_color.dart';
import 'package:insta_attend/Controller/attendance_controller.dart';

class WeeklyAttendance extends StatelessWidget {
  final List<AttendanceForWeek> attendance;
  const WeeklyAttendance({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: attendance.length,
        itemBuilder: (context, index) {
          final AttendanceForWeek attendanceForWeek = attendance[index];
          return _TimeCard(attendance: attendanceForWeek);
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 15);
        },
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.attendance});

  final AttendanceForWeek attendance;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {"title": "Check In", "value": formatTime(attendance.checkInTime)},
      {"title": "Check Out", "value": formatTime(attendance.checkOutTime)},
      {"title": "Duration", "value": attendance.durationOfWork ?? "NA"},
      {"title": "Status", "value": attendance.attendanceStatus ?? "NA"},
    ];
    return InkWell(
      onTap: () {
        Get.find<AttendanceController>().fetchAttendanceForDate(attendance.date ?? "");
        Get.to(() => const AttendanceDetails());
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kcGrey50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /**** Card Title ****/
            Text(
              "Date: ${formatDate(attendance.date)}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 70,
              ),
              itemBuilder: (context, index) {
                return _valueCard(
                  items[index]["title"]!,
                  items[index]["value"]!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "NA";

    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (_) {
      return "NA";
    }
  }

  Widget _valueCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kcGrey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String formatTime(String? value) {
    if (value == null || value.isEmpty) return "NA";

    try {
      return DateFormat('hh:mm a').format(DateTime.parse(value).toLocal());
    } catch (_) {
      return "NA";
    }
  }
}
