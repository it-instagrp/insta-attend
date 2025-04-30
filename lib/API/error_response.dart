// {message: "Category of error", error: "Actual Error"}


class ErrorResponse {
  String? message;
  String? error;

  ErrorResponse({this.message, this.error});

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}