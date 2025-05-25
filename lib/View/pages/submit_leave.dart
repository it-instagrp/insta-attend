import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/custom_button.dart';
import 'package:insta_attend/Component/Button/main_button.dart' as main;
import 'package:insta_attend/Component/Fields/custom_drop_down.dart';
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/leave_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Constant/constant_font.dart';

class SubmitLeave extends StatelessWidget {
  SubmitLeave({super.key});

  final LeaveController controller = Get.find<LeaveController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F3F8),
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.white,
        padding: const EdgeInsets.all(15.0),
        child: main.MainButton(label: "Submit Leave", onTap: ()=>showConfirmationDialogue(context)),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 50,
        leading: InkWell(
          onTap: ()=>Get.back(),
          child: SizedBox(
              width: 20,
              height: 20,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: SvgPicture.asset(kaBackButton, fit: BoxFit.scaleDown, width: 10, height: 10,),
              )),
        ),
        centerTitle: true,
        title: Text("Submit Leave", style: TextStyle(
          fontSize:  18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),),
      ),
      body: Container(
        margin: EdgeInsets.all(15.0),
        padding: EdgeInsets.all(
          15.0
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              isThreeLine: false,
              horizontalTitleGap: 0,
              title: Text("Fill Leave Information", style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600
              ),),
              subtitle: Text("Information about leave details", style: TextStyle(
                fontSize: 12,
                color: kcGrey500
              ),),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text("Leave Category", style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kcGrey600
              ),),
            ),
            SizedBox(height: 5,),
        Obx(() => CustomDropDown(
          options: LeaveReason.values.map((e) => e.description).toList(),
          onChanged: (value) {
            controller.leaveReason.value = LeaveReason.values.firstWhere(
                  (element) => element.description == value,
              orElse: () => LeaveReason.other,
            );
          },
          hintText: controller.leaveReason.value.description.isNotEmpty ? controller.leaveReason.value.description : "Select Leave Type",
          title: "Leave Type",
        )),
            SizedBox(
              height: 15,
            ),
            Obx(()=>CustomTextfield(title: "Leave Duration", hintText: convertDuration(controller.fromDate.value, controller.toDate.value), icon: kaDuration, controller: TextEditingController(), isDisabled: true, onTap: ()=>showDurationRangeDialog(context),))
          ],
        ),
      ),
    );
  }

  void showDurationRangeDialog(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 2)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    // Handle the picked date after the dialog is closed
    if (picked != null) {
      controller.fromDate.value = picked.start.toIso8601String().split('T')[0];
      controller.toDate.value = picked.end.toIso8601String().split('T')[0];
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Leave Duration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(convertDuration(controller.fromDate.value, controller.toDate.value), textAlign: TextAlign.center),
                SizedBox(height: 16),
                CustomButton(label: "Submit Date", onPressed: (){
                  Navigator.pop(context);
                }),
                SizedBox(height: 16),
                CustomButton(label: "Clear Range", onPressed: (){
                  controller.fromDate.value = "";
                  controller.toDate.value = "";
                  Navigator.pop(context);
                },hierarchy: ButtonHierarchy.secondary,)
              ],
            ),
          ),
        ),
      );
    }
  }


  String convertDuration(String from, String to){
    try{
      final fromDate = DateFormat("dd MMM").format(DateTime.parse(from));
      final toDate = DateFormat("dd MMM").format(DateTime.parse(to));
      return  "$fromDate - $toDate";
    }catch(e){
      return "Select Duration";
    }
  }


  void showConfirmationDialogue(BuildContext  context){
    showModalBottomSheet(
        barrierColor: Colors.black.withAlpha(180),
        context: context,
        isScrollControlled: true,
        builder: (context){
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                    ),
                    Text("Submit Leave", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    SizedBox(
                      height: 15,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text("Double-check your leave details to ensure everything is correct. Do you want to proceed?", style: kfBodyMedium.copyWith(color: kcGrey400),)),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 45,
                        width: MediaQuery.of(context).size.width,
                        child: Obx(()=>controller.isLoading.value ? Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: kcPurple600,),) : main.MainButton(label: "Submit Leave", onTap: ()=>controller.requestLeave(context)))),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 45,
                        width: MediaQuery.of(context).size.width,
                        child: CustomButton(label: "No, Let me check", onPressed: ()=>Navigator.pop(context), hierarchy: ButtonHierarchy.secondary,)),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
              Positioned(
                  left: 0,
                  right: 0,
                  top: -50,
                  child: SvgPicture.asset(kaSubmitLeaveTop))
            ],
          );
        });
  }
}
