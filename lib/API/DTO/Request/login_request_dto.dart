class LoginRequestDTO {
  String? email;
  String? password;
  String? fcmToken;
  String? imeiNumber;

  LoginRequestDTO({this.email, this.password, this.fcmToken, this.imeiNumber});

  LoginRequestDTO.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    fcmToken = json['fcm_token'];
    imeiNumber = json['imei_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['password'] = this.password;
    data['fcm_token'] = this.fcmToken;
    data['imei_number'] = this.imeiNumber;
    return data;
  }
}
