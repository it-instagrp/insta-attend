import 'package:flutter/material.dart';
import 'package:insta_attend/Controller/attendance_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Constant/constant_color.dart';
// import '../../Model/attendance_detail.dart';
import 'package:insta_attend/Model/Attendance.dart';

class AttendanceDetails extends StatefulWidget {
  const AttendanceDetails({super.key});

  @override
  State<AttendanceDetails> createState() => _AttendanceDetailsState();
}

class _AttendanceDetailsState extends State<AttendanceDetails> {
  final AttendanceController controller = Get.find<AttendanceController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // App bar with title
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Attendance Details"),
      centerTitle: true,
      elevation: 0,
    );
  }

  // Main body with loading and data states
  Widget _buildBody() {
    return Obx(() {
      if (controller.isSelectedDateLoading.value) {
        return const Center(
          child: CircularProgressIndicator(strokeCap: StrokeCap.round),
        );
      }

      final data = controller.selectedDateAttendance.value;

      if (data == null) {
        return const Center(child: Text("No attendance details found"));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(data),
            const SizedBox(height: 16),
            _buildEmployeeSection(data),
            const SizedBox(height: 16),
            _buildAttendanceSummarySection(data),
            const SizedBox(height: 16),
            _buildLocationSection(data),
          ],
        ),
      );
    });
  }

  // Header card with date and status
  Widget _buildHeaderCard(Attendance data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Text(
            _formatDate(data.date),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Chip(
            label: Text(
              data.status ?? "NA",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: kcPurple200.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  // Employee information section
  Widget _buildEmployeeSection(Attendance data)  {
    return _SectionCard(
      title: "Employee Information",
      children: [
        _buildInfoRow("Employee", data.employeeName),
        _buildInfoRow("Department", data.department),
      ],
    );
  }

  // Attendance summary section
  Widget _buildAttendanceSummarySection(Attendance data) {
    return _SectionCard(
      title: "Attendance Summary",
      children: [
        _buildInfoRow("Check In", _formatTime(data.checkInTime)),
        _buildInfoRow("Check Out", _formatTime(data.checkOutTime)),
        _buildInfoRow("Duration", data.duration),
        _buildInfoRow("Status", data.status),
      ],
    );
  }

  // Location information section
  Widget _buildLocationSection(Attendance data) {
    return _SectionCard(
      title: "Location Information",
      children: [
        _buildLocationTile("Check In Location", data.checkInLocation),
        const SizedBox(height: 12),
        _buildLocationTile("Check Out Location", data.checkOutLocation),
      ],
    );
  }

  // Reusable info row widget
  Widget _buildInfoRow(String label, String? value) {
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
              (value != null && value.isNotEmpty) ? value : "NA",
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable location tile widget
  Widget _buildLocationTile(String title, String? location) {
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
          Text((location != null && location.isNotEmpty) ? location : "NA"),
        ],
      ),
    );
  }

  // Reusable white card decoration
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }

  // Format time from ISO string or return raw string if already formatted
  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return "NA";

    try {
      return DateFormat('hh:mm a').format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value; // Return raw string if already formatted (e.g. "09:30 AM")
    }
  }

  // Format date from ISO string or return raw string if already formatted
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "NA";

    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (_) {
      return date; // Return raw date if parsing fails
    }
  }
}

// Section card wrapper for consistent styling
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