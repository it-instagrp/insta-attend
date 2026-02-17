import 'dart:convert';

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
    if (json['face_embedding'] != null) {
      var embeddingData = json['face_embedding'];

      if (embeddingData is String) {
        // If the API sent a string "[0.1, 0.2...]", decode it first
        List<dynamic> decoded = jsonDecode(embeddingData);
        faceEmbedding = decoded.map((e) => (e as num).toDouble()).toList();
      } else if (embeddingData is List) {
        // If the API sent a proper JSON array [0.1, 0.2...]
        faceEmbedding = embeddingData.map((e) => (e as num).toDouble()).toList();
      }
    }
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
