import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final Map<String, String>? attendanceStatusMap;
  final DateTime initialDate;

   AttendanceCalendar({
    super.key,
    required this.onDateSelected,
    this.attendanceStatusMap,
    DateTime? initialDate,
  }) : initialDate = initialDate ?? DateTime.now();

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  late DateTime currentMonth;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    selectedDate = widget.initialDate;
  }

  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  String? getStatusForDate(DateTime date) {
    if (widget.attendanceStatusMap == null) return null;
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return widget.attendanceStatusMap![dateString];
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'half day':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF7C3AED),
              ),
              Text(
                DateFormat('MMMM yyyy').format(currentMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right),
                color: const Color(0xFF7C3AED),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekday Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map((day) => SizedBox(
              width: 40,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: getFirstDayOfMonth(currentMonth) + getDaysInMonth(currentMonth),
            itemBuilder: (context, index) {
              if (index < getFirstDayOfMonth(currentMonth)) {
                return const SizedBox();
              }

              final dayNumber = index - getFirstDayOfMonth(currentMonth) + 1;
              final date = DateTime(currentMonth.year, currentMonth.month, dayNumber);
              final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(selectedDate);
              final status = getStatusForDate(date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                  widget.onDateSelected(date);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7C3AED) : Colors.grey.shade100,
                    border: Border.all(
                      color: status != null ? getStatusColor(status) : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}