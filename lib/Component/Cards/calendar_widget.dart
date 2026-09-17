import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final Map<String, String>? attendanceStatusMap;
  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;

  AttendanceCalendar({
    super.key,
    required this.onDateSelected,
    required this.minDate,
    required this.maxDate,
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
    //CHANGE 1: Ensure dates are at midnight to avoid timezone issues
    selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
    currentMonth = DateTime(selectedDate.year, selectedDate.month, 1);
  }

  @override
  void didUpdateWidget(covariant AttendanceCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      setState(() {
        //CHANGE 2: Ensure dates are at midnight
        selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
        currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
      });
    }
  }

  //CHANGE 3: Ensure date comparison without time component
  DateTime get _minDateOnly => DateTime(widget.minDate.year, widget.minDate.month, widget.minDate.day);
  DateTime get _maxDateOnly => DateTime(widget.maxDate.year, widget.maxDate.month, widget.maxDate.day);

  bool get _isPrevMonthDisabled {
    final DateTime prevMonthEnd =
    DateTime(currentMonth.year, currentMonth.month, 1).subtract(const Duration(days: 1));
    return prevMonthEnd.isBefore(_minDateOnly);
  }

  bool get _isNextMonthDisabled {
    final DateTime nextMonthStart = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    return nextMonthStart.isAfter(_maxDateOnly);
  }

  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  //Weekday calculation (your current implementation is correct!)
  int getFirstDayOfMonth(DateTime date) {
    return (DateTime(date.year, date.month, 1).weekday - 1) % 7;
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

  //Helper function for efficient date comparison
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
                onPressed: _isPrevMonthDisabled
                    ? null
                    : () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left),
                color: _isPrevMonthDisabled ? Colors.grey.shade300 : const Color(0xFF7C3AED),
              ),
              Text(
                DateFormat('MMMM yyyy').format(currentMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _isNextMonthDisabled
                    ? null
                    : () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right),
                color: _isNextMonthDisabled ? Colors.grey.shade300 : const Color(0xFF7C3AED),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekday Headers - Indian format (Monday first)
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

              // ✅ CHANGE 6: Use efficient _isSameDay() instead of DateFormat comparison
              final isSelected = _isSameDay(date, selectedDate);

              final status = getStatusForDate(date);
              final bool isOutOfRange = date.isBefore(_minDateOnly) || date.isAfter(_maxDateOnly);

              return GestureDetector(
                onTap: isOutOfRange
                    ? null
                    : () {
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
                        color: isOutOfRange
                            ? Colors.grey.shade400
                            : (isSelected ? Colors.white : Colors.black),
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