class Designation {
  String? id;
  String? designationName;
  bool? adminAccess;
  String? createdAt;
  String? updatedAt;

  Designation(
      {this.id,
        this.designationName,
        this.adminAccess,
        this.createdAt,
        this.updatedAt});

  Designation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    designationName = json['designation_name'];
    adminAccess = json['admin_access'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['designation_name'] = this.designationName;
    data['admin_access'] = this.adminAccess;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
