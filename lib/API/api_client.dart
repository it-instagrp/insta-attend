import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../View/pages/login_page.dart';
import 'app_constants.dart';
import 'error_response.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'Unable to connect to server'.tr;
  final int timeoutInSeconds = 40;

  String _token = "";
  late Map<String, String> _mainHeaders;
  bool _isRedirectingToLogin = false;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    _token = sharedPreferences.getString(token) ?? "";
    if (kDebugMode) {
      debugPrint('ApiClient Initialized with Token: $_token');
    }
    updateHeader(_token);
  }

  /// Dynamically updates authorization headers when user logs in or refreshes token
  void updateHeader(String newDynamicToken) {
    _token = newDynamicToken;
    _mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
    if (kDebugMode) {
      log('Updated Headers: $_mainHeaders');
    }
  }

  /// GET Request
  Future<Response> getData(
    String uri, {
    String? id,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      final String finalUri = id != null ? '$uri/$id' : uri;
      Uri url = Uri.parse(appBaseUrl + finalUri);
      if (query != null) {
        url = url.replace(queryParameters: query);
      }

      if (kDebugMode) {
        debugPrint('====> API GET Call: $url');
      }

      http.Response response = await http
          .get(url, headers: headers ?? _mainHeaders)
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, finalUri);
    } catch (e) {
      debugPrint('ApiClient GET Error: $e');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  /// POST Request
  Future<Response> postData(
    String uri,
    dynamic body, {
    String? id,
    Map<String, String>? headers,
    int? timeout,
  }) async {
    try {
      final String finalUri = id != null ? '$uri/$id' : uri;

      if (kDebugMode) {
        log('====> API POST Call: $appBaseUrl$finalUri');
        log('====> API Body: ${jsonEncode(body)}');
      }

      http.Response response = await http
          .post(
            Uri.parse(appBaseUrl + finalUri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeout ?? timeoutInSeconds));

      return handleResponse(response, finalUri);
    } catch (e) {
      debugPrint('ApiClient POST Error: $e');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  /// PUT Request
  Future<Response> putData(
    String uri,
    dynamic body, {
    String? id,
    Map<String, String>? headers,
  }) async {
    try {
      final String finalUri = id != null ? '$uri/$id' : uri;

      if (kDebugMode) {
        debugPrint('====> API PUT Call: $appBaseUrl$finalUri');
      }

      http.Response response = await http
          .put(
            Uri.parse(appBaseUrl + finalUri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, finalUri);
    } catch (e) {
      debugPrint('ApiClient PUT Error: $e');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  /// DELETE Request
  Future<Response> deleteData(
    String uri, {
    String? id,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final String finalUri = id != null ? '$uri/$id' : uri;

      Uri url = Uri.parse(appBaseUrl + finalUri);
      if (queryParameters != null) {
        url = url.replace(queryParameters: queryParameters);
      }

      if (kDebugMode) {
        debugPrint('====> API DELETE Call: $url');
      }

      http.Response response = await http
          .delete(url, headers: headers ?? _mainHeaders)
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, finalUri);
    } catch (e) {
      debugPrint('ApiClient DELETE Error: $e');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  /// Multipart POST Request
  Future<Response> postMultipartData(
    String uri,
    Map<String, dynamic> body,
    List<MultipartBody> multipartBody, {
    Map<String, String>? headers,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('====> API Multipart Call: $appBaseUrl$uri');
      }
      http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(appBaseUrl + uri),
      );
      request.headers.addAll(headers ?? _mainHeaders);

      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(
            http.MultipartFile(
              multipart.key,
              multipart.file!.readAsBytes().asStream(),
              list.length,
              filename: '${DateTime.now().millisecondsSinceEpoch}.png',
            ),
          );
        }
      }

      final requestBody = _processReportFields(body);
      request.fields.addAll(requestBody);

      http.Response response = await http.Response.fromStream(
        await request.send(),
      );

      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('ApiClient Multipart Error: $e');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  /// Handles and Normalizes HTTP Responses Globally
  Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      body = response.body;
    }

    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
        headers: response.request?.headers ?? {},
        method: response.request?.method ?? '',
        url: response.request?.url ?? Uri(),
      ),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );

    if (kDebugMode) {
      debugPrint('====> API [$uri] Status: ${response0.statusCode}');
    }

    // Handle 401 Unauthorized Session Expiration
    if (response0.statusCode == 401) {
      _clearSessionData();
      return Response(
        statusCode: 401,
        statusText: "Unauthorized: Redirected to Login",
      );
    }

    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.error,
        );
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: response0.body['message'],
        );
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }

    return response0;
  }

  /// Clears user authentication session safely without destroying non-auth preferences
  void _clearSessionData() {
    // Prevent multiple concurrent 401 calls from spamming redirect navigation
    if (_isRedirectingToLogin) return;
    _isRedirectingToLogin = true;

    // Clear specific auth keys rather than destroying SharedPreferences completely
    sharedPreferences.remove(token);
    updateHeader("");

    Future.delayed(Duration.zero, () {
      Get.offAll(() => LoginPage(), transition: Transition.fade);
      _isRedirectingToLogin = false;
    });
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
