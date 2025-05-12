

import 'package:get/get.dart';
import 'package:insta_attend/API/DTO/Request/check_in_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/check_out_request_dto.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/API/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceRepository{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  const AttendanceRepository({required this.apiClient, required this.sharedPreferences});


  Future<Response> clockIn(CheckInRequestDTO request) async{
    return await apiClient.postData(checkInUrl, request.toJson());
  }

  Future<Response> clockOut(CheckOutRequestDTO request) async{
    return await apiClient.postData(checkOutUrl, request.toJson());
  }

  Future<Response> getMyAttendance(userId) async{
    return await apiClient.getData(attendanceByIdUrl(userId));
  }
}