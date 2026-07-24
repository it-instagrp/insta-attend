import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Constant/constant_color.dart';
import '../../Constant/constant_font.dart';
import '../../Controller/attendance_controller.dart';
import '../../Controller/auth_controller.dart';
import '../Button/main_button.dart';

/// A self-contained card that displays:
///  - "Total Working Hour" header + current pay-period label
///  - Today's duration & monthly duration time cards
///  - Check In / Check Out button
///
/// Usage:
///   TotalWorkingHourCard()
class TotalWorkingHourCard extends StatelessWidget {
  TotalWorkingHourCard({super.key});

  final AttendanceController _attendanceController =
  Get.find<AttendanceController>();
  final AuthController _authController = Get.find<AuthController>();

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Returns "Paid Period of 1 Jun 2025 - 30 Jun 2025"
  String _currentMonthPeriod() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    final fmt = DateFormat('d MMM yyyy');
    return 'Paid Period of ${fmt.format(start)} - ${fmt.format(end)}';
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Text('Total Working Hour', style: kfLabelLarge),
          Text(
            _currentMonthPeriod(),
            style: kfBodySmall.copyWith(color: kcGrey500),
          ),

          const SizedBox(height: 20),

          // ── Time cards row ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TimeCard(
                title: 'Today',
                time: _attendanceController.getTodayDuration(),
              ),
              _TimeCard(
                title: 'This Pay Period',
                time: _attendanceController.getMonthlyDuration(),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ── Check In / Check Out button ──────────────────────────────────────
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: double.maxFinite,
              child: Obx(() {
                if (_attendanceController.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: kcPurple600,
                      strokeCap: StrokeCap.round,
                    ),
                  );
                }
                return _attendanceController.isCheckIn.value
                    ? MainButton(
                  label: 'Check In',
                  onTap: () =>
                      _attendanceController.clockIn(context),
                  buttonSize: ButtonSize.xl,
                )
                    : MainButton(
                  label: 'Check Out',
                  onTap: () =>
                      _attendanceController.clockOut(context),
                  buttonSize: ButtonSize.xl,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private sub-widget ────────────────────────────────────────────────────────

/// Compact card showing a labelled duration value.
class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.title, required this.time});

  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: kcGrey50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Icon(Icons.watch_later_rounded, color: kcGrey300, size: 16),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kcGrey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Value
          Text(
            '$time Hrs',
            style: TextStyle(
              fontSize: 20,
              color: kcBaseBlack,
            ),
          ),
        ],
      ),
    );
  }
}