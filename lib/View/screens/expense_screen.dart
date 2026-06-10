import 'package:flutter/material.dart';
import 'package:insta_attend/Component/Cards/expense_card.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Controller/expense_controller.dart';
import 'package:get/get.dart';
import 'package:insta_attend/View/pages/create_expense.dart';
import '../../Component/Button/main_button.dart';
import '../../Component/Cards/toggle_card.dart';
import '../../Constant/constant_color.dart';
import '../../Constant/constant_font.dart';
import '../../Component/Cards/expense_history_card.dart';
import '../../Component/Cards/no_content.dart';

class ExpenseScreen extends StatelessWidget {
  ExpenseScreen({super.key});

  final ExpenseController controller = Get.find<ExpenseController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getMyStats();
      controller.getMyExpense();
    });

    return Container(
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFFF1F3F8),
      child: Stack(
        children: [
          Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: kcPurple500,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: ListTile(
              title: Text(
                "Expense Summary",
                style: kfHeadlineSmall.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                "Claim your expenses here",
                style: kfLabelLarge.copyWith(color: kcPurple200),
              ),
              trailing: Image.asset(kaExpense),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 150,
            bottom: 70,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Obx(
                    () =>
                        controller.isLoading.value
                            ? const Center(
                              child: CircularProgressIndicator(
                                strokeCap: StrokeCap.round,
                              ),
                            )
                            : ExpenseCard(
                              periodOfExpense:
                                  controller.stats.value?.expensePeriod ?? "NA",
                              totalExpense:
                                  controller.stats.value?.totalExpenses ?? 0,
                              reviewExpense:
                                  controller.stats.value?.expenseInReview ?? 0,
                              approvedExpense:
                                  controller.stats.value?.approvedExpense ?? 0,
                            ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ToggleCard(
                    items: const ["Review", "Approved", "Rejected"],
                    onSelected:
                        (filter) => controller.expenseFilter.value = filter,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeCap: StrokeCap.round,
                          ),
                        );
                      }
                      final targetExpenses = controller.filteredExpenses;
                      if (targetExpenses.isEmpty) {
                        return NoContent(
                          icon: kaNoExpense,
                          title: "No Expenses Logged",
                          description:
                              "There are no expenses listed under this status filter for the selected tracking period.",
                        );
                      }
                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: targetExpenses.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder:
                            (context, index) => ExpenseHistoryCard(
                              expense: targetExpenses[index],
                            ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 70,
              padding: const EdgeInsets.all(10.0),
              color: Colors.white,
              child: MainButton(
                label: "Create New Expense",
                onTap:
                    () => Get.to(
                      () => CreateExpense(),
                      transition: Transition.fade,
                    ),
                buttonSize: ButtonSize.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
