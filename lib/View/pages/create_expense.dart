import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/custom_button.dart';
import 'package:insta_attend/Component/Button/main_button.dart' as main;
import 'package:insta_attend/Component/Fields/custom_drop_down.dart';
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/expense_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Constant/constant_font.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateExpense extends StatelessWidget {
  CreateExpense({super.key});

  final ExpenseController controller = Get.find<ExpenseController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F3F8),
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.white,
        padding: const EdgeInsets.all(15.0),
        child: main.MainButton(
          label: "Submit Expense",
          onTap: () => showConfirmationDialogue(context),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 50,
        leading: InkWell(
          onTap: () => Get.back(),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: SvgPicture.asset(
                kaBackButton,
                fit: BoxFit.scaleDown,
                width: 10,
                height: 10,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Create Expense",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101828),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(15.0),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              isThreeLine: false,
              horizontalTitleGap: 0,
              title: Text(
                "Fill Expense Information",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                "Information about expense details",
                style: TextStyle(fontSize: 12, color: kcGrey500),
              ),
            ),

            // Expense Type Dropdown
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Expense Type",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kcGrey600,
                ),
              ),
            ),
            SizedBox(height: 5),
            Obx(
                  () => CustomDropDown(
                options: controller.expenseType,
                onChanged: (value) {
                  controller.selectedExpenseType.value = value ?? '';
                },
                hintText: controller.selectedExpenseType.value.isNotEmpty
                    ? controller.selectedExpenseType.value
                    : "Select Expense Type",
                title: "Expense Type",
              ),
            ),
            SizedBox(height: 15),

            // Amount Field
            CustomTextField(
              title: "Amount",
              hintText: "Enter amount",
              icon: kaExpenseIcon,
              controller: controller.amountController,
              isDisabled: false,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 15),

            // Expense Date Field
            Obx(
                  () => CustomTextField(
                title: "Expense Date",
                hintText: controller.expenseDate.value.isNotEmpty
                    ? formatDate(controller.expenseDate.value)
                    : "Select Date",
                icon: kaDuration,
                controller: TextEditingController(),
                isDisabled: true,
                onTap: () => showDatePickerDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDatePickerDialog(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.expenseDate.value = picked.toIso8601String().split('T')[0];
    }
  }

  String formatDate(String date) {
    try {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
    } catch (e) {
      return "Select Date";
    }
  }

  void _showImageSourcePicker(BuildContext context){
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => SafeArea(
          child: Column(
           mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                "Upload Receipt",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: kcPurple500,),
                title: Text("Take a photo"),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickReceiptImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: kcPurple500),
                title: Text("Choose from gallery"),
                onTap: (){
                  Navigator.pop(context);
                  controller.pickReceiptImage(context, ImageSource.gallery);
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
    );
  }

  void showConfirmationDialogue(BuildContext context) {
    showModalBottomSheet(
      barrierColor: Colors.black.withAlpha(180),
      context: context,
      isScrollControlled: true,
      builder: (context) {
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
                  SizedBox(height: 60),
                  Text(
                    "Submit Expense",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Receipt Image",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5,),
                      controller.pickedReceiptImage.value != null
                      ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              controller.pickedReceiptImage.value!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            bottom: 5,
                            child: InkWell(
                              onTap: () => controller.pickedReceiptImage.value = null,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close, color: Colors.white, size: 16,),
                              ),
                            ),
                          )
                        ],
                      ) : InkWell(
                        onTap: () => _showImageSourcePicker(context),
                        child: Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kcGrey400),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_outlined, color: kcGrey400 ,),
                              SizedBox(height: 5,),
                              Text(
                                "Upload Receipt",
                                style: TextStyle(color: kcGrey400, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Double-check your expense details to ensure everything is correct. Do you want to proceed?",
                      style: kfBodyMedium.copyWith(color: kcGrey400),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    height: 45,
                    width: MediaQuery.of(context).size.width,
                    child: Obx(
                          () => controller.isLoading.value
                          ? Center(
                        child: CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                          color: kcPurple600,
                        ),
                      )
                          : main.MainButton(
                        label: "Submit Expense",
                        onTap: () => controller.createExpense(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 45,
                    width: MediaQuery.of(context).size.width,
                    child: CustomButton(
                      label: "No, Let me check",
                      onPressed: () => Navigator.pop(context),
                      hierarchy: ButtonHierarchy.secondary,
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -50,
              child: SvgPicture.asset(kaSubmitLeaveTop),
            ),
          ],
        );
      },
    );
  }
}