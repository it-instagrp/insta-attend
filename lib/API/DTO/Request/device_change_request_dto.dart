class DeviceChangeRequestDTO {
  String? email;
  String? password;
  String? imeiNumber;
  String? deviceName;

  DeviceChangeRequestDTO({this.email, this.password, this.imeiNumber, this.deviceName});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['password'] = this.password;
    data['imei_number'] = this.imeiNumber;
    data['device_name'] = this.deviceName;
    return data;
  }
}