class User {
  String? id;
  String? username;
  String? email;
  String? phoneNumber;
  bool? geofencing;
  bool? isEnrolled;
  bool? deletePermission;
  String? createdAt;
  String? updatedAt;
  Department? department;
  Designation? designation;

  User(
      {this.id,
        this.username,
        this.email,
        this.phoneNumber,
        this.geofencing,
        this.isEnrolled,
        this.deletePermission,
        this.createdAt,
        this.updatedAt,
        this.department,
        this.designation});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    geofencing = json['geofencing'];
    isEnrolled = json['is_enrolled'];
    deletePermission = json['delete_permission'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    department = json['department'] != null
        ? new Department.fromJson(json['department'])
        : null;
    designation = json['designation'] != null
        ? new Designation.fromJson(json['designation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['geofencing'] = this.geofencing;
    data['is_enrolled'] = this.isEnrolled;
    data['delete_permission'] = this.deletePermission;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.department != null) {
      data['department'] = this.department!.toJson();
    }
    if (this.designation != null) {
      data['designation'] = this.designation!.toJson();
    }
    return data;
  }
}

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
