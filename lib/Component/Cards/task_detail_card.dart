import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:intl/intl.dart';
import '../../Model/task.dart';

class TaskDetailCard extends StatelessWidget {
  final Task task;
  TaskDetailCard({super.key, required this.task});

  final RxDouble progress = 0.6.obs;

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: kcPurple500,
              radius: 14,
              child: SvgPicture.asset(kaTaskIcon),
            ),
            title: Text(task.taskTitle, style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black
            ),),
          ),
          Row(
            children: [
              SizedBox(
                width: 20.0,
              ),
              Chip(
                  backgroundColor: kcGrey200,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.circular(100.0)
                  ),
                  label: Text(task.status.name, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: kcGrey600
                  ),)),
              SizedBox(
                width: 10.0,
              ),
              Chip(
                  backgroundColor: _getPriorityColor(task.priority),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.circular(100.0)
                  ),
                  label: Text(task.priority.name, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white
                  ),)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Obx(() => SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: SliderComponentShape.noThumb, // Hides the thumb
                overlayShape: SliderComponentShape.noOverlay, // Removes ripple
                trackHeight: 8.0, // Optional: customize track height
              ),
              child: Slider(
                activeColor: kcPurple600,
                inactiveColor: Color(0xFFE7E7E7),
                value: progress.value,
                onChanged: (value) {
                  progress.value = value;
                },
              ),
            )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(kaCalender),
              SizedBox(width: 5,),
              Text(DateFormat("dd MMM").format(task.deadLine)),
              SizedBox(
                width: 20.0,
              ),
              SvgPicture.asset(kaCalender),
              SizedBox(width: 5,),
              Text(DateFormat("dd MMM").format(task.deadLine))
            ],
          )
        ],
      ),
    );
  }
  
  Color _getPriorityColor(TaskPriority priority){
    switch(priority){
      case TaskPriority.Low:
        return kcSuccess400;
      case TaskPriority.Medium:
        return kcWarning400;
      case TaskPriority.High:
        return kcError400;
    }
  }
}
