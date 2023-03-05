import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/todoModel.dart';

class DatabaseModel {
  //the following method opens the databse and creates desired table

  static late Database theDB;

  Future<Database> get openingDB async {
    Database theDB = await initDB();
    return theDB;
  }

  Future<Database> initDB() async {
    var dataBasePath = await getDatabasesPath();
    var path = join(dataBasePath, 'todoItems.db');
    var theDataBase = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE ToDos(id INTEGER PRIMARY KEY AUTOINCREMENT, todo TEXT, date TEXT, time TEXT, status BOOLEAN, notified BOOLEAN)');
    });

    return theDataBase;
  }

  Future<int> insertingToTable(Map<String, dynamic> row) async {
    Database db = await openingDB;
    return db.insert('ToDos', row);
  }

  Future<List<Todo>> queryingData() async {
    Database db = await openingDB;
    List<Map<String, dynamic>> rows = await db.query('ToDos');
    List<Todo> finalRows = List.generate(rows.length, (position) {
      return Todo(
          id: rows[position]['id'],
          todo: rows[position]['todo'],
          date: rows[position]['date'],
          time: rows[position]['time'],
          status: rows[position]['status'],
          notified: rows[position]['notified']);
    });
    return finalRows;
  }

  deletingRecord(int ids) async {
    Database db = await openingDB;
    db.rawDelete('delete from ToDos where id=$ids');
  }

  updatingTaskStatus(int ids) async {
    Database db = await openingDB;
    db.rawUpdate('update ToDos set status = 1 where id=$ids ');
  }

  updatingNotificationStatus(int ids) async {
    Database db = await openingDB;
    db.rawUpdate('update ToDos set notified = 1 where id=$ids ');

  }
}
