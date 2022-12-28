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
          'CREATE TABLE ToDos(id INTEGER PRIMARY KEY AUTOINCREMENT, todo TEXT, date TEXT, time TEXT)');
    });

    return theDataBase;
  }

  Future<int> insertingToTable(Map<String, dynamic> row) async {
    Database db = await openingDB;
    return db.insert('ToDos', row);
  }

  Future<List<String>> queryingData() async {
    Database db = await openingDB;
    List<Map<String, Object?>> rows = await db.query('ToDos');
    List<Todo> finalRows = List.generate(rows.length, (position) {
      return Todo(
          todo: rows[position]['todo'].toString(),
          date: rows[position]['date'].toString(),
          time: rows[position]['time'].toString());
    });
    int length = 0;
    List<String> vals = [];
    while (length < finalRows.length) {
      vals.add(
          finalRows[length].todo +
          finalRows[length].date +
          finalRows[length].time);
      if (length == finalRows.length - 1) {
        break;
      }
      length++;
    }
    return vals;
  }
}
