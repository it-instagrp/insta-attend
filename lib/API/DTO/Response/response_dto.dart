class ResponseDTO {
  final int code;
  final String message;
  final dynamic data;

  ResponseDTO({
    required this.code,
    required this.message,
    required this.data,
  });


  factory ResponseDTO.fromJson(Map<String, dynamic> json) {
    return ResponseDTO(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data,
    };
  }

  Map<String, dynamic>? get dataAsMap =>
      data is Map<String, dynamic> ? data as Map<String, dynamic> : null;


  List<dynamic>? get dataAsList =>
      data is List ? data as List<dynamic> : null;
}
