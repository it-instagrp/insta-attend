import 'package:flutter/material.dart';
import 'package:insta_attend/Component/Cards/expense_card.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Controller/expense_controller.dart';
import 'package:get/get.dart';
import 'package:insta_attend/View/pages/create_expense.dart';
import '../../Component/Button/main_button.dart';
import '../../Component/Cards/no_content.dart';
import '../../Component/Cards/toggle_card.dart';
import '../../Constant/constant_color.dart';
import '../../Constant/constant_font.dart';

class ExpenseScreen extends StatelessWidget {
  ExpenseScreen({super.key});

  final ExpenseController controller = Get.find<ExpenseController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Color(0xFFF1F3F8),
      child: Stack(
        children: [
          Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: kcPurple500,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0)
                )
            ),
          ),
          Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: ListTile(
                title: Text("Expense Summary", style: kfHeadlineSmall.copyWith(color: Colors.white),),
                subtitle: Text("Claim your expenses here", style: kfLabelLarge.copyWith(color: kcPurple200),),
                trailing: Image.asset(kaExpense),
              )),
          Positioned(
              left: 0,
              right: 0,
              top: 150,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0
                      ),
                      // child: Obx(()=>ExpenseCard(),),
                      child: ExpenseCard(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0
                      ),
                      child: ToggleCard(items: ["Review", "Approved", "Rejected"], onSelected: (filter)=>
                      {
                      }),
                    ),
                    // Container(
                    //   margin: EdgeInsets.all(18.0),
                    //   height: 280,
                    //   child: Obx(() => controller.isLoading.value
                    //       ? Center(
                    //     child: CircularProgressIndicator(
                    //       strokeCap: StrokeCap.round,
                    //       color: kcPurple600,
                    //     ),
                    //   )
                    //       : controller.filteredExpenses.isNotEmpty
                    //       ? ListView.separated(
                    //     separatorBuilder: (context, index) => SizedBox(height: 10.0),
                    //     itemCount: controller.filteredExpenses.length,
                    //     itemBuilder: (context, index) {
                    //       final leave = controller.filteredExpenses[index];
                    //       // return ExpenseCard(leave: leave);
                    //     },
                    //   )
                    //       : NoContent(
                    //     icon: kaNoLeave,
                    //     title: "No Leave Submitted!",
                    //     description:
                    //     "Ready to catch some fresh air? Click “Submit Leave” and take that well-deserved break!",
                    //   )),)
                  ],
                ),
              )),
          Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 70,
                padding: EdgeInsets.all(10.0),
                color: Colors.white,
                child: MainButton(label: "Create New Expense", onTap: (){
                  Get.to(()=>CreateExpense(), transition: Transition.fade);
                }, buttonSize: ButtonSize.sm,),
              )
          )
        ],
      ),
    );
  }
}
