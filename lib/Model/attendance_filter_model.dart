/// Model for managing attendance filters
class AttendanceFilter {
  DateTime startDate;
  DateTime endDate;
  String filterType; // "thisMonth", "last15Days", "last30Days", "custom"

  AttendanceFilter({
    required this.startDate,
    required this.endDate,
    required this.filterType,
  });

  /// Factory constructors for different filters
  factory AttendanceFilter.thisMonth() {
    final now = DateTime.now();
    return AttendanceFilter(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      filterType: 'thisMonth',
    );
  }

  factory AttendanceFilter.last15Days() {
    final now = DateTime.now();
    return AttendanceFilter(
      startDate: now.subtract(const Duration(days: 15)),
      endDate: now,
      filterType: 'last15Days',
    );
  }

  factory AttendanceFilter.last30Days() {
    final now = DateTime.now();
    return AttendanceFilter(
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now,
      filterType: 'last30Days',
    );
  }

  factory AttendanceFilter.custom({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return AttendanceFilter(
      startDate: startDate,
      endDate: endDate,
      filterType: 'custom',
    );
  }

  int get daysInRange => endDate.difference(startDate).inDays + 1;
}