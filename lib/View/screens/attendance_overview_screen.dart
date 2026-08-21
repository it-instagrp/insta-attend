import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:insta_attend/Component/Cards/calendar_widget.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Controller/attendance_controller.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:insta_attend/Model/attendance_filter_model.dart';
import 'package:insta_attend/API/DTO/Response/attendance_details_dto.dart';
import 'package:insta_attend/Utils/notification_service.dart';

import '../pages/attendance_details.dart';


class AttendanceOverviewPage extends StatefulWidget {
  const AttendanceOverviewPage({super.key});

  @override
  State<AttendanceOverviewPage> createState() => _AttendanceOverviewPageState();
}

class _AttendanceOverviewPageState extends State<AttendanceOverviewPage> {
  final AttendanceController attendanceController = Get.find<AttendanceController>();
  final AuthController authController = Get.find<AuthController>();

  late AttendanceFilter currentFilter;

  DateTime customStartDate = DateTime.now().subtract(const Duration(days: 15));
  DateTime customEndDate = DateTime.now();

  DateTime get _calendarMinDate =>
      currentFilter.filterType == 'thisMonth' ? DateTime.now() : currentFilter.startDate;

  DateTime get _calendarMaxDate {
    if (currentFilter.filterType == 'thisMonth') return DateTime.now();
    return currentFilter.endDate.isAfter(DateTime.now()) ? DateTime.now() : currentFilter.endDate;
  }

  @override
  void initState() {
    super.initState();
    currentFilter = AttendanceFilter.thisMonth();
    _loadAttendanceData();
  }

  /// Maps AttendanceFilter's camelCase filterType to the API's snake_case filter param
  String _apiFilterFor(AttendanceFilter filter) {
    switch (filter.filterType) {
      case 'thisMonth':
        return 'this_month';
      case 'last15Days':
        return 'last_15_days';
      case 'last30Days':
        return 'last_30_days';
      case 'custom':
        return 'custom';
      default:
        return 'this_month';
    }
  }

  void _loadAttendanceData() {
    final bool isThisMonth = currentFilter.filterType == 'thisMonth';
    final bool isCustom = currentFilter.filterType == 'custom';

    // "This Month" is treated as "today only" — sent as a custom range of today→today
    // since the API has no dedicated "today" filter.
    final String apiFilter = isThisMonth ? 'custom' : _apiFilterFor(currentFilter);
    final DateTime? rangeStart = isThisMonth ? DateTime.now() : (isCustom ? currentFilter.startDate : null);
    final DateTime? rangeEnd = isThisMonth ? DateTime.now() : (isCustom ? currentFilter.endDate : null);

    attendanceController.fetchAttendanceSummary(
      filter: apiFilter,
      startDate: rangeStart,
      endDate: rangeEnd,
    );

    attendanceController.fetchAttendanceDetailsList(
      filter: apiFilter,
      startDate: rangeStart,
      endDate: rangeEnd,
    );
  }

  void _applyFilter(AttendanceFilter filter) {
    setState(() {
      currentFilter = filter;
    });
    _loadAttendanceData();
  }

  /// Generates the PDF document, writes bytes to file storage, and triggers the download notification.
  Future<void> _exportToPdf() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Generating PDF Report...'),
        backgroundColor: kcPurple500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    try {
      // 1. Target directory (Prefer Public Downloads for user access)
      Directory? directory = await getDownloadsDirectory();
      directory ??= await getApplicationDocumentsDirectory();

      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String fileName = 'Attendance_Report_$timestamp.pdf';
      final String filePath = '${directory.path}/$fileName';

      // 2. Build PDF Document
      final pdf = pw.Document();
      final List<AttendanceDetailsRecordDto> records = attendanceController.attendanceDetailRows;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Attendance Summary Report",
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Text("User: ${authController.currentUser.value.username ?? 'Employee'}"),
                pw.Text("Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}"),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: ['Date', 'Status', 'Check In', 'Check Out'],
                  data: records.map((r) => [
                    r.date ?? '--',
                    r.status ?? '--',
                    r.checkInTime ?? '--',
                    r.checkOutTime ?? '--',
                  ]).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            );
          },
        ),
      );

      // 3. Write generated bytes to the target file path
      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // 4. Trigger download completion notification with tap payload
      await NotificationService.showDownloadNotification(
        fileName: fileName,
        filePath: filePath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved to: $fileName'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final String currentUserName = authController.currentUser.value.username ?? 'NA';

    return Container(
      height: screenHeight,
      color: const Color(0xFFF1F3F8),
      child: Stack(
        children: [
          // 1. Purple Header Background
          Container(
            height: 230,
            width: screenWidth,
            decoration: BoxDecoration(
              color: kcPurple500,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
          ),

          // 2. Header Title
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: _buildHeader(currentUserName),
          ),

          // 3. Scrollable Content Area
          Positioned(
            left: 0,
            right: 0,
            top: 140,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Filter Chips
                  _buildEqualFilterRow(),
                  const SizedBox(height: 12),

                  // Calendar View (Allows tapping a calendar date to open details)
                  // Obx(() => AttendanceCalendar(
                  //   onDateSelected: (selectedDate) {
                  //     final String formattedSelected = DateFormat('yyyy-MM-dd').format(selectedDate);
                  //     final record = attendanceController.attendanceDetailRows.firstWhereOrNull(
                  //           (r) => r.date != null && r.date!.startsWith(formattedSelected),
                  //     );
                  //
                  //     if (record != null && record.date != null && record.date!.isNotEmpty) {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => AttendanceDetails(attendanceId: record.date!),
                  //         ),
                  //       );
                  //     }
                  //   },
                  //   attendanceStatusMap: Map<String, String>.from(
                  //     attendanceController.attendanceStatusMap,
                  //   ),
                  //   initialDate: DateTime.now(),
                  // )),
                  Obx(() => AttendanceCalendar(
                    minDate: _calendarMinDate,
                    maxDate: _calendarMaxDate,
                    initialDate: _calendarMinDate,
                    onDateSelected: (selectedDate) {
                      // Intentionally no-op: tapping a calendar date no longer
                      // navigates or shows details.
                    },
                    attendanceStatusMap: Map<String, String>.from(
                      attendanceController.attendanceStatusMap,
                    ),
                  )),
                  const SizedBox(height: 12),

                  // Summary Statistics
                  Obx(() {
                    if (attendanceController.isSummaryLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (attendanceController.attendanceSummary.value != null) {
                      return _buildSummaryCard();
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 12),

                  // Attendance Log Details
                  Obx(() {
                    if (attendanceController.isDetailsListLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _buildAttendanceListCard();
                  }),
                  const SizedBox(height: 16),

                  // 4. PDF Export Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _exportToPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
                      label: const Text(
                        'Export as PDF',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPurple500,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header ListTile
  Widget _buildHeader(String currentUserName) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        "My Attendance",
        style: kfHeadlineSmall.copyWith(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "Welcome back, $currentUserName",
        style: kfLabelLarge.copyWith(color: kcPurple200),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Safe Responsive Filter Row
  Widget _buildEqualFilterRow() {
    final List<Map<String, dynamic>> filterOptions = [
      {'label': 'This Month', 'filter': AttendanceFilter.thisMonth()},
      {'label': 'Last 15 Days', 'filter': AttendanceFilter.last15Days()},
      {'label': 'Last 30 Days', 'filter': AttendanceFilter.last30Days()},
      {'label': 'Custom', 'filter': null},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
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
      child: Row(
        children: filterOptions.map((opt) {
          final String label = opt['label'];
          final AttendanceFilter? filter = opt['filter'];
          final bool isCustom = label == 'Custom';

          final bool isSelected = isCustom
              ? (currentFilter.filterType == 'custom')
              : (filter != null && currentFilter.filterType == filter.filterType);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (isCustom) {
                    _showCustomDateRangePicker();
                  } else if (filter != null) {
                    _applyFilter(filter);
                  }
                },
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? kcPurple500 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Attendance Summary Card
  Widget _buildSummaryCard() {
    final summary = attendanceController.attendanceSummary.value!;
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
          const Text(
            'Attendance Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: (summary.attendancePercentage / 100).clamp(0.0, 1.0),
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(kcPurple500),
                      backgroundColor: const Color(0xFFF1F3F8),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${summary.attendancePercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Present',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('Present', summary.presentDays, const Color(0xFF10B981)),
                    const SizedBox(height: 8),
                    _buildStatRow('Half Day', summary.halfDays, const Color(0xFFF59E0B)),
                    const SizedBox(height: 8),
                    _buildStatRow('Absent', summary.absentDays, const Color(0xFFEF4444)),
                    const SizedBox(height: 8),
                    _buildStatRow('Off / Holiday', summary.offDays, Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Attendance Details List Card
  Widget _buildAttendanceListCard() {
    final List<AttendanceDetailsRecordDto> records = attendanceController.attendanceDetailRows;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Attendance Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          records.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No attendance records found',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildAttendanceCard(records[index]);
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildAttendanceCard(AttendanceDetailsRecordDto record) {
  //   final DateTime? parsedDate = record.date != null ? DateTime.tryParse(record.date!) : null;
  //
  //   return InkWell(
  //     onTap: () {
  //       if (record.date != null && record.date!.isNotEmpty) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => AttendanceDetails(attendanceId: record.date!),
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Attendance date missing for this record')),
  //         );
  //       }
  //     },
  Widget _buildAttendanceCard(AttendanceDetailsRecordDto record) {
    final DateTime? parsedDate = record.date != null ? DateTime.tryParse(record.date!) : null;

    return InkWell(
      onTap: () {
        if (record.date != null && record.date!.isNotEmpty) {
          // // Convert ISO date string to clean yyyy-MM-dd format
          // final String cleanDateId = parsedDate != null
          //     ? DateFormat('yyyy-MM-dd').format(parsedDate)
          //     : record.date!;
          //
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AttendanceDetails(attendanceId: cleanDateId),
          //   ),
          // );
          // _showAttendanceRowDetails(record);
          attendanceController.fetchAttendanceForDate(record.date!);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AttendanceDetails()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance date missing for this record')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    parsedDate != null ? DateFormat('dd').format(parsedDate) : '--',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    parsedDate != null ? DateFormat('MMM').format(parsedDate) : '--',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(record.status ?? 'NA'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'In: ${record.checkInTime ?? 'NA'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Out: ${record.checkOutTime ?? 'NA'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toString().toLowerCase()) {
      case 'present':
        color = const Color(0xFF10B981);
        break;
      case 'half day':
        color = const Color(0xFFF59E0B);
        break;
      case 'absent':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  void _showCustomDateRangePicker() {
    DateTime tempStart = customStartDate;
    DateTime tempEnd = customEndDate;
    final DateTime now = DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 8,
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kcPurple200.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.date_range_rounded, color: kcPurple600, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Custom Date Range",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Select period for logs",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _buildModalDateTile(
                      label: "From Date",
                      date: tempStart,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempStart.isAfter(now) ? now : tempStart,
                          firstDate: DateTime(2020),
                          lastDate: now,
                        );
                        if (picked != null) {
                          setModalState(() {
                            tempStart = picked;
                            if (tempEnd.isBefore(tempStart)) {
                              tempEnd = tempStart;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildModalDateTile(
                      label: "To Date",
                      date: tempEnd,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempEnd.isBefore(tempStart) ? tempStart : tempEnd,
                          firstDate: tempStart,
                          lastDate: now,
                        );
                        if (picked != null) {
                          setModalState(() => tempEnd = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                customStartDate = tempStart;
                                customEndDate = tempEnd;
                              });
                              _applyFilter(AttendanceFilter.custom(
                                startDate: tempStart,
                                endDate: tempEnd,
                              ));
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kcPurple500,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Apply Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildModalDateTile({required String label, required DateTime date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Icon(Icons.calendar_month_rounded, color: kcPurple600, size: 20),
          ],
        ),
      ),
    );
  }
  void _showAttendanceRowDetails(AttendanceDetailsRecordDto record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          record.date != null
              ? DateFormat('dd MMM yyyy').format(DateTime.parse(record.date!))
              : 'Attendance Details',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${record.status ?? 'NA'}'),
            const SizedBox(height: 8),
            Text('Check In: ${record.checkInTime ?? 'NA'}'),
            const SizedBox(height: 8),
            Text('Check Out: ${record.checkOutTime ?? 'NA'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}