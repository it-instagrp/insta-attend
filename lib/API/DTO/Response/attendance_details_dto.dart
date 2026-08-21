class AttendanceDetailsDto {
  String? filter;
  String? startDate;
  String? endDate;
  List<AttendanceDetailsRecordDto>? records;

  AttendanceDetailsDto({
    this.filter,
    this.startDate,
    this.endDate,
    this.records,
  });

  factory AttendanceDetailsDto.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailsDto(
      filter: json['filter'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      records: json['records'] != null
          ? List<AttendanceDetailsRecordDto>.from(
        (json['records'] as List).map(
              (row) => AttendanceDetailsRecordDto.fromJson(row),
        ),
      )
          : [],
    );
  }
}

class AttendanceDetailsRecordDto {
  String? date;
  String? status;
  String? checkInTime;
  String? checkOutTime;

  AttendanceDetailsRecordDto({
    this.date,
    this.status,
    this.checkInTime,
    this.checkOutTime,
  });

  factory AttendanceDetailsRecordDto.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailsRecordDto(
      date: json['date'],
      status: json['status'],
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
    );
  }
}