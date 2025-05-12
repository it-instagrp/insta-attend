import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:insta_attend/API/DTO/Request/check_in_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/check_out_request_dto.dart';
import 'package:insta_attend/API/Repository/attendance_repository.dart';
import 'package:insta_attend/Model/Attendance.dart';
import 'package:insta_attend/Utils/toast_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AttendanceController extends GetxController{

  final AttendanceRepository attendanceRepo;

  AttendanceController({required this.attendanceRepo});

  //18.483669, 73.809200
  // 18.500083, 73.788667

  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  RxDouble lat = 18.483669.obs;
  RxDouble long = 73.809200.obs;
  RxList<Attendance> attendance = <Attendance>[].obs;
  RxBool isLoading = false.obs;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best
      )
    );
  }

  bool isInRange(double userLat, double userLng, double geoLat, double geoLng) {
    double distanceInMeters = Geolocator.distanceBetween(userLat, userLng, geoLat, geoLng);
    return distanceInMeters <= 200;
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemarks[0];
    return "${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
  }

  void clockIn(BuildContext context) async {
    isLoading.value = true;
    try {
      Position position = await getCurrentLocation();
      bool inRange = isInRange(position.latitude, position.longitude, lat.value, long.value);
      if (inRange) {
        String address = await getAddressFromLatLng(position.latitude, position.longitude);
        Response response = await attendanceRepo.clockIn(CheckInRequestDTO(
          checkInLocation: address
        ));
        if(response.statusCode == 200 || response.statusCode == 201){
          showSuccess(context, "Marked Clock In");
          if(kDebugMode)print("Attendance Marked at: $address");
        } else {
          showError(context, response.body['message']);
        }
      } else {
        print("Not in range");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
  void clockOut(BuildContext context) async {
    isLoading.value = true;
    try {
      Position position = await getCurrentLocation();
      bool inRange = isInRange(position.latitude, position.longitude, lat.value, long.value);

      if (inRange) {
        String address = await getAddressFromLatLng(position.latitude, position.longitude);
        Response response = await attendanceRepo.clockOut(CheckOutRequestDTO(
            checkOutLocation: address
        ));
        if(response.statusCode == 200 || response.statusCode == 201){
          showSuccess(context, "Marked Clock Out");
          if(kDebugMode)print("Attendance Marked at: $address");
        } else {
          showError(context, response.body['message']);
        }
      } else {
        print("Not in range");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }


  void getMyAttendance() async {
    isLoading.value = true;
    try {
      final String userId = sharedPreferences.getString("uid") ?? "";
      Response response = await attendanceRepo.getMyAttendance(userId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = response.body['data'];
        attendance.value = data.map((json) => Attendance.fromJson(json)).toList();
      } else {
        print("Failed to fetch attendance. Status Code: ${response.statusCode}");
      }
    } catch (err) {
      print("Error while fetching attendance: $err");
    } finally {
      isLoading.value = false;
    }
  }

  String calculateTotalDuration(List<Attendance> attendanceList) {
    int totalMinutes = 0;

    for (var record in attendanceList) {
      if (record.duration != null && record.duration!.isNotEmpty) {
        final timeParts = record.duration!.split(":");
        if (timeParts.length == 2) {
          int hours = int.parse(timeParts[0]);
          int minutes = int.parse(timeParts[1]);
          totalMinutes += (hours * 60) + minutes;
        }
      }
    }

    int totalHours = totalMinutes ~/ 60;
    int remainingMinutes = totalMinutes % 60;
    return "${totalHours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}";
  }

  String getTodayDuration() {
    DateTime today = DateTime.now();
    String formattedToday = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    var todayRecords = attendance.where((record) {
      return record.date == formattedToday;
    }).toList();

    return calculateTotalDuration(todayRecords);
  }

  String getMonthlyDuration() {
    DateTime now = DateTime.now();
    DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    String formattedFirstOfMonth = "${firstOfMonth.year}-${firstOfMonth.month.toString().padLeft(2, '0')}-${firstOfMonth.day.toString().padLeft(2, '0')}";

    var monthlyRecords = attendance.where((record) {
      DateTime recordDate = DateTime.parse(record.date ?? DateTime.now().toString());
      return recordDate.isAfter(firstOfMonth.subtract(Duration(days: 1))) &&
          recordDate.isBefore(now.add(Duration(days: 1)));
    }).toList();

    return calculateTotalDuration(monthlyRecords);
  }




  @override
  void onInit() {
    getMyAttendance();
    super.onInit();
  }



}