import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:insta_attend/API/Repository/auth_repository.dart';
import 'package:insta_attend/Utils/toast_messages.dart';

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

}