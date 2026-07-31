import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:insta_attend/Component/Cards/calendar_widget.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Model/attendance_filter_model.dart';
import 'package:insta_attend/Model/attendance_summary_model.dart';
import 'package:insta_attend/View/screens/attendance_details_page.dart';

class AttendanceOverviewPage extends StatefulWidget {
  const AttendanceOverviewPage({super.key});

  @override
  State<AttendanceOverviewPage> createState() => _AttendanceOverviewPageState();
}

class _AttendanceOverviewPageState extends State<AttendanceOverviewPage> {
  late AttendanceFilter currentFilter;
  List<Map<String, dynamic>> attendanceRecords = [];
  late AttendanceSummary summary;
  Map<String, String> attendanceStatusMap = {};

  final String currentUserName = "Rupesh Patil";

  DateTime customStartDate = DateTime.now().subtract(const Duration(days: 15));
  DateTime customEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    currentFilter = AttendanceFilter.thisMonth();
    _loadAttendanceData();
  }

  void _loadAttendanceData() {
    attendanceStatusMap = {};
    for (var record in attendanceRecords) {
      final dateString = DateFormat('yyyy-MM-dd').format(record['date']);
      attendanceStatusMap[dateString] = record['status'];
    }

    int presentCount = 0, halfCount = 0, absentCount = 0;
    for (var record in attendanceRecords) {
      switch (record['status'].toString().toLowerCase()) {
        case 'present':
          presentCount++;
          break;
        case 'half day':
          halfCount++;
          break;
        case 'absent':
          absentCount++;
          break;
      }
    }

    summary = AttendanceSummary(
      presentDays: presentCount,
      halfDays: halfCount,
      absentDays: absentCount,
      totalDays: currentFilter.daysInRange,
    );

    setState(() {});
  }

  void _applyFilter(AttendanceFilter filter) {
    setState(() {
      currentFilter = filter;
    });
    _loadAttendanceData();
  }

  void _exportToPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Generating PDF Report...'),
        backgroundColor: kcPurple500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight,
      color: const Color(0xFFF1F3F8),
      child: Stack(
        children: [
          // 1. Purple Header Background
          Container(
            height: 250,
            width: screenWidth,
            decoration: BoxDecoration(
              color: kcPurple500,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
          ),

          // 2. Header Title
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: _buildHeader(),
          ),

          // 3. Scrollable Content Area (Starts at top: 150 and scrolls completely down)
          Positioned(
            left: 0,
            right: 0,
            top: 150,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Filter Chips
                  _buildEqualFilterRow(),
                  const SizedBox(height: 12),

                  // Calendar View
                  AttendanceCalendar(
                    onDateSelected: (date) {},
                    attendanceStatusMap: attendanceStatusMap,
                    initialDate: DateTime.now(),
                  ),
                  const SizedBox(height: 12),

                  // Summary Statistics
                  _buildSummaryCard(),
                  const SizedBox(height: 12),

                  // Attendance Log Details
                  _buildAttendanceListCard(),
                  const SizedBox(height: 16),

                  // 4. Scrollable PDF Export Button (Only visible when scrolled down)
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
  Widget _buildHeader() {
    return ListTile(
      title: Text(
        "My Attendance",
        style: kfHeadlineSmall.copyWith(color: Colors.white),
      ),
      subtitle: Text(
        "Welcome back, $currentUserName",
        style: kfLabelLarge.copyWith(color: kcPurple200),
      ),
    );
  }

  // Improved Equal Filter Row with Fixed Container Height
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
              ? (currentFilter.startDate != null && currentFilter.endDate != null)
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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? kcPurple500 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
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

  // Summary Card
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 20),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: summary.attendancePercentage / 100,
                      strokeWidth: 9,
                      valueColor: AlwaysStoppedAnimation<Color>(kcPurple500),
                      backgroundColor: const Color(0xFFF1F3F8),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${summary.attendancePercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Present',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('Present', summary.presentDays, const Color(0xFF10B981)),
                    const SizedBox(height: 10),
                    _buildStatRow('Half Day', summary.halfDays, const Color(0xFFF59E0B)),
                    const SizedBox(height: 10),
                    _buildStatRow('Absent', summary.absentDays, const Color(0xFFEF4444)),
                    const SizedBox(height: 10),
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attendanceRecords.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = attendanceRecords[index];
              return _buildAttendanceCard(record);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceDetailsPage(attendanceData: record),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(record['date']),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('MMM').format(record['date']),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(record['status']),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('In: ${record['checkInTime']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(width: 12),
                      Text('Out: ${record['checkOutTime']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
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

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
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
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                          initialDate: tempStart,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() => tempStart = picked);
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
                          initialDate: tempEnd,
                          firstDate: tempStart,
                          lastDate: DateTime.now(),
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
}