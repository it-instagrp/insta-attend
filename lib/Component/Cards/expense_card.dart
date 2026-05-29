import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';

enum ExpenseType{
  total, review, approved
}

class ExpenseCard extends StatelessWidget {
  final String periodOfExpense;
  final int totalExpense, reviewExpense, approvedExpense;
  const ExpenseCard({super.key, this.periodOfExpense = "1 Jan 2025 - 30 Dec 2024", this.totalExpense = 1010, this.reviewExpense = 445, this.approvedExpense = 555});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 366,
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total Expense", style: kfLabelLarge,),
          SizedBox(
            height: 5,
          ),
          Text("Period $periodOfExpense", style: kfBodySmall,),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Expanded(child: _buildExpenseSection(ExpenseType.total, totalExpense)),
              SizedBox(width: 8),
              Expanded(child: _buildExpenseSection(ExpenseType.review, reviewExpense)),
              SizedBox(width: 8),
              Expanded(child: _buildExpenseSection(ExpenseType.approved, approvedExpense)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildExpenseSection(ExpenseType type, int amount) {
    return Container(
      padding: EdgeInsets.all(10.0),       // reduced from 12 → gives text more room
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: kcGrey25,
        border: Border.all(color: kcGrey100, width: 1.5),  // reduced from 2 → saves 1px per side
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                _getExpenseIcon(type),
                fit: BoxFit.scaleDown,
                height: 14,
                width: 14,
              ),
              SizedBox(width: 4),
              Flexible(                     // prevents label from overflowing
                child: Text(
                  _getExpenseTitle(type),
                  style: kfLabelMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text("₹ ${amount.toString()}", style: kfTitleLarge),
        ],
      ),
    );
  }

  String _getExpenseTitle(ExpenseType type){
    switch(type){
      case ExpenseType.total:
        return "Total";
      case ExpenseType.review:
        return "Review";
      case ExpenseType.approved:
        return "Approved";
    }
  }

  String _getExpenseIcon(ExpenseType type){
    switch(type){
      case ExpenseType.total:
        return kaTotalExpense;
      case ExpenseType.review:
        return kaReviewExpense;
      case ExpenseType.approved:
        return kaApprovedExpense;
    }
  }
}
