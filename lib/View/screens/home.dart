import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Cards/meeting_card.dart';
import 'package:insta_attend/Component/Cards/no_content.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:insta_attend/View/pages/profile_page.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final AuthController controller = Get.find<AuthController>();

  final List<Map<String, dynamic>> meetings = [
    {
      "meetingTitle": "Huddle Meeting",
      "time": "01:30 AM - 02:00 AM",
      "attendee": ["Mustkeem Baraskar", "Rohini Raut"],
      "link": "https://www.nextechvision.in"
    },
    {
      "meetingTitle": "Huddle Meeting",
      "time": "01:30 AM - 02:00 AM",
      "attendee": ["Mustkeem Baraskar", "Rohini Raut", "Pravin Patil", "Varsha Patil"],
      "link": "https://www.nextechvision.in"
    }
  ];

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
            onTap: ()=>Get.to(()=>ProfilePage(), transition: Transition.fadeIn),
            child: CircleAvatar(
              backgroundColor: kcPurple200,
              radius: 25,
              child: ClipOval(
                child: Image.asset(kaProfile),
              ),
            ),
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(()=>Text(
                controller.currentUser.value.username ?? "NA",
                style: kfTitleMedium.copyWith(fontWeight: FontWeight.w600),
              )),
              Obx(()=>Text(
                controller.currentUser.value.designation?.designationName ?? "User",
                style: kfTitleSmall.copyWith(
                    fontWeight: FontWeight.w500, color: Color(0xFF6E62FF)),
              ))
            ],
          ),
          Spacer(),
          _buildTopIcons(),
        ],
      ),
    );
  }

  Widget _buildTopIcons() {
    return Row(
      children: [
        InkWell(
          onTap: () {},
          child: CircleAvatar(
            radius: 20,
            backgroundColor: kcPurple100,
            child: SvgPicture.asset(kaTopMessage),
          ),
        ),
        SizedBox(width: 20),
        InkWell(
          onTap: () {},
          child: CircleAvatar(
            radius: 20,
            backgroundColor: kcPurple100,
            child: SvgPicture.asset(kaTopNotification),
          ),
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
                  "My Work Summary",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "Today task & presence activity",
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
                  "Today Meeting",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 5),
                _buildMeetingBadge(),
              ],
            ),
            subtitle: Text(
              "Your Schedule for the day",
              style: TextStyle(fontSize: 12, color: Color(0xFF475467)),
            ),
          ),
          meetings.isNotEmpty
              ? Column(
            children: meetings.map((meeting) {
              return MeetingCard(
                meetingTitle: meeting["meetingTitle"],
                time: meeting["time"],
                link: meeting["link"],
                attendee: meeting["attendee"],
              );
            }).toList(),
          )
              : NoContent(
            icon: kaNoMeeting,
            title: "No Meeting Available",
            description:
            "It looks like you don’t have any meetings scheduled at the moment. This space will be updated as new meetings are added!",
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  Widget _buildMeetingBadge() {
    return Container(
      alignment: Alignment.center,
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: kcPurple100,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        meetings.length.toString(),
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: kcPurple500),
      ),
    );
  }
}
