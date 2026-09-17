import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_attend/Constant/constant_color.dart';
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
import 'package:insta_attend/Model/approval_status.dart';
import 'package:insta_attend/Model/organization.dart';
import 'package:insta_attend/Constant/mock_data.dart';
import 'package:toastification/toastification.dart';
import 'package:insta_attend/Component/Cards/pending_approval_dialog.dart';

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
  Worker? _searchDebouncer;

  /******* Organization & Country Code State *******/
  RxList<Organization> organizationList = <Organization>[].obs;
  Rx<Organization?> selectedOrganization = Rx<Organization?>(null);
  RxBool isOrganizationSearchLoading = false.obs;
  RxString organizationSearchQuery = ''.obs;

  RxList<Map<String, String>> countryCodeList = <Map<String, String>>[].obs;
  Rx<Map<String, String>?> selectedCountryCode = Rx<Map<String, String>?>(null);

  final TextEditingController organizationSearchController = TextEditingController();

  /******* Approval Status State *******/
  Rx<ApprovalStatus> userApprovalStatus = ApprovalStatus.pending.obs;
  RxString registrationId = ''.obs;

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
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController forgotPasswordEmailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Initialize country codes from mock data
    countryCodeList.assignAll(MockData.mockCountryCodes);
    if (countryCodeList.isNotEmpty) {
      selectedCountryCode.value = countryCodeList[0];
    }
    // Load approval status from local storage
    loadApprovalStatus();

    _searchDebouncer = debounce(organizationSearchQuery, (query) => searchOrganizations(query), time: const Duration(milliseconds: 350),);
  }
  @override
  void onClose() {
    _searchDebouncer?.dispose();
    super.onClose();
  }

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

  /// Search organizations from mock data
  Future<void> searchOrganizations(String query) async {
    try {
      final trimmedQuery = query.trim();
      organizationSearchQuery.value = trimmedQuery;

      if (trimmedQuery.isEmpty) {
        organizationList.clear();
        isOrganizationSearchLoading.value = false;
        return;
      }
      if (trimmedQuery.length < 3){
        organizationList.clear();
        isOrganizationSearchLoading.value = false;
        return;
      }
      isOrganizationSearchLoading.value = true;

      Response response = await authRepo.searchOrganization(trimmedQuery);
      if(response.statusCode == 200 && response.body != null) {
        // Parse response payload (adjust key if API uses a different path like response.body['data'])
        final List<dynamic> dataList = response.body['data'] is List
            ? response.body['data']
            : [];
        // Map dynamic JSON objects into your Organization model list
        final List<Organization> fetchedOrgs = dataList
        .map((json) => Organization.fromJson( json as Map<String, dynamic>))
        .toList();
        // Update reactive organization list
        organizationList.assignAll(fetchedOrgs);
      } else {
        // Clear results and show error message if request fails
        organizationList.clear();
        showError(response.body?['message']?? 'Failed to search organizations');
      }
    } catch (err) {
      // Catch unexpected runtime errors
      organizationList.clear();
      debugPrint('Exception in searchOrganizations: $err');
      showError('Something went wrong while fetching organizations');
    } finally {
      // 6. Turn off loading state regardless of outcome
      isOrganizationSearchLoading.value = false;
    }
  }

  /// Validate password strength
  String? validatePasswordStrength(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value.length > 15) {
      return 'Password must be at most 15 characters';
    }
    return null;
  }

  /// Validate confirm password matches
  String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    if (value.trim() != originalPassword?.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate phone number based on selected country
  String? validatePhoneByCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final countryCode = selectedCountryCode.value;
    if (countryCode == null) {
      return 'Please select a country code';
    }

    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Phone must contain only digits';
    }

    // Validate digit length based on country
    final expectedDigits = countryCode['digits'] ?? '10';
    final countryName = countryCode['name'] ?? 'selected country';

    if (value.trim().length != int.parse(expectedDigits)) {
      return 'Phone number must be $expectedDigits digits for $countryName';
    }

    return null;
  }

  /// Validate new registration form
  bool validateNewRegistrationForm(BuildContext context) {
    if (selectedOrganization.value == null) {
      showError('Please select your organization');
      return false;
    }

    if (usernameController.text.trim().isEmpty) {
      showError('Please enter your name');
      return false;
    }

    final emailError = validateEmail(emailController.text);
    if (emailError != null) {
      showError('Please enter a valid email');
      return false;
    }

    final countryCode = selectedCountryCode.value;
    if (countryCode == null) {
      showError('Please select a country code');
      return false;
    }

    final phoneError = validatePhoneByCountry(phoneController.text);
    if (phoneError != null) {
      showError(phoneError);
      return false;
    }

    final passwordError = validatePasswordStrength(passwordController.text);
    if (passwordError != null) {
      showError(passwordError);
      return false;
    }

    final confirmError = validateConfirmPassword(
      confirmPasswordController.text,
      passwordController.text,
    );
    if (confirmError != null) {
      showError(confirmError);
      return false;
    }

    return true;
  }
  /// Register with organization using mock data
  Future<void> registerWithOrganization(BuildContext context) async {
    try {
      isRegisterPageLoading.value = true;

      if (!validateNewRegistrationForm(context)) {
        isRegisterPageLoading.value = false;
        return;
      }

      final RegisterRequestDTO request = RegisterRequestDTO(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        password: passwordController.text.trim(),
        organization_id: selectedOrganization.value?.id,
      );

      Response response = await authRepo.register(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final regId = response.body['data']['registration_id'] ?? '';
        final status = response.body['data']['status'] ?? 'PENDING';

        registrationId.value = regId;
        userApprovalStatus.value = ApprovalStatus.pending;

        await sharedPreferences.setString('registration_id', regId);
        await sharedPreferences.setString('approval_status', status);

        currentUser.value.registrationId = regId;
        currentUser.value.approvalStatus = status;
        currentUser.value.organization = selectedOrganization.value;

        showSuccess('Registration submitted successfully!');
        clearNewRegistrationForm();
        Get.offAll(() => LoginPage(), transition: Transition.fade);
      } else {
        showError(response.body?['message'] ?? 'Registration failed');
      }
    } catch (err) {
      showError('Something went wrong during registration');
      debugPrint('Exception in registerWithOrganization: $err');
    } finally {
      isRegisterPageLoading.value = false;
    }
  }
  void clearNewRegistrationForm() {
    organizationSearchController.clear();
    usernameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedOrganization.value = null;
    organizationList.clear();
  }

  /// Load approval status from local storage
  Future<void> loadApprovalStatus() async {
    try {
      final regId = sharedPreferences.getString('registration_id') ?? '';
      final status = sharedPreferences.getString('approval_status') ?? 'PENDING';

      registrationId.value = regId;
      userApprovalStatus.value = approvalStatusFromString(status);  // CHANGED THIS LINE

      if (currentUser.value.id != null) {
        currentUser.value.registrationId = regId;
        currentUser.value.approvalStatus = status;
      }
    } catch (err) {
      debugPrint('Exception in loadApprovalStatus: $err');
    }
  }

  bool canAccessAttendance() {
    return userApprovalStatus.value.isApproved;
  }

  /// Simulate HR approval (for demo purposes)
  void simulateHRApproval() {
    try {
      MockData.DEMO_APPROVAL_STATUS = 'APPROVED';

      final mockApprovalData = MockData.getApprovalStatusResponse();

      userApprovalStatus.value = ApprovalStatus.approved;

      currentUser.value.approvalStatus = 'APPROVED';
      currentUser.value.department = Department(
        id: mockApprovalData['department_id'] as String?,
        departmentName: mockApprovalData['department'] as String?,
      );
      currentUser.value.designation = Designation(
        id: mockApprovalData['designation_id'] as String?,
        designationName: mockApprovalData['designation'] as String?,
      );

      sharedPreferences.setString('approval_status', 'APPROVED');
      sharedPreferences.setString(
        'user',
        jsonEncode(currentUser.value.toJson()),
      );

      showSuccess('HR Admin has approved your registration!');
    } catch (err) {
      debugPrint('Exception in simulateHRApproval: $err');
      showError('Something went wrong');
    }
  }

  // EXISTING METHODS BELOW (unchanged)

  Future<void> pickProfilePhoto(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return;

      final File file = File(pickedFile.path);
      final String extension = pickedFile.path.split('.').last.toLowerCase();
      if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
        showError("Only JPG and PNG format are allowed");
        return;
      }

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop Profile Photo",
            toolbarColor: kcPurple800,
            toolbarWidgetColor: kcBaseWhite,
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

      final int fileSizeInBytes = await finalFile.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 5) {
        showError("File size exceeds 5 MB : image not uploaded");
        return;
      }

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
    isProfileFormValid.value = firstNameValid && lastNameValid && emailValid && phoneValid;

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

        Response response = await authRepo.updateProfile(request, currentUser.value.id!);

        if (response.statusCode == 200) {
          currentUser.value.faceEmbedding = faceResult;
          currentUser.value.isEnrolled = true;
          await sharedPreferences.setString("user", jsonEncode(currentUser.value.toJson()));
          showSuccess("Face biometric profile updated successfully");
        } else {
          showError(response.body?['message'] ?? "Failed to update face biometric profile");
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
          _showDeviceChangeDialog(context, responseBody['message'] ?? '', deviceImei);
          return;
        }

        if (response.statusCode == 200) {
          final String userToken = responseBody['data']['token'];
          final String user = jsonEncode(responseBody['data']['user']);

          currentUser.value = User.fromJson(responseBody['data']['user']);

          final String backendStatus = responseBody['data']['user']['status'] ??
              responseBody['data']['status'] ??
              'APPROVED';

          userApprovalStatus.value = approvalStatusFromString(backendStatus);
          await sharedPreferences.setString('approval_status', backendStatus);
          await sharedPreferences.setString('registration_id', currentUser.value.registrationId ?? '');

          if (!canAccessAttendance()) {
            _showPendingApprovalDialog(context);
            return;
          }

          showSuccess("Login Successful");

          final String orgId = currentUser.value.organization?.id ??
              responseBody['data']['user']['organization_id'] ?? '';

          await authRepo.sharedPreferences.setString("organization_id", orgId);
          authRepo.apiClient.updateHeader(userToken, organizationId: orgId);

          await authRepo.sharedPreferences.setString("token", userToken);
          await authRepo.sharedPreferences.setString("user", user);
          await authRepo.sharedPreferences.setString("uid", responseBody['data']['user']['id']);

          clearLoginForm();
          Get.offAll(() => Homescreen(), transition: Transition.fade);
        } else if (response.statusCode == 403 ||
            response.statusCode == 400 ||
            (responseBody is Map && responseBody['message']?.toString().toLowerCase().contains('pending') == true)) {
          // HR approval pending condition
          _showPendingApprovalDialog(context);
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

  void _showDeviceChangeDialog(BuildContext context, String message, String deviceImei) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
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
        showSuccess("Request sent to HR. You'll be notified once your new device is approved.");
      } else {
        showError(response.body?['message'] ?? "Failed to send device change request");
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
        showSuccess(response.body?['message'] ?? "If account exists, a reset link has been sent");
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
        username: "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        faceEmbedding: newFaceEmbedding.isNotEmpty ? newFaceEmbedding.toList() : null,
        profilePhoto: pickedProfileImage.value,
      );

      Response response = await authRepo.updateProfile(request, currentUser.value.id!);

      if (response.statusCode == 200) {
        newFaceEmbedding.clear();
        pickedProfileImage.value = null;
        showSuccess("Profile Updated Successfully");

        currentUser.value.username = request.username;
        currentUser.value.email = request.email;
        currentUser.value.phoneNumber = request.phoneNumber;

        await sharedPreferences.setString("user", jsonEncode(currentUser.value.toJson()));
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
      if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
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
  void _showPendingApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const PendingApprovalDialog(
        message: "Your Request is Not Approved Yet. For approval status, contact your HR Admin.",
      ),
    );
  }
}