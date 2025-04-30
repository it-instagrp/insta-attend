import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_constants.dart';
import 'error_response.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'Unable to connect to server'.tr;
  final int timeoutInSeconds = 40;

  String liveToken = token;
  String userId = uid;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    liveToken = sharedPreferences.getString(token) ?? "";
    userId = sharedPreferences.getString(uid) ?? "";
    if (kDebugMode) {
      print('Token: $token');
      print('UserId: $userId');
    }
    updateHeader(token, userId);
  }

  void updateHeader(String token, String userId) {
    _mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    this.userId = userId;
    if (kDebugMode) {
      print('Updated Headers: $_mainHeaders');
      log('Updated Headers: $_mainHeaders');
    }
  }

// Modified getData method with optional id parameter
  Future<Response> getData(String uri, {String? id, Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      // Append ID to URI if provided
      final String finalUri = id != null ? '$uri/$id' : uri;

      if (kDebugMode) {
        print('====> API Call: $appBaseUrl$finalUri\nHeader: $_mainHeaders');
      }

      Uri url = Uri.parse(appBaseUrl + finalUri);
      if (query != null) {
        url = url.replace(queryParameters: query);
      }

      http.Response response = await http.get(
        url,
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, finalUri);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

// Modified putData (update) method with optional id parameter
  Future<Response> putData(String uri, dynamic body, {String? id, Map<String, String>? headers}) async {
    try {
      // Append ID to URI if provided
      final String finalUri = id != null ? '$uri/$id' : uri;

      if (kDebugMode) {
        print('====> API Call: $appBaseUrl$finalUri\nHeader: $_mainHeaders');
        print('====> API Body: $body');
      }

      http.Response response = await http.put(
        Uri.parse(appBaseUrl + finalUri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, finalUri);
    } catch (e) {
      print('Error: $e');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

// Modified deleteData method with optional id parameter
  Future<Response> deleteData(String uri, {String? id, Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      // Append ID to URI if provided
      final String finalUri = id != null ? '$uri/$id' : uri;

      Uri url = Uri.parse(appBaseUrl + finalUri);
      if (queryParameters != null) {
        url = url.replace(queryParameters: queryParameters);
      }

      if (kDebugMode) {
        print('====> API Call: $url\nHeader: $_mainHeaders');
      }

      http.Response response = await http.delete(
        url,
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, finalUri);
    } catch (e) {
      print('Error: $e');
      return Response(statusCode: 1, statusText: "No Internet connection");
    }
  }

// Also modify the postData for consistency
  Future<Response> postData(String uri, dynamic body, {String? id, Map<String, String>? headers, int? timeout}) async {
    try {
      // Append ID to URI if provided
      final String finalUri = id != null ? '$uri/$id' : uri;

      if (kDebugMode) {
        log('====> API Call: $appBaseUrl$finalUri\nHeader: $_mainHeaders');
        print('====> API Body: $body');
      }

      http.Response response = await http.post(
        Uri.parse(appBaseUrl + finalUri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeout ?? timeoutInSeconds));

      return handleResponse(response, finalUri);
    } catch (e) {
      print('Error: $e');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(String uri, Map<String, dynamic> body, List<MultipartBody> multipartBody, {Map<String, String>? headers}) async {
    try {
      if (kDebugMode) {
        print('====> API Call:  $appBaseUrl$uri\nHeader: $_mainHeaders');
        print('====> API Body: $body with ${multipartBody.length} pictures');
      }
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(_mainHeaders);
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(http.MultipartFile(
            multipart.key, multipart.file!.readAsBytes().asStream(), list.length,
            filename: '${DateTime.now().toString()}.png',
          ));
        }
      }

      final requestBody = _processReportFields(body);

      request.fields.addAll(requestBody);
      print("response"+body.toString());
      http.Response response = await http.Response.fromStream(await request.send());
      print("response");
      print("response"+response.body);
      return handleResponse(response, uri);
    } catch (e) {
      print('Error: $e');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      body = response.body;
      print("===>${body}");
    }

    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url
      ),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );

    if (kDebugMode) {
      print('====> API Response Handling Start');
      print('====> Request URI: $uri');
      print('====> Response Status Code: ${response0.statusCode}');
      print('====> Response Status Text: ${response0.statusText}');
      print('====> Response Headers: ${response0.headers}');
      print('====> Response Body: ${response0.bodyString}');
    }

    if (response0.statusCode != 200 && response0.body != null && response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: errorResponse.error
        );
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: response0.body['message']
        );
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(
          statusCode: 0,
          statusText: noInternetMessage
      );
    }

    if (kDebugMode) {
      print('====> API Response Handling End');
      print('====> Processed Response Status Code: ${response0.statusCode}');
      print('====> Processed Response Status Text: ${response0.statusText}');
      print('====> Processed Response Body: ${response0.bodyString}');
    }

    return response0;
  }
}

Map<String, String> _processReportFields(Map<String, dynamic> reportData) {
  return reportData.map((key, value) {
    if (value is Map || value is List) {
      return MapEntry(key, json.encode(value));
    }
    return MapEntry(key, value?.toString() ?? '');
  });
}


class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}
