import 'package:insta_attend/API/Repository/asset_repository.dart';
import 'package:insta_attend/API/Repository/attendance_repository.dart';
import 'package:insta_attend/API/Repository/auth_repository.dart';
import 'package:insta_attend/API/Repository/leave_repository.dart';
import 'package:insta_attend/API/Repository/version_repository.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/Controller/asset_controller.dart';
import 'package:insta_attend/Controller/attendance_controller.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:insta_attend/Controller/homescreen_controller.dart';
import 'package:insta_attend/Controller/leave_controller.dart';
import 'package:insta_attend/Controller/onboarding_controller.dart';
import 'package:insta_attend/Controller/version_controller.dart';
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
  Get.lazyPut(()=>LeaveRepository(apiClient: Get.find<ApiClient>(), sharedPreferences: sharedPreferences), fenix: true);
  Get.lazyPut(()=>VersionRepository(apiClient: Get.find<ApiClient>(), sharedPreferences: sharedPreferences), fenix: true);
  Get.lazyPut(()=>AssetRepository(apiClient: Get.find<ApiClient>(), sharedPreferences: sharedPreferences), fenix: true);


  /**** GetXController Injection ****/
  Get.lazyPut(()=>AuthController(authRepo: Get.find<AuthRepository>()), fenix: true);
  Get.lazyPut(()=>OnboardingController());
  Get.lazyPut(()=>HomescreenController(), fenix: true);
  Get.lazyPut(()=>AttendanceController(attendanceRepo: Get.find<AttendanceRepository>()), fenix: true);
  Get.lazyPut(()=>LeaveController(leaveRepository: Get.find<LeaveRepository>()), fenix: true);
  Get.lazyPut(()=>VersionController(versionRepo: Get.find<VersionRepository>()), fenix: true);
  Get.lazyPut(()=>AssetController(assetRepo: Get.find<AssetRepository>()), fenix: true);

}