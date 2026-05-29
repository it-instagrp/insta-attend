import 'package:insta_attend/API/DTO/Request/expense_request_dto.dart';
import 'package:insta_attend/API/api_client.dart';
import 'package:insta_attend/API/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class ExpenseRepository {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  
  const ExpenseRepository({required this.sharedPreferences, required this.apiClient});
  
  Future<Response> createExpense(ExpenseRequestDTO request) async{
    return await apiClient.postData(createExpenseUrl, request.toJson());
  }

  Future<Response> getMyExpense({int? pageNumber, int? pageSize}) async{
    return await apiClient.getData(getMyExpenseUrl(pageNumber: pageNumber ?? 1, pageSize: pageSize ?? 10));
  }

  Future<Response> updateMyExpense(String expenseId, ExpenseRequestDTO request) async{
    return await apiClient.putData(updateMyExpenseUrl(expenseId), request.toJson());
  }

  Future<Response> deleteMyExpense(String expenseId) async{
    return await apiClient.deleteData(deleteMyExpenseUrl(expenseId));
  }
}