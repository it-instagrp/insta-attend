class CheckInRequestDTO {
  String? checkInLocation;
  List<double>? faceEmbedding;

  CheckInRequestDTO({this.checkInLocation, this.faceEmbedding});

  CheckInRequestDTO.fromJson(Map<String, dynamic> json) {
    checkInLocation = json['check_in_location'];
    faceEmbedding = json['face_embedding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['check_in_location'] = this.checkInLocation;
    data['face_embedding'] = this.faceEmbedding;
    return data;
  }
}
