class UpdateProfileRequestDTO {
  String? username;
  String? email;
  String? phoneNumber;
  List<double>? faceEmbedding;

  UpdateProfileRequestDTO({this.username, this.email, this.phoneNumber, this.faceEmbedding});

  UpdateProfileRequestDTO.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    faceEmbedding = json['face_embedding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['face_embedding'] = this.faceEmbedding;
    return data;
  }
}
