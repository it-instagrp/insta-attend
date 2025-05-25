import 'package:get/get.dart';
import 'package:insta_attend/API/DTO/Request/apply_leave_request_dto.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/API/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveRepository{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  const LeaveRepository({required this.apiClient, required this.sharedPreferences});

  Future<Response> getLeaveList(String userId) async {
    return await apiClient.getData(getMyLeaves(userId));
  }

  Future<Response> requestLeave(ApplyLeaveRequestDTO request) async{
    return await apiClient.postData(applyLeave, request.toJson());
  }
}