class RegisterRequestDTO {
  String? organization_id;
  String? username;
  String? email;
  String? phoneNumber;
  String? password;
  // List<double>? faceEmbedding;

  RegisterRequestDTO({
    this.organization_id,
    this.username,
    this.email,
    this.phoneNumber,
    this.password,
    // this.faceEmbedding,
  });

  RegisterRequestDTO.fromJson(Map<String, dynamic> json) {
    organization_id = json['organization_id'];
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    password = json['password'];
    // faceEmbedding = json['face_embedding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['organization_id'] = this.organization_id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['password'] = this.password;
    // data['face_embedding'] = this.faceEmbedding;
    return data;
  }
}
