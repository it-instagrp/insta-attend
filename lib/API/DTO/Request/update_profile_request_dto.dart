class UpdateProfileRequestDTO {
  String? username;
  String? email;
  String? phoneNumber;

  UpdateProfileRequestDTO({this.username, this.email, this.phoneNumber});

  UpdateProfileRequestDTO.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    return data;
  }
}
