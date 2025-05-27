class RegisterRequestDTO {
  String? username;
  String? email;
  String? phoneNumber;
  String? password;
  String? department_id;
  String? designation_id;

  RegisterRequestDTO(
      {this.username,
        this.email,
        this.phoneNumber,
        this.password,
        this.department_id,
        this.designation_id});

  RegisterRequestDTO.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    password = json['password'];
    department_id = json['department_id'];
    designation_id = json['designation_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['password'] = this.password;
    data['department_id'] = this.department_id;
    data['designation_id'] = this.designation_id;
    return data;
  }
}
