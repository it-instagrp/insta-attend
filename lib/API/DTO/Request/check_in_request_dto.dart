class CheckInRequestDTO {
  String? checkInLocation;

  CheckInRequestDTO({this.checkInLocation});

  CheckInRequestDTO.fromJson(Map<String, dynamic> json) {
    checkInLocation = json['check_in_location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['check_in_location'] = this.checkInLocation;
    return data;
  }
}
