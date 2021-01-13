import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/task.dart';
import '../providers/tasks.dart';

class TaskEditScreen extends StatefulWidget {
  static const routeName = '/taskEditScreen';
  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _form = GlobalKey<FormState>();
  String _currentSelectedValue;
  static const List<String> _priorityIndex = ['High', 'Medium', 'Low'];
  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  double completionValue = 0;
  // final _taskTitleFocusNode = FocusNode();
  // final _taskDescFocusNode = FocusNode();
  // final _taskApxCompletionTimeNode = FocusNode();

  var _editedTask = Task(
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
    taskCompletionTime: null,
  );
  var _initValues = {
    'taskName': '',
    'taskDeadlineDate': null,
    'taskDeadlineTime': null,
    'taskApxCompletionTime': null,
    'taskApxCompletionTimeMin': 0,
    'taskImpIndex': 'Medium',
    'taskCreatedTime': null,
    'taskDesc': '',
    'taskStatus': false,
    'taskCompletionStatus': 0,
    'taskCompletionTime': null,
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final taskId = ModalRoute.of(context).settings.arguments as String;
      if (taskId != null) {
        _editedTask =
            Provider.of<Tasks>(context, listen: false).findByID(taskId);
        _initValues = {
          'taskName': _editedTask.taskName,
          'taskDeadlineDate': _editedTask.taskDeadlineDate,
          'taskDeadlineTime': _editedTask.taskDeadlineTime,
          'taskApxCompletionTime': _editedTask.taskApxCompletionTime,
          'taskApxCompletionTimeMin': _editedTask.taskApxCompletionTimeMin,
          'taskImpIndex': _editedTask.taskImpIndex,
          'taskCreatedTime': _editedTask.taskCreatedTime,
          'taskDesc': _editedTask.taskDesc,
          'taskStatus': _editedTask.taskStatus,
          'taskCompletionStatus': _editedTask.taskCompletionStatus,
          'taskCompletionTime': _editedTask.taskCompletionTime,
        };
        completionValue = _editedTask.taskCompletionStatus;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    final DateTime currentTime = DateTime.now().toLocal();
    if (!isValid) {
      return;
    }
    if (_editedTask.taskId != null) {
    } else {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select Date and Time values for deadline',
            ),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedTask.taskId != null) {
      await Provider.of<Tasks>(context, listen: false)
          .updateTask(_editedTask.taskId, _editedTask);
    } else {
      try {
        _editedTask = Task(
          taskId: _editedTask.taskId,
          taskName: _editedTask.taskName,
          taskDeadlineDate: _editedTask.taskDeadlineDate,
          taskDeadlineTime: _editedTask.taskDeadlineTime,
          taskApxCompletionTime: _editedTask.taskApxCompletionTime,
          taskApxCompletionTimeMin: _editedTask.taskApxCompletionTimeMin,
          taskImpIndex: _editedTask.taskImpIndex,
          taskCreatedTime: currentTime.toIso8601String(),
          taskDesc: _editedTask.taskDesc,
          taskStatus: _editedTask.taskStatus,
          taskCompletionStatus: completionValue,
          taskCompletionTime: _editedTask.taskCompletionTime,
        );
        await Provider.of<Tasks>(context, listen: false).addTask(_editedTask);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void _presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: _selectedDate == null ? DateTime.now() : _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2044),
            helpText: 'Choose Deadline Date')
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        _editedTask = Task(
          taskId: _editedTask.taskId,
          taskName: _editedTask.taskName,
          taskDeadlineDate: _selectedDate,
          taskDeadlineTime: _editedTask.taskDeadlineTime,
          taskApxCompletionTime: _editedTask.taskApxCompletionTime,
          taskApxCompletionTimeMin: _editedTask.taskApxCompletionTimeMin,
          taskImpIndex: _editedTask.taskImpIndex,
          taskCreatedTime: _editedTask.taskCreatedTime,
          taskDesc: _editedTask.taskDesc,
          taskStatus: _editedTask.taskStatus,
          taskCompletionStatus: completionValue,
          taskCompletionTime: _editedTask.taskCompletionTime,
        );
      });
    });
    print('...');
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _selectedTime == null ? TimeOfDay.now() : _selectedTime,
      helpText: 'Choose The Deadline Time',
    ).then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTime = pickedTime;
        _editedTask = Task(
          taskId: _editedTask.taskId,
          taskName: _editedTask.taskName,
          taskDeadlineDate: _editedTask.taskDeadlineDate,
          taskDeadlineTime: _selectedTime,
          taskApxCompletionTime: _editedTask.taskApxCompletionTime,
          taskApxCompletionTimeMin: _editedTask.taskApxCompletionTimeMin,
          taskImpIndex: _editedTask.taskImpIndex,
          taskCreatedTime: _editedTask.taskCreatedTime,
          taskDesc: _editedTask.taskDesc,
          taskStatus: _editedTask.taskStatus,
          taskCompletionStatus: completionValue,
          taskCompletionTime: _editedTask.taskCompletionTime,
        );
      });
    });
    print('...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    Divider(
                      height: 2,
                    ),
                    TextFormField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      initialValue: _initValues['taskName'],
                      decoration: InputDecoration(
                        labelText: 'Task Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        if (value.length > 50) {
                          return 'Please limit the characters to 50';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedTask = Task(
                          taskId: _editedTask.taskId,
                          taskName: value,
                          taskDeadlineDate: _editedTask.taskDeadlineDate,
                          taskDeadlineTime: _editedTask.taskDeadlineTime,
                          taskApxCompletionTime:
                              _editedTask.taskApxCompletionTime,
                          taskApxCompletionTimeMin:
                              _editedTask.taskApxCompletionTimeMin,
                          taskImpIndex: _editedTask.taskImpIndex,
                          taskCreatedTime: _editedTask.taskCreatedTime,
                          taskDesc: _editedTask.taskDesc,
                          taskStatus: _editedTask.taskStatus,
                          taskCompletionStatus:
                              _editedTask.taskCompletionStatus,
                          taskCompletionTime: _editedTask.taskCompletionTime,
                        );
                      },
                    ),
                    Divider(
                      height: 5,
                    ),
                    TextFormField(
                      autocorrect: true,
                      enableSuggestions: true,
                      // expands: true,
                      textCapitalization: TextCapitalization.sentences,
                      initialValue: _initValues['taskDesc'],
                      decoration: InputDecoration(
                        labelText: 'Task Description (Optional)',
                        hintText:
                            'Steps to be followed to complete the task...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      // textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.length > 250) {
                          return 'Please provide a Description lesser than 250 characters.';
                        }
                        if (value.isEmpty) {
                          value = '';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedTask = Task(
                          taskId: _editedTask.taskId,
                          taskName: _editedTask.taskName,
                          taskDeadlineDate: _editedTask.taskDeadlineDate,
                          taskDeadlineTime: _editedTask.taskDeadlineTime,
                          taskApxCompletionTime:
                              _editedTask.taskApxCompletionTime,
                          taskApxCompletionTimeMin:
                              _editedTask.taskApxCompletionTimeMin,
                          taskImpIndex: _editedTask.taskImpIndex,
                          taskCreatedTime: _editedTask.taskCreatedTime,
                          taskDesc: value,
                          taskStatus: _editedTask.taskStatus,
                          taskCompletionStatus:
                              _editedTask.taskCompletionStatus,
                          taskCompletionTime: _editedTask.taskCompletionTime,
                        );
                      },
                    ),
                    Divider(
                      height: 5,
                    ),
                    TextFormField(
                      autocorrect: true,
                      initialValue: _initValues['taskApxCompletionTime'] == null
                          ? _initValues['taskApxCompletionTime']
                          : _initValues['taskApxCompletionTime']
                              .toString()
                              .split('.')[0],
                      decoration: InputDecoration(
                          labelText:
                              'Approximate time for completing task - hours',
                          hintText: '(eg: 2, 8, 30...)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          alignLabelWithHint: true),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        print(value.runtimeType);
                        if (value.isEmpty) {
                          return 'Please provide a value in hours.';
                        }
                        if (!isNumeric(value)) {
                          return 'Numbers only allowed (eg: 2, 8, 10)';
                        }
                        if (value.contains('.')) {
                          return 'Only whole numbers are allowed';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        try {
                          _editedTask = Task(
                            taskId: _editedTask.taskId,
                            taskName: _editedTask.taskName,
                            taskDeadlineDate: _editedTask.taskDeadlineDate,
                            taskDeadlineTime: _editedTask.taskDeadlineTime,
                            taskApxCompletionTime: double.parse(value.trim()),
                            taskApxCompletionTimeMin:
                                _editedTask.taskApxCompletionTimeMin,
                            taskImpIndex: _editedTask.taskImpIndex,
                            taskCreatedTime: _editedTask.taskCreatedTime,
                            taskDesc: _editedTask.taskDesc,
                            taskStatus: _editedTask.taskStatus,
                            taskCompletionStatus:
                                _editedTask.taskCompletionStatus,
                            taskCompletionTime: _editedTask.taskCompletionTime,
                          );
                        } catch (error) {}
                      },
                    ),
                    Divider(
                      height: 5,
                    ),
                    TextFormField(
                      autocorrect: true,
                      initialValue: _initValues['taskApxCompletionTimeMin'] ==
                              null
                          ? _initValues['taskApxCompletionTimeMin']
                          : _initValues['taskApxCompletionTimeMin'].toString(),
                      decoration: InputDecoration(
                          labelText:
                              'Approximate time for completing task - Minutes',
                          hintText: '(eg: 10, 20, 30...60)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          alignLabelWithHint: true),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        print(value.runtimeType);
                        if (value.isEmpty) {
                          return 'Please provide a value within 60 Minutes.';
                        }
                        if (!isNumeric(value)) {
                          return 'Numbers only allowed (eg: 15, 30)';
                        }
                        if (value.contains('.')) {
                          return 'Only whole numbers are allowed';
                        }
                        if (int.parse(value) > 60) {
                          return 'Please provide a value within 60 Minutes.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        try {
                          _editedTask = Task(
                            taskId: _editedTask.taskId,
                            taskName: _editedTask.taskName,
                            taskDeadlineDate: _editedTask.taskDeadlineDate,
                            taskDeadlineTime: _editedTask.taskDeadlineTime,
                            taskApxCompletionTime:
                                _editedTask.taskApxCompletionTime,
                            taskApxCompletionTimeMin: int.parse(value.trim()),
                            taskImpIndex: _editedTask.taskImpIndex,
                            taskCreatedTime: _editedTask.taskCreatedTime,
                            taskDesc: _editedTask.taskDesc,
                            taskStatus: _editedTask.taskStatus,
                            taskCompletionStatus:
                                _editedTask.taskCompletionStatus,
                            taskCompletionTime: _editedTask.taskCompletionTime,
                          );
                        } catch (error) {}
                      },
                    ),
                    //   ),
                    // ]),
                    Divider(
                      height: 5,
                    ),
                    FormField(builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            labelText: 'Priority',
                            hintText: 'Please select Priority',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        isEmpty: _currentSelectedValue == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentSelectedValue == null
                                ? _initValues['taskImpIndex']
                                : _currentSelectedValue,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                _currentSelectedValue = newValue;
                                _editedTask = Task(
                                  taskId: _editedTask.taskId,
                                  taskName: _editedTask.taskName,
                                  taskDeadlineDate:
                                      _editedTask.taskDeadlineDate,
                                  taskDeadlineTime:
                                      _editedTask.taskDeadlineTime,
                                  taskApxCompletionTime:
                                      _editedTask.taskApxCompletionTime,
                                  taskApxCompletionTimeMin:
                                      _editedTask.taskApxCompletionTimeMin,
                                  taskImpIndex: newValue,
                                  taskCreatedTime: _editedTask.taskCreatedTime,
                                  taskDesc: _editedTask.taskDesc,
                                  taskStatus: _editedTask.taskStatus,
                                  taskCompletionStatus:
                                      _editedTask.taskCompletionStatus,
                                  taskCompletionTime:
                                      _editedTask.taskCompletionTime,
                                );
                                state.didChange(newValue);
                              });
                            },
                            items: _priorityIndex.map((String priority) {
                              return DropdownMenuItem<String>(
                                value: priority,
                                child: Text(priority),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }),
                    Divider(
                      height: 5,
                    ),
                    Container(
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? _editedTask.taskDeadlineDate == null
                                      ? 'No Date Chosen!'
                                      : 'Picked Date: ${DateFormat.yMd().format(_editedTask.taskDeadlineDate)}'
                                  : 'Picked Date: ${DateFormat.yMd().format(_selectedDate)}',
                            ),
                          ),
                          FlatButton(
                            textColor: Theme.of(context).primaryColor,
                            child: Text(
                              'Choose Target Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _presentDatePicker,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _selectedTime == null
                                  ? _editedTask.taskDeadlineTime == null
                                      ? 'No Time Chosen!'
                                      : 'Picked Time: ${_editedTask.taskDeadlineTime.hour}:${_editedTask.taskDeadlineTime.minute}'
                                  : 'Picked Date: ${_selectedTime.hour}:${_selectedTime.minute}',
                            ),
                          ),
                          FlatButton(
                            textColor: Theme.of(context).primaryColor,
                            child: Text(
                              'Choose Target Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _presentTimePicker,
                          ),
                        ],
                      ),
                    ),
                    Slider(
                        min: 0,
                        max: 90,
                        divisions: 9,
                        label: 'Current completion $completionValue%',
                        value: completionValue,
                        onChanged: (double value) {
                          setState(() {
                            completionValue = value;
                            _editedTask = Task(
                              taskId: _editedTask.taskId,
                              taskName: _editedTask.taskName,
                              taskDeadlineDate: _editedTask.taskDeadlineDate,
                              taskDeadlineTime: _editedTask.taskDeadlineTime,
                              taskApxCompletionTime:
                                  _editedTask.taskApxCompletionTime,
                              taskApxCompletionTimeMin:
                                  _editedTask.taskApxCompletionTimeMin,
                              taskImpIndex: _editedTask.taskImpIndex,
                              taskCreatedTime: _editedTask.taskCreatedTime,
                              taskDesc: _editedTask.taskDesc,
                              taskStatus: _editedTask.taskStatus,
                              taskCompletionStatus: completionValue,
                              taskCompletionTime:
                                  _editedTask.taskCompletionTime,
                            );
                          });
                        },
                        semanticFormatterCallback: (double newValue) {
                          return '${newValue.round()} %';
                        }),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _editedTask.taskId == null
                                ? null
                                : () {
                                    _editedTask = Task(
                                      taskId: _editedTask.taskId,
                                      taskName: _editedTask.taskName,
                                      taskDeadlineDate:
                                          _editedTask.taskDeadlineDate,
                                      taskDeadlineTime:
                                          _editedTask.taskDeadlineTime,
                                      taskApxCompletionTime:
                                          _editedTask.taskApxCompletionTime,
                                      taskApxCompletionTimeMin:
                                          _editedTask.taskApxCompletionTimeMin,
                                      taskImpIndex: _editedTask.taskImpIndex,
                                      taskCreatedTime:
                                          _editedTask.taskCreatedTime,
                                      taskDesc: _editedTask.taskDesc,
                                      taskStatus: !_editedTask.taskStatus,
                                      taskCompletionStatus:
                                          _editedTask.taskCompletionStatus,
                                      taskCompletionTime:
                                          _editedTask.taskCompletionTime,
                                    );
                                    print('Clicked completion');
                                    _saveForm();
                                    return;
                                  },
                            icon: Icon(
                              Icons.done,
                              color: _editedTask.taskId != null
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            label: Text(
                              'Completed',
                              style: TextStyle(
                                  color: _editedTask.taskId != null
                                      ? Colors.white
                                      : Colors.grey),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: _saveForm,
                            icon: Icon(Icons.save),
                            label: Text(_editedTask.taskId == null
                                ? 'Add Task'
                                : 'Update task'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
