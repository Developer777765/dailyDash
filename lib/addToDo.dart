import 'package:flutter/material.dart';
import 'package:path/path.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Colors.green,
              Colors.black87,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
        ),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: const Text(
          'Add Your Todo',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Container(
          //color: Colors.black,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/add_todo_background.jpg"),
                  fit: BoxFit.cover)),
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
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                          onPrimaryContainer: Colors.green,    
                          primary: Colors.green,
                          onSurface: Colors.white,
                          background: Colors.black,
                         // onBackground: Colors.black
                        )
                        
                        ),
                        child: child!,
                      );
                    }
                  );

                  //if the user sets the time then showTimePicker() returns TimeOfDay() instance which consists the user set time
                  //after that we turn the instance to String so we can set it on the "set time" Text Field otherwise we leave it as it is
                  //the following condition does the above said
                  if (pickedTime != null) {
                    valueOfFormattedTime =
                        formattingTime(pickedTime.toString());
                    editingController.text =
                        'Pull of before $valueOfFormattedTime';
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
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                          primary: Colors.green,
                          onSurface: Colors.white,
                          background: Colors.black,
                          onBackground: Colors.black
                        )
                        
                        ),
                        child: child!,
                      );
                    },
                  );
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
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Add Todo'),
                  onPressed: () {
                    //accessing database helper
                    DatabaseModel dataBaseModel = DatabaseModel();

                    Todo todo = Todo(
                        todo: editingControllerForEvent.text,
                        date: valueOfFormattedDate,
                        time: valueOfFormattedTime,
                        status: 0,
                        notified: 0);

                    Map<String, Object?> row = todo.toMap();
                    if (editingController.text != 'Thing to be done') {
                      if (valueOfFormattedDate != null &&
                          valueOfFormattedTime != null) {
                        dataBaseModel.insertingToTable(row);

                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('You must fill every field')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('You must fill every field')));
                    }
                  },
                ),
              )
            ],
          ))),
    );
  }

  String formattingTime(String time) {
    var amORpm = 'AM';
    var hourString = time.substring(10, 12);
    var minuteString = time.substring(13, 15);

    dynamic finalTime;
    var hour = int.parse(hourString);
    if (hour >= 12) {
      hour = hour - 12;

      if (hour == 0) {
        hour = 12;
      }
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
