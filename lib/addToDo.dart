import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/dataBase.dart';
import 'package:todo/main.dart';
import 'package:todo/todoModel.dart';

class AddTask extends StatefulWidget {
  State<AddTask> createState() => AddTaskState();
}

class AddTaskState extends State<AddTask> {
  var editingController = TextEditingController();
  var defaultText = 'Set Time';

  var editingControllerForDate = TextEditingController();
  var defaultTextDate = 'Pick a date';

  var editingControllerForEvent = TextEditingController();
  var valueOfFormattedTime;
  var valueOfFormattedDate;

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.purple,
          automaticallyImplyLeading: false,
          title: const Text(
            'Add Your Todo',
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: Container(
            //color: Colors.black,
            padding: const EdgeInsets.all(55),
            width: 475,
            child: Center(
                child: Column(
              children: [
                const SizedBox(
                  height: 37,
                ),
                TextField(
                    // ignore: prefer_const_constructors
                    decoration: InputDecoration(hintText: 'Thing to be done'),
                    controller: editingControllerForEvent),
                const SizedBox(
                  height: 37,
                ),
                TextField(
                  enabled: true,
                  readOnly: true,
                  onTap: () async {
                    editingController.text = 'set time';
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    //if the user sets the time then showTimePicker() returns TimeOfDay() instance which consists the user set time
                    //after that we turn the instance to String so we can set it on the "set time" Text Field otherwise we leave it as it is
                    //the following condition does the above said
                    if (pickedTime != null) {
                      valueOfFormattedTime =
                          formattingTime(pickedTime.toString());
                      editingController.text =
                          'Pull of before ${formattingTime(pickedTime.toString())}';
                    }
                  },
                  //following param is justa a hint
                  decoration: const InputDecoration(hintText: 'Set time'),
                  controller: editingController,
                ),
                const SizedBox(
                  height: 37,
                ),
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(hintText: 'Pick a date'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1947),
                        lastDate: DateTime(2100));
                    if (pickedDate != null) {
                      valueOfFormattedDate =
                          pickedDate.toString().substring(0, 10);
                      editingControllerForDate.text =
                          'Scheduled on ' + valueOfFormattedDate;
                    }
                  },
                  controller: editingControllerForDate,
                ),
                const SizedBox(
                  height: 55,
                ),
                Center(
                  child: ElevatedButton(
                    child: const Text('Add Todo'),
                    onPressed: () async {
                      //accessing database helper
                      DatabaseModel dataBaseModel = DatabaseModel();

                      Todo todo = Todo(
                          todo: editingControllerForEvent.text,
                          date: valueOfFormattedDate,
                          time: valueOfFormattedTime,
                          status: 0
                          );

                      Map<String, Object?> row = todo.toMap();
                      if (editingController.text != 'Thing to be done') {
                        if (valueOfFormattedDate != null &&
                            valueOfFormattedTime != null) {
                          dataBaseModel.insertingToTable(row);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => MyApp()));
                          // Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('You must fill every field')));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('You must fill every field')));
                      }
                    },
                  ),
                )
              ],
            ))),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyApp()));
    return true;
  }

  String formattingTime(String time) {
    var amORpm = 'AM';
    var hourString = time.substring(10, 12);
    var minuteString = time.substring(13, 15);

    dynamic finalTime;
    var hour = int.parse(hourString);
    if (hour >= 12) {
      hour = hour - 12;

      amORpm = 'PM';

      //switching between AM & PM
      if (hour < 10) {
        finalTime = '0$hour:$minuteString $amORpm';
        return finalTime;
      }
    }
    //switching between AM & PM
    if (hour < 10) {
      finalTime = '0$hour:$minuteString $amORpm';
      return finalTime;
    }
    finalTime = '$hour:$minuteString $amORpm';
    return finalTime;
  }
}
