class CheckOutRequestDTO {
  String? checkOutLocation;

  CheckOutRequestDTO({this.checkOutLocation});

  CheckOutRequestDTO.fromJson(Map<String, dynamic> json) {
    checkOutLocation = json['check_out_location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['check_out_location'] = this.checkOutLocation;
    return data;
  }
}
