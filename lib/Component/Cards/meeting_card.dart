import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/custom_button.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';

class MeetingCard extends StatelessWidget {
  final String meetingTitle, time, link;
  final List attendee;
  const MeetingCard({super.key, required this.meetingTitle, required this.time, required this.link, required this.attendee});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      padding: EdgeInsets.all(13.0),
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: kcGrey100,
        border: Border.all(
          color: kcGrey200
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: kcPurple500,
                child: SvgPicture.asset(kaMeet),
              ),
              SizedBox(
                width: 5,
              ),
              Text(meetingTitle, style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black
              ),),
              Spacer(),
              Icon(Icons.watch_later, color: kcGrey300, size: 16,),
              SizedBox(
                width: 5,
              ),
              Text(time, style: TextStyle(
                color: Color(0xFF475467),
                fontSize: 12,
                fontWeight: FontWeight.w500
              ),)
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 25,
                child: Stack(
                  children: List.generate(_getAttendeeLength(attendee.length), (index) {
                    return Positioned(
                      left: (index * 15).toDouble(),
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          shape: BoxShape.circle,
                          color: kcPurple400,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (attendee.length > 3) // Only show the + if there are more than 3 attendees
                Text("+ ${attendee.length - 3}", style: TextStyle(
                    fontSize: 12,
                    color: Colors.black
                )),
              Spacer(),
              InkWell(
                onTap: (){},
                child: Container(
                  alignment: Alignment.center,
                  width: 75,
                  height: 25,
                  decoration: BoxDecoration(
                    color: kcPurple600,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text("Join Meet", style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  int _getAttendeeLength(attendeeLength){
    if(attendeeLength <= 3){
      return attendeeLength;
    } else {
      return 3;
    }
  }
}
