import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:insta_attend/API/DTO/Request/expense_request_dto.dart';
import 'package:insta_attend/API/Repository/expense_repository.dart';
import 'package:insta_attend/Model/expense.dart';
import 'package:insta_attend/Model/expense_stats.dart';
import 'package:insta_attend/Utils/toast_messages.dart';
import 'package:insta_attend/View/pages/create_expense.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository expenseRepo;

  ExpenseController({required this.expenseRepo});

  // State Lists
  final RxList<Expense> myExpenses = <Expense>[].obs;
  final RxList<Expense> reviewExpense = <Expense>[].obs;
  final RxList<Expense> approvedExpense = <Expense>[].obs;
  final RxList<Expense> rejectedExpense = <Expense>[].obs;

  // Loading and Filtering State
  final RxBool isExpenseLoading = false.obs;
  final Rxn<ExpenseStats> stats = Rxn<ExpenseStats>();
  final RxString expenseDate = ''.obs;
  final List<String> expenseType = ["Travel", "Purchase", "Daily Allowance"];
  final RxString selectedExpenseType = ''.obs;

  RxInt expenseFilter = 0.obs; // 0: Review (Pending), 1: Approved, 2: Rejected
  Rx<File?> pickedReceiptImage = Rx<File?>(null);
  final RxnString editingExpenseId = RxnString();

  final TextEditingController amountController = TextEditingController();

  String getUserId() {
    return expenseRepo.sharedPreferences.getString("uid") ?? "";
  }

  /// Pick and validate receipt image attachment
  Future<void> pickReceiptImage(
      BuildContext context,
      ImageSource source,
      ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return;

      final String extension = pickedFile.path.split('.').last.toLowerCase();
      if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
        showError("Only JPG and PNG format are allowed");
        return;
      }

      final int fileSizeInBytes = await File(pickedFile.path).length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 5) {
        showError("File size exceeds 5 MB: Image not uploaded");
        return;
      }

      pickedReceiptImage.value = File(pickedFile.path);
    } catch (e) {
      debugPrint("Error picking receipt image: $e");
      showError("Something went wrong while picking the image");
    }
  }

  /// Create new expense submission
  Future<void> createExpense() async {
    try {
      isExpenseLoading.value = true;

      final double amount = double.tryParse(amountController.text.trim()) ?? 0.0;

      if (selectedExpenseType.value == expenseType.last && amount > 300.0) {
        showError(
          "Expense more than 300 should be communicated with administration",
        );
        return;
      }

      final ExpenseRequestDTO request = ExpenseRequestDTO(
        expenseAmount: amount,
        expenseType: selectedExpenseType.value,
        expenseDate: expenseDate.value,
        expenseStatus: "Pending",
        image: pickedReceiptImage.value,
      );

      Response response = await expenseRepo.createExpense(request);

      if (response.statusCode == 201 || response.statusCode == 200) {
        showSuccess("Expense created, waiting for admin approval");
        getMyExpense();
        clearForm();
        Get.back();
        Get.back();
      } else {
        showError(response.body?['message'] ?? "Failed to create expense");
      }
    } catch (err) {
      debugPrint("Exception in create expense: $err");
      if (kDebugMode) log("Exception in create expense", error: err);
      showError("Something went wrong");
    } finally {
      isExpenseLoading.value = false;
    }
  }

  /// Populate state for editing existing expense
  void startEditingExpense(Expense expense) {
    editingExpenseId.value = expense.id;
    amountController.text = expense.expenseAmount?.toStringAsFixed(0) ?? '';
    selectedExpenseType.value = expense.expenseType ?? '';
    expenseDate.value = expense.expenseDate ?? '';
    pickedReceiptImage.value = null;
    Get.to(() => CreateExpense(), transition: Transition.fade);
  }

  /// Submit expense update request
  Future<void> updateExpense() async {
    if (editingExpenseId.value == null) return;

    try {
      isExpenseLoading.value = true;
      // final String userId = getUserId();

      final ExpenseRequestDTO request = ExpenseRequestDTO(
        expenseAmount: double.tryParse(amountController.text.trim()),
        expenseType: selectedExpenseType.value,
        expenseDate: expenseDate.value,
        expenseStatus: "Pending",
        image: pickedReceiptImage.value,
      );

      Response response = await expenseRepo.updateMyExpense(
        editingExpenseId.value!,
        request,
      );

      if (response.statusCode == 200) {
        showSuccess("Expense updated successfully");
        getMyExpense();
        clearForm();
        Get.back();
        Get.back();
      } else {
        showError(response.body?['message'] ?? "Failed to update expense");
      }
    } catch (err) {
      if (kDebugMode) log("Exception in update expense", error: err);
      showError("Something went wrong");
    } finally {
      isExpenseLoading.value = false;
    }
  }

  /// Fetch user expense history
  Future<void> getMyExpense() async {
    try {
      isExpenseLoading.value = true;
      Response response = await expenseRepo.getMyExpense();

      if (response.statusCode == 200 && response.body?['data'] != null) {
        List<dynamic> expenseList =
            response.body['data']['data'] as List<dynamic>? ?? [];

        List<Expense> list =
        expenseList.map((expense) => Expense.fromJson(expense)).toList();

        myExpenses.assignAll(list);

        // Filter and categorize based on status
        reviewExpense.assignAll(
          list
              .where((l) => l.expenseStatus?.toLowerCase() == 'pending')
              .toList(),
        );
        approvedExpense.assignAll(
          list
              .where((l) => l.expenseStatus?.toLowerCase() == 'approved')
              .toList(),
        );
        rejectedExpense.assignAll(
          list
              .where((l) => l.expenseStatus?.toLowerCase() == 'rejected')
              .toList(),
        );
      }
    } catch (err) {
      showError("Something went wrong");
      if (kDebugMode) log("Exception in get my expenses", error: err);
    } finally {
      isExpenseLoading.value = false;
    }
  }

  /// Get overall expense statistics summary
  Future<void> getMyStats() async {
    try {
      isExpenseLoading.value = true;
      Response response = await expenseRepo.getMyStats();

      if (response.statusCode == 200 && response.body?['data'] != null) {
        stats.value = ExpenseStats.fromJson(response.body['data']);
      } else {
        showError(response.body?['message'] ?? "Failed to fetch stats");
      }
    } catch (err) {
      debugPrint("Exception in getMyStats: $err");
    } finally {
      isExpenseLoading.value = false;
    }
  }

  /// Reset form fields
  void clearForm() {
    amountController.clear();
    selectedExpenseType.value = '';
    expenseDate.value = '';
    pickedReceiptImage.value = null;
    editingExpenseId.value = null;
  }

  /// Returns active expense list according to selected tab/filter
  List<Expense> get filteredExpenses {
    switch (expenseFilter.value) {
      case 0:
        return reviewExpense;
      case 1:
        return approvedExpense;
      case 2:
        return rejectedExpense;
      default:
        return [];
    }
  }
}