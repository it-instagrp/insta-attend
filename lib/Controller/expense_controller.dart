import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:insta_attend/API/DTO/Request/expense_request_dto.dart';
import 'package:insta_attend/API/Repository/expense_repository.dart';
import 'package:insta_attend/Model/expense.dart';
import 'package:insta_attend/Utils/toast_messages.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository expenseRepo;

  ExpenseController({required this.expenseRepo});

  final RxList<Expense> myExpenses = <Expense>[].obs;
  final RxList<Expense> reviewExpense = <Expense>[].obs;
  final RxList<Expense> approvedExpense = <Expense>[].obs;
  final RxList<Expense> rejectedExpense = <Expense>[].obs;
  final RxBool isLoading = false.obs;
  final RxString expenseDate = ''.obs;
  final List<String> expenseType = ["Travel", "Purchase", "Daily Allowance"];
  final RxString selectedExpenseType = ''.obs;
  RxInt expenseFilter = 0.obs; // 0: Review, 1: Approved, 2: Rejected

  final TextEditingController amountController = TextEditingController();

  Future<String> getUserId() async {
    return await expenseRepo.sharedPreferences.getString("uid") ?? "";
  }

  Future<void> createExpense(BuildContext context) async {
    try {
      isLoading.value = true;

      if (selectedExpenseType.value == expenseType.last &&
          ((double.tryParse(amountController.text.trim()) ?? 0.0) > 300.0)) {
        showError(
          context,
          "Expense more than 300 should be communicated with administration",
        );
        return;
      }

      final String userId = await getUserId();

      final ExpenseRequestDTO request = ExpenseRequestDTO(
        expenseAmount: double.tryParse(amountController.text.trim()),
        expenseType: selectedExpenseType.value,
        expenseBy: userId,
        expenseDate: expenseDate.value,
        expenseStatus: "Pending",
      );

      Response response = await expenseRepo.createExpense(request);

      if (response.statusCode == 201) {
        showSuccess(
          context,
          "Expense created, waiting for admin approval",
        );
        getMyExpense(context);
        clearForm();
        Get.back();
        Get.back();
      } else {
        showError(context, response.body['message']);
      }
    } catch (err) {
      showError(context, "Something went wrong");
      if (kDebugMode) log("Exception in create expenses", error: err);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMyExpense(BuildContext context) async {
    try {
      isLoading.value = true;
      Response response = await expenseRepo.getMyExpense();
      if (response.statusCode == 200) {
        List<dynamic> expenseList = response.body['data']['data'] as List<dynamic>;
        List<Expense> list = expenseList.map((expense)=>Expense.fromJson(expense)).toList();
        myExpenses.assignAll(list);

        // Filter based on status
        reviewExpense.assignAll(list.where((l) => l.expenseStatus?.toLowerCase() == 'pending').toList());
        approvedExpense.assignAll(list.where((l) => l.expenseStatus?.toLowerCase() == 'approved').toList());
        rejectedExpense.assignAll(list.where((l) => l.expenseStatus?.toLowerCase() == 'rejected').toList());
      }
    } catch (err) {
      showError(context, "Something went wrong");
      if (kDebugMode) log("Exception in get my expenses", error: err);
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    amountController.clear();
    selectedExpenseType.value = '';
    expenseDate.value = '';
  }

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
