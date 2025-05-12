import 'package:insta_attend/API/Repository/attendance_repository.dart';
import 'package:insta_attend/API/Repository/auth_repository.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/Controller/attendance_controller.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../API/app_constants.dart';

Future<void> init() async{
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  /**** Repository Injection ****/
  Get.lazyPut(()=>ApiClient(appBaseUrl: appBaseUrl, sharedPreferences: sharedPreferences));
  Get.lazyPut(()=>sharedPreferences);
  Get.lazyPut(()=>AuthRepository(apiClient: Get.find<ApiClient>(), sharedPreferences: sharedPreferences), fenix: true);
  Get.lazyPut(()=>AttendanceRepository(apiClient: Get.find<ApiClient>(), sharedPreferences: sharedPreferences), fenix: true);


  /**** GetXController Injection ****/
  Get.lazyPut(()=>AuthController(authRepo: Get.find<AuthRepository>()), fenix: true);
  Get.lazyPut(()=>AttendanceController(attendanceRepo: Get.find<AttendanceRepository>()), fenix: true);

}