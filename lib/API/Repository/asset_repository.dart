import 'package:get/get.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/API/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AssetRepository {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AssetRepository({required this.apiClient, required this.sharedPreferences});

  Future<Response> getMyAssets() async{
    final String userId = await sharedPreferences.getString("uid") ?? "NA";
    return await apiClient.getData(getMyAssetsUrl(userId));
  }
}
