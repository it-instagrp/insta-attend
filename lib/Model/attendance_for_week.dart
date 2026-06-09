class AttendanceForWeek {
  String? id;
  String? date;
  String? checkInTime;
  String? checkOutTime;
  String? durationOfWork;
  String? attendanceStatus;

  AttendanceForWeek(
      {this.id,
        this.date,
        this.checkInTime,
        this.checkOutTime,
        this.durationOfWork,
        this.attendanceStatus});

  AttendanceForWeek.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    checkInTime = json['checkInTime'];
    checkOutTime = json['checkOutTime'];
    durationOfWork = json['durationOfWork'];
    attendanceStatus = json['attendanceStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['checkInTime'] = this.checkInTime;
    data['checkOutTime'] = this.checkOutTime;
    data['durationOfWork'] = this.durationOfWork;
    data['attendanceStatus'] = this.attendanceStatus;
    return data;
  }
}
