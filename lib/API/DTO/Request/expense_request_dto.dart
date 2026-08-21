import 'dart:io';

class ExpenseRequestDTO {
  String? expenseDate;
  String? expenseType;
  double? expenseAmount;
  String? expenseStatus;
  File? image;

  ExpenseRequestDTO({
    this.expenseDate,
    this.expenseType,
    this.expenseAmount,
    this.expenseStatus,
    this.image,
  });

  ExpenseRequestDTO.fromJson(Map<String, dynamic> json) {
    expenseDate = json['expense_date'];
    expenseType = json['expense_type'];
    expenseAmount = json['expense_amount'];
    expenseStatus = json['expense_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['expense_date'] = this.expenseDate;
    data['expense_type'] = this.expenseType;
    data['expense_amount'] = this.expenseAmount;
    data['expense_status'] = this.expenseStatus;
    return data;
  }
}