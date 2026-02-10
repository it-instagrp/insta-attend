import 'package:flutter/material.dart';
import 'package:insta_attend/Component/Button/main_button.dart';
import 'package:insta_attend/Component/Cards/attendance_history_card.dart';
import 'package:insta_attend/Component/Cards/no_content.dart';
import 'package:insta_attend/Component/Cards/task_card.dart';
import 'package:insta_attend/Component/Cards/task_detail_card.dart';
import 'package:insta_attend/Component/Cards/toggle_card.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Model/attendance_history.dart';
import 'package:insta_attend/Model/task.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class TaskScreen extends StatelessWidget {
  TaskScreen({super.key});

  RxInt selectedIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Color(0xFFF1F3F8),
      child: Stack(
        children: [
          Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: kcPurple500,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0)
                )
            ),
          ),
          Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: ListTile(
                title: Text("Challenges Awaiting", style: kfHeadlineSmall.copyWith(color: Colors.white),),
                subtitle: Text("Let’s tackle your to do list", style: kfLabelLarge.copyWith(color: kcPurple200),),
                trailing: Image.asset(kaTask),
              )),
          Positioned(
              left: 0,
              right: 0,
              top: 150,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10
                      ),
                      child: TaskCard(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ToggleCard(items: ["All", "In Progress", "Finish"], onSelected: (index){
                        selectedIndex.value = index;
                      }),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 18.0),
                      decoration: BoxDecoration(
                          color: tasks.isEmpty ? Colors.white : Color(0xFFF1F3F8),
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: tasks.isNotEmpty ? ListView.separated(
                        shrinkWrap: true,
                          separatorBuilder: (context, index)=>SizedBox(height: 10.0,),
                          itemCount: tasks.length,
                          itemBuilder: (context, index){
                            final task = tasks[index];
                            return TaskDetailCard(task: task);
                          }
                      ) : NoContent(icon: kaNoTask, title: "No Tasks Assigned", description: "It looks like you don’t have any tasks assigned to you right now. Don’t worry, this space will be updated as new tasks become available."),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String getCurrentMonthPeriod() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0); // last day of month

    final formatter = DateFormat('d MMM yyyy');
    return 'Paid Period of ${formatter.format(startOfMonth)} - ${formatter.format(endOfMonth)}';
  }

  Widget _getTimeCard({required String title, required String time}){
    return Container(
      padding: EdgeInsets.all(10.0),
      width: 140,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
              color: kcGrey50
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.watch_later_rounded, color: kcGrey300, size: 16,),
              SizedBox(
                width: 5,
              ),
              Text(title, style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kcGrey500,
              ),),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text("${time} Hrs", style: TextStyle(
            fontSize: 20,
            color: kcBaseBlack,
          ),),
        ],
      ),
    );
  }

  final List<Task> tasks = [
    Task(priority: TaskPriority.High, status: TaskStatus.InProgress, taskTitle: "Wiring Dashboard Analytics", comment: 2, deadLine: DateTime.now()),
    Task(priority: TaskPriority.High, status: TaskStatus.InProgress, taskTitle: "API Dashboard Analytics Integration", comment: 2, deadLine: DateTime.now()),
  ];
}
