import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Controller/attendance_controller.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:insta_attend/View/pages/profile_page.dart';
import 'package:intl/intl.dart';
import 'package:popover/popover.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final AuthController controller = Get.find<AuthController>();
  final AttendanceController attendanceController = Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          _buildProfileSection(context),
          SizedBox(height: 20),
          _buildWorkSummarySection(),
          SizedBox(height: 15),
          _buildMeetingsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => Get.to(() => ProfilePage(), transition: Transition.fade),
            child: CircleAvatar(
              backgroundColor: kcPurple200,
              radius: 25,
              child: ClipOval(
                child: Image.asset(kaProfile),
              ),
            ),
          ),
          SizedBox(width: 10),

          /// 🔧 Wrap in Expanded to take available space
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.currentUser.value.username ?? "NA",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kfTitleMedium.copyWith(fontWeight: FontWeight.w600),
                )),
                Obx(() => Text(
                  controller.currentUser.value.designation?.designationName ?? "User",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kfTitleSmall.copyWith(
                      fontWeight: FontWeight.w500, color: Color(0xFF6E62FF)),
                )),
              ],
            ),
          ),

          /// Push icons to the end
          _buildTopIcons(context),
        ],
      ),
    );
  }

  Widget _buildTopIcons(BuildContext context) {
    return Row(
      children: [
        Builder(
            builder: (context) {
              return InkWell(
                onTap: () {
                  showMessages(context);
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: kcPurple100,
                  child: SvgPicture.asset(kaTopMessage),
                ),
              );
            }
        ),
        SizedBox(width: 20),
        Builder(
            builder: (context) {
              return InkWell(
                onTap: () {
                  showNotifications(context);
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: kcPurple100,
                  child: SvgPicture.asset(kaTopNotification),
                ),
              );
            }
        ),
      ],
    );
  }

  Widget _buildWorkSummarySection() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Color(0xFF795FFC),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: 0,
            bottom: 0,
            child: Image.asset(
              kaExploreCamera,
              width: 120,
              height: 85,
            ),
          ),
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "Please check your status and update",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMeetingsSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Row(
              children: [
                Text(
                  "Current Status",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 5),
              ],
            ),
            subtitle: Text(
              "Your status for attendance",
              style: TextStyle(fontSize: 12, color: Color(0xFF475467)),
            ),
          ),
          _buildAttendanceStatus(),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  void showNotifications(BuildContext context){
    showPopover(
        arrowHeight: 0,
        arrowWidth: 0,
        context: context,
        bodyBuilder: (context){
          return Container(
            height: 100,
            width: 200,
            child: Center(
              child: Text("No new notifications"),
            ),
          );
        });
  }

  void showMessages(BuildContext context){
    showPopover(
        arrowHeight: 0,
        arrowWidth: 0,
        context: context,
        bodyBuilder: (context){
          return Container(
            height: 100,
            width: 200,
            child: Center(
              child: Text("No new messages"),
            ),
          );
        });
  }

  Widget _buildAttendanceStatus() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Card with fixed width
              SizedBox(
                width: 140,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: kcGrey100,
                      border: Border.all(color: kcGrey200)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: kcGrey500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Obx(
                            () => Text(
                          attendanceController.attendanceStatus.value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: kcGrey500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Time Card with fixed width
              SizedBox(
                width: 140,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: kcGrey100,
                      border: Border.all(color: kcGrey200)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Time",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: kcGrey500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Obx(() {
                        String timeToDisplay = '';
                        String timeString = '';
                        if (attendanceController.attendanceStatus.value == "Checked In") {
                          timeString = attendanceController.checkInTime.value;
                        } else if (attendanceController.attendanceStatus.value == "Checked Out") {
                          timeString = attendanceController.checkOutTime.value;
                        }

                        if (timeString.isNotEmpty) {
                          try {
                            final dateTime = DateTime.parse(timeString).toLocal();
                            timeToDisplay = DateFormat('h:mm a').format(dateTime);
                          } catch (e) {
                            print('Error parsing time: $e');
                            timeToDisplay = 'N/A';
                          }
                        }
                        return Text(
                          timeToDisplay,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: kcGrey500,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: kcGrey100,
                border: Border.all(color: kcGrey200)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Address",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kcGrey500,
                  ),
                ),
                SizedBox(height: 5),
                Obx(() {
                  String addressToDisplay = '';
                  if (attendanceController.attendanceStatus.value == "Checked In") {
                    addressToDisplay = attendanceController.checkInAddress.value;
                  } else if (attendanceController.attendanceStatus.value == "Checked Out") {
                    addressToDisplay = attendanceController.checkOutAddress.value;
                  }
                  return Text(
                    addressToDisplay,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kcGrey500,
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          WorkDurationProgressBar(),
        ],
      ),
    );
  }
}

class WorkDurationProgressBar extends StatelessWidget {
  final AttendanceController controller = Get.find<AttendanceController>();
  final double targetHours = 8.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalMinutes = controller.todayWorkDuration.value.inMinutes;
      final totalTargetMinutes = targetHours * 60;
      final progress = (totalMinutes / totalTargetMinutes).clamp(0.0, 1.0);

      Color progressColor;
      if (totalMinutes < 4 * 60) {
        progressColor = Colors.red;
      } else if (totalMinutes < 6 * 60) {
        progressColor = Colors.yellow;
      } else {
        progressColor = Colors.green;
      }

      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      final formattedTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Work', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('$formattedTime / ${targetHours.toStringAsFixed(0)}h'),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: kcGrey200,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    });
  }
}