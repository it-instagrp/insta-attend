class User {
  String? id;
  bool? geofencing;
  bool? isEnrolled;
  bool? deletePermission;
  String? username;
  String? email;
  String? phoneNumber;
  String? circle;
  String? role;
  String? updatedAt;
  String? createdAt;

  User(
      {this.id,
        this.geofencing,
        this.isEnrolled,
        this.deletePermission,
        this.username,
        this.email,
        this.phoneNumber,
        this.circle,
        this.role,
        this.updatedAt,
        this.createdAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    geofencing = json['geofencing'];
    isEnrolled = json['is_enrolled'];
    deletePermission = json['delete_permission'];
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    circle = json['circle'];
    role = json['role'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['geofencing'] = this.geofencing;
    data['is_enrolled'] = this.isEnrolled;
    data['delete_permission'] = this.deletePermission;
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['circle'] = this.circle;
    data['role'] = this.role;
    data['updatedAt'] = this.updatedAt;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
