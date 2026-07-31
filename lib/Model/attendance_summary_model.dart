/// Model for attendance summary statistics
class AttendanceSummary {
  final int presentDays;
  final int halfDays;
  final int absentDays;
  final int totalDays;

  AttendanceSummary({
    required this.presentDays,
    required this.halfDays,
    required this.absentDays,
    required this.totalDays,
  });

  /// Calculate attendance percentage
  double get attendancePercentage {
    if (totalDays == 0) return 0.0;
    return ((presentDays + (halfDays * 0.5)) / totalDays) * 100;
  }

  /// Get count of off/holiday days
  int get offDays => totalDays - presentDays - halfDays - absentDays;
}