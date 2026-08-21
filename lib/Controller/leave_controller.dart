import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:insta_attend/API/DTO/Request/apply_leave_request_dto.dart';
import 'package:insta_attend/API/Repository/leave_repository.dart';
import 'package:insta_attend/Model/Leave.dart';
import 'package:insta_attend/Utils/toast_messages.dart';
import 'package:insta_attend/Controller/auth_controller.dart';

enum LeaveReason {
  sick('Sick Leave'),
  vacation('Vacation'),
  personal('Personal Leave'),
  other('Other');

  final String description;
  const LeaveReason(this.description);
}

class LeaveController extends GetxController {
  final LeaveRepository leaveRepository;

  LeaveController({required this.leaveRepository});

  // State Flags and Filtering
  RxBool isLeaveLoading = false.obs;
  RxString fromDate = "".obs;
  RxString toDate = "".obs;
  var leaveReason = LeaveReason.other.obs;
  RxInt leaveFilter = 0.obs; // 0: Review (Pending), 1: Approved, 2: Rejected

  // Leave Collections
  RxList<Leave> allLeaves = <Leave>[].obs;
  RxList<Leave> reviewLeaves = <Leave>[].obs;
  RxList<Leave> approvedLeaves = <Leave>[].obs;
  RxList<Leave> rejectedLeaves = <Leave>[].obs;

  // Form Controllers
  final TextEditingController reasonController = TextEditingController();

  /// Reset form fields
  void clearLeaveForm() {
    fromDate.value = "";
    toDate.value = "";
    leaveReason.value = LeaveReason.other;
    reasonController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    getMyLeaves();
  }

  /// Fetch list of leaves for the authenticated user
  Future<void> getMyLeaves() async {
    isLeaveLoading.value = true;
    try {
      final AuthController authController = Get.find<AuthController>();

      final String userId = authController.currentUser.value.id ??
          leaveRepository.sharedPreferences.getString("uid") ??
          "";

      if (userId.isEmpty) {
        debugPrint("Cannot fetch leaves: user ID is missing.");
        return;
      }

      Response response = await leaveRepository.getLeaveList(userId);

      if (response.statusCode == 200 && response.body?['data'] != null) {
        List<dynamic> dataList = response.body['data'] as List<dynamic>;
        List<Leave> leaves =
        dataList.map((json) => Leave.fromJson(json)).toList();

        allLeaves.assignAll(leaves);

        // Filter based on status
        reviewLeaves.assignAll(
          leaves.where((l) => l.status?.toLowerCase() == 'pending').toList(),
        );
        approvedLeaves.assignAll(
          leaves.where((l) => l.status?.toLowerCase() == 'approved').toList(),
        );
        rejectedLeaves.assignAll(
          leaves.where((l) => l.status?.toLowerCase() == 'rejected').toList(),
        );
      } else {
        showError(response.body?['message'] ?? "Failed to fetch leaves");
      }
    } catch (err) {
      showError("Something went wrong");
      debugPrint("Error in getMyLeaves: $err");
    } finally {
      isLeaveLoading.value = false;
    }
  }

  /// Submit leave application request
  Future<void> requestLeave(BuildContext context) async {
    isLeaveLoading.value = true;
    try {
      if (fromDate.value.isEmpty || toDate.value.isEmpty) {
        showError("Please select a leave duration");
        return;
      }

      final ApplyLeaveRequestDTO request = ApplyLeaveRequestDTO(
        from: fromDate.value,
        to: toDate.value,
        leaveType: leaveReason.value.description,
      );

      Response response = await leaveRepository.requestLeave(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSuccess("Leave Requested Successfully");
        clearLeaveForm();
        getMyLeaves();
        Get.back();
        Get.back();
      } else {
        showError(response.body?['message'] ?? "Failed to request leave");
      }
    } catch (err) {
      showError("Something went wrong");
      debugPrint("Error in requestLeave: $err");
    } finally {
      isLeaveLoading.value = false;
    }
  }

  /// Returns active leave list according to selected tab/filter
  List<Leave> get filteredLeaves {
    switch (leaveFilter.value) {
      case 0:
        return reviewLeaves;
      case 1:
        return approvedLeaves;
      case 2:
        return rejectedLeaves;
      default:
        return [];
    }
  }
}