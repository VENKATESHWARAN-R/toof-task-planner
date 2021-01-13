import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// import './task_edit_screen.dart';
import '../providers/task.dart';
import '../providers/tasks.dart';

class TaskDetailScreen extends StatefulWidget {
  static const routeName = '/taskDetailScreen';

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  // String taskId;
  // DateTime remainingTime;
  // DateTime targetBy;
  // bool isTargetOver = false;
  // int availableMinutes;
  var _detailTask = Task(
    taskId: null,
    taskName: '',
    taskDeadlineDate: null,
    taskDeadlineTime: null,
    taskApxCompletionTime: null,
    taskApxCompletionTimeMin: 0,
    taskImpIndex: 'Medium',
    taskCreatedTime: null,
    taskDesc: null,
    taskStatus: false,
    taskCompletionStatus: 0,
  );

  @override
  void didChangeDependencies() {
    final taskId = ModalRoute.of(context).settings.arguments as String;
    _detailTask = Provider.of<Tasks>(context, listen: false).findByID(taskId);
    // targetBy = DateTime(
    //     _detailTask.taskDeadlineDate.year,
    //     _detailTask.taskDeadlineDate.month,
    //     _detailTask.taskDeadlineDate.day,
    //     _detailTask.taskDeadlineTime.hour,
    //     _detailTask.taskDeadlineTime.minute);
    // remainingTime = targetBy
    //     .subtract(Duration(hours: _detailTask.taskApxCompletionTime.round()));
    // isTargetOver = remainingTime.isBefore(targetBy);
    // availableMinutes = targetBy.difference(remainingTime).inMinutes;
    super.didChangeDependencies();
  }

  // Widget buildContainer(Widget child) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       border: Border.all(color: Colors.grey),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     margin: EdgeInsets.all(10),
  //     padding: EdgeInsets.all(10),
  //     // height: 150,
  //     width: double.infinity,
  //     child: child,
  //   );
  // }

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        // actions: <Widget>[
        //   IconButton(
        //       icon: Icon(Icons.edit),
        //       onPressed: () {
        //         Navigator.of(context).pushNamed(
        //           TaskEditScreen.routeName,
        //           arguments: _detailTask.taskId,
        //         );
        //       }),
        // ],
      ),
      body: Container(
        decoration: BoxDecoration(
          // color: Colors.white70,
          gradient: LinearGradient(
            colors: [
              Colors.cyan,
              Colors.lightGreen,
              // Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
              // Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 1],
          ),
        ),
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                height: 40,
                width: double.infinity,
                child: Text(
                  '${_detailTask.taskName.toUpperCase()}',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Anton',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextFormField(
                readOnly: true,
                maxLines: 10,
                initialValue: '${_detailTask.taskDesc}',
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              Divider(height: 5),
              Container(
                height: 50,
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Assigned Time'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                          '${_detailTask.taskApxCompletionTime.round()}hours ${_detailTask.taskApxCompletionTimeMin}minutes'),
                    ),
                  ],
                ),
              ),
              // Divider(
              //   height: 5,
              // ),
              Container(
                height: 50,
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Target on'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                          '${DateFormat.yMd().format(_detailTask.taskDeadlineDate)} ${_detailTask.taskDeadlineTime.hour}:${_detailTask.taskDeadlineTime.minute}'),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Priority'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text('${_detailTask.taskImpIndex}'),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Needed time '),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        _detailTask.taskCompletionStatus < 1
                            ? '${_detailTask.taskApxCompletionTime.round()}h:${_detailTask.taskApxCompletionTimeMin}m'
                            : _getTaskRemainingTime(
                                _detailTask.taskApxCompletionTime
                                    .toString()
                                    .split('.')[0],
                                _detailTask.taskApxCompletionTimeMin,
                                _detailTask.taskCompletionStatus),
                      ),
                      // ${targetBy.difference(remainingTime).inMinutes}
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                padding: EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                          'Completed ${_detailTask.taskCompletionStatus.round()}%'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: LinearProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                        valueColor: AlwaysStoppedAnimation(Colors.green),
                        minHeight: 5,
                        value: _detailTask.taskStatus
                            ? 1
                            : (_detailTask.taskCompletionStatus / 100),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
