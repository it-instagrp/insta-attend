class AttendanceDetails {
  String? id;
  String? employeeId;
  String? employeeName;
  String? department;
  String? designation;
  String? date;
  String? checkInTime;
  String? checkInLocation;
  String? checkOutTime;
  String? checkOutLocation;
  String? status;
  String? duration;
  String? createdAt;
  String? updatedAt;
  User? user;

  AttendanceDetails(
      {this.id,
        this.employeeId,
        this.employeeName,
        this.department,
        this.designation,
        this.date,
        this.checkInTime,
        this.checkInLocation,
        this.checkOutTime,
        this.checkOutLocation,
        this.status,
        this.duration,
        this.createdAt,
        this.updatedAt,
        this.user});

  AttendanceDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeId = json['employee_id'];
    employeeName = json['employee_name'];
    department = json['department'];
    designation = json['designation'];
    date = json['date'];
    checkInTime = json['check_in_time'];
    checkInLocation = json['check_in_location'];
    checkOutTime = json['check_out_time'];
    checkOutLocation = json['check_out_location'];
    status = json['status'];
    duration = json['duration'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    user = json['User'] != null ? new User.fromJson(json['User']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['employee_id'] = this.employeeId;
    data['employee_name'] = this.employeeName;
    data['department'] = this.department;
    data['designation'] = this.designation;
    data['date'] = this.date;
    data['check_in_time'] = this.checkInTime;
    data['check_in_location'] = this.checkInLocation;
    data['check_out_time'] = this.checkOutTime;
    data['check_out_location'] = this.checkOutLocation;
    data['status'] = this.status;
    data['duration'] = this.duration;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.user != null) {
      data['User'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? username;
  String? email;

  User({this.username, this.email});

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    return data;
  }
}
