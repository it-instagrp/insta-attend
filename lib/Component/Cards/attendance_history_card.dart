import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Model/Attendance.dart';
import 'package:insta_attend/Model/attendance_history.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryCard extends StatelessWidget {
  final Attendance history;
  const AttendanceHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0
      ),
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_changeToDay(history.date ?? DateTime.now().toString())),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.0
            ),
            decoration: BoxDecoration(
              color: kcGrey100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kcGrey200
              )
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: ListTile(
                      isThreeLine: false,
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Total Hours", style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: kcGrey500
                      ),),
                      subtitle: Text(_getTime(history.duration ?? "00:00"), style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kcGrey600
                      ),),
                    )),
                Expanded(
                    child: ListTile(
                      isThreeLine: false,
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Check in & out", style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kcGrey500
                      ),),
                      subtitle: Text("${_getTime(history.checkInTime ?? DateTime.now().toString())} - ${_getTime(history.checkOutTime ?? DateTime.now().toString())}", style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kcGrey600
                      ),),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Change to day format: dd MMM yyyy
  String _changeToDay(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat("dd MMM yyyy").format(parsedDate);
    } catch (e) {
      return "Invalid Date"; // Fallback in case of invalid date format
    }
  }

  // Get time in hh:mm format
  String _getTime(String time) {
    if (time == "null" || time == null) return "N/A"; // Handle null check for empty or missing time

    try {
      // Check if the time is in DateTime format or string
      if (time.contains("T")) {
        // If time contains "T", it's a full DateTime string (ISO 8601 format)
        DateTime parsedTime = DateTime.parse(time);
        return DateFormat("HH:mm").format(parsedTime);
      } else {
        // Otherwise, it's already in the "hh:mm" format (like duration)
        List<String> timeParts = time.split(":");
        if (timeParts.length == 2) {
          String hours = timeParts[0];
          String minutes = timeParts[1];
          return "$hours:$minutes"; // Return formatted time as "hh:mm"
        } else {
          return "00:00"; // Fallback if the time string is not in "hh:mm" format
        }
      }
    } catch (e) {
      return "Invalid Time"; // Fallback in case of any error
    }
  }

}
