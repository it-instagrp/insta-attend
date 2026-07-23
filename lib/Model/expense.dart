class Expense {
  String? id;
  String? expenseDate;
  String? expenseType;
  double? expenseAmount;
  String? expenseStatus;
  String? createdAt;
  String? updatedAt;
  ExpenseBy? expenseBy;

  Expense({
    this.id,
    this.expenseDate,
    this.expenseType,
    this.expenseAmount,
    this.expenseStatus,
    this.createdAt,
    this.updatedAt,
    this.expenseBy,
  });

  Expense.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    expenseDate = json['expense_date'];
    expenseType = json['expense_type'];
    expenseAmount = (json['expense_amount'] as num).toDouble();
    expenseStatus = json['expense_status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    expenseBy =
        json['expenseBy'] != null
            ? new ExpenseBy.fromJson(json['expenseBy'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['expense_date'] = this.expenseDate;
    data['expense_type'] = this.expenseType;
    data['expense_amount'] = this.expenseAmount;
    data['expense_status'] = this.expenseStatus;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.expenseBy != null) {
      data['expenseBy'] = this.expenseBy!.toJson();
    }
    return data;
  }
}

class ExpenseBy {
  String? username;
  String? email;

  ExpenseBy({this.username, this.email});

  ExpenseBy.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    return data;
  }
}
