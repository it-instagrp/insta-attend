import 'package:flutter/material.dart';
import 'package:insta_attend/Component/Button/main_button.dart';
import 'package:insta_attend/Component/Cards/leave_card.dart';
import 'package:insta_attend/Component/Cards/leave_history_card.dart';
import 'package:insta_attend/Component/Cards/no_content.dart';
import 'package:insta_attend/Component/Cards/toggle_card.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Controller/leave_controller.dart';
import 'package:insta_attend/View/pages/submit_leave.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class LeaveScreen extends StatelessWidget {
  LeaveScreen({super.key});

  final LeaveController controller = Get.find<LeaveController>();

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
                title: Text("Leave Summary", style: kfHeadlineSmall.copyWith(color: Colors.white),),
                subtitle: Text("Submit Leave", style: kfLabelLarge.copyWith(color: kcPurple200),),
                trailing: Image.asset(kaLeave),
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
                      child: Obx(()=>LeaveCard(usedLeave: controller.approvedLeaves.value.length, availableLeave: (11 - (controller.approvedLeaves.value.length)),)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0
                      ),
                      child: ToggleCard(items: ["Review", "Approved", "Rejected"], onSelected: (filter)=>controller.leaveFilter.value = filter),
                    ),
                    Container(
                      margin: EdgeInsets.all(18.0),
                      height: 280,
                      child: Obx(() => controller.isLoading.value
                          ? Center(
                        child: CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                          color: kcPurple600,
                        ),
                      )
                          : controller.filteredLeaves.isNotEmpty
                          ? ListView.separated(
                        separatorBuilder: (context, index) => SizedBox(height: 10.0),
                        itemCount: controller.filteredLeaves.length,
                        itemBuilder: (context, index) {
                          final leave = controller.filteredLeaves[index];
                          return LeaveHistoryCard(leave: leave);
                        },
                      )
                          : NoContent(
                        icon: kaNoLeave,
                        title: "No Leave Submitted!",
                        description:
                        "Ready to catch some fresh air? Click “Submit Leave” and take that well-deserved break!",
                      )),)
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
                child: MainButton(label: "Submit Leave", onTap: (){
                  Get.to(()=>SubmitLeave(), transition: Transition.fade);
                }, buttonSize: ButtonSize.sm,),
              )
          )
        ],
      ),
    );
  }

  String getCurrentYearPeriod() {
    DateTime now = DateTime.now();
    DateTime startOfYear = DateTime(now.year, 1, 1);
    DateTime endOfYear = DateTime(now.year, 12, 31);
    final formatter = DateFormat('d MMM yyyy');
    return 'Period of ${formatter.format(startOfYear)} - ${formatter.format(endOfYear)}';
  }

}
