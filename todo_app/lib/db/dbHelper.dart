import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_app/model/taskItem.dart';

class DbHelper{
  static Database _db;

  Future<Database> get db async {
    if(_db != null) {
      return _db;
    }

    _db = await initDb();
    
    return _db;
  }

  initDb() async{
    var dbFolder = await getDatabasesPath();
    String path = join(dbFolder, "Tasks.db");

    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }



  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE Tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, taskTitle TEXT, isDone BOOLEAN)");

  }

  Future<List<TaskItem>> getTaskItems() async {
    var dbClient = await db;

    List<Map> result = await dbClient.rawQuery("SELECT * FROM Tasks");
    List<TaskItem> items = [];

    for(int i = 0;i <result.length;i++) {
      var item = TaskItem(result[i]["taskTitle"], result[i]["isDone"] == 0 ? false : true );
      item.setId(result[i]["id"]);
      items.add(item);
    }

    return items;
  }

  Future<int> insertTaskItem(TaskItem taskItem) async{
    var dbClient = await db;
    int result = await dbClient.insert("Tasks", taskItem.toMap());
    return result;
  }

  Future<int> removeTaskItem(TaskItem item) async {
    var dbClient = await db;

    int result = await dbClient.rawDelete("DELETE FROM Tasks WHERE id = ?", [item.getId]);
    return result;
  }

  Future<int> updateTaskItem(TaskItem item) async {
    var dbClient = await db;

    int result = await dbClient.update("Tasks", item.toMap(), where: "id = ?", whereArgs: [item.getId]);
    return result;
  }


}