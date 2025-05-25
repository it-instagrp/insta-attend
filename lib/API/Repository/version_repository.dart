import 'package:get/get.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/API/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';


class VersionRepository {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  VersionRepository({required this.apiClient, required this.sharedPreferences});
  
  Future<Response> getVersionList() async{
    return await apiClient.getData(versionUrl);
  }
}
