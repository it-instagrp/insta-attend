import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:insta_attend/Model/Attendance.dart';
import 'package:insta_attend/Model/attendance_detail.dart';
// ============================================================
// OLD/UNUSED - replaced by DTO-based summary/details parsing below
// ============================================================
// import 'package:insta_attend/Model/attendance_summary.dart';
// import 'package:insta_attend/Model/attendance_detail_row.dart';
// import 'package:insta_attend/API/attendance_repository.dart';
import 'package:insta_attend/Utils/toast_messages.dart';
import '../API/DTO/Request/check_in_request_dto.dart';
import '../API/Repository/attendance_repository.dart';
import '../API/DTO/Response/attendance_summary_dto.dart';
import '../API/DTO/Response/attendance_details_dto.dart';
import '../Constant/constant_color.dart';
import '../Model/attendance_summary_model.dart';
import '../View/pages/face_scanner_page.dart';
import 'package:insta_attend/API/DTO/Request/check_out_request_dto.dart';

class AttendanceController extends GetxController {
  // --- Direct Dio HTTP Setup ---
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.ams.instagrp.in/api/', // TODO: Replace with your actual base URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final AuthController authController = Get.find<AuthController>();
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  // NEW: repository for Attendance Details & Summary screen (matches app-wide ApiClient/Repository pattern)
  final AttendanceRepository attendanceRepository = Get.find<AttendanceRepository>();

  // Fallback office coordinates
  final RxDouble lat = 18.483669.obs;
  final RxDouble long = 73.809200.obs;

  // Reactive State Variables
  final RxList<Attendance> attendance = <Attendance>[].obs;
  final RxBool isAttendanceLoading = false.obs;
  final RxBool isClockingLoading = false.obs;
  final RxBool isWeeklyAttendanceLoading = false.obs;
  final RxBool isAttendanceDetailsLoading = false.obs;
  final RxBool isExporting = false.obs;

  final RxString attendanceStatus = "No Check-in".obs;
  final RxString checkInTime = "".obs;
  final RxString checkOutTime = "".obs;
  final RxString checkInAddress = "".obs;
  final RxString checkOutAddress = "".obs;
  final RxBool isCheckIn = true.obs;

  final Rx<Duration> todayWorkDuration = Duration.zero.obs;
  Timer? _durationTimer;

  // ============================================================
  // OLD HOME SCREEN WEEKLY ATTENDANCE FEATURE
  // COMMENTED OUT - KEPT FOR ROLLBACK/REFERENCE
  // Not used by AttendanceOverviewPage (new screen); only used by old Home screen.
  // ============================================================
  // final RxList<AttendanceForWeek> weeklyAttendance = <AttendanceForWeek>[].obs;
  final Rxn<AttendanceDetail> attendanceDetails = Rxn<AttendanceDetail>();
  final Rxn<Attendance> selectedDateAttendance = Rxn<Attendance>();
  final RxBool isSelectedDateLoading = false.obs;

  // Claude's added map/summary structures
  final RxMap<String, String> attendanceStatusMap = <String, String>{}.obs;
  final RxInt presentDays = 0.obs;
  final RxInt halfDays = 0.obs;
  final RxInt absentDays = 0.obs;

  // NEW: Attendance Details & Summary screen state
  final Rxn<AttendanceSummary> attendanceSummary = Rxn<AttendanceSummary>();
  final RxList<AttendanceDetailsRecordDto> attendanceDetailRows = <AttendanceDetailsRecordDto>[].obs;
  final RxBool isSummaryLoading = false.obs;
  final RxBool isDetailsListLoading = false.obs;
  final RxString selectedFilter = "this_month".obs; // this_month | last_15_days | last_30_days | custom

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

  // ==========================================
  // LOCATION & HELPER METHODS
  // ==========================================

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

  bool isInRange(double userLat, double userLng, double geoLat, double geoLng, {double maxDistanceMeters = 200.0}) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      geoLat,
      geoLng,
    );
    return distanceInMeters <= maxDistanceMeters;
  }

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

  // ==========================================
  // CLOCK IN & CLOCK OUT LOGIC
  // ==========================================

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

        // final response = await _dio.post(
        //   '/attendance/clock-in',
        //   data: {
        //     'latitude': position.latitude,
        //     'longitude': position.longitude,
        //     'checkInLocation': locationAddress,
        //     'faceEmbedding': faceResult,
        //     'timestamp': DateTime.now().toIso8601String(),
        //   },
        // );
        //
        // if (response.statusCode == 200 || response.statusCode == 201) {
        //   showSuccess("Marked Clock In");
        //   getMyAttendance();
        // } else {
        //   String msg = "Error occurred during clock in";
        //   if (response.data is Map && response.data['message'] != null) {
        //     msg = response.data['message'];
        //   }
        //   _handleAttendanceError(context, msg);
        // }
        final CheckInRequestDTO request = CheckInRequestDTO(
          checkInLocation: locationAddress,
          faceEmbedding: faceResult,
        );

        final response = await attendanceRepository.clockIn(request);

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSuccess("Marked Clock In");
          getMyAttendance();
        } else {
          String msg = "Error occurred during clock in";
          if (response.body is Map && response.body['message'] != null) {
            msg = response.body['message'];
          }
          _handleAttendanceError(context, msg);
        }
      } on DioException catch (e) {
        debugPrint("Dio error during clock in: $e");
        String errorMsg = "Failed to complete clock in process";
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          errorMsg = e.response?.data['message'];
        }
        _handleAttendanceError(context, errorMsg);
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

        final CheckOutRequestDTO request = CheckOutRequestDTO(
          checkOutLocation: locationAddress,
          faceEmbedding: faceResult,
        );

        final response = await attendanceRepository.clockOut(request);

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSuccess("Marked Clock Out");
          getMyAttendance();
        } else {
          String msg = "Error occurred during clock out";
          if (response.body is Map && response.body['message'] != null) {
            msg = response.body['message'];
          }
          _handleAttendanceError(context, msg);
        }
      } on DioException catch (e) {
        debugPrint("Dio error during clock out: $e");
        String errorMsg = "Failed to complete clock out process";
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          errorMsg = e.response?.data['message'];
        }
        _handleAttendanceError(context, errorMsg);
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

  // ==========================================
  // FETCHING DATA & EXPORTS
  // ==========================================

  void getMyAttendance() async {
    isAttendanceLoading.value = true;
    try {
      final String userId = authController.currentUser.value.id ?? sharedPreferences.getString("uid") ?? "";

      if (userId.isEmpty) {
        debugPrint("getMyAttendance: No user ID available");
        return;
      }

      log("Fetching attendance for UID: $userId");
      final response = await attendanceRepository.getMyAttendance(userId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = [];
        if (response.body is Map && response.body['data'] != null) {
          data = response.body['data'];
        }

        attendance.value = data.map((json) => Attendance.fromJson(json)).toList();

        _calculateSummary();
        _generateStatusMap();

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

  void _calculateSummary() {
    int p = 0, h = 0, a = 0;
    for (var record in attendance) {
      final status = (record.status ?? '').toLowerCase();
      if (status.contains('present') && !status.contains('half')) {
        p++;
      } else if (status.contains('half')) {
        h++;
      } else if (status.contains('absent')) {
        a++;
      }
    }
    presentDays.value = p;
    halfDays.value = h;
    absentDays.value = a;
  }

  void _generateStatusMap() {
    final map = <String, String>{};
    for (var record in attendance) {
      if (record.date != null && record.status != null) {
        final dateString = record.date!.split(' ')[0];
        map[dateString] = record.status!;
      }
    }
    attendanceStatusMap.value = map;
  }

  // ============================================================
  // OLD HOME SCREEN WEEKLY ATTENDANCE FEATURE
  // COMMENTED OUT - KEPT FOR ROLLBACK/REFERENCE
  // ============================================================
  // Future<void> getMyWeekAttendance() async {
  //   try {
  //     isWeeklyAttendanceLoading.value = true;
  //     final String userId = authController.currentUser.value.id ?? sharedPreferences.getString("uid") ?? "";
  //
  //     if (userId.isEmpty) {
  //       debugPrint("getMyWeekAttendance: userId is empty, skipping");
  //       return;
  //     }
  //
  //     final response = await _dio.get('/attendance/weekly/$userId');
  //     if (response.statusCode == 200) {
  //       List<dynamic> attendanceData = [];
  //       if (response.data is Map && response.data['data'] != null) {
  //         attendanceData = response.data['data'];
  //       }
  //
  //       final List<AttendanceForWeek> parsedList = List<AttendanceForWeek>.from(
  //         attendanceData.map((atd) => AttendanceForWeek.fromJson(atd)),
  //       );
  //       weeklyAttendance.assignAll(parsedList);
  //     } else {
  //       debugPrint("getMyWeekAttendance failed: ${response.statusCode}");
  //     }
  //   } catch (err) {
  //     debugPrint("Exception in getMyWeekAttendance: $err");
  //   } finally {
  //     isWeeklyAttendanceLoading.value = false;
  //   }
  // }

  Future<void> getAttendanceDetails(String attendanceId) async {
    try {
      isAttendanceDetailsLoading.value = true;
      attendanceDetails.value = null;

      final response =
      await attendanceRepository.getAttendanceDetails(attendanceId);

      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['data'] != null) {
        attendanceDetails.value =
            AttendanceDetail.fromJson(response.body['data']);
      } else {
        showError(response.statusText ?? 'Failed to load attendance details');
      }
    } catch (err) {
      debugPrint('Exception in getAttendanceDetails: $err');
      showError('Something went wrong while loading attendance details');
    } finally {
      isAttendanceDetailsLoading.value = false;
    }
  }

  // NEW: Attendance Details & Summary screen (self-only, date-range filtered, via AttendanceRepository)
  Future<void> fetchAttendanceSummary({
    String filter = "this_month",
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    isSummaryLoading.value = true;
    try {
      selectedFilter.value = filter;
      final response = await attendanceRepository.getAttendanceSummary(
        filter: filter,
        startDate: startDate?.toIso8601String().substring(0, 10),
        endDate: endDate?.toIso8601String().substring(0, 10),
      );

      if (response.statusCode == 200 && response.body is Map && response.body['data'] != null) {
        final AttendanceSummaryDto dto = AttendanceSummaryDto.fromJson(response.body['data']);

        final int present = dto.presentCount ?? 0;

        final int half = dto.halfDayCount ?? 0;
        final int absent = dto.absentCount ?? 0;
        final int offHoliday = dto.weeklyOffHolidayCount ?? 0;

        attendanceSummary.value = AttendanceSummary(
          presentDays: present,
          halfDays: half,
          absentDays: absent,
          totalDays: present + half + absent + offHoliday,
        );
      } else {
        showError(response.statusText ?? "Failed to load attendance summary");
      }
    } catch (err) {
      showError("Something went wrong while loading attendance summary");
      debugPrint("Exception in fetchAttendanceSummary: $err");
    } finally {
      isSummaryLoading.value = false;
    }
  }

  Future<void> fetchAttendanceDetailsList({
    String filter = "this_month",
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    isDetailsListLoading.value = true;
    try {
      selectedFilter.value = filter;
      final response = await attendanceRepository.getAttendanceDetailsList(
        filter: filter,
        startDate: startDate?.toIso8601String().substring(0, 10),
        endDate: endDate?.toIso8601String().substring(0, 10),
      );

      if (response.statusCode == 200 && response.body is Map && response.body['data'] != null) {
        final AttendanceDetailsDto dto = AttendanceDetailsDto.fromJson(response.body['data']);
        attendanceDetailRows.value = dto.records ?? [];
        _generateStatusMapFromDetailRows(attendanceDetailRows);
      } else {
        showError(response.statusText ?? "Failed to load attendance details");
      }
    } catch (err) {
      showError("Something went wrong while loading attendance details");
      debugPrint("Exception in fetchAttendanceDetailsList: $err");
    } finally {
      isDetailsListLoading.value = false;
    }
  }

  void _generateStatusMapFromDetailRows(
    Iterable<AttendanceDetailsRecordDto> records,
  ) {
    final map = <String, String>{};

    for (final record in records) {
      if (record.date != null && record.status != null) {
        final parsedDate = DateTime.tryParse(record.date!);
        final dateString = parsedDate != null
            ? parsedDate.toIso8601String().substring(0, 10)
            : record.date!.split(' ')[0];

        map[dateString] = record.status!;
      }
    }

    attendanceStatusMap.value = map;
  }

  Future<void> exportAttendancePDF({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      isExporting.value = true;
      final response = await _dio.post(
        '/attendance/export/pdf',
        data: {
          'from': startDate.toIso8601String(),
          'to': endDate.toIso8601String(),
        },
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        showSuccess('PDF exported successfully');
      } else {
        showError('Failed to export PDF');
      }
    } catch (e) {
      showError('Error exporting PDF: $e');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportAttendanceExcel({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      isExporting.value = true;
      final response = await _dio.post(
        '/attendance/export/excel',
        data: {
          'from': startDate.toIso8601String(),
          'to': endDate.toIso8601String(),
        },
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        showSuccess('Excel exported successfully');
      } else {
        showError('Failed to export Excel');
      }
    } catch (e) {
      showError('Error exporting Excel: $e');
    } finally {
      isExporting.value = false;
    }
  }
  Future<void> fetchAttendanceForDate(String date) async {
    isSelectedDateLoading.value = true;
    selectedDateAttendance.value = null;
    try {
      final String userId = authController.currentUser.value.id ?? sharedPreferences.getString("uid") ?? "";
      final response = await attendanceRepository.getMyAttendance(userId);

      if (response.statusCode == 200 && response.body is Map && response.body['data'] != null) {
        final List<Attendance> records = (response.body['data'] as List)
            .map((j) => Attendance.fromJson(j)).toList();
        selectedDateAttendance.value = records.firstWhereOrNull((r) => r.date == date);
        if (selectedDateAttendance.value == null) {
          showError("No detailed record found for this date");
        }
      } else {
        showError(response.statusText ?? "Failed to load attendance details");
      }
    } catch (err) {
      showError("Something went wrong while loading attendance details");
    } finally {
      isSelectedDateLoading.value = false;
    }
  }

  // ==========================================
  // DURATION CALCULATIONS
  // ==========================================

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

  String getTodayDuration() {
    String today = DateTime.now().toIso8601String().substring(0, 10);
    var todayRecords = attendance.where((record) => record.date == today).toList();
    return calculateTotalDuration(todayRecords);
  }

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
}
