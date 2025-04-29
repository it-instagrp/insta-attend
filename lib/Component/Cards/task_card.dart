import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';

enum TaskType{
  todo, inprogress, completed
}

class TaskCard extends StatelessWidget {
  final int todoTask, inprogressTask, completedTask;
  const TaskCard({super.key, this.completedTask = 0, this.todoTask = 0, this.inprogressTask = 0});

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
          Text("Summary of Your Work", style: kfLabelLarge,),
          SizedBox(
            height: 5,
          ),
          Text("Your current task progress", style: kfBodySmall,),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTaskSection(TaskType.todo, todoTask),
              _buildTaskSection(TaskType.inprogress, inprogressTask),
              _buildTaskSection(TaskType.completed, completedTask),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTaskSection(TaskType type, int amount){
    return Container(
      padding: EdgeInsets.all(12.0),
      height: 80,
      width: 110,
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
              SvgPicture.asset(_getTaskIcon(type), fit: BoxFit.scaleDown, height: 15, width: 15,),
              SizedBox(width: 5,),
              Text(_getTaskTitle(type), style: kfLabelMedium,),
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

  String _getTaskTitle(TaskType type){
    switch(type){
      case TaskType.todo:
        return "Todo";
      case TaskType.inprogress:
        return "In Progress";
      case TaskType.completed:
        return "Completed";
    }
  }

  String _getTaskIcon(TaskType type){
    switch(type){
      case TaskType.todo:
        return kaTodo;
      case TaskType.inprogress:
        return kaInprogress;
      case TaskType.completed:
        return kaCompleted;
    }
  }
}
