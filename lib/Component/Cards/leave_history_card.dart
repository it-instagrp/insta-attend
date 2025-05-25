import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Model/Leave.dart';
import 'package:intl/intl.dart';

class LeaveHistoryCard extends StatelessWidget {
  final Leave leave;
  const LeaveHistoryCard({super.key, required this.leave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      width: MediaQuery.of(context).size.width,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(kaLeaveCardIcon, fit: BoxFit.scaleDown, height: 20, width: 20,),
              SizedBox(
                width: 10.0,
              ),
              Text(formatedDate(leave.createdAt ?? "NA"), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: kcGrey100,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: kcGrey200)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Leave Date",
                      style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: kcGrey500
                    ),),
                    Text(getToFrom(leave.from ?? "NA", leave.to ?? "NA"), style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                    ),),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Leaves",
                      style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: kcGrey500
                    ),),
                    Text(getLeaveDays(leave.from ?? "NA", leave.to ?? "NA"), style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                    ),),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String formatedDate(String date){
    try{
      final result = DateFormat('dd MMMM yyyy').format(DateTime.parse(date));
      return result;
    }catch(err){
      print("Something went wrong: "+err.toString());
      return "NA";
    }
  }


  String getToFrom(String fromDate, String toDate){
    try{
      final parsedFromDate = DateFormat('dd MMM').format(DateTime.parse(fromDate));
      final parsedToDate = DateFormat('dd MMM').format(DateTime.parse(toDate));
      return "${parsedFromDate} - ${parsedToDate}";
    }catch(err){
      print("Something went wrong: "+err.toString());
      return "NA";
    }
  }

  String getLeaveDays(String fromDate, String toDate){
    try{
      final parsedFromDate = DateTime.parse(fromDate);
      final parsedToDate = DateTime.parse(toDate);
      final difference = parsedToDate.difference(parsedFromDate).inDays;
      return "${difference}";
    }catch(err){
      print("Something went wrong: "+err.toString());
      return "NA";
    }
  }

}
