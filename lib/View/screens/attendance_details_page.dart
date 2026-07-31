import 'package:flutter/material.dart';
import 'package:insta_attend/Component/Button/main_button.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:intl/intl.dart';

class AttendanceDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? attendanceData;

  const AttendanceDetailsPage({
    super.key,
    this.attendanceData,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic or fallback values
    final DateTime date = attendanceData?['date'] ?? DateTime(2026, 6, 25);
    final String status = attendanceData?['status'] ?? 'Present';
    final String checkInTime = attendanceData?['checkInTime'] ?? '09:05 AM';
    final String checkOutTime = attendanceData?['checkOutTime'] ?? '06:12 PM';
    final String duration = attendanceData?['duration'] ?? '09h 07m';
    final String breakDuration = attendanceData?['breakDuration'] ?? '01h 00m';
    final String location = attendanceData?['location'] ?? 'Pune Office';
    final String remarks = attendanceData?['remarks'] ?? 'On Time';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F8),
      body: Stack(
        children: [
          // Purple Background Header Block
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: kcPurple500,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
          ),

          // Header Text & Back Navigation Button
          Positioned(
            top: 60,
            left: 8,
            right: 16,
            child: _buildHeader(context),
          ),

          // Scrollable Content Cards
          Positioned.fill(
            top: 130,
            bottom: 80,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // 1. Date & Status Overview Card
                  _buildHeaderCard(date, status),
                  const SizedBox(height: 12),

                  // 2. Clock In/Out Section Card
                  _buildClockCard(checkInTime, checkOutTime),
                  const SizedBox(height: 12),

                  // 3. Working Hours Card
                  _buildHoursCard(duration, breakDuration),
                  const SizedBox(height: 12),

                  // 4. Location Card
                  _buildLocationCard(location),
                  const SizedBox(height: 12),

                  // 5. Remarks Card
                  _buildRemarksCard(remarks),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Fixed Action Button Container
          _buildBottomCloseButton(context),
        ],
      ),
    );
  }

  // Header Bar Navigation & Titles
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Attendance Details",
              style: kfHeadlineSmall.copyWith(color: Colors.white),
            ),
            Text(
              "Daily Log Summary",
              style: kfLabelLarge.copyWith(color: kcPurple200),
            ),
          ],
        ),
      ],
    );
  }

  // Header Status Card
  Widget _buildHeaderCard(DateTime date, String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('dd MMMM yyyy').format(date),
            style: kfHeadlineSmall.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE').format(date),
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          _buildStatusBadge(status),
        ],
      ),
    );
  }

  // Clock In & Clock Out Card
  Widget _buildClockCard(String checkIn, String checkOut) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Clock In & Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimeCard('Check In', checkIn, Icons.login, kcPurple600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeCard('Check Out', checkOut, Icons.logout, const Color(0xFFDC2626)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hours Card
  Widget _buildHoursCard(String duration, String breakDuration) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Working Hours', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          _buildInfoRow('Total Working Hours', duration, Icons.schedule),
          const SizedBox(height: 14),
          _buildInfoRow('Break Duration', breakDuration, Icons.coffee),
        ],
      ),
    );
  }

  // Location Card
  Widget _buildLocationCard(String location) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          Row(
            children: [
              Icon(Icons.location_on, color: kcPurple600, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check In Location', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(location, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Remarks Card
  Widget _buildRemarksCard(String remarks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Remarks', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(remarks, style: const TextStyle(fontSize: 14, color: Colors.black45)),
          ),
        ],
      ),
    );
  }

  // Bottom Fixed Docked Close Button
  Widget _buildBottomCloseButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 75,
        padding: const EdgeInsets.all(12.0),
        color: Colors.white,
        child: MainButton(
          label: "Close",
          onTap: () => Navigator.pop(context),
          buttonSize: ButtonSize.sm,
        ),
      ),
    );
  }

  // Status Badge Component
  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'present':
        color = const Color(0xFF10B981);
        icon = Icons.check_circle;
        break;
      case 'half day':
        color = const Color(0xFFF59E0B);
        icon = Icons.schedule;
        break;
      case 'absent':
        color = const Color(0xFFEF4444);
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  // Time Tile Sub-component
  Widget _buildTimeCard(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Text(time, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Info Row Sub-component
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: kcPurple600, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}