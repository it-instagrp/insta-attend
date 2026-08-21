import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insta_attend/Utils/unique_id_service.dart';
import 'package:insta_attend/API/DTO/Request/change_password_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/forgot_password_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/login_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/register_request_dto.dart';
import 'package:insta_attend/API/DTO/Request/update_profile_request_dto.dart';
import 'package:insta_attend/API/Repository/auth_repository.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/Model/User.dart';
import 'package:insta_attend/Model/department.dart';
import 'package:insta_attend/Model/designation.dart';
import 'package:insta_attend/Utils/fcm_service.dart';
import 'package:insta_attend/Utils/toast_messages.dart';
import 'package:insta_attend/View/pages/face_scanner_page.dart';
import 'package:insta_attend/View/pages/homescreen.dart';
import 'package:insta_attend/View/pages/login_page.dart';
import 'package:insta_attend/API/DTO/Request/device_change_request_dto.dart';

class AuthController extends GetxController {
  final AuthRepository authRepo;
  AuthController({required this.authRepo});

  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  File? profileImage;

  /******* Loading State Variables *******/
  RxBool isLoading = false.obs;
  RxBool isLoginPageLoading = false.obs;
  RxBool isRegisterPageLoading = false.obs;
  RxBool isForgotPasswordLoading = false.obs;
  RxBool isLogOutLoading = false.obs;
  RxBool isUploadProfileImageLoading = false.obs;
  RxBool isChangePasswordLoading = false.obs;
  RxBool isUpdateProfileLoading = false.obs;
  RxBool isFaceRegisterLoading = false.obs;
  RxBool isDropDownLoading = false.obs;

  /******* Reactive Data Models & State *******/
  var currentUser = User().obs;
  var selectedDepartment = ''.obs;
  var selectedDesignation = ''.obs;
  RxBool isConsentGiven = false.obs;

  RxList<Department> departmentList = <Department>[].obs;
  RxList<Designation> designationList = <Designation>[].obs;
  RxList<double> newFaceEmbedding = <double>[].obs;

  RxBool isLoginFormValid = false.obs;
  RxBool isProfileFormValid = false.obs;
  RxBool hasProfileChanges = false.obs;

  RxString originalFirstName = "".obs;
  RxString originalLastName = "".obs;
  RxString originalEmail = "".obs;
  RxString originalPhone = "".obs;

  // Holds locally picked profile photo for preview/upload
  Rx<File?> pickedProfileImage = Rx<File?>(null);

  /******* Text Editing Controllers *******/
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController forgotPasswordEmailController =
      TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your password";
    }
    return null;
  }

  void checkLoginFormValidity() {
    final emailValid = validateEmail(emailController.text) == null;
    final passwordValid = validatePassword(passwordController.text) == null;
    isLoginFormValid.value = emailValid && passwordValid;
  }

  /// Pick and crop user profile photo with format, resolution, and size validations.
  Future<void> pickProfilePhoto(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return; // User canceled

      final File file = File(pickedFile.path);
      final String extension = pickedFile.path.split('.').last.toLowerCase();
      if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
        showError("Only JPG and PNG format are allowed");
        return;
      }

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square crop
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop Profile Photo",
            toolbarColor: const Color(0xFF5B2ED4),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: "Crop Profile Photo",
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      final File finalFile = File(croppedFile.path);

      // Validate size (max 5 MB)
      final int fileSizeInBytes = await finalFile.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 5) {
        showError("File size exceeds 5 MB : image not uploaded");
        return;
      }

      // Validate resolution (min 800x800)
      final Uint8List imageBytes = await finalFile.readAsBytes();
      final decodedImage = await decodeImageFromList(imageBytes);
      if (decodedImage.width < 800 || decodedImage.height < 800) {
        showError("Image resolution must be at least 800x800");
        return;
      }

      pickedProfileImage.value = finalFile;
      if (pickedProfileImage.value!.path.isNotEmpty) {
        uploadProfilePicture(context);
      }
      checkProfileFromValidity();
      hasProfileChanges.value = true;
    } catch (e) {
      debugPrint("Error picking profile photo: $e");
      showError("Something went wrong while picking the photo");
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required";
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return "Name must contain only letters";
    }
    if (value.trim().length > 50) {
      return "Name is too long";
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return "Phone must contain only digits";
    }
    if (value.trim().length != 10) {
      return "Phone number must be 10 digits";
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter new password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    if (value.length > 12) {
      return "Password must be at most 12 characters";
    }
    return null;
  }

  void snapshotOriginalProfileData() {
    originalFirstName.value = firstNameController.text.trim();
    originalLastName.value = lastNameController.text.trim();
    originalEmail.value = emailController.text.trim();
    originalPhone.value = phoneController.text.trim();
    hasProfileChanges.value = false;
  }

  void checkProfileFromValidity() {
    final firstNameValid = validateName(firstNameController.text) == null;
    final lastNameValid = validateName(lastNameController.text) == null;
    final emailValid = validateEmail(emailController.text) == null;
    final phoneValid = validatePhone(phoneController.text) == null;
    isProfileFormValid.value =
        firstNameValid && lastNameValid && emailValid && phoneValid;

    hasProfileChanges.value =
        firstNameController.text.trim() != originalFirstName.value ||
        lastNameController.text.trim() != originalLastName.value ||
        emailController.text.trim() != originalEmail.value ||
        phoneController.text.trim() != originalPhone.value;
  }

  Future<void> pickAndScanFace(BuildContext context) async {
    final dynamic result = await Get.to(
      () => const FaceScannerPage(isRegistration: true),
    );

    if (result != null && result is List<double>) {
      newFaceEmbedding.value = result;
      showSuccess("Face scanned successfully. Ready to update profile.");
    } else {
      showError("Face scan failed or was cancelled.");
    }
  }

  bool validateRegisterForm(BuildContext context) {
    isRegisterPageLoading.value = true;
    if (usernameController.text.trim().isEmpty) {
      showError("Please enter your name");
      isRegisterPageLoading.value = false;
      return false;
    } else if (emailController.text.trim().isEmpty) {
      showError("Please enter your email");
      isRegisterPageLoading.value = false;
      return false;
    } else if (phoneController.text.trim().isEmpty) {
      showError("Please enter your phone number");
      isRegisterPageLoading.value = false;
      return false;
    } else if (selectedDepartment.value.isEmpty) {
      showError("Please select your department");
      isRegisterPageLoading.value = false;
      return false;
    } else if (selectedDesignation.value.isEmpty) {
      showError("Please select your designation");
      isRegisterPageLoading.value = false;
      return false;
    } else if (passwordController.text.trim().isEmpty) {
      showError("Please enter your password");
      isRegisterPageLoading.value = false;
      return false;
    } else if (confirmPasswordController.text.trim().isEmpty) {
      showError("Please confirm your password");
      isRegisterPageLoading.value = false;
      return false;
    } else if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      showError("Password do not match");
      isRegisterPageLoading.value = false;
      return false;
    } else if (!isConsentGiven.value) {
      showError("Please accept the terms & conditions");
      isRegisterPageLoading.value = false;
      return false;
    }
    return true;
  }

  Future<void> register(BuildContext context) async {
    try {
      final dynamic faceResult = await Get.to(
        () => const FaceScannerPage(isRegistration: true),
      );
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
        // faceEmbedding: faceResult as List<double>?,
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
        await authRepo.sharedPreferences.setString("uid", user.id!);
        clearRegisterForm();
        Get.offAll(() => Homescreen(), transition: Transition.fade);
      } else {
        showError(response.body['message']);
      }
    } catch (err) {
      showError("Something went wrong");
      debugPrint("Internal Exception in register: $err");
    } finally {
      isRegisterPageLoading.value = false;
    }
  }

  Future<void> enrollUserFace(BuildContext context) async {
    try {
      final dynamic faceResult = await Get.to(
        () => const FaceScannerPage(isRegistration: true),
      );

      if (faceResult != null && faceResult is List<double>) {
        isFaceRegisterLoading.value = true;
        final UpdateProfileRequestDTO request = UpdateProfileRequestDTO(
          faceEmbedding: faceResult,
        );

        Response response = await authRepo.updateProfile(
          request,
          currentUser.value.id!,
        );

        if (response.statusCode == 200) {
          currentUser.value.faceEmbedding = faceResult;
          currentUser.value.isEnrolled = true;
          await sharedPreferences.setString(
            "user",
            jsonEncode(currentUser.value.toJson()),
          );
          showSuccess("Face biometric profile updated successfully");
        } else {
          showError(
            response.body?['message'] ??
                "Failed to update face biometric profile",
          );
        }
      } else {
        showError("Face enrollment cancelled or failed");
      }
    } catch (err) {
      showError("Something went wrong during enrollment");
      debugPrint("Exception in enrollUserFace: $err");
    } finally {
      isFaceRegisterLoading.value = false;
    }
  }

  Future<void> login(BuildContext context) async {
    isLoginPageLoading.value = true;
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

        final String deviceImei = await UniqueIdService.getUniqueId();

        final LoginRequestDTO request = LoginRequestDTO(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          fcmToken: fcmToken,
          imeiNumber: deviceImei,
        );

        Response response = await authRepo.login(request);
        var responseBody = response.body;

        if (response.statusCode == 401 &&
            responseBody is Map &&
            responseBody['data'] is Map &&
            responseBody['data']['reason'] == 'DEVICE_CHANGE_REQUIRED') {
          _showDeviceChangeDialog(
            context,
            responseBody['message'] ?? '',
            deviceImei,
          );
          return;
        }

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
          showError(responseBody?['message'] ?? "Login failed");
        }
      }
    } catch (err) {
      showError("Something went wrong");
      if (kDebugMode) debugPrint("Exception in Login: $err");
    } finally {
      isLoginPageLoading.value = false;
    }
  }

  void _showDeviceChangeDialog(
    BuildContext context,
    String message,
    String deviceImei,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("New Device Detected"),
            content: Text(
              message.isNotEmpty
                  ? message
                  : "Do you want to send a request to HR for approval of this new device login?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _sendDeviceChangeRequest(deviceImei);
                },
                child: const Text("Yes"),
              ),
            ],
          ),
    );
  }

  Future<void> _sendDeviceChangeRequest(String deviceImei) async {
    isLoginPageLoading.value = true;
    try {
      final String deviceName = await UniqueIdService.getDeviceName();

      final DeviceChangeRequestDTO request = DeviceChangeRequestDTO(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        imeiNumber: deviceImei,
        deviceName: deviceName,
      );

      final Response response = await authRepo.requestDeviceChange(request);

      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['data'] is Map &&
          response.body['data']['status'] == 'Pending') {
        showSuccess(
          "Request sent to HR. You'll be notified once your new device is approved.",
        );
      } else {
        showError(
          response.body?['message'] ?? "Failed to send device change request",
        );
      }
    } catch (err) {
      showError("Something went wrong while sending the request");
      debugPrint("Exception in _sendDeviceChangeRequest: $err");
    } finally {
      isLoginPageLoading.value = false;
    }
  }

  Future<void> forgotPassword(BuildContext context) async {
    isForgotPasswordLoading.value = true;
    try {
      final ForgotPasswordRequestDto request = ForgotPasswordRequestDto(
        email: forgotPasswordEmailController.text.trim(),
      );
      Response response = await authRepo.forgotPassword(request);
      if (response.statusCode == 200) {
        Get.back();
        showSuccess(
          response.body?['message'] ??
              "If account exists, a reset link has been sent",
        );
        forgotPasswordEmailController.clear();
      } else {
        showError(response.body?['message'] ?? "Unable to send reset link");
      }
    } catch (err) {
      showError("Something went wrong");
      if (kDebugMode) debugPrint("Exception in forgotPassword: $err");
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await sharedPreferences.clear();
      emailController.clear();
      passwordController.clear();
      usernameController.clear();
      phoneController.clear();
      confirmPasswordController.clear();

      Get.offAll(() => LoginPage(), transition: Transition.fade);
      showSuccess("Logged out successfully");
    } catch (err) {
      showError("Something went wrong");
      if (kDebugMode) debugPrint("Exception in logout: $err");
    } finally {
      isLogOutLoading.value = false;
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    isUpdateProfileLoading.value = true;
    try {
      final UpdateProfileRequestDTO request = UpdateProfileRequestDTO(
        username:
            "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        faceEmbedding:
            newFaceEmbedding.isNotEmpty ? newFaceEmbedding.toList() : null,
        profilePhoto: pickedProfileImage.value,
      );

      Response response = await authRepo.updateProfile(
        request,
        currentUser.value.id!,
      );

      if (response.statusCode == 200) {
        newFaceEmbedding.clear();
        pickedProfileImage.value = null;
        showSuccess("Profile Updated Successfully");

        currentUser.value.username = request.username;
        currentUser.value.email = request.email;
        currentUser.value.phoneNumber = request.phoneNumber;

        await sharedPreferences.setString(
          "user",
          jsonEncode(currentUser.value.toJson()),
        );
      } else {
        showError(response.body?['message'] ?? "Failed to update profile");
      }
    } catch (err) {
      showError("Something went wrong");
      debugPrint("Exception in updateProfile: $err");
    } finally {
      isUpdateProfileLoading.value = false;
      Get.back();
    }
  }

  Future<void> changePassword(BuildContext context) async {
    isChangePasswordLoading.value = true;
    try {
      if (passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        Get.back();
        showError("Please enter password");
        return;
      }
      final ChangePasswordRequestDTO request = ChangePasswordRequestDTO(
        currentPassword: passwordController.text.trim(),
        newPassword: confirmPasswordController.text.trim(),
      );
      Response response = await authRepo.changePassword(request);
      if (response.statusCode == 200) {
        Get.back();
        passwordController.clear();
        confirmPasswordController.clear();
        showSuccess("Password Changed Successfully");
      } else {
        showError(response.body?['message'] ?? "Failed to change password");
      }
    } catch (err) {
      showError("Something went wrong");
      debugPrint("Exception in changePassword: $err");
    } finally {
      isChangePasswordLoading.value = false;
    }
  }

  Future<void> uploadProfilePicture(BuildContext context) async {
    try {
      isUploadProfileImageLoading.value = true;

      final String userId = sharedPreferences.getString("uid") ?? "";

      Response response = await authRepo.uploadProfilePicture(
        userId,
        MultipartBody("avatar", XFile(pickedProfileImage.value!.path)),
      );

      if (response.statusCode == 200) {
        showSuccess("Profile picture updated successfully");
      }
    } catch (err) {
      showError("Something went wrong");
      if (kDebugMode) log("Exception in upload profile picture", error: err);
    } finally {
      isUploadProfileImageLoading.value = false;
    }
  }

  void clearLoginForm() {
    emailController.clear();
    passwordController.clear();
  }

  void clearRegisterForm() {
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
    try {
      isDropDownLoading.value = true;
      Response response = await authRepo.getDepartments();
      if (response.statusCode == 200) {
        List<dynamic> dataList = response.body['data'] as List<dynamic>;
        List<Department> departments =
            dataList.map((json) => Department.fromJson(json)).toList();
        departmentList.assignAll(departments);
      }
    } catch (err) {
      if (kDebugMode) debugPrint("Exception in getDepartment: $err");
      showError("Something went wrong");
    } finally {
      isDropDownLoading.value = false;
    }
  }

  Future<void> getDesignation() async {
    isDropDownLoading.value = true;
    try {
      Response response = await authRepo.getDesignations();
      if (response.statusCode == 200) {
        List<dynamic> dataList = response.body['data'] as List<dynamic>;
        List<Designation> designations =
            dataList.map((json) => Designation.fromJson(json)).toList();
        designationList.assignAll(designations);
      }
    } catch (err) {
      if (kDebugMode) debugPrint("Exception in getDesignation: $err");
      showError("Something went wrong");
    } finally {
      isDropDownLoading.value = false;
    }
  }
}
