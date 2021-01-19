import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/db/dbHelper.dart';
import 'package:todo_app/model/taskItem.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<TaskItem> _taskItems = [];
  final TextEditingController _textFieldController = TextEditingController();
  DbHelper _db;
  String _filterValue = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF283eaf),
                    Color(0xFF00d4ff)
                  ]
              ),
            ),
          ),
          Positioned(
            top:20.0,
            height: 200.0,
            child: Image.asset("assets/images/beer.png"),
          ),
          Positioned(
            top: 200.0,
            right: 80.0,
            child: Text("PubTodo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            top: 300.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
              child: ListView(
                children: [
                  SizedBox(height: 15.0,),
                  Column(children:_getItems(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 315.0,
            left: 20.0,
            child: PopupMenuButton<String>(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Text(
                  "$_filterValue",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onSelected: (String value) {
                setState(() {
                  _filterValue = value;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'All',
                  child: Text('All'),
                ),
                const PopupMenuItem<String>(
                  value: 'Done',
                  child: Text('Done'),
                ),
                const PopupMenuItem<String>(
                  value: 'Undone',
                  child: Text('Undone'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(context),
          tooltip: 'Add Item',
          child: Icon(Icons.add)),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _db = DbHelper();

  }
  void _addTodoItem(String taskTitle) {
    setState(() {
      TaskItem item = TaskItem(taskTitle, false);
      _db.insertTaskItem(item);
    });
    _textFieldController.clear();
  }

  Widget _buildTodoItem(TaskItem item) {
    return Row(
      children: [
        Flexible(
          child: CheckboxListTile(
            title: Text(item.getTaskTitle, style: TextStyle(decoration: item.getIsDone ? TextDecoration.lineThrough : null),),
            controlAffinity: ListTileControlAffinity.leading,
            value: item.getIsDone,
            onChanged: (bool value) {
              setState(() {
                item.setIsDone(value);
                _db.updateTaskItem(item);
              });
            },
            activeColor: Colors.green,
            checkColor: Colors.black,
          ),
        ),
        IconButton(
          icon: Icon(Icons.update),
          onPressed: () {
            setState(() {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
                      title: const Text('Update a task in your list'),
                      content: TextField(
                        controller: _textFieldController,
                        decoration: const InputDecoration(hintText: 'Enter task here'),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Update'),
                          onPressed: () {
                            setState(() {
                              item.setTaskTitle(_textFieldController.text);
                              _db.updateTaskItem(item);
                              Fluttertoast.showToast(
                                msg: "Task is Updated!",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                              );
                              Navigator.of(context).pop();
                            });
                            _textFieldController.clear();
                          },
                        ),
                        TextButton(onPressed: () {Navigator.pop(context);}, child: Text("Cancel"))
                      ],
                    );
                  });
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.restore_from_trash),
          onPressed: () {
            setState(() {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Are you sure to delete?"),
                  actions: [
                    TextButton(onPressed: () {
                      setState(() {
                        _db.removeTaskItem(item);
                        Fluttertoast.showToast(
                          msg: "Task is Deleted!",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                        Navigator.pop(context);
                      });
                    }, child: Text("Yes")),
                    TextButton(onPressed: () {Navigator.pop(context);}, child: Text("No"))
                  ],
                  backgroundColor: Colors.white,
                  elevation: 35.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
                ),
              );
            });
          },
        ),
      ],
    );
  }

  Future<AlertDialog> _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
            title: const Text('Add a task to your list'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: 'Enter task here'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  Fluttertoast.showToast(
                    msg: "Task is Added!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  Navigator.of(context).pop();
                  _addTodoItem(_textFieldController.text);
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  List<Widget> _getItems() {
    final List<Widget> _todoWidgets = <Widget>[];
    for (TaskItem item in _taskItems) {
      if(_filterValue == "Done" && item.getIsDone == true) {
        _todoWidgets.add(_buildTodoItem(item));
      }
      else if (_filterValue == "Undone" && item.getIsDone == false){
        _todoWidgets.add(_buildTodoItem(item));
      }
      else if(_filterValue == "All") {
        _todoWidgets.add(_buildTodoItem(item));
      }
    }
    _db.getTaskItems().then((value) {
      setState(() {
        _taskItems = value;
      });

    } );
    return _todoWidgets;
  }
}
