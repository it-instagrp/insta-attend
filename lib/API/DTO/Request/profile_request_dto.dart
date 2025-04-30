class ProfileRequestDTO {
  String? username;
  String? email;
  String? phoneNumber;
  String? circle;

  ProfileRequestDTO({this.username, this.email, this.phoneNumber, this.circle});

  ProfileRequestDTO.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    circle = json['circle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['circle'] = this.circle;
    return data;
  }
}
