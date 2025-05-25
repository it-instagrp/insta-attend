class ApplyLeaveRequestDTO {
  String? from;
  String? to;
  String? leaveType;
  String? userId;

  ApplyLeaveRequestDTO({this.from, this.to, this.leaveType, this.userId});

  ApplyLeaveRequestDTO.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    leaveType = json['leave_type'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['leave_type'] = this.leaveType;
    data['user_id'] = this.userId;
    return data;
  }
}
