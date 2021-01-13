import 'package:flutter/material.dart';
import '../providers/tasks.dart';
import 'package:provider/provider.dart';

import './task_item.dart';

class TaskList extends StatelessWidget {
  final bool showAll;
  final bool showPrioratized;

  TaskList(this.showAll, this.showPrioratized);

  @override
  Widget build(BuildContext context) {
    final taskdata = Provider.of<Tasks>(context);
    final tasks = showAll
        ? taskdata.completedTasks //: taskdata.activeTasks;
        : (showPrioratized
            ? taskdata.prioratizedTaskList
            : taskdata.activeTasks);
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: tasks.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: tasks[i],
              child: TaskItem(),
            ),
          ),
        ),
      ],
    );
  }
}
