import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';

enum LeaveType {
  available('Available'),
  used('Leave Used');

  final String description;

  const LeaveType(this.description);
}


class LeaveCard extends StatelessWidget {
  final String periodOfLeave;
  final int availableLeave, usedLeave;
  const LeaveCard({super.key, this.periodOfLeave = "1 Jan 2025 - 30 Dec 2024", this.availableLeave = 11, this.usedLeave = 2});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 366,
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
          Text("Total Leave", style: kfLabelLarge,),
          SizedBox(
            height: 5,
          ),
          Text("Period $periodOfLeave", style: kfBodySmall,),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLeaveSection(LeaveType.available, availableLeave),
              _buildLeaveSection(LeaveType.used, usedLeave),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLeaveSection(LeaveType type, int amount){
    return Container(
      padding: EdgeInsets.all(12.0),
      height: 80,
      width: 140,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: kcGrey25,
          border: Border.all(
              color: kcGrey100,
              width: 2
          )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(_getLeaveIcon(type), fit: BoxFit.scaleDown, height: 15, width: 15,),
              SizedBox(width: 5,),
              Text(type.description, style: kfLabelMedium,),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text("${amount.toString()}", style: kfTitleLarge,)
        ],
      ),
    );
  }

  String _getLeaveIcon(LeaveType type){
    switch(type){
      case LeaveType.available:
        return kaApprovedExpense;
      case LeaveType.used:
        return kaUsedLeaves;
    }
  }
}
