import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todo/addToDo.dart';
import 'package:todo/dataBase.dart';
import 'package:todo/todoModel.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  AwesomeNotifications awesome = AwesomeNotifications();
  runApp(const MyApp());
  awesome.initialize(null, [
    NotificationChannel(
        channelKey: 'notificationTodo',
        channelName: 'notificationForTodo',
        channelDescription: 'notification channel to trigger todo notification',
        defaultColor: Colors.pink,
        playSound: true,
        importance: NotificationImportance.Max,
        defaultRingtoneType: DefaultRingtoneType.Notification)
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late DatabaseModel databaseModel;

  //following list will have each todos
  List<Todo> listOfValues = [];

  //following list will have indexes of selected todos
  List<int> indexes = [];

//this list will hold only the ids of failed task
  List<int> failedTasks = [];

  //finally this list will hold id of todos to perfrom CRUD operations
  List<int> selectedItems = [];

  bool lonPressEnabled = false;

  List<int> succeeded = [];
  List<int> failed = [];
   int xPulledOff = 0;
   int yFailed = 0;

  @override
  void initState() {
    super.initState();
    DatabaseModel data = DatabaseModel();
    databaseModel = data;
  }

  @override
  Widget build(BuildContext context) {
    databaseModel.queryingData().then((value) {
      if (value.isNotEmpty) {
        listOfValues = value;

        for (int i = 0; i < listOfValues.length; i++) {
          if (listOfValues[i].notified == 0) {
            databaseModel.updatingNotificationStatus(listOfValues[i].id);
            shotsFired(
                listOfValues[i].id,
                listOfValues[i].date,
                listOfValues[i].time,
                listOfValues[i].status,
                listOfValues[i].todo);
          }

          if(listOfValues[i].status == 1){
            succeeded.add(listOfValues[i].id);
          }
          
        }
      } else {
        settingListOfValues = [];
      }
    });
    
    xPulledOff = succeeded.length; 
    return Scaffold(
        extendBodyBehindAppBar: true,
       appBar: AppBar(
          title: Column(children: const <Widget>[
            Text(
              'Your',
              style: TextStyle(
                fontSize: 32, /*color: Colors.purple*/
              ),
            ),
            Text(
              'Things',
              style: TextStyle(
                fontSize: 32, /* color: Colors.purple*/
              ),
            )
          ]),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                          'assets/wallpaperflare.com_wallpaper (1).jpg'),
                      fit: BoxFit.cover))),
          toolbarHeight: 170,
          elevation: 0,
          actions: [
            Opacity(
              opacity: 0.7,
              child: Container(
                width: MediaQuery.of(context).size.width/2,
                color: Colors.black,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              width: 81,
                              child: Text(
                                '$xPulledOff',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                ),
                              ),
                            ),
                            Container(
                              child: const Text(
                                'Task in total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              width: 60,
                              child: Text(
                                '07',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                ),
                              ),
                            ),
                            Container(
                              child: const Text(
                                '  Remains',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 32,
                        ),
                        CircularPercentIndicator(
                          radius: 35.0,
                          progressColor: Colors.red,
                          lineWidth: 5,
                          percent: 0.5,
                        ).animate().slide(),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          '65% Processed',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
//
        body: content(),
        floatingActionButton: Row(children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AddTask()))
                  .then((value) => refreshPage());
            },
            child: const Icon(Icons.add),
          ),
          ElevatedButton(
              onPressed: () {
                lonPressEnabled = false;
                for (int i = 0; i < selectedItems.length; i++) {
                  //deleting the todo from the database
                  databaseModel.deletingRecord(selectedItems[i]);
                  //cancelling the scheduled notification
                  callingOffShots(selectedItems[i]);
                }

                selectedItems = [];
                indexes = [];

                refreshPage();
              },
              child: const Icon(Icons.delete)),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  var triedUpdatingFailed = false;
                  lonPressEnabled = false;
                  for (int i = 0; i < selectedItems.length; i++) {
                    if (failedTasks.contains(selectedItems[i])) {
                      triedUpdatingFailed = true;
                    } else {
                      databaseModel.updatingTaskStatus(selectedItems[i]);
                      callingOffShots(selectedItems[i]);
                      succeeded.add(selectedItems[i]);
                    }
                  }
                  if (triedUpdatingFailed) {
                    //scaffoldKey.currentState.showsnackBar(new SnackBar(content: Text('You can not update failed task')));
                  }
                  triedUpdatingFailed = false;
                  selectedItems = [];
                  indexes = [];
                });
              },
              child: const Icon(Icons.update))
        ]));
  }

 

  //the following method actually returns the body of our main page which is the list of todos
  Widget content() {
    succeeded = [];

    return SafeArea(
      child: StreamBuilder(
        stream: databaseModel.queryingData().asStream(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (listOfValues.isEmpty) {
            return const Center(
              child: Text('Not even a thing to pull off'),
            );
          } else {
            return ListView.builder(
              key: UniqueKey(),
              itemBuilder: (context, index) {
                return Card(
                  color: (indexes.contains(index))
                      ? Colors.blue.withOpacity(0.5)
                      : Colors.transparent,
                  child: ListTile(
                    title: Text(listOfValues[index].todo),
                    subtitle: Text('Planned on ${listOfValues[index].date}'),
                    trailing: FittedBox(
                      fit: BoxFit.fill,
                      child: Row(
                        children: <Widget>[
                          Text(listOfValues[index].time),
                          const SizedBox(
                            width: 5,
                          ),
                          statusChecker(
                              listOfValues[index].id,
                              listOfValues[index].status,
                              listOfValues[index].time,
                              listOfValues[index].date)
                        ],
                      ),
                    ),
                    //trailing: Wrap(spacing: 16, children: <Widget>[Text(listOfValues[index].time), const Icon(Icons.done)]),
                    //trailing: Text(listOfValues[index].time),
                    onLongPress: () {
                      setState(() {
                        lonPressEnabled = true;
                        if (!indexes.contains(index)) {
                          indexes.add(index);
                          selectedItems.add(listOfValues[index].id);
                        }
                      });
                    },
                    onTap: () {
                      setState(() {
                        if (indexes.isNotEmpty && lonPressEnabled) {
                          if (indexes.contains(index)) {
                            indexes.remove(index);
                            selectedItems.remove(listOfValues[index].id);
                          } else {
                            indexes.add(index);
                            selectedItems.add(listOfValues[index].id);
                          }
                        }
                      });
                    },
                  ),
                );
              },
              itemCount: listOfValues.length,
            );
          }
        },
      ),
    );
  }

  refreshPage() {
    setState(() {});
  }

  Icon statusChecker(
      int id, int status, String timeOfEvent, String dateOfEvent) {
    int hour = int.parse(timeOfEvent.substring(0, 2));
    String minutes = timeOfEvent.substring(3, 5);
    String amORpm = timeOfEvent.substring(6, 8);
    String formattedTime;

    if ( amORpm == 'PM') {
      if(hour == 12){
        hour = 12;
      }else{
      hour = hour + 12;
      }
      formattedTime = '$dateOfEvent $hour:$minutes:00';
    } else if (hour == 12 && amORpm == 'AM') {
      formattedTime = '$dateOfEvent 00:$minutes:00';
    }  else if(hour >= 10){
      formattedTime = '$dateOfEvent $hour:$minutes:00';
    } else{
      formattedTime = '$dateOfEvent 0$hour:$minutes:00';
    }

    //now comparing target time with current time

    DateTime now = DateTime.now();
    DateTime targetTime = DateTime.parse(formattedTime);

    if (now.isAfter(targetTime) && status == 0) {
      failedTasks.add(id);
      
      //this is for 'failed' task
      return const Icon(Icons.dangerous_outlined);
    } else if (now.isBefore(targetTime) && status == 0) {
      //this is for 'under progress' task
      var hour1 = hour - now.hour;
      var durationMin = (int.parse(minutes) - now.minute) + (hour1 * 60);
      Future.delayed(Duration(minutes: durationMin), () {
        setState(() {});
       
      });

      return const Icon(Icons.undo_rounded);
    } else {
      //this is for 'completed' task
      return const Icon(Icons.done_outline_rounded);
    }
  }

   // a simple setter to initialize listOfValues
  set settingListOfValues(List<Todo> val) {
    listOfValues = val;
  }

  Future<bool> shotsFired(
      int ids, String date, String time, int status, String todo) async {
    //we need the day of week so the below part
    var dateParts = date.split('-');
    var year = int.parse(dateParts[0]);
    var month = int.parse(dateParts[1]);
    var day = int.parse(dateParts[2]);
    var dateOfEvent = DateTime(year, month, day);
    var dayOfWeek = dateOfEvent.weekday;

    //we need hour & minute in 24 hour format so the below part
    int hour = int.parse(time.substring(0, 2));
    int minutes = int.parse(time.substring(3, 5));
    String amORpm = time.substring(6, 8);

    if (hour < 12 && amORpm == 'PM') {
      hour = hour + 12;
    }
    print('Day = $dayOfWeek, hour = $hour, minutes = $minutes');

    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: ids,
          channelKey: 'notificationTodo',
          title: 'TODO',
          body: todo,
          displayOnBackground: true,
          displayOnForeground: true),
      schedule: NotificationCalendar(
          weekday: dayOfWeek,
          hour: hour,
          minute: minutes,
          second: 0,
          millisecond: 0,
          repeats: false),
    );
  }

  Future<void> callingOffShots(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
