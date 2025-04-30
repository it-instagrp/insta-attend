class RegisterRequestDTO {
  String? username;
  String? email;
  String? phoneNumber;
  String? password;
  String? circle;
  String? role;

  RegisterRequestDTO(
      {this.username,
        this.email,
        this.phoneNumber,
        this.password,
        this.circle,
        this.role});

  RegisterRequestDTO.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    password = json['password'];
    circle = json['circle'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['password'] = this.password;
    data['circle'] = this.circle;
    data['role'] = this.role;
    return data;
  }
}
