import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

//import '../providers/auth.dart';
import '../providers/task.dart';
import '../screens/task_edit_screen.dart';
import '../screens/task_detail_screen.dart';

class TaskItem extends StatelessWidget {
  String _getTaskRemainingTime(String hour, int min, double completion) {
    var totalMin = (int.parse(hour) * 60) + min;
    var remainingMin = totalMin * ((100 - completion) / 100);
    var remainingTimeH = remainingMin ~/ 60 < 1 ? 0 : (remainingMin ~/ 60);
    var remainingTimeM = remainingMin - (remainingTimeH * 60);
    var remainingTime = '${remainingTimeH}h:${remainingTimeM.round()}m';
    return remainingTime;
  }

  @override
  Widget build(BuildContext context) {
    final task = Provider.of<Task>(context, listen: false);
    //final authData = Provider.of<Auth>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(5),
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            TaskDetailScreen.routeName,
            arguments: task.taskId,
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          // margin: EdgeInsets.all(5),
          elevation: 10,
          child:
              // Column(
              //   children: <Widget>[
              ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    child: FittedBox(
                      child: Text(
                        task.taskCompletionStatus < 1
                            ? '${task.taskApxCompletionTime.round()}h:${task.taskApxCompletionTimeMin}m'
                            : _getTaskRemainingTime(
                                task.taskApxCompletionTime
                                    .toString()
                                    .split('.')[0],
                                task.taskApxCompletionTimeMin,
                                task.taskCompletionStatus),
                        softWrap: true,
                      ),
                    ),
                  ),
                  title: Text(
                    '${task.taskName.toUpperCase()} - ${task.taskImpIndex} ',
                    //- ${DateTime.parse(task.taskCreatedTime).year}-${DateTime.parse(task.taskCreatedTime).month}-${DateTime.parse(task.taskCreatedTime).day}
                    softWrap: true,
                  ),
                  subtitle: Text(
                    'Target: ${DateFormat.yMd().format(task.taskDeadlineDate)} ${task.taskDeadlineTime.hour}:${task.taskDeadlineTime.minute}',
                    softWrap: true,
                  ),
                  trailing: task.taskStatus
                      ? null
                      // ? CircleAvatar(
                      //     backgroundColor: Colors.green,
                      //   )
                      : CircleAvatar(
                          child: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => Navigator.of(context).pushNamed(
                                    TaskEditScreen.routeName,
                                    arguments: task.taskId,
                                  )),
                          backgroundColor: Colors.blueAccent,
                        ),
                  tileColor: DateTime(
                              task.taskDeadlineDate.year,
                              task.taskDeadlineDate.month,
                              task.taskDeadlineDate.day,
                              task.taskDeadlineTime.hour,
                              task.taskDeadlineTime.minute)
                          .subtract(Duration(
                              hours: task.taskApxCompletionTime.round(),
                              minutes: task.taskApxCompletionTimeMin))
                          .isBefore(DateTime.now())
                      //
                      ? task.taskStatus
                          ? Colors.green[200]
                          : Colors.red[200]
                      : task.taskStatus
                          ? Colors.green[200]
                          : Colors.blue[150],
                ),
                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                  minHeight: 5,
                  value:
                      task.taskStatus ? 1 : (task.taskCompletionStatus / 100),
                )
              ],
            ),
          ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
