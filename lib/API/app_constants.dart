import 'package:flutter/material.dart';

final String token = "token";
final String uid = "uid";


/**** Global Context ****/
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();


/**** URLs ****/
// final String appBaseUrl = "https://api.ams.instagrp.in/api/";
final String appBaseUrl = "http://192.168.1.28:8081/api/";

//TODO
// https://api.ams.instagrp.in/api/delete-my-account create this url page to host a html which will allow user to request deletion of his account

/**** Auth URLs ****/
final String registerUrl = "auth/register";
final String loginUrl = "auth/login";
final String meUrl = "auth/me";
final String profileUrl = "auth/profile";
final String uploadProfilePictureUrl = "auth/avatar";
final String forgotPasswordUrl = "auth/forgot-password";
final String changePasswordUrl = "auth/change-password";
final String getDesignationUrl = "designation";
final String getDepartmentUrl = "department";
final String updateProfileUrl = "users";



/**** Attendance URLs ****/
final String checkInUrl = "attendance/check-in";
final String checkOutUrl = "attendance/check-out";
String attendanceByIdUrl(String id) => "attendance/${id}";
// String getWeeklyAttendanceUrl(String userId) {
//   return 'attendance/weekly/${userId}';
// }
String getWeeklyAttendanceUrl(String userId) => 'attendance/weekly/$userId';
String getAttendanceDetailUrl(String attendanceId) => 'attendance/record/$attendanceId';

/**** Departments URLs ****/
final String getDepartments = "department";



/**** Leave URLs ****/
String getMyLeaves(String id)=>"leave/${id}";
final String applyLeave = "leave";


/**** Version URLs ****/
final String versionUrl = "version";


/**** Assets URLs ****/
String getMyAssetsUrl(String id) => "asset/$id";


/**** Expense URLs ****/
final String createExpenseUrl = "expense";
String getMyExpenseUrl({int pageNumber=1, int pageSize = 10}) => "expense/my?pageNumber=${pageNumber}&pageSize=${pageSize}";
String updateMyExpenseUrl(String id) => "expense/$id";
String deleteMyExpenseUrl(String id) => "expense/$id";
final String getMyStatsUrl = "expense/stats";
