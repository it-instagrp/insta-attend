class Leave {
  String? id;
  String? userId;
  String? from;
  String? to;
  String? leaveType;
  String? status;
  String? createdAt;
  String? updatedAt;

  Leave(
      {this.id,
        this.userId,
        this.from,
        this.to,
        this.leaveType,
        this.status,
        this.createdAt,
        this.updatedAt});

  Leave.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    from = json['from'];
    to = json['to'];
    leaveType = json['leave_type'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['from'] = this.from;
    data['to'] = this.to;
    data['leave_type'] = this.leaveType;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
