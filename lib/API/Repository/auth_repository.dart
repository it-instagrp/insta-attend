import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:insta_attend/API/DTO/Request/change_password_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/forgot_password_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/login_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/register_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/update_profile_request_dto.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/API/app_constants.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepository({required this.apiClient, required this.sharedPreferences});

  // ==================== SESSION & LOCAL STORAGE METHODS ====================

  /// Save token locally and dynamically update ApiClient headers
  Future<bool> saveUserToken(String userToken) async {
    apiClient.updateHeader(userToken);
    return await sharedPreferences.setString(token, userToken);
  }

  /// Retrieve stored authentication token
  String getUserToken() {
    return sharedPreferences.getString(token) ?? "";
  }

  /// Check if an active user token exists
  bool isLoggedIn() {
    return getUserToken().isNotEmpty;
  }

  /// Clear user session data safely
  Future<bool> clearSessionData() async {
    apiClient.updateHeader("");
    return await sharedPreferences.remove(token);
  }

  // ==================== AUTHENTICATION API METHODS ====================

  Future<Response> register(RegisterRequestDTO request) async {
    return await apiClient.postData(registerUrl, request.toJson());
  }

  Future<Response> login(LoginRequestDTO request) async {
    return await apiClient.postData(loginUrl, request.toJson());
  }

  Future<Response> me() async {
    return await apiClient.getData(meUrl);
  }

  Future<Response> updateProfile(
      UpdateProfileRequestDTO request,
      String userId,
      ) async {
    return await apiClient.putData(profileUrl, request.toJson(), id: userId);
  }

  Future<Response> uploadProfilePicture(
      String userId,
      MultipartBody file,
      ) async {
    return await apiClient.postMultipartData(
      uploadProfilePictureUrl,
      {},
      [file],
    );
  }

  Future<Response> changePassword(ChangePasswordRequestDTO request) async {
    return await apiClient.postData(changePasswordUrl, request.toJson());
  }

  Future<Response> getDepartments() async {
    return await apiClient.getData(getDepartmentUrl);
  }

  Future<Response> getDesignations() async {
    return await apiClient.getData(getDesignationUrl);
  }

  Future<Response> forgotPassword(ForgotPasswordRequestDto request) async {
    return await apiClient.postData(forgotPasswordUrl, request.toJson());
  }
}