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
import 'package:insta_attend/Utils/responsive_size.dart';

class ExpenseScreen extends StatelessWidget {
  ExpenseScreen({super.key});

  final ExpenseController controller = Get.find<ExpenseController>();

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
            height: screenHeight * 0.28,
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
            left: 0,
            right: 0,
            top: screenHeight * 0.08,
            bottom: screenHeight * 0.08,
            child: Column(
              children: [
                 ListTile(
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.rw),
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
                SizedBox(height: 10.rh),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.rw),
                  child: ToggleCard(
                    items: const ["Review", "Approved", "Rejected"],
                    onSelected:
                        (filter) => controller.expenseFilter.value = filter,
                  ),
                ),
                 SizedBox(height: 15.rh),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.rw),
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
              height: screenHeight * 0.08,
              padding: EdgeInsets.all(10.rw),
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
