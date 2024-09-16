// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_taskly/models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors, prefer_const_constructors_in_immutables
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  // ignore: unused_field
  late double _deviceHeight, _devicewidth;
  // ignore: unused_field
  String? _newTaskContent;

  Box? _box;
  _HomePageState();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _devicewidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        title: const Text(
          "TASKLY!",
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: _taskVeiw(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskVeiw() {
    Hive.openBox('tasks');
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      // ignore: no_leading_underscores_for_local_identifiers
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.hasData) {
          _box = _snapshot.data;
          return _tasksList();
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _tasksList() {
    // ignore: unused_local_variable
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      // ignore: no_leading_underscores_for_local_identifiers
      itemBuilder: (BuildContext _context, int _index) {
        // ignore: unused_local_variable
        var task = Task.fromMap(tasks[_index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(DateTime.now().toString()),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
          onTap: () {
            task.done = !task.done;
            _box!.putAt(
              _index,
              tasks.asMap(),
            );
            // ignore: unused_label
            onLongPress:
            () {
              _box!.deleteAt(_index);
              setState(() {});
            };
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      child: const Icon(
        Icons.add,
      ),
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      // ignore: no_leading_underscores_for_local_identifiers
      builder: (BuildContext _context) {
        return AlertDialog(
          title: Text("Add New Task!"),
          content: TextField(
            // ignore: no_leading_underscores_for_local_identifiers
            onSubmitted: (_value) {
              if (_newTaskContent != null) {
                // ignore: no_leading_underscores_for_local_identifiers
                var _task = Task(
                    content: _newTaskContent!,
                    timestamp: DateTime.now(),
                    done: false);
                _box!.add(_task.toMap());
                setState(() {
                  _newTaskContent = null;
                  Navigator.pop(context);
                });
              }
            },
            // ignore: no_leading_underscores_for_local_identifiers
            onChanged: (_value) {
              setState(() {
                _newTaskContent = _value;
              });
            },
          ),
        );
      },
    );
  }
}
