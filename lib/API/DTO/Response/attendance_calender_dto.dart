class AttendanceCalendarDto {
  String? filter;
  String? startDate;
  String? endDate;
  List<AttendanceCalendarRecordDto>? records;

  AttendanceCalendarDto({
    this.filter,
    this.startDate,
    this.endDate,
    this.records,
  });

  factory AttendanceCalendarDto.fromJson(Map<String, dynamic> json) {
    return AttendanceCalendarDto(
      filter: json['filter'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      records: json['records'] != null
          ? List<AttendanceCalendarRecordDto>.from(
        (json['records'] as List).map(
              (row) => AttendanceCalendarRecordDto.fromJson(row),
        ),
      )
          : [],
    );
  }
}

class AttendanceCalendarRecordDto {
  String? date;
  String? status;

  AttendanceCalendarRecordDto({this.date, this.status});

  factory AttendanceCalendarRecordDto.fromJson(Map<String, dynamic> json) {
    return AttendanceCalendarRecordDto(
      date: json['date'],
      status: json['status'],
    );
  }
}