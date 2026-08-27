class AttendanceSummaryDto {
  String? filter;
  String? startDate;
  String? endDate;
  int? presentCount;
  int? halfDayCount;
  int? absentCount;
  int? weeklyOffHolidayCount;

  AttendanceSummaryDto({
    this.filter,
    this.startDate,
    this.endDate,
    this.presentCount,
    this.halfDayCount,
    this.absentCount,
    this.weeklyOffHolidayCount,
  });

  factory AttendanceSummaryDto.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryDto(
      filter: json['filter'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      presentCount: (json['presentCount'] as num).toInt(),
      halfDayCount: (json['halfDayCount'] as num).toInt(),
      absentCount: (json['absentCount'] as num).toInt(),
      weeklyOffHolidayCount: (json['weeklyOffHolidayCount'] as num).toInt(),
    );
  }
}