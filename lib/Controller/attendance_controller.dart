import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insta_attend/API/DTO/Request/check_in_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/check_out_request_dto.dart';
import 'package:insta_attend/API/Repository/attendance_repository.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:insta_attend/Model/Attendance.dart';
import 'package:insta_attend/Model/attendance_detail.dart';
import 'package:insta_attend/Model/attendance_for_week.dart';
import 'package:insta_attend/Utils/toast_messages.dart';
import '../Constant/constant_color.dart';
import '../View/pages/face_scanner_page.dart';

class AttendanceController extends GetxController {
  final AttendanceRepository attendanceRepo;
  AttendanceController({required this.attendanceRepo});

  final AuthController authController = Get.find<AuthController>();
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  // Fallback office coordinates
  final RxDouble lat = 18.483669.obs;
  final RxDouble long = 73.809200.obs;

  // Reactive State Variables
  final RxList<Attendance> attendance = <Attendance>[].obs;
  final RxBool isAttendanceLoading = false.obs;
  final RxBool isClockingLoading = false.obs;
  final RxBool isWeeklyAttendanceLoading = false.obs;
  final RxBool isAttendanceDetailsLoading = false.obs;

  final RxString attendanceStatus = "No Check-in".obs;
  final RxString checkInTime = "".obs;
  final RxString checkOutTime = "".obs;
  final RxString checkInAddress = "".obs;
  final RxString checkOutAddress = "".obs;
  final RxBool isCheckIn = true.obs;

  final Rx<Duration> todayWorkDuration = Duration.zero.obs;
  Timer? _durationTimer;

  final RxList<AttendanceForWeek> weeklyAttendance = <AttendanceForWeek>[].obs;
  final Rxn<AttendanceDetail> attendanceDetails = Rxn<AttendanceDetail>();

  @override
  void onClose() {
    _durationTimer?.cancel();
    super.onClose();
  }

  /// Get department's latitude and longitude from user session
  Future<void> getLatLong(BuildContext context) async {
    try {
      final String latLong =
          authController.currentUser.value.department?.departmentLatLong ?? "";

      if (latLong.isNotEmpty && latLong.contains(',')) {
        final List<String> positionArray = latLong.split(",");
        if (positionArray.length >= 2) {
          lat.value = double.tryParse(positionArray[0].trim()) ?? 18.483669;
          long.value = double.tryParse(positionArray[1].trim()) ?? 73.809200;
        }
      }
    } catch (err) {
      showError("Something went wrong loading office location");
      debugPrint("Exception in getLatLong: ${err.toString()}");
    }
  }

  /// Get current user GPS location
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
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  /// Check if user is within radius (meters) of office location
  bool isInRange(double userLat, double userLng, double geoLat, double geoLng, {double maxDistanceMeters = 200.0}) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      geoLat,
      geoLng,
    );
    return distanceInMeters <= maxDistanceMeters;
  }

  /// Convert lat/lng to readable address string
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}".trim();
      }
    } catch (e) {
      debugPrint("Error reverse geocoding: $e");
    }
    return "Unknown Location";
  }

  void _handleAttendanceError(BuildContext context, String serverMessage) {
    if (serverMessage.toLowerCase().contains("face not registered")) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Face Profile Required"),
          content: const Text(
            "Your face biometric profile is missing from server records. Would you like to scan and register your face now?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: kcGrey500)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPurple600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                authController.enrollUserFace(context);
              },
              child: const Text(
                "Register Now",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      showError(serverMessage);
    }
  }

  /// Mark user Clock In
  void clockIn(BuildContext context) async {
    final dynamic faceResult = await Get.to(
          () => const FaceScannerPage(isRegistration: false),
    );

    if (faceResult != null && faceResult is List<double>) {
      isClockingLoading.value = true;
      try {
        await getLatLong(context);
        Position position = await getCurrentLocation();

        bool isGeofenced = authController.currentUser.value.geofencing ?? false;
        String locationAddress = "";

        if (isGeofenced) {
          bool inRange = isInRange(
            position.latitude,
            position.longitude,
            lat.value,
            long.value,
          );

          if (!inRange) {
            showError("You are not within office premises");
            return;
          }
          locationAddress = authController.currentUser.value.department?.departmentAddress ?? "Office Premises";
        } else {
          locationAddress = await getAddressFromLatLng(
            position.latitude,
            position.longitude,
          );
        }

        Response response = await attendanceRepo.clockIn(
          CheckInRequestDTO(
            checkInLocation: locationAddress,
            faceEmbedding: faceResult,
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSuccess("Marked Clock In");
          getMyAttendance();
        } else {
          _handleAttendanceError(
            context,
            response.body?['message'] ?? "Error occurred during clock in",
          );
        }
      } catch (e) {
        debugPrint("Error during clock in: $e");
        showError("Failed to complete clock in process");
      } finally {
        isClockingLoading.value = false;
      }
    } else {
      showError("Face verification cancelled or failed");
    }
  }

  /// Mark user Clock Out
  void clockOut(BuildContext context) async {
    final dynamic faceResult = await Get.to(
          () => const FaceScannerPage(isRegistration: false),
    );

    if (faceResult != null && faceResult is List<double>) {
      isClockingLoading.value = true;
      try {
        Position position = await getCurrentLocation();
        bool isGeofenced = authController.currentUser.value.geofencing ?? false;
        String locationAddress = "";

        if (isGeofenced) {
          bool inRange = isInRange(
            position.latitude,
            position.longitude,
            lat.value,
            long.value,
          );

          if (!inRange) {
            showError("You are not within office premises");
            return;
          }
          locationAddress = authController.currentUser.value.department?.departmentAddress ?? "Office Premises";
        } else {
          locationAddress = await getAddressFromLatLng(
            position.latitude,
            position.longitude,
          );
        }

        Response response = await attendanceRepo.clockOut(
          CheckOutRequestDTO(
            checkOutLocation: locationAddress,
            faceEmbedding: faceResult,
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSuccess("Marked Clock Out");
          getMyAttendance();
        } else {
          _handleAttendanceError(
            context,
            response.body?['message'] ?? "Error occurred during clock out",
          );
        }
      } catch (e) {
        debugPrint("Error during clock out: $e");
        showError("Failed to complete clock out process");
      } finally {
        isClockingLoading.value = false;
      }
    } else {
      showError("Face verification cancelled or failed");
    }
  }

  /// Fetch user attendance and check today's status
  void getMyAttendance() async {
    isAttendanceLoading.value = true;
    try {
      final String userId = authController.currentUser.value.id ?? sharedPreferences.getString("uid") ?? "";

      if (userId.isEmpty) {
        debugPrint("getMyAttendance: No user ID available");
        return;
      }

      log("Fetching attendance for UID: $userId");
      Response response = await attendanceRepo.getMyAttendance(userId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = response.body['data'] ?? [];
        attendance.value = data.map((json) => Attendance.fromJson(json)).toList();

        String today = DateTime.now().toIso8601String().substring(0, 10);
        var todayRecords = attendance.where((record) => record.date == today).toList();

        if (todayRecords.isNotEmpty) {
          final latestRecord = todayRecords.last;

          checkInTime.value = latestRecord.checkInTime ?? "";
          checkInAddress.value = latestRecord.checkInLocation ?? "";

          if (latestRecord.checkOutTime != null && latestRecord.checkOutTime!.isNotEmpty) {
            attendanceStatus.value = "Checked Out";
            isCheckIn.value = true;
            checkOutTime.value = latestRecord.checkOutTime!;
            checkOutAddress.value = latestRecord.checkOutLocation!;
            updateTodayDuration();
            _durationTimer?.cancel();
          } else {
            attendanceStatus.value = "Checked In";
            isCheckIn.value = false;
            checkOutTime.value = "";
            checkOutAddress.value = "";
            updateTodayDuration();
            _startDurationTimer();
          }
        } else {
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
      isAttendanceLoading.value = false;
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateTodayDuration();
    });
  }

  void updateTodayDuration() {
    String today = DateTime.now().toIso8601String().substring(0, 10);
    var todayRecords = attendance.where((record) => record.date == today).toList();

    if (todayRecords.isNotEmpty) {
      final latestRecord = todayRecords.last;
      if (latestRecord.checkInTime != null && latestRecord.checkInTime!.isNotEmpty) {
        DateTime? checkInDateTime = DateTime.tryParse(latestRecord.checkInTime!)?.toLocal();
        if (checkInDateTime != null) {
          if (latestRecord.checkOutTime != null && latestRecord.checkOutTime!.isNotEmpty) {
            DateTime? checkOutDateTime = DateTime.tryParse(latestRecord.checkOutTime!)?.toLocal();
            if (checkOutDateTime != null) {
              todayWorkDuration.value = checkOutDateTime.difference(checkInDateTime);
            }
          } else {
            todayWorkDuration.value = DateTime.now().toLocal().difference(checkInDateTime);
          }
        }
      }
    } else {
      todayWorkDuration.value = Duration.zero;
    }
  }

  /// Calculate total duration from list of attendance records
  String calculateTotalDuration(List<Attendance> attendanceList) {
    int totalMinutes = attendanceList.fold(0, (sum, record) {
      if (record.duration != null && record.duration!.contains(":")) {
        final parts = record.duration!.split(":");
        if (parts.length >= 2) {
          int hours = int.tryParse(parts[0]) ?? 0;
          int minutes = int.tryParse(parts[1]) ?? 0;
          return sum + (hours * 60) + minutes;
        }
      }
      return sum;
    });

    int totalHours = totalMinutes ~/ 60;
    int remainingMinutes = totalMinutes % 60;
    return "${totalHours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}";
  }

  /// Get today’s total work duration
  String getTodayDuration() {
    String today = DateTime.now().toIso8601String().substring(0, 10);
    var todayRecords = attendance.where((record) => record.date == today).toList();
    return calculateTotalDuration(todayRecords);
  }

  /// Get current month's total work duration
  String getMonthlyDuration() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    var monthlyRecords = attendance.where((record) {
      if (record.date == null) return false;
      DateTime? recordDate = DateTime.tryParse(record.date!);
      if (recordDate == null) return false;
      return recordDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    return calculateTotalDuration(monthlyRecords);
  }

  /// Fetch weekly summary records
  Future<void> getMyWeekAttendance() async {
    try {
      isWeeklyAttendanceLoading.value = true;
      final String userId = authController.currentUser.value.id ?? sharedPreferences.getString("uid") ?? "";

      if (userId.isEmpty) {
        debugPrint("getMyWeekAttendance: userId is empty, skipping");
        return;
      }

      Response response = await attendanceRepo.getWeeklyAttendance(userId);
      if (response.statusCode == 200) {
        final List<dynamic> attendanceData = response.body['data'] ?? [];
        final List<AttendanceForWeek> parsedList = List<AttendanceForWeek>.from(
          attendanceData.map((atd) => AttendanceForWeek.fromJson(atd)),
        );
        weeklyAttendance.assignAll(parsedList);
      } else {
        debugPrint("getMyWeekAttendance failed: ${response.statusCode}");
      }
    } catch (err) {
      debugPrint("Exception in getMyWeekAttendance: $err");
    } finally {
      isWeeklyAttendanceLoading.value = false;
    }
  }

  /// Get detailed view of specific attendance record
  Future<void> getAttendanceDetails(String attendanceId) async {
    try {
      isAttendanceDetailsLoading.value = true;
      Response response = await attendanceRepo.getAttendanceDetails(attendanceId);

      if (response.statusCode == 200 && response.body['data'] != null) {
        attendanceDetails.value = AttendanceDetail.fromJson(response.body['data']);
      } else {
        showError(response.body?['message'] ?? "Failed to load details");
      }
    } catch (err) {
      showError("Something went wrong");
      debugPrint("Exception in getAttendanceDetails: $err");
    } finally {
      isAttendanceDetailsLoading.value = false;
    }
  }
}