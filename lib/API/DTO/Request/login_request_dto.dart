class LoginRequestDTO {
  String? email;
  String? password;
  String? fcmToken;

  LoginRequestDTO({this.email, this.password, this.fcmToken});

  LoginRequestDTO.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    fcmToken = json['fcm_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['password'] = this.password;
    data['fcm_token'] = this.fcmToken;
    return data;
  }
}