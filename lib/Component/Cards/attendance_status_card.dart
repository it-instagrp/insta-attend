import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Constant/constant_color.dart';
import '../../Controller/attendance_controller.dart';

/// A self-contained card that displays:
///  - Current attendance status (Checked In / Checked Out / etc.)
///  - Time of the last check-in or check-out
///  - Work-duration progress bar towards the daily 8-hour target
///
/// Usage:
///   AttendanceStatusCard()
class AttendanceStatusCard extends StatelessWidget {
  AttendanceStatusCard({super.key});

  final AttendanceController _controller = Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          ListTile(
            title: const Text(
              'Current Status',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Your status for attendance',
              style: TextStyle(fontSize: 12, color: Color(0xFF475467)),
            ),
          ),

          // ── Status + Time cards + Progress bar ───────────────────────────────
          _AttendanceStatusBody(controller: _controller),

          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

// ─── Body (status + time cards + progress bar) ────────────────────────────────

class _AttendanceStatusBody extends StatelessWidget {
  const _AttendanceStatusBody({required this.controller});

  final AttendanceController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Status + Time row ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusCard(controller: controller),
              _TimeCard(controller: controller),
            ],
          ),

          const SizedBox(height: 20.0),

          // ── Progress bar ───────────────────────────────────────────────────
          WorkDurationProgressBar(),
        ],
      ),
    );
  }
}

// ─── Status card ──────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.controller});

  final AttendanceController controller;
  static const double _cardWidth = 140;
  static const double _cardHeight = 88;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: kcGrey100,
          border: Border.all(color: kcGrey200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kcGrey500,
              ),
            ),
            const SizedBox(height: 5),
            Obx(
              () => Text(
                controller.attendanceStatus.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: kcGrey500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Time card ────────────────────────────────────────────────────────────────

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.controller});

  final AttendanceController controller;
  static const double _cardWidth = 140;
  static const double _cardHeight = 88;

  /// Parses an ISO-8601 UTC string and formats it as "h:mm a" in local time.
  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: kcGrey100,
          border: Border.all(color: kcGrey200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kcGrey500,
              ),
            ),
            const SizedBox(height: 5),
            Obx(() {
              final status = controller.attendanceStatus.value;
              String raw = '';
              if (status == 'Checked In') {
                raw = controller.checkInTime.value;
              } else if (status == 'Checked Out') {
                raw = controller.checkOutTime.value;
              }
              return Text(
                _formatTime(raw),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: kcGrey500,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Work duration progress bar ───────────────────────────────────────────────

/// Displays a colour-coded linear progress bar for today's work duration
/// against an 8-hour target.
///
/// Colour thresholds:
///   < 4 h → red
///   4–6 h → yellow
///   ≥ 6 h → green
class WorkDurationProgressBar extends StatelessWidget {
  WorkDurationProgressBar({super.key});

  final AttendanceController _controller = Get.find<AttendanceController>();
  static const double _targetHours = 8.0;

  Color _progressColor(int totalMinutes) {
    final targetMinutes = (_targetHours * 60).toInt();
    if (totalMinutes > targetMinutes) return kcPurple500;
    if (totalMinutes < 4 * 60) return Colors.red;
    if (totalMinutes < 6 * 60) return Colors.yellow;
    return Colors.green;
  }

  String _formatted(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalMinutes = _controller.todayWorkDuration.value.inMinutes;
      final progress = (totalMinutes / (_targetHours * 60)).clamp(0.0, 1.0);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Work",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  if (totalMinutes > (_targetHours * 60).toInt())
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kcPurple500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Overtime",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: kcPurple500,
                        ),
                      ),
                    ),
                  Text(
                    '${_formatted(totalMinutes)} / ${_targetHours.toStringAsFixed(0)}h',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: kcGrey200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _progressColor(totalMinutes),
            ),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    });
  }
}
