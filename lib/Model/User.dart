import 'department.dart';
import 'designation.dart';

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
  List<double>? faceEmbedding;

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
        this.designation,
      this.faceEmbedding
      });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    geofencing = json['geofencing'];
    isEnrolled = json['is_enrolled'];
    faceEmbedding = json['face_embedding'];
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
    data['face_embedding'] = this.faceEmbedding;
    if (this.department != null) {
      data['department'] = this.department!.toJson();
    }
    if (this.designation != null) {
      data['designation'] = this.designation!.toJson();
    }
    return data;
  }
}
