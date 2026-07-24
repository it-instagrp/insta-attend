import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/custom_button.dart';
import 'package:insta_attend/Component/Button/main_button.dart' as main;
import 'package:insta_attend/Component/Fields/custom_drop_down.dart';
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/expense_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Constant/constant_font.dart';
import 'package:image_picker/image_picker.dart';

class CreateExpense extends StatelessWidget {
  CreateExpense({super.key});

  final ExpenseController controller = Get.find<ExpenseController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F8),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  // App bar with dynamic title (Create/Edit)
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leadingWidth: 50,
      leading: InkWell(
        onTap: () => Get.back(),
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
      title: Obx(
            () => Text(
          controller.editingExpenseId.value != null
              ? "Edit Expense"
              : "Create Expense",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101828),
          ),
        ),
      ),
    );
  }

  // Main form body with all input fields
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormHeader(),
            const SizedBox(height: 20),
            _buildExpenseTypeField(),
            const SizedBox(height: 15),
            _buildAmountField(),
            const SizedBox(height: 15),
            _buildExpenseDateField(),
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
        "Fill Expense Information",
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        "Information about expense details",
        style: TextStyle(fontSize: 12, color: kcGrey500),
      ),
    );
  }

  // Expense type dropdown selector
  Widget _buildExpenseTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Expense Type",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kcGrey600,
          ),
        ),
        const SizedBox(height: 5),
        Obx(
              () => CustomDropDown(
            options: controller.expenseType,
            onChanged: (value) {
              controller.selectedExpenseType.value = value ?? '';
            },
            hintText: controller.selectedExpenseType.value.isNotEmpty
                ? controller.selectedExpenseType.value
                : "Select Expense Type",
            title: "Expense Type",
          ),
        ),
      ],
    );
  }

  // Amount input field
  Widget _buildAmountField() {
    return CustomTextField(
      title: "Amount",
      hintText: "Enter amount",
      icon: kaExpenseIcon,
      controller: controller.amountController,
      isDisabled: false,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  // Expense date picker field
  Widget _buildExpenseDateField() {
    return Obx(
          () => CustomTextField(
        title: "Expense Date",
        hintText: controller.expenseDate.value.isNotEmpty
            ? _formatDate(controller.expenseDate.value)
            : "Select Date",
        icon: kaDuration,
        controller: TextEditingController(),
        isDisabled: true,
        onTap: () => _showDatePickerDialog(Get.context!),
      ),
    );
  }

  // Bottom submit button with loading state
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Obx(
            () => main.MainButton(
          label: controller.editingExpenseId.value != null
              ? "Update Expense"
              : "Submit Expense",
          onTap: () => _showConfirmationDialog(context),
        ),
      ),
    );
  }

  // Date picker dialog
  Future<void> _showDatePickerDialog(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      controller.expenseDate.value = picked.toIso8601String().split('T')[0];
    }
  }

  // Format date string to readable format
  String _formatDate(String date) {
    try {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
    } catch (e) {
      return "Select Date";
    }
  }

  // Image source picker (Camera or Gallery)
  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Upload Receipt",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: kcPurple500),
              title: const Text("Take a photo"),
              onTap: () {
                Navigator.pop(context);
                controller.pickReceiptImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: kcPurple500),
              title: const Text("Choose from gallery"),
              onTap: () {
                Navigator.pop(context);
                controller.pickReceiptImage(context, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Receipt image display widget (for confirmation dialog)
  Widget _buildReceiptImageSection(BuildContext context) {
    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Receipt Image",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          controller.pickedReceiptImage.value != null
              ? _buildReceiptImagePreview()
              : _buildReceiptUploadPlaceholder(context),
        ],
      ),
    );
  }

  // Receipt image preview with delete button
  Widget _buildReceiptImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            controller.pickedReceiptImage.value!,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: InkWell(
            onTap: () => controller.pickedReceiptImage.value = null,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Receipt upload placeholder
  Widget _buildReceiptUploadPlaceholder(BuildContext context) {
    return InkWell(
      onTap: () => _showImageSourcePicker(context),
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kcGrey400),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_outlined, color: kcGrey400),
            const SizedBox(height: 5),
            Text(
              "Upload Receipt",
              style: TextStyle(color: kcGrey400, fontSize: 12),
            ),
          ],
        ),
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

  // Confirmation dialog before submitting expense
  void _showConfirmationDialog(BuildContext context) {
    showModalBottomSheet(
      barrierColor: Colors.black.withAlpha(180),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Submit Expense",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildReceiptImageSection(context),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Double-check your expense details to ensure everything is correct. Do you want to proceed?",
                      style: kfBodyMedium.copyWith(color: kcGrey400),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildConfirmationButtons(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -50,
              child: SvgPicture.asset(kaSubmitLeaveTop),
            ),
          ],
        );
      },
    );
  }

  // Confirm/Cancel buttons in dialog
  Widget _buildConfirmationButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 45,
          width: MediaQuery.of(context).size.width,
          child: Obx(
                () => controller.isLoading.value
                ? _buildLoadingIndicator()
                : main.MainButton(
              label: controller.editingExpenseId.value != null
                  ? "Update Expense"
                  : "Submit Expense",
              onTap: () => controller.editingExpenseId.value != null
                  ? controller.updateExpense()
                  : controller.createExpense(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 45,
          width: MediaQuery.of(context).size.width,
          child: CustomButton(
            label: "No, Let me check",
            onPressed: () => Navigator.pop(context),
            hierarchy: ButtonHierarchy.secondary,
          ),
        ),
      ],
    );
  }
}