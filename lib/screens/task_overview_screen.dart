import 'package:flutter/material.dart';
import './task_edit_screen.dart';
import 'package:provider/provider.dart';

import '../widgets/task_list.dart';
import '../widgets/app_drawer.dart';
import '../providers/tasks.dart';

enum FilterOptions {
  Completed,
  Active,
  Prioratized,
}

class TaskOverviewScreen extends StatefulWidget {
  static const routeName = '/task-details';
  @override
  _TaskOverviewScreenState createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends State<TaskOverviewScreen> {
  var _showOnlyCompleted = false;
  var _showOnlyPrioratized = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Tasks>(context).fetchAndSetTasks().then((_) {
        print('fetched tasks');
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_showOnlyCompleted
              ? 'Completed Tasks'
              : (_showOnlyPrioratized ? 'Prioratized Tasks' : 'Active Tasks')),
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (FilterOptions selectedValue) {
                setState(() {
                  if (selectedValue == FilterOptions.Completed) {
                    _showOnlyCompleted = true;
                    _showOnlyPrioratized = false;
                  } else if (selectedValue == FilterOptions.Prioratized) {
                    _showOnlyPrioratized = true;
                    _showOnlyCompleted = false;
                  } else {
                    _showOnlyCompleted = false;
                    _showOnlyPrioratized = false;
                  }
                });
              },
              icon: Icon(
                Icons.more_vert,
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text('Active Tasks'),
                  value: FilterOptions.Active,
                ),
                PopupMenuItem(
                  child: Text('Completed Tasks'),
                  value: FilterOptions.Completed,
                ),
                PopupMenuItem(
                    child: Text('Prioratize Tasks'),
                    value: FilterOptions.Prioratized)
              ],
            ),
          ]),
      drawer: AppDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () =>
            Navigator.of(context).pushNamed(TaskEditScreen.routeName),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
              child: TaskList(_showOnlyCompleted, _showOnlyPrioratized),
            ),
    );
  }
}
