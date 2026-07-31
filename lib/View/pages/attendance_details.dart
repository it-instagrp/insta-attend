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
  Widget _buildHeaderCard(AttendanceDetail data) {
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
          Chip(label: Text(data.status ?? "NA")),
        ],
      ),
    );
  }

  // Employee information section
  Widget _buildEmployeeSection(AttendanceDetail data) {
    return _SectionCard(
      title: "Employee Information",
      children: [
        _buildInfoRow("Employee", data.employeeName),
        _buildInfoRow("Department", data.department),
        _buildInfoRow("Designation", data.designation),
        _buildInfoRow("Email", data.user?.email),
      ],
    );
  }

  // Attendance summary section
  Widget _buildAttendanceSummarySection(AttendanceDetail data) {
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
  Widget _buildLocationSection(AttendanceDetail data) {
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
              value ?? "NA",
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
          Text(location ?? "NA"),
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

  // Format time from ISO string to readable format
  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return "NA";

    try {
      return DateFormat('hh:mm a').format(DateTime.parse(value).toLocal());
    } catch (_) {
      return "NA";
    }
  }

  // Format date from ISO string to readable format
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "NA";

    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (_) {
      return "NA";
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