class Department {
  String? id;
  String? departmentName;
  String? departmentLatLong;
  String? departmentAddress;
  String? departmentLead;
  String? createdAt;
  String? updatedAt;

  Department(
      {this.id,
        this.departmentName,
        this.departmentLatLong,
        this.departmentAddress,
        this.departmentLead,
        this.createdAt,
        this.updatedAt});

  Department.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    departmentName = json['department_name'];
    departmentLatLong = json['department_lat_long'];
    departmentAddress = json['department_address'];
    departmentLead = json['department_lead'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['department_name'] = this.departmentName;
    data['department_lat_long'] = this.departmentLatLong;
    data['department_address'] = this.departmentAddress;
    data['department_lead'] = this.departmentLead;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
