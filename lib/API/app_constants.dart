final String token = "token";
final String uid = "uid";


/**** URLs ****/
final String appBaseUrl = "https://api.instaams.instagrp.in/api/";
// final String appBaseUrl = "http://192.168.1.26:8081/api/";

/**** Auth URLs ****/
final String registerUrl = "auth/register";
final String loginUrl = "auth/login";
final String meUrl = "auth/me";
final String profileUrl = "auth/profile";
final String forgotPasswordUrl = "auth/forgot-password";
final String changePasswordUrl = "auth/change-password";
final String getDesignationUrl = "designation";
final String getDepartmentUrl = "department";
final String updateProfileUrl = "users";


/**** Attendance URLs ****/
final String checkInUrl = "attendance/check-in";
final String checkOutUrl = "attendance/check-out";
String attendanceByIdUrl(String id) => "attendance/${id}";


/**** Departments URLs ****/
final String getDepartments = "department";



/**** Leave URLs ****/
String getMyLeaves(String id)=>"leave/${id}";
final String applyLeave = "leave";


/**** Version URLs ****/
final String versionUrl = "version";


/**** Assets URLs ****/
String getMyAssetsUrl(String id) => "asset/$id";
