import 'dart:convert';

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

import '../Model/department.dart';
import '../Model/designation.dart';

class AuthController extends GetxController {
  final AuthRepository authRepo;
  AuthController({required this.authRepo});

  RxBool isLoading = false.obs;
  RxBool isDropDownLoading = false.obs;
  var currentUser = User().obs;
  var selectedDepartment = ''.obs;
  var selectedDesignation = ''.obs;
  RxBool isConsentGiven = false.obs;
  RxList<Department> departmentList = <Department>[].obs;
  RxList<Designation> designationList = <Designation>[].obs;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool validateRegisterForm(BuildContext context) {
    isLoading.value = true;
    if (usernameController.text.trim().isEmpty) {
      showError(context, "Please enter your name");
      isLoading.value = false;
      return false;
    } else if (emailController.text.trim().isEmpty) {
      showError(context, "Please enter your email");
      isLoading.value = false;
      return false;
    } else if (phoneController.text.trim().isEmpty) {
      showError(context, "Please enter your phone number");
      isLoading.value = false;
      return false;
    } else if (passwordController.text.trim().isEmpty) {
      showError(context, "Please enter your password");
      isLoading.value = false;
      return false;
    } else if (confirmPasswordController.text.trim().isEmpty) {
      showError(context, "Please confirm your password");
      isLoading.value = false;
      return false;
    } else if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      showError(context, "Password do not match");
      isLoading.value = false;
      return false;
    } else if (!isConsentGiven.value) {
      showError(context, "Please accept the terms & conditions");
      isLoading.value = false;
      return false;
    } else {
      return true;
    }
  }

  Future<void> register(BuildContext context) async {
    try {
      final RegisterRequestDTO request = RegisterRequestDTO(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        department_id: selectedDepartment.value,
        password: passwordController.text.trim(),
        designation_id: selectedDesignation.value,
      );

      Response response = await authRepo.register(request);
      if (response.statusCode == 201) {
        showSuccess(context, "Registered Successfully");
        final User user = User.fromJson(response.body['data']['user']);
        currentUser.value = user;
        final String token = response.body['data']['token'];
        authRepo.apiClient.updateHeader(token);
        await authRepo.sharedPreferences.setString("token", token);
        await authRepo.sharedPreferences.setString(
          "user",
          jsonEncode(user.toJson()),
        );
        Get.offAll(() => Homescreen(), transition: Transition.fade);
      } else {
        showError(context, response.body['message']);
      }
    } catch (err) {
      showError(context, "Something went wrong");
      print("Internal Exception: ${err.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(BuildContext context) async {
    isLoading.value = true;
    try {
      if (emailController.text.isEmpty) {
        showError(context, "Please enter email");
      } else if (passwordController.text.isEmpty) {
        showError(context, "Please enter password");
      } else {
        final LoginRequestDTO request = LoginRequestDTO(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Response response = await authRepo.login(request);
        var responseBody = response.body;
        if (response.statusCode == 200) {
          showSuccess(context, "Login Successful");
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
          Get.offAll(() => Homescreen(), transition: Transition.fade);
        } else {
          showError(context, responseBody['message']);
        }
      }
    } catch (err) {
      showError(context, "Somethings went wrong");
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
      authRepo.sharedPreferences.clear();
      Get.offAll(() => LoginPage(), transition: Transition.fade);
      showSuccess(context, "logged out");
    } catch (err) {
      showError(context, "Something went wrong");
      if (kDebugMode) print("Exception: ${err.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    isLoading.value = true;
    try {
      final UpdateProfileRequestDTO request = UpdateProfileRequestDTO(
        username:
            "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );
      Response response = await authRepo.updateProfile(
        request,
        currentUser.value.id!,
      );

      if (response.statusCode == 200) {
        showSuccess(context, "Profile Updated Successfully");
      } else {
        showError(context, response.body['message']);
      }
    } catch (err) {
      showError(context, "Something went wrong");
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
        showError(context, "Please enter password");
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
        showSuccess(context, "Password Changed Successfully");
      }else{
        showError(context, response.body['message']);
      }
    }catch(err){
      showError(context, "Something went wrong");
      print("Exception: " + err.toString());
    }finally{
      isLoading.value = false;
    }
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
      showError(Get.context!, "Something went wrong");
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
      showError(Get.context!, "Something went wrong");
    }finally{
      isDropDownLoading.value = false;
    }
  }
}
