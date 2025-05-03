import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:insta_attend/API/DTO/Request/login_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/register_request_dto.dart';
import 'package:insta_attend/API/Repository/auth_repository.dart';
import 'package:insta_attend/Model/User.dart';
import 'package:insta_attend/Utils/toast_messages.dart';
import 'package:insta_attend/View/pages/homescreen.dart';

class AuthController extends GetxController{

  final AuthRepository authRepo;
  AuthController({required this.authRepo});

  RxBool isLoading = false.obs;


  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  var selectedDepartment = ''.obs;
  RxBool isConsentGiven = false.obs;


  bool validateRegisterForm(BuildContext context){
    isLoading.value = true;
    if(usernameController.text.trim().isEmpty){
      showError(context, "Please enter your name");
      isLoading.value = false;
      return false;
    }else if(emailController.text.trim().isEmpty){
      showError(context, "Please enter your email");
      isLoading.value = false;
      return false;
    } else if(phoneController.text.trim().isEmpty){
      showError(context, "Please enter your phone number");
      isLoading.value = false;
      return false;
    } else if(passwordController.text.trim().isEmpty){
      showError(context, "Please enter your password");
      isLoading.value = false;
      return false;
    } else if(confirmPasswordController.text.trim().isEmpty){
      showError(context, "Please confirm your password");
      isLoading.value = false;
      return false;
    } else if(passwordController.text.trim() != confirmPasswordController.text.trim()){
      showError(context, "Password do not match");
      isLoading.value = false;
      return false;
    } else if(!isConsentGiven.value){
      showError(context, "Please accept the terms & conditions");
      isLoading.value = false;
      return false;
    } else {
      return true;
    }
  }

  Future<void> register(BuildContext context) async{
    try{
      final RegisterRequestDTO request = RegisterRequestDTO(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        circle: selectedDepartment.value,
        password: passwordController.text.trim(),
        role: "user"
      );

      Response response = await authRepo.register(request);
      if(response.statusCode == 201){
        showSuccess(context, "Registered Successfully");
        final User user = User.fromJson(response.body['data']['user']);
        final String token = response.body['data']['token'];
        authRepo.apiClient.updateHeader(token);
        await authRepo.sharedPreferences.setString("token", token);
        await authRepo.sharedPreferences.setString("user", jsonEncode(user.toJson()));
        Get.offAll(()=>Homescreen(), transition: Transition.fadeIn);
      } else {
        showError(context, response.body['message']);
      }
    }catch(err){
      showError(context, "Something went wrong");
      print("Internal Exception: ${err.toString()}");
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> login(BuildContext context) async{
    isLoading.value = true;
    try{
      if(emailController.text.isEmpty) {
        showError(context, "Please enter email");
      }else if(passwordController.text.isEmpty) {
        showError(context, "Please enter password");
      } else {
        final LoginRequestDTO request = LoginRequestDTO(
            email: emailController.text.trim(),
            password: passwordController.text.trim()
        );

        Response response = await authRepo.login(request);
        var responseBody = response.body;
        if(response.statusCode == 200){
          showSuccess(context, "Login Successful");
          final String userToken = responseBody['data']['token'];
          final String user = jsonEncode(responseBody['data']['user']);
          authRepo.apiClient.updateHeader(userToken);
          await authRepo.sharedPreferences.setString("token", userToken);
          await authRepo.sharedPreferences.setString("user", user);
          Get.offAll(()=>Homescreen(), transition: Transition.fadeIn);
        } else {
          showError(context, responseBody['message']);
        }
      }
    }catch(err){
      showError(context, "Somethings went wrong");
      if(kDebugMode)print("Exception in Login: ${err.toString()}");
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(BuildContext context) async{
    //To be implemented in backend
  }

}