import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:insta_attend/API/DTO/Request/change_password_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/login_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/register_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/update_profile_request_dto.dart';
import 'package:insta_attend/API/Repository/auth_repository.dart';
import 'package:insta_attend/Model/User.dart';
import 'package:insta_attend/Utils/toast_messages.dart';
import 'package:insta_attend/View/pages/homescreen.dart';
import 'package:insta_attend/View/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/department.dart';
import '../Model/designation.dart';
import '../Utils/fcm_service.dart';
import '../View/pages/face_scanner_page.dart';

class AuthController extends GetxController {
  final AuthRepository authRepo;
  AuthController({required this.authRepo});

  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  File? profileImage;

  RxBool isLoading = false.obs;
  RxBool isDropDownLoading = false.obs;
  var currentUser = User().obs;
  var selectedDepartment = ''.obs;
  var selectedDesignation = ''.obs;
  RxBool isConsentGiven = false.obs;
  RxList<Department> departmentList = <Department>[].obs;
  RxList<Designation> designationList = <Designation>[].obs;
  RxList<double> newFaceEmbedding = <double>[].obs;
  RxBool isLoginFormValid = false.obs;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController forgotPasswordEmailController = TextEditingController();

  String? validateEmail(String? value){
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if(!emailRegex.hasMatch(value.trim())) {
      return "Please enter valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty){
      return "Please enter your password";
    }
    return null;
  }

  void checkLoginFormValidity() {
    final emailValid = validateEmail(emailController.text) == null;
    final passwordValid = validatePassword(passwordController.text) == null;
    isLoginFormValid.value = emailValid && passwordValid;
  }


  Future<void> pickAndScanFace(BuildContext context) async {
    // Navigate to the FaceScannerPage for high-quality embedding extraction
    final dynamic result = await Get.to(() => const FaceScannerPage(isRegistration: true));

    if (result != null && result is List<double>) {
      // Store the 192-dimension embedding for the profile update
      // Assuming you have a variable to hold the new embedding in your controller
      newFaceEmbedding.value = result;
      showSuccess("Face scanned successfully. Ready to update profile.");
    } else {
      showError("Face scan failed or was cancelled.");
    }
  }

  bool validateRegisterForm(BuildContext context) {
    isLoading.value = true;
    if (usernameController.text.trim().isEmpty) {
      showError("Please enter your name");
      isLoading.value = false;
      return false;
    } else if (emailController.text.trim().isEmpty) {
      showError("Please enter your email");
      isLoading.value = false;
      return false;
    } else if (phoneController.text.trim().isEmpty) {
      showError("Please enter your phone number");
      isLoading.value = false;
      return false;
    } else if (passwordController.text.trim().isEmpty) {
      showError("Please enter your password");
      isLoading.value = false;
      return false;
    } else if (confirmPasswordController.text.trim().isEmpty) {
      showError("Please confirm your password");
      isLoading.value = false;
      return false;
    } else if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      showError("Password do not match");
      isLoading.value = false;
      return false;
    } else if (!isConsentGiven.value) {
      showError("Please accept the terms & conditions");
      isLoading.value = false;
      return false;
    } else {
      return true;
    }
  }

  Future<void> register(BuildContext context) async {
    try {
      final dynamic faceResult = await Get.to(() => FaceScannerPage(isRegistration: true));
      if (faceResult == null) {
        showError("Face enrollment is required to register");
        return;
      }
      final RegisterRequestDTO request = RegisterRequestDTO(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        department_id: selectedDepartment.value,
        password: passwordController.text.trim(),
        designation_id: selectedDesignation.value,
        faceEmbedding: faceResult as List<double>?
      );

      Response response = await authRepo.register(request);
      if (response.statusCode == 201) {
        showSuccess("Registered Successfully");
        final User user = User.fromJson(response.body['data']['user']);
        currentUser.value = user;
        final String token = response.body['data']['token'];
        authRepo.apiClient.updateHeader(token);
        await authRepo.sharedPreferences.setString("token", token);
        await authRepo.sharedPreferences.setString(
          "user",
          jsonEncode(user.toJson()),
        );
        clearRegisterForm();
        Get.offAll(() => Homescreen(), transition: Transition.fade);
      } else {
        showError(response.body['message']);
      }
    } catch (err) {
      showError("Something went wrong");
      print("Internal Exception: ${err.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enrollUserFace(BuildContext context) async {
    try {
      final dynamic faceResult = await Get.to(() => const FaceScannerPage(isRegistration: true));

      if (faceResult != null && faceResult is List<double>) {
        isLoading.value = true;
        final UpdateProfileRequestDTO request = UpdateProfileRequestDTO(
          faceEmbedding: faceResult,
        );

        Response response = await authRepo.updateProfile(request, currentUser.value.id!);

        if (response.statusCode == 200) {
          currentUser.value.faceEmbedding = faceResult;
          currentUser.value.isEnrolled = true;
          await sharedPreferences.setString("user", jsonEncode(currentUser.value.toJson()));
          showSuccess("Face biometric profile updated successfully");
        } else {
          showError(response.body['message'] ?? "Failed to update face biometric profile");
        }
      } else {
        showError("Face enrollment cancelled or failed");
      }
    } catch (err) {
      showError("Something went wrong during enrollment");
      debugPrint("Exception in enrollUserFace: ${err.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(BuildContext context) async {
    isLoading.value = true;
    try {
      if (emailController.text.isEmpty) {
        showError("Please enter email");
      } else if (passwordController.text.isEmpty) {
        showError("Please enter password");
      } else {
        String? fcmToken;
        try {
          fcmToken = await FCMService.getFCMToken().timeout(
            const Duration(seconds: 3),
          );
        } catch (e) {
          debugPrint("FCM Token retrieval timed out or failed: $e");
        }

        final LoginRequestDTO request = LoginRequestDTO(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          fcmToken: fcmToken, // Pass token to request
        );

        Response response = await authRepo.login(request);
        var responseBody = response.body;

        if (response.statusCode == 200) {
          showSuccess("Login Successful");
          final String userToken = responseBody['data']['token'];
          final String user = jsonEncode(responseBody['data']['user']);
          currentUser.value = User.fromJson(responseBody['data']['user']);
          authRepo.apiClient.updateHeader(userToken);
          await authRepo.sharedPreferences.setString("token", userToken);
          await authRepo.sharedPreferences.setString("user", user);
          await authRepo.sharedPreferences.setString(
            "uid",
            responseBody['data']['user']['id'],
          );
          clearLoginForm();
          Get.offAll(() => Homescreen(), transition: Transition.fade);
        } else {
          showError(responseBody['message']);
        }
      }
    } catch (err) {
      showError("Something went wrong");
      if (kDebugMode) print("Exception in Login: ${err.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(BuildContext context) async {
    //To be implemented in backend
  }

  Future<void> logout(BuildContext context) async {
    try {
      await sharedPreferences.clear().then((_){
        print("Shared Preferences cleared");
      });
      emailController.clear();
      passwordController.clear();
      usernameController.clear();
      phoneController.clear();
      confirmPasswordController.clear();
      Get.offAll(() => LoginPage(), transition: Transition.fade);
      showSuccess("logged out");
    } catch (err) {
      showError("Something went wrong");
      if (kDebugMode) print("Exception: ${err.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    isLoading.value = true;
    try {
      final UpdateProfileRequestDTO request = UpdateProfileRequestDTO(
          username: "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
          email: emailController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          faceEmbedding: newFaceEmbedding.isNotEmpty ? newFaceEmbedding.toList() : null
      );

      Response response = await authRepo.updateProfile(
          request,
          currentUser.value.id!
      );

      if (response.statusCode == 200) {
        newFaceEmbedding.clear();
        showSuccess("Profile Updated Successfully");

        // Update local currentUser data so the UI reflects changes immediately
        currentUser.value.username = request.username;
        currentUser.value.email = request.email;
        currentUser.value.phoneNumber = request.phoneNumber;

        // Update session storage
        await sharedPreferences.setString("user", jsonEncode(currentUser.value.toJson()));
      } else {
        showError(response.body['message']);
      }
    } catch (err) {
      showError("Something went wrong");
      print("Exception: " + err.toString());
    } finally {
      isLoading.value = false;
      Get.back();
    }
  }

  Future<void> changePassword(BuildContext context) async{
    isLoading.value = true;
    try{
      if(passwordController.text.isEmpty || confirmPasswordController.text.isEmpty){
        Get.back();
        showError("Please enter password");
        return;
      }
      final ChangePasswordRequestDTO request = ChangePasswordRequestDTO(
        currentPassword: passwordController.text.trim(),
        newPassword: confirmPasswordController.text.trim(),
      );
      Response response = await authRepo.changePassword(request);
      if(response.statusCode == 200){
        Get.back();
        passwordController.clear();
        confirmPasswordController.clear();
        showSuccess("Password Changed Successfully");
      }else{
        showError(response.body['message']);
      }
    }catch(err){
      showError("Something went wrong");
      print("Exception: " + err.toString());
    }finally{
      isLoading.value = false;
    }
  }
  void clearLoginForm(){
    emailController.clear();
    passwordController.clear();
  }
  void clearRegisterForm(){
    usernameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedDesignation.value = '';
    selectedDepartment.value = '';
    isConsentGiven.value = false;
  }


  Future<void> getDepartment() async {
    try{
      Response response = await authRepo.getDepartments();
      isDropDownLoading.value = true;
      if(response.statusCode == 200){
        List<dynamic> dataList = response.body['data'] as List<dynamic>;
        List<Department> departments = dataList.map((json) => Department.fromJson(json)).toList();
        departmentList.assignAll(departments);
      }
    }catch (err){
      if (kDebugMode) print("Exception: ${err.toString()}");
      showError("Something went wrong");
    }finally{
      isDropDownLoading.value = false;
    }
  }

  Future<void> getDesignation() async {
    isDropDownLoading.value = true;
    try{
      Response response = await authRepo.getDesignations();
      if(response.statusCode == 200){
        List<dynamic> dataList = response.body['data'] as List<dynamic>;
        List<Designation> designations = dataList.map((json) => Designation.fromJson(json)).toList();
        designationList.assignAll(designations);
      }
    }catch (err){
      if (kDebugMode) print("Exception: ${err.toString()}");
      showError("Something went wrong");
    }finally{
      isDropDownLoading.value = false;
    }
  }
}
