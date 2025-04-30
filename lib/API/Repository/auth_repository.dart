import 'package:get/get.dart';
import 'package:insta_attend/API/DTO/Request/register_request_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_client.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepository({required this.apiClient, required this.sharedPreferences});


  Future<Response> register(RegisterRequestDTO request) async{
    return await apiClient.postData("", request.toJson());
  }

}
