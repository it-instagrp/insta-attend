import 'dart:convert';

class CheckInRequestDTO {
  String? checkInLocation;
  List<double>? faceEmbedding;

  CheckInRequestDTO({this.checkInLocation, this.faceEmbedding});

  CheckInRequestDTO.fromJson(Map<String, dynamic> json) {
    checkInLocation = json['check_in_location'];
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
    data['check_in_location'] = this.checkInLocation;
    data['face_embedding'] = this.faceEmbedding;
    return data;
  }
}
