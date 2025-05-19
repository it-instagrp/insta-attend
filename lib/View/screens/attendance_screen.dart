import 'package:flutter/material.dart';
import 'package:insta_attend/Component/Button/main_button.dart';
import 'package:insta_attend/Component/Cards/no_content.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Controller/attendance_controller.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../Component/Cards/attendance_history_card.dart';

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({super.key});

  final AttendanceController controller = Get.find<AttendanceController>();

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
                title: Text("Let's Clock-In!", style: kfHeadlineSmall.copyWith(color: Colors.white),),
                subtitle: Text("Don’t miss your clock in schedule", style: kfLabelLarge.copyWith(color: kcPurple200),),
                trailing: Image.asset(kaClockIn),
              )),
          Positioned(
              left: 0,
              right: 0,
              top: 150,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 15.0
                      ),
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Working Hour", style: kfLabelLarge,),
                          Text(getCurrentMonthPeriod(), style: kfBodySmall.copyWith(color: kcGrey500),),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _getTimeCard(title: "Today", time: controller.getTodayDuration()),
                              _getTimeCard(title: "This Pay Period", time: controller.getMonthlyDuration()),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                  width: double.maxFinite,
                                  child: Obx(()=>controller.isLoading.value ? Center(child: CircularProgressIndicator(color: kcPurple600, strokeCap: StrokeCap.round,),) : controller.isCheckIn.value ? MainButton(label: "Clock In", onTap: (){
                                    controller.clockIn(context);
                                  }, buttonSize: ButtonSize.xl,) : MainButton(label: "Clock Out", onTap: (){
                                    controller.clockOut(context);
                                  }, buttonSize: ButtonSize.xl,)))),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(18.0),
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: Obx(()=> controller.isLoading.value ? Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: kcPurple600,),) : controller.attendance.isNotEmpty ? ListView.separated(
                          separatorBuilder: (context, index)=>SizedBox(height: 10.0,),
                          itemCount: controller.attendance.value.length,
                          itemBuilder: (context, index){
                            final attendanceOne = controller.attendance[index];
                            return AttendanceHistoryCard(history: attendanceOne,);
                          }
                      ) : NoContent(icon: kaNoAttendance, title: "No Working Time Available", description: "It looks like you don’t have any working time in this period. Don’t worry, this space will be updated as new working time submitted.")),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String getCurrentMonthPeriod() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0); // last day of month

    final formatter = DateFormat('d MMM yyyy');
    return 'Paid Period of ${formatter.format(startOfMonth)} - ${formatter.format(endOfMonth)}';
  }

  Widget _getTimeCard({required String title, required String time}){
    return Container(
      padding: EdgeInsets.all(10.0),
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: kcGrey50
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.watch_later_rounded, color: kcGrey300, size: 16,),
              SizedBox(
                width: 5,
              ),
              Text(title, style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kcGrey500,
              ),),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text("${time} Hrs", style: TextStyle(
            fontSize: 20,
            color: kcBaseBlack,
          ),),
        ],
      ),
    );
  }

}
