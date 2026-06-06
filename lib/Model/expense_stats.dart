class ExpenseStats {
  int? totalExpenses;
  int? expenseInReview;
  int? approvedExpense;
  String? expensePeriod;

  ExpenseStats(
      {this.totalExpenses,
        this.expenseInReview,
        this.approvedExpense,
        this.expensePeriod});

  ExpenseStats.fromJson(Map<String, dynamic> json) {
    totalExpenses = json['totalExpenses'];
    expenseInReview = json['expenseInReview'];
    approvedExpense = json['approvedExpense'];
    expensePeriod = json['expensePeriod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalExpenses'] = this.totalExpenses;
    data['expenseInReview'] = this.expenseInReview;
    data['approvedExpense'] = this.approvedExpense;
    data['expensePeriod'] = this.expensePeriod;
    return data;
  }
}
