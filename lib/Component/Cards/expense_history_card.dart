import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Model/expense.dart';
import 'package:intl/intl.dart';

class ExpenseHistoryCard extends StatelessWidget{
  final Expense expense;
  final VoidCallback? onEdit;
  const ExpenseHistoryCard({super.key, required this.expense, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    kaFaq,
                    fit: BoxFit.scaleDown,
                    height: 18,
                    width: 18,
                    colorFilter: ColorFilter.mode(kcPurple500, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    _formatHeaderDate(expense.expenseDate ?? expense.createdAt ?? ""),
                    style: kfLabelMedium.copyWith(color: kcGrey800, fontSize: 13),
                  ),
                ],
              ),
              if ((expense.expenseStatus?.toLowerCase() ?? 'pending') == 'pending')
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.edit_rounded, size: 18, color: kcPurple500),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: kcGrey100,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: kcGrey200, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Type",
                        style: kfBodySmall.copyWith(color: kcGrey500, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        expense.expenseType ?? "N/A",
                        style: kfTitleMedium.copyWith(color: kcGrey900, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total Expense",
                      style: kfBodySmall.copyWith(color: kcGrey500, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      "₹ ${expense.expenseAmount?.toStringAsFixed(0) ?? '0'}",
                      style: kfTitleMedium.copyWith(color: kcGrey900, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(expense.expenseStatus),
                    size: 16,
                    color: _getStatusColor(expense.expenseStatus),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusLabel(expense.expenseStatus, expense.updatedAt ?? expense.createdAt ?? ""),
                    style: kfLabelSmall.copyWith(
                      color: _getStatusColor(expense.expenseStatus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "By ",
                    style: kfBodySmall.copyWith(color: kcGrey500, fontSize: 11),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(kaProfile),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Text(
                      expense.expenseBy?.username ?? "User",
                      style: kfLabelSmall.copyWith(color: kcGrey800, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatHeaderDate(String rawDate) {
    if (rawDate.isEmpty) return "N/A";
    try {
      final DateTime parsed = DateTime.parse(rawDate);
      return DateFormat('dd MMMM yyyy').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  String _formatStatusDate(String rawDate) {
    if (rawDate.isEmpty) return "";
    try {
      final DateTime parsed = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return "";
    }
  }

  Color _getStatusColor(String? status) {
    final s = status?.toLowerCase() ?? 'pending';
    if (s == 'approved') return kcSuccess600;
    if (s == 'rejected') return kcError600;
    return kcWarning600;
  }

  IconData _getStatusIcon(String? status) {
    final s = status?.toLowerCase() ?? 'pending';
    if (s == 'approved') return Icons.check_circle_rounded;
    if (s == 'rejected') return Icons.cancel_rounded;
    return Icons.pending_actions_rounded;
  }

  String _getStatusLabel(String? status, String targetDate) {
    final s = status?.toLowerCase() ?? 'pending';
    final formattedDate = _formatStatusDate(targetDate);
    final dateSuffix = formattedDate.isNotEmpty ? " at $formattedDate" : "";

    if (s == 'approved') return "Approved$dateSuffix";
    if (s == 'rejected') return "Rejected$dateSuffix";
    return "In Review";
  }
}