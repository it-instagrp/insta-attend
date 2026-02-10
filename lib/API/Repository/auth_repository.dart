import 'package:get/get.dart';
import 'package:insta_attend/API/DTO/Request/change_password_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/login_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/register_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/update_profile_request_dto.dart';
import 'package:insta_attend/API/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_client.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepository({required this.apiClient, required this.sharedPreferences});


  Future<Response> register(RegisterRequestDTO request) async{
    return await apiClient.postData(registerUrl, request.toJson());
  }

  Future<Response> login(LoginRequestDTO request) async{
    return await apiClient.postData(loginUrl, request.toJson());
  }

  Future<Response> me(LoginRequestDTO request) async{
    return await apiClient.getData(meUrl);
  }

  Future<Response> updateProfile(UpdateProfileRequestDTO request, String userId, MultipartBody file) async{
    return await apiClient.putMultipartData(profileUrl, request.toJson(), [file]);
  }

  Future<Response> changePassword(ChangePasswordRequestDTO request) async{
    return await apiClient.postData(changePasswordUrl, request.toJson());
  }

  Future<Response> getDepartments() async{
    return await apiClient.getData(getDepartmentUrl);
  }

  Future<Response> getDesignations() async{
    return await apiClient.getData(getDesignationUrl);
  }

}
