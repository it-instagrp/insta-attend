import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  final RxList<Expense> myExpenses = <Expense>[].obs;
  final RxList<Expense> reviewExpense = <Expense>[].obs;
  final RxList<Expense> approvedExpense = <Expense>[].obs;
  final RxList<Expense> rejectedExpense = <Expense>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<ExpenseStats> stats = Rxn<ExpenseStats>();
  final RxString expenseDate = ''.obs;
  final List<String> expenseType = ["Travel", "Purchase", "Daily Allowance"];
  final RxString selectedExpenseType = ''.obs;
  RxInt expenseFilter = 0.obs; // 0: Review, 1: Approved, 2: Rejected
  Rx<File?> pickedReceiptImage = Rx<File?>(null);
  final RxnString editingExpenseId = RxnString();

  final TextEditingController amountController = TextEditingController();

  Future<String> getUserId() async {
    return await expenseRepo.sharedPreferences.getString("uid") ?? "";
  }
  Future<void> pickReceiptImage(BuildContext context, ImageSource source) async{
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;
      final String extension = pickedFile.path.split('.').last.toLowerCase();
      if(extension != 'jpg' && extension != 'jpeg' && extension != 'png'){
        showError("Only JPG and PNG format are allowed");
        return;
      }
      final int fileSizeInBytes = await File(pickedFile.path).length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 5){
        showError("File size exceeds 5 MB: Image not uploaded");
        return;
      }
      pickedReceiptImage.value = File(pickedFile.path);
    } catch (e) {
      debugPrint("Error picking receipt image: $e");
      showError("Something went wrong while picking the image/file");
    }
  }

  Future<void> createExpense() async {
    try {
      isLoading.value = true;

      if (selectedExpenseType.value == expenseType.last &&
          ((double.tryParse(amountController.text.trim()) ?? 0.0) > 300.0)) {
        showError("Expense more than 300 should be communicated with administration",
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
        image: pickedReceiptImage.value,
      );

      Response response = await expenseRepo.createExpense(request);

      if (response.statusCode == 201) {
        showSuccess(
          "Expense created, waiting for admin approval",
        );
        getMyExpense();
        clearForm();
        Get.back();
        Get.back();
      } else {
        showError(response.body['message']);
      }
    } catch (err) {
      debugPrint("Exception in get my expenses: $err");
      if (kDebugMode) log("Exception in create expenses", error: err);
    } finally {
      isLoading.value = false;
    }
  }
  void startEditingExpense(Expense expense) {
    editingExpenseId.value =expense.id;
    amountController.text = expense.expenseAmount?.toStringAsFixed(0) ?? '';
    selectedExpenseType.value =expense.expenseType ?? '';
    expenseDate.value = expense.expenseDate ?? '';
    pickedReceiptImage.value = null;
    Get.to(() => CreateExpense(), transition: Transition.fade);
  }
  Future<void> updateExpense() async {
    try{
      isLoading.value =true;
      final String userId = await getUserId();
      final ExpenseRequestDTO request = ExpenseRequestDTO(
        expenseAmount: double.tryParse(amountController.text.trim()),
        expenseType: selectedExpenseType.value,
        expenseBy: userId,
        expenseDate: expenseDate.value,
        expenseStatus: "Pending",
        image: pickedReceiptImage.value,
      );
      Response response = await expenseRepo.updateMyExpense(editingExpenseId.value!, request);
      if (response.statusCode == 200){
        showSuccess("Expense updated successfully");
        getMyExpense();
        clearForm();
        Get.back();
        Get.back();
      } else {
        showError(response.body['message']);
      }
    } catch (err){
      if(kDebugMode) log("Exception in update expense", error: err);
      showError("Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMyExpense() async {
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
      showError("Something went wrong");
      if (kDebugMode) log("Exception in get my expenses", error: err);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMyStats() async{
    try{
      isLoading.value = true;
      Response response = await expenseRepo.getMyStats();

      if(response.statusCode == 200){
        stats.value = ExpenseStats.fromJson(response.body['data']);
      } else {
        showError(response.body['message']);
      }
    }catch(err){
      debugPrint("Exception in getMyStats: $err");
    }finally{
      isLoading.value = false;
    }
  }

  void clearForm() {
    amountController.clear();
    selectedExpenseType.value = '';
    expenseDate.value = '';
    pickedReceiptImage.value = null;
    editingExpenseId.value = null;
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
