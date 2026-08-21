class ApplyLeaveRequestDTO {
  String? from;
  String? to;
  String? leaveType;

  ApplyLeaveRequestDTO({this.from, this.to, this.leaveType});

  ApplyLeaveRequestDTO.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    leaveType = json['leave_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['leave_type'] = this.leaveType;
    return data;
  }
}