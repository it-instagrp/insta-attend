import 'package:flutter/material.dart';
import 'package:insta_attend/Controller/attendance_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Constant/constant_color.dart';
import '../../Model/attendance_detail.dart';

class AttendanceDetails extends StatefulWidget {
  final String attendanceId;

  const AttendanceDetails({super.key, required this.attendanceId});

  @override
  State<AttendanceDetails> createState() => _AttendanceDetailsState();
}

class _AttendanceDetailsState extends State<AttendanceDetails> {
  final AttendanceController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.getAttendanceDetails(widget.attendanceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("Attendance Details"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isAttendanceDetailsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(strokeCap: StrokeCap.round),
          );
        }

        final data = controller.attendanceDetails.value;

        if (data == null) {
          return const Center(child: Text("No attendance details found"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _HeaderCard(data),

              const SizedBox(height: 16),

              _SectionCard(
                title: "Employee Information",
                children: [
                  _InfoRow("Employee", data.employeeName),
                  _InfoRow("Department", data.department),
                  _InfoRow("Designation", data.designation),
                  _InfoRow("Email", data.user?.email),
                ],
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: "Attendance Summary",
                children: [
                  _InfoRow("Check In", formatTime(data.checkInTime)),
                  _InfoRow("Check Out", formatTime(data.checkOutTime)),
                  _InfoRow("Duration", data.duration),
                  _InfoRow("Status", data.status),
                ],
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: "Location Information",
                children: [
                  _LocationTile("Check In Location", data.checkInLocation),

                  const SizedBox(height: 12),

                  _LocationTile("Check Out Location", data.checkOutLocation),
                ],
              ),
            ],
          ),
        );
      }),
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

class _HeaderCard extends StatelessWidget {
  final AttendanceDetail data;

  const _HeaderCard(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            formatDate(data.date),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Chip(label: Text(data.status ?? "NA")),
        ],
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
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const Divider(height: 24),

          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),

          Expanded(
            flex: 6,
            child: Text(
              value ?? "NA",
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final String title;
  final String? location;

  const _LocationTile(this.title, this.location);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: kcGrey50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 6),

          Text(location ?? "NA"),
        ],
      ),
    );
  }
}
