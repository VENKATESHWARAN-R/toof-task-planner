import 'dart:convert';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import './task.dart';
import '../models/http_exception.dart';
import 'task.dart';

class Tasks with ChangeNotifier {
  List<Task> _taskList = [];
  final String authToken;
  final String userId;
  List<Task> _prioratizedTaskList = [];

  Tasks(
    this.authToken,
    this.userId,
    this._taskList,
  );

  List<Task> get taskList {
    return [..._taskList];
  }

  List<Task> get prioratizedTaskList {
    return [..._prioratizedTaskList];
  }

  List<Task> get completedTasks {
    return _taskList.where((element) => element.taskStatus).toList();
  }

  List<Task> get activeTasks {
    return _taskList.where((element) => !element.taskStatus).toList();
  }

  Task findByID(String id) {
    return _taskList.firstWhere((element) => element.taskId == id);
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.Hm(); //"17:00"
    return format.format(dt);
  }

  TimeOfDay _getTimeFromString(String time) {
    var timeval;
    int hour;
    int minutes;
    // String timeOfDayEve;
    // timeOfDayEve = time.split(' ')[1];
    hour = int.parse(time.split(':')[0]);
    minutes = int.parse(time.split(':')[1]);
    // if (timeOfDayEve.trim() == 'PM') {
    //   hour = hour + 12;
    // }
    timeval = TimeOfDay(hour: hour, minute: minutes);
    return timeval;
  }

  String _getTaskRemainingTime(String hour, int min, double completion) {
    var totalMin = (int.parse(hour) * 60) + min;
    var remainingMin = totalMin * ((100 - completion) / 100);
    var remainingTimeH = remainingMin ~/ 60 < 1 ? 0 : (remainingMin ~/ 60);
    var remainingTimeM = remainingMin - (remainingTimeH * 60);
    var remainingTime = '$remainingTimeH:${remainingTimeM.round()}';
    return remainingTime;
  }

  double _findPriority(Task currentTask) {
    String remainingTimeToComplete = _getTaskRemainingTime(
        currentTask.taskApxCompletionTime.toString().split('.')[0],
        currentTask.taskApxCompletionTimeMin,
        currentTask.taskCompletionStatus);
    int remainingHours = int.parse(remainingTimeToComplete.split(':')[0]);
    int remainingMin = int.parse(remainingTimeToComplete.split(':')[1]);
    // int remainingHours = currentTask.taskApxCompletionTime.round();
    // int remainingMin = currentTask.taskApxCompletionTimeMin.round();
    if (currentTask.taskCompletionStatus < 1) {
      remainingHours = currentTask.taskApxCompletionTime.round();
      remainingMin = currentTask.taskApxCompletionTimeMin.round();
    }
    DateTime timeToDeadline = DateTime(
      currentTask.taskDeadlineDate.year,
      currentTask.taskDeadlineDate.month,
      currentTask.taskDeadlineDate.day,
      currentTask.taskDeadlineTime.hour,
      currentTask.taskDeadlineTime.minute,
    ).subtract(
      Duration(
        hours: remainingHours,
        minutes: remainingMin,
      ),
    );

    int availableTime = timeToDeadline.difference(DateTime.now()).inMinutes;
    print(availableTime);
    int impIndex = 1;
    if (currentTask.taskImpIndex == 'High') {
      impIndex = 3;
    } else if (currentTask.taskImpIndex == 'Medium') {
      impIndex = 2;
    }
    double priorityIndex =
        impIndex / (availableTime == 0 ? 0.1 : availableTime);
    print('Till this works');
    if (availableTime.isNegative) {
      double negativePlaceHolder = 0;
      print(negativePlaceHolder.isNegative);
      print('but this also works $negativePlaceHolder');
      priorityIndex = impIndex.toDouble() * availableTime.toDouble();
    }
    // print('Priority index for this element is $priorityIndex');
    print(priorityIndex);
    return priorityIndex;
  }

  Map _mapSorter(Map<String, double> currentMap, bool isNeg) {
    // print('I m in map sorter');
    var sortedKeys = currentMap.keys.toList(growable: false)
      ..sort((k1, k2) => currentMap[k1].compareTo(currentMap[k2]));
    print('sorted keys $sortedKeys');
    Map sortedMap = new Map.fromIterable(
        isNeg ? sortedKeys : sortedKeys.reversed,
        key: (k) => k.toString(),
        value: (k) => currentMap[k]) as Map<String, double>;
    print('sorted map $sortedMap');
    return sortedMap;
  }

  void _prioratizeTasks() {
    if (_taskList.isEmpty) {
      return;
    }
    double priority;
    final Map<String, double> _negativePriority = {};
    final Map<String, double> _priority = {};
    Map<String, double> _negativePriorityMap;
    Map<String, double> _priorityMap;
    activeTasks.forEach((element) {
      priority = _findPriority(element);
      // print('PRiority - $priority');
      if (priority.isNegative) {
        _negativePriority[element.taskId.toString()] = priority;
        return;
      }
      // print('I am adding the priority to priority map');
      _priority[element.taskId.toString()] = priority;
      // print('I have added the priority to priority map');
      // print('priority map - $_priority');
    });
    _priorityMap = _mapSorter(_priority, false);
    _negativePriorityMap = _mapSorter(_negativePriority, true);
    _negativePriorityMap.addAll(_priorityMap);
    // print('_negativePriorityMap $_negativePriorityMap');
    if (_prioratizedTaskList.isNotEmpty) {
      // print('Priority list cleared');
      _prioratizedTaskList.clear();
    }
    print('_negativePriorityMap $_negativePriorityMap');
    _negativePriorityMap.forEach((key, value) {
      print(value);
      // print('I am adding elements to the list');
      _prioratizedTaskList
          .add(activeTasks.firstWhere((element) => element.taskId == key));
    });
    print('_prioratized tasks $_prioratizedTaskList');
    // print('I have added elements to the list');
  }

  Future<void> fetchAndSetTasks() async {
    var url =
        'https://task-planner-33be4-default-rtdb.firebaseio.com/tasks/$userId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      final List<Task> loadedTasks = [];
      TimeOfDay _deadLineTime;
      String timeofday;
      extractedData.forEach((prodId, prodData) {
        timeofday = prodData['taskDeadlineTime'];
        if (timeofday != null) {
          _deadLineTime = _getTimeFromString(timeofday);
        }
        print('Throwing error 1');
        // _startTime = TimeOfDay(
        //     hour: int.parse(timeofday.split(":")[0]),
        //     minute: int.parse(timeofday.split(":")[1]));
        loadedTasks.add(
          Task(
            taskId: prodId,
            taskName: prodData['taskName'],
            taskApxCompletionTime: prodData['taskApxCompletionTime'],
            taskApxCompletionTimeMin:
                int.parse(prodData['taskApxCompletionTimeMin'].toString()),
            taskDeadlineDate: prodData['taskDeadlineDate'] == null
                ? null
                : DateTime.parse(prodData['taskDeadlineDate']),
            taskDeadlineTime: timeofday == null ? null : _deadLineTime,
            taskImpIndex: prodData['taskImpIndex'],
            taskCreatedTime: prodData['taskCreatedTime'],
            taskDesc: prodData['taskDesc'],
            taskStatus: prodData['taskStatus'],
            taskCompletionStatus: prodData['taskCompletionStatus'],
            taskCompletionTime: prodData['taskCompletionTime'] == null
                ? null
                : DateTime.parse(prodData['taskCompletionTime']),
          ),
        );
      });
      print('Throwing error 2');
      _taskList = loadedTasks;
      print('Throwing error 3');
      _prioratizeTasks();
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addTask(Task newTask) async {
    final url =
        'https://task-planner-33be4-default-rtdb.firebaseio.com/tasks/$userId.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'taskName': newTask.taskName,
          'taskApxCompletionTime': newTask.taskApxCompletionTime,
          'taskApxCompletionTimeMin': newTask.taskApxCompletionTimeMin,
          'taskDeadlineDate': newTask.taskDeadlineDate.toIso8601String(),
          'taskDeadlineTime': _formatTimeOfDay(newTask.taskDeadlineTime),
          'taskImpIndex': newTask.taskImpIndex,
          'taskCreatedTime': newTask.taskCreatedTime,
          'taskCreatorId': userId,
          'taskDesc': newTask.taskDesc,
          'taskStatus': newTask.taskStatus,
          'taskCompletionStatus': newTask.taskCompletionStatus,
          'taskCompletionTime': newTask.taskCompletionTime,
        }),
      );
      final newTaskLocal = Task(
        taskId: json.decode(response.body)['name'],
        taskName: newTask.taskName,
        taskApxCompletionTime: newTask.taskApxCompletionTime,
        taskApxCompletionTimeMin: newTask.taskApxCompletionTimeMin,
        taskDeadlineDate: newTask.taskDeadlineDate,
        taskDeadlineTime: newTask.taskDeadlineTime,
        taskImpIndex: newTask.taskImpIndex,
        taskCreatedTime: newTask.taskCreatedTime,
        taskDesc: newTask.taskDesc,
        taskStatus: newTask.taskStatus,
        taskCompletionTime: newTask.taskCompletionTime,
      );
      _taskList.add(newTaskLocal);
      _prioratizeTasks();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateTask(String id, Task newTask) async {
    final prodIndex = _taskList.indexWhere((prod) => prod.taskId == id);
    if (prodIndex >= 0) {
      final url =
          'https://task-planner-33be4-default-rtdb.firebaseio.com/tasks/$userId/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'taskName': newTask.taskName,
            'taskApxCompletionTime': newTask.taskApxCompletionTime,
            'taskApxCompletionTimeMin': newTask.taskApxCompletionTimeMin,
            'taskDeadlineDate': newTask.taskDeadlineDate.toIso8601String(),
            'taskDeadlineTime': _formatTimeOfDay(newTask.taskDeadlineTime),
            'taskImpIndex': newTask.taskImpIndex,
            'taskCreatedTime': newTask.taskCreatedTime,
            'taskDesc': newTask.taskDesc,
            'taskStatus': newTask.taskStatus,
            'taskCompletionStatus': newTask.taskCompletionStatus,
            'taskCompletionTime':
                newTask.taskStatus ? DateTime.now().toIso8601String() : null,
          }));
      _taskList[prodIndex] = newTask;
      _prioratizeTasks();
      notifyListeners();
    } else {
      print(
          'Product not found for updating - Method updateTask - File providers/tasks.dart');
    }
  }

  Future<void> deleteTask(String id) async {
    final url =
        'https://task-planner-33be4-default-rtdb.firebaseio.com/tasks/$id.json?auth=$authToken';
    final existingProductIndex =
        _taskList.indexWhere((prod) => prod.taskId == id);
    var existingProduct = _taskList[existingProductIndex];
    _taskList.removeAt(existingProductIndex);
    _prioratizeTasks();
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _taskList.insert(existingProductIndex, existingProduct);
      _prioratizeTasks();
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
