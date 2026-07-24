import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/custom_button.dart';
import 'package:insta_attend/Component/Button/main_button.dart' as main;
import 'package:insta_attend/Component/Fields/custom_drop_down.dart';
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/leave_controller.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Model/Leave.dart';
import 'package:intl/intl.dart';
import '../../Utils/bottom_sheet_helper.dart';

class SubmitLeave extends StatelessWidget {
  SubmitLeave({super.key});

  final LeaveController controller = Get.find<LeaveController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if(didPop){
          _clearForm();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F3F8),
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomButton(context),
      ),
    );
  }

  void _clearForm(){
    controller.clearLeaveForm();
  }

  // App bar with back button and title
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leadingWidth: 50,
      leading: InkWell(
        onTap: () {
          _clearForm();
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SvgPicture.asset(
            kaBackButton,
            fit: BoxFit.scaleDown,
            width: 10,
            height: 10,
          ),
        ),
      ),
      centerTitle: true,
      title: const Text(
        "Submit Leave",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
      ),
    );
  }

  // Main form body
  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormHeader(),
            const SizedBox(height: 20),
            _buildLeaveCategoryField(),
            const SizedBox(height: 15),
            _buildLeaveDurationField(),
          ],
        ),
      ),
    );
  }

  // Form title and description
  Widget _buildFormHeader() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "Fill Leave Information",
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        "Information about leave details",
        style: TextStyle(fontSize: 12, color: kcGrey500),
      ),
    );
  }

  // Leave category/type dropdown
  Widget _buildLeaveCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Leave Category",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kcGrey600,
          ),
        ),
        const SizedBox(height: 5),
        Obx(
              () => CustomDropDown(
            options: LeaveReason.values.map((e) => e.description).toList(),
            onChanged: (value) => _handleLeaveReasonChange(value),
            hintText: controller.leaveReason.value.description.isNotEmpty
                ? controller.leaveReason.value.description
                : "Select Leave Type",
            title: "Leave Type",
          ),
        ),
      ],
    );
  }

  // Leave duration date range field
  Widget _buildLeaveDurationField() {
    return Obx(
          () => CustomTextField(
        title: "Leave Duration",
        hintText: _formatDateRange(
          controller.fromDate.value,
          controller.toDate.value,
        ),
        icon: kaDuration,
        controller: TextEditingController(),
        isDisabled: true,
        onTap: () => _showDateRangePickerDialog(Get.context!),
      ),
    );
  }

  // Bottom submit button
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: main.MainButton(
        label: "Submit Leave",
        onTap: () {
          if (_validateForm()) {
            _showConfirmationDialog(context);
          }
        }
      ),
    );
  }

  // Reusable loading indicator
  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        strokeCap: StrokeCap.round,
        color: kcPurple600,
      ),
    );
  }

  // Date range picker dialog with confirmation
  Future<void> _showDateRangePickerDialog(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 2)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _setDateRange(picked);
      _showDurationConfirmationDialog(context);
    }
  }

  // Set the selected date range in controller
  void _setDateRange(DateTimeRange range) {
    controller.fromDate.value = range.start.toIso8601String().split('T')[0];
    controller.toDate.value = range.end.toIso8601String().split('T')[0];
  }

  // Confirmation dialog for selected dates
  void _showDurationConfirmationDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Leave Duration",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDateRange(
                  controller.fromDate.value,
                  controller.toDate.value,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: "Submit Date",
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: "Clear Range",
                onPressed: () => _clearDateRange(context),
                hierarchy: ButtonHierarchy.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Clear selected dates and close dialog
  void _clearDateRange(BuildContext context) {
    controller.fromDate.value = "";
    controller.toDate.value = "";
    Navigator.pop(context);
  }

  // Handle leave reason dropdown change
  void _handleLeaveReasonChange(String? value) {
    if (value == null) return;
    controller.leaveReason.value = LeaveReason.values.firstWhere(
          (element) => element.description == value,
      orElse: () => LeaveReason.other,
    );
  }

  // Format date range to readable string
  String _formatDateRange(String from, String to) {
    try {
      final fromDate = DateFormat("dd MMM").format(DateTime.parse(from));
      final toDate = DateFormat("dd MMM").format(DateTime.parse(to));
      return "$fromDate - $toDate";
    } catch (e) {
      return "Select Duration";
    }
  }

  // Final confirmation dialog before submitting leave
  void _showConfirmationDialog(BuildContext context) {
    showCustomBottomSheet(
      context: context,
      title: "Submit Leave",
      description:
      "Double-check your leave details to ensure everything is correct. Do you want to proceed?",
      topIconAsset: kaSubmitLeaveTop,
      primaryButton: Obx(
            () => controller.isLoading.value
            ? _buildLoadingIndicator()
            : main.MainButton(
          label: "Submit Leave",
          onTap: () => controller.requestLeave(context),
        ),
      ),
    );
  }

  bool _validateForm() {
    if (controller.leaveReason.value == LeaveReason.other){
      Get.snackbar("Validation", "Please select leave category.",
      snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (controller.fromDate.value.isEmpty || controller.toDate.value.isEmpty){
      Get.snackbar("Validation", "Please select leave duration",
      snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }
}