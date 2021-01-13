import 'package:flutter/material.dart';

class Task with ChangeNotifier {
  final String taskId;
  final String taskName;
  final String taskDesc;
  final DateTime taskDeadlineDate;
  final TimeOfDay taskDeadlineTime;
  final double taskApxCompletionTime;
  final int taskApxCompletionTimeMin;
  final String taskImpIndex;
  bool taskStatus;
  String taskCreatedTime;
  double taskCompletionStatus;
  DateTime taskCompletionTime;

  Task({
    @required this.taskId,
    @required this.taskName,
    this.taskDesc = ' ',
    @required this.taskDeadlineDate,
    @required this.taskDeadlineTime,
    @required this.taskApxCompletionTime,
    this.taskApxCompletionTimeMin = 0,
    @required this.taskImpIndex,
    this.taskStatus = false,
    this.taskCreatedTime,
    this.taskCompletionStatus = 0.0,
    this.taskCompletionTime,
  });
}
