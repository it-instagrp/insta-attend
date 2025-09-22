import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:insta_attend/API/DTO/Request/check_in_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/check_out_request_dto.dart';
import 'package:insta_attend/API/Repository/attendance_repository.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:insta_attend/Model/Attendance.dart';
import 'package:insta_attend/Utils/toast_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AttendanceController extends GetxController {
  final AttendanceRepository attendanceRepo;
  AttendanceController({required this.attendanceRepo});

  final AuthController authController = Get.find<AuthController>();

  /**** Default latitude and longitude (fallback) ****/
  RxDouble lat = 18.483669.obs;
  RxDouble long = 73.809200.obs;

  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  RxList<Attendance> attendance = <Attendance>[].obs;
  RxBool isLoading = false.obs;
  RxString attendanceStatus = "No Check-in".obs;
  RxString checkInTime = "".obs;
  RxString checkOutTime = "".obs;
  RxString checkInAddress = "".obs;
  RxString checkOutAddress = "".obs;
  RxBool isCheckIn = true.obs;
  Rx<Duration> todayWorkDuration = Duration.zero.obs;
  Timer? _durationTimer;

  @override
  void onInit() {
    super.onInit();
    getMyAttendance();
  }

  @override
  void onClose() {
    _durationTimer?.cancel();
    super.onClose();
  }

  /**** Get department's latitude and longitude from user ****/
  Future<void> getLatLong(BuildContext context) async {
    try {
      final String latLong = authController.currentUser.value.department?.departmentLatLong ?? "";
      final List<String> positionArray = latLong.split(", ");
      lat.value = double.tryParse(positionArray[0]) ?? 0.0;
      long.value = double.tryParse(positionArray[1]) ?? 0.0;
    } catch (err) {
      showError(context, "Something went wrong");
      debugPrint("Something went wrong: ${err.toString()}");
    }
  }

  /**** Get current user location ****/
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }
    }

    return await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.best));
  }

  /**** Check if user is within 200 meters of office location ****/
  bool isInRange(double userLat, double userLng, double geoLat, double geoLng) {
    double distanceInMeters = Geolocator.distanceBetween(userLat, userLng, geoLat, geoLng);
    return distanceInMeters <= 200;
  }

  /**** Convert lat/lng to address string ****/
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemarks[0];
    return "${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
  }

  /**** Mark user Clock In ****/
  void clockIn(BuildContext context) async {
    isLoading.value = true;
    try {
      await getLatLong(context);
      Position position = await getCurrentLocation();

      if(authController.currentUser.value.geofencing == true){
        bool inRange = isInRange(position.latitude, position.longitude, lat.value, long.value);

        if (inRange) {
          String address = await getAddressFromLatLng(position.latitude, position.longitude);
          Response response = await attendanceRepo.clockIn(CheckInRequestDTO(
              checkInLocation: authController.currentUser.value.department?.departmentAddress ?? "N/A"
          ));

          if (response.statusCode == 200 || response.statusCode == 201) {
            showSuccess(context, "Marked Clock In");
            if (kDebugMode) debugPrint("Attendance Marked at: $address");
          } else {
            showError(context, response.body['message']);
          }
        } else {
          showError(context, "You are not in office premises");
          debugPrint("Not in range");
        }
      } else {
        String address = await getAddressFromLatLng(position.latitude, position.longitude);
        Response response = await attendanceRepo.clockIn(CheckInRequestDTO(
            checkInLocation: address
        ));

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSuccess(context, "Marked Clock In");
          if (kDebugMode) debugPrint("Attendance Marked at: $address");
        } else {
          showError(context, response.body['message']);
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /**** Mark user Clock Out ****/
  void clockOut(BuildContext context) async {
    isLoading.value = true;
    try {
      Position position = await getCurrentLocation();
      if(authController.currentUser.value.geofencing == true){
        bool inRange = isInRange(position.latitude, position.longitude, lat.value, long.value);

        if (inRange) {
          String address = await getAddressFromLatLng(position.latitude, position.longitude);
          Response response = await attendanceRepo.clockOut(CheckOutRequestDTO(
              checkOutLocation: authController.currentUser.value.department?.departmentAddress ?? "N/A"
          ));

          if (response.statusCode == 200 || response.statusCode == 201) {
            showSuccess(context, "Marked Clock In");
            if (kDebugMode) debugPrint("Attendance Marked at: $address");
          } else {
            showError(context, response.body['message']);
          }
        } else {
          showError(context, "You are not in office premises");
          debugPrint("Not in range");
        }
      } else {
        String address = await getAddressFromLatLng(position.latitude, position.longitude);
        Response response = await attendanceRepo.clockOut(CheckOutRequestDTO(
            checkOutLocation: address
        ));

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSuccess(context, "Marked Clock In");
          if (kDebugMode) debugPrint("Attendance Marked at: $address");
        } else {
          showError(context, response.body['message']);
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /**** Fetch user attendance and check today status ****/
  void getMyAttendance() async {
    isLoading.value = true;
    try {
      final String userId = sharedPreferences.getString("uid") ?? "";
      log("UID from session: $userId");
      Response response = await attendanceRepo.getMyAttendance(userId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = response.body['data'];
        attendance.value = data.map((json) => Attendance.fromJson(json)).toList();

        String today = DateTime.now().toIso8601String().substring(0, 10);
        var todayRecords = attendance.where((record) => record.date == today).toList();

        // If there are records for today, process the latest one
        if (todayRecords.isNotEmpty) {
          final latestRecord = todayRecords.last;

          checkInTime.value = latestRecord.checkInTime ?? "";
          checkInAddress.value = latestRecord.checkInLocation ?? "";

          if (latestRecord.checkOutTime != null && latestRecord.checkOutTime!.isNotEmpty) {
            // User has checked out
            attendanceStatus.value = "Checked Out";
            isCheckIn.value = true;
            checkOutTime.value = latestRecord.checkOutTime!;
            checkOutAddress.value = latestRecord.checkOutLocation!;
            updateTodayDuration();
            _durationTimer?.cancel();

            print("Status: ${attendanceStatus.value}, CheckIn: ${isCheckIn}, Check Out Time: ${checkOutTime.value}, Check in Time: ${checkInTime.value}");
          } else {
            // User is currently checked in
            attendanceStatus.value = "Checked In";
            isCheckIn.value = false;
            checkOutTime.value = "";
            checkOutAddress.value = "";
            updateTodayDuration();
            _startDurationTimer();

            // Debugging statement added here
            print("Status: ${attendanceStatus.value}, CheckIn Time: ${checkInTime.value}, CheckIn Address: ${checkInAddress.value}");
          }
        } else {
          // No attendance records for today
          attendanceStatus.value = "No Check-in";
          isCheckIn.value = true;
          checkInTime.value = "";
          checkInAddress.value = "";
          checkOutTime.value = "";
          checkOutAddress.value = "";
          todayWorkDuration.value = Duration.zero;
          _durationTimer?.cancel();
        }
      } else {
        debugPrint("Failed to fetch attendance. Status Code: ${response.statusCode}");
      }
    } catch (err) {
      debugPrint("Error while fetching attendance: $err");
    } finally {
      isLoading.value = false;
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateTodayDuration();
    });
  }

  void updateTodayDuration() {
    String today = DateTime.now().toIso8601String().substring(0, 10);
    var todayRecords = attendance.where((record) => record.date == today).toList();

    if (todayRecords.isNotEmpty) {
      final latestRecord = todayRecords.last;
      if (latestRecord.checkInTime != null) {
        DateTime checkInDateTime = DateTime.parse(latestRecord.checkInTime!).toLocal();
        if (latestRecord.checkOutTime != null && latestRecord.checkOutTime!.isNotEmpty) {
          DateTime checkOutDateTime = DateTime.parse(latestRecord.checkOutTime!).toLocal();
          todayWorkDuration.value = checkOutDateTime.difference(checkInDateTime);
        } else {
          todayWorkDuration.value = DateTime.now().toLocal().difference(checkInDateTime);
        }
      }
    } else {
      todayWorkDuration.value = Duration.zero;
    }
  }

  /**** Calculate total duration from list of attendance records ****/
  String calculateTotalDuration(List<Attendance> attendanceList) {
    int totalMinutes = attendanceList.fold(0, (sum, record) {
      if (record.duration != null && record.duration!.contains(":")) {
        final parts = record.duration!.split(":");
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        return sum + (hours * 60) + minutes;
      }
      return sum;
    });

    int totalHours = totalMinutes ~/ 60;
    int remainingMinutes = totalMinutes % 60;
    return "${totalHours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}";
  }

  /**** Get today’s total work duration ****/
  String getTodayDuration() {
    String today = DateTime.now().toIso8601String().substring(0, 10);
    var todayRecords = attendance.where((record) => record.date == today).toList();
    return calculateTotalDuration(todayRecords);
  }

  /**** Get current month's total work duration ****/
  String getMonthlyDuration() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    var monthlyRecords = attendance.where((record) {
      if (record.date == null) return false;
      DateTime recordDate = DateTime.parse(record.date!);
      return recordDate.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
          recordDate.isBefore(now.add(Duration(days: 1)));
    }).toList();

    return calculateTotalDuration(monthlyRecords);
  }
}