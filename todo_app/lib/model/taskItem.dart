
class TaskItem {
  int _id;
  String _taskTitle;
  bool _isDone;

  TaskItem(this._taskTitle, this._isDone);

  bool get getIsDone => _isDone;
  String get getTaskTitle => _taskTitle;
  int get getId => _id;

  void setTaskTitle(String value) {
    _taskTitle = value;
  }
  void setIsDone(bool value) {
    _isDone = value;
  }

  void setId(int id) {
    _id = id;
  }

  Map<String,dynamic> toMap() {
    var map = Map<String,dynamic>();

    map["taskTitle"] = _taskTitle;
    map["isDone"] = _isDone;

    return map;
  }

  TaskItem.fromMap(Map<String,dynamic> map) {
    _taskTitle = map["taskTitle"];
    _isDone = map["isDone"];
  }
}