import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:insta_attend/API/DTO/Request/apply_leave_request_dto.dart';
import 'package:insta_attend/API/Repository/leave_repository.dart';
import 'package:insta_attend/Model/Leave.dart';
import 'package:insta_attend/Utils/toast_messages.dart';

enum LeaveReason{
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

  RxBool isLoading = false.obs;
  RxString fromDate = "".obs;
  RxString toDate = "".obs;
  var leaveReason = LeaveReason.other.obs;
  RxInt leaveFilter = 0.obs; // 0: Review, 1: Approved, 2: Rejected

  RxList<Leave> allLeaves = <Leave>[].obs;
  RxList<Leave> reviewLeaves = <Leave>[].obs;
  RxList<Leave> approvedLeaves = <Leave>[].obs;
  RxList<Leave> rejectedLeaves = <Leave>[].obs;

  final TextEditingController reasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getMyLeaves();
  }

  Future<void> getMyLeaves() async {
    isLoading.value = true;
    try {
      final String userId = leaveRepository.sharedPreferences.getString("uid") ?? "";
      Response response = await leaveRepository.getLeaveList(userId);

      if (response.statusCode == 200) {
        List<dynamic> dataList = response.body['data'] as List<dynamic>;
        List<Leave> leaves = dataList.map((json) => Leave.fromJson(json)).toList();

        allLeaves.assignAll(leaves);

        // Filter based on status
        reviewLeaves.assignAll(leaves.where((l) => l.status?.toLowerCase() == 'pending').toList());
        approvedLeaves.assignAll(leaves.where((l) => l.status?.toLowerCase() == 'approved').toList());
        rejectedLeaves.assignAll(leaves.where((l) => l.status?.toLowerCase() == 'rejected').toList());

      } else {
        showError(Get.context!, response.body['message']);
      }
    } catch (err) {
      showError(Get.context!, "Something went wrong");
      print("Error: " + err.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestLeave(BuildContext context) async {
    isLoading.value = true;
    try {
      if (fromDate.value.isEmpty || toDate.value.isEmpty) {
        showError(context, "Please select a leave duration");
        return;
      }
      final String userId = leaveRepository.sharedPreferences.getString("uid") ?? "";
      final ApplyLeaveRequestDTO request = ApplyLeaveRequestDTO(
        from: fromDate.value,
        to: toDate.value,
        leaveType: leaveReason.value.description,
        userId: userId,
      );
      Response response = await leaveRepository.requestLeave(request);

      if (response.statusCode == 200) {
        showSuccess(context, "Leave Requested Successfully");
        getMyLeaves();
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        showError(context, response.body['message']);
      }
    } catch (err) {
      showError(context, "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

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
