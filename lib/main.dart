import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:page_transition/page_transition.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todo/addToDo.dart';
import 'package:todo/dataBase.dart';
import 'package:todo/splashScreen.dart';
import 'package:todo/todoModel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() async {
  AwesomeNotifications awesome = AwesomeNotifications();
  runApp(const MyApp());
  awesome.initialize("resource://mipmap/daily_dash_launcher", [
    NotificationChannel(
        
        channelKey: 'notificationTodo',
        channelName: 'notificationForTodo',
        channelDescription: 'notification channel to trigger todo notification',
        defaultColor: Colors.black,
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
      theme: ThemeData.dark().copyWith(
          timePickerTheme: TimePickerThemeData(
            helpTextStyle: TextStyle(color: Colors.white),
            backgroundColor: Colors.black,
            hourMinuteShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                side: BorderSide(color: Colors.green)),
            dayPeriodColor: Colors.green,
            dayPeriodTextColor: Colors.white,
            dayPeriodBorderSide: const BorderSide(
              color: Colors.black,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              //side: BorderSide(color: Colors.grey, width: 4),
            ),
            hourMinuteColor: Colors.green,
            hourMinuteTextColor: Colors.white,
            dialHandColor: Colors.green,
            //entryModeIconColor: Colors.green
          ),
          primaryColor: Colors.grey[900],
          // ignore: deprecated_member_use
          accentColor: Colors.blue[300],
          scaffoldBackgroundColor: Colors.grey[900],
          textTheme: const TextTheme(
              headline1: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              headline2: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              bodyText1: TextStyle(fontSize: 16.0, color: Colors.green),
              bodyText2: TextStyle(fontSize: 14.0, color: Colors.green)),
          iconTheme: const IconThemeData(color: Colors.white),
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.green,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0))),
          appBarTheme: const AppBarTheme(color: Colors.grey)),
      home: const MyHomePage(title: 'DailyDash'),
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

  late ScrollController scrollerController;

  //following list will have each todos
  List<Todo> listOfValues = [];

  //following list will have indexes of selected todos
  static List<int> indexes = [];

//this list will hold only the ids of failed task
  static List<int> failedTasks = [];

  //this list will hold every id of every todo
  static List<int> allIds = [];

  //finally this list will hold id of todos to perfrom CRUD operations
  static List<int> selectedItems = [];

  static bool lonPressEnabled = false;

  List<int> succeeded = [];
  List<int> failed = [];
  List<int> underProcess = [];
  int numOfUnderProcess = 0;

  bool isFabVisible = true;

  @override
  void initState() {
    super.initState();
    scrollerController = ScrollController(keepScrollOffset: true);
    DatabaseModel data = DatabaseModel();
    databaseModel = data;
  }

  @override
  void dispose() {
    scrollerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    databaseModel.queryingData().then((value) {
      if (value.isNotEmpty) {
        listOfValues = value;

        for (int i = 0; i < listOfValues.length; i++) {
          allIds.add(listOfValues[i].id);
          failedTasks.add(-1);
          if (listOfValues[i].notified == 0) {
            databaseModel.updatingNotificationStatus(listOfValues[i].id);
            shotsFired(
                listOfValues[i].id,
                listOfValues[i].date,
                listOfValues[i].time,
                listOfValues[i].status,
                listOfValues[i].todo);
          }
          numOfUnderProcess = findUnderProcess(
              listOfValues[i].id,
              listOfValues[i].status,
              listOfValues[i].time,
              listOfValues[i].date);
        }
      } else {
        settingListOfValues = [];
      }
    });

    return WillPopScope(child:
    Scaffold(
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
                    image: AssetImage('assets/daily_dash_app_bar.jpg'),
                    fit: BoxFit.cover))),
        toolbarHeight: 160,
        elevation: 0,
        actions: [
          //Opacity(
          //opacity: 0.7,
          //child:
          Container(
            width: MediaQuery.of(context).size.width / 2,
            color: Colors.transparent,
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
                          child: StreamBuilder(
                              stream: databaseModel.queryingData().asStream(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (listOfValues.isEmpty) {
                                  return const Text(
                                    '00',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35),
                                  );
                                } else {
                                  if (listOfValues.length < 10) {
                                    String formattedLength =
                                        "0${listOfValues.length}";
                                    return Text(
                                      formattedLength,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35,
                                      ),
                                    );
                                  }
                                  return Text(
                                    listOfValues.length.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                    ),
                                  );
                                }
                              }),
                        ),
                        const Text(
                          'Total tasks',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
                          child: StreamBuilder(
                            stream: databaseModel.queryingData().asStream(),
                            builder: (context, snapshot) {
                              if (listOfValues.isEmpty) {
                                return const Text(
                                  '00',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35),
                                );
                              } else {
                                if (underProcess.length < 10) {
                                  String formattedUnderprocess =
                                      "0${numOfUnderProcess}";
                                  return Text(
                                    formattedUnderprocess,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                    ),
                                  );
                                }
                                return Text(
                                  '$numOfUnderProcess',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 35,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const Text(
                          '  Remains',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                StreamBuilder(
                    stream: databaseModel.queryingData().asStream(),
                    builder: (context, snapShot) {
                      var counter = 0;
                      for (int i = 0; i < listOfValues.length; i++) {
                        if (listOfValues[i].status == 1) {
                          counter = counter + 1;
                        }
                      }
                      double percent = (counter / listOfValues.length) * 100;
                      var percentAsString = percent.toString().substring(0, 2);
                      //   int processed = percent .round();
                      // print(percentAsString);
                      return Row(
                        children: [
                          const SizedBox(
                            width: 32,
                          ),
                          CircularPercentIndicator(
                            radius: 35.0,
                            progressColor: Colors.green,
                            lineWidth: 5,
                            percent: percent / 100,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '$percentAsString% Processed',
                            //'bug in production',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      );
                    })
              ],
            ),
          ),
          //  )
        ],
      ),
//
      body: content(),

      //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      floatingActionButton: isFabVisible
          ? SpeedDial(
              renderOverlay: false,
              backgroundColor: Colors.green,
              animatedIcon: AnimatedIcons.menu_close,
              children: [
                SpeedDialChild(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.add, color: Colors.black),
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            /*
                            MaterialPageRoute( 
                              builder: (context) => AddTask())*/
                            PageTransition(
                                child: AddTask(),
                                type: PageTransitionType.rightToLeftWithFade,
                                duration: Duration(milliseconds: 550),
                                reverseDuration: Duration(milliseconds: 550)),
                          )
                          .then((value) => refreshPage());
                    }),
                SpeedDialChild(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.delete, color: Colors.black),
                    onTap: () {
                      if (selectedItems.isNotEmpty) {
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
                      }
                    }),
                SpeedDialChild(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.update, color: Colors.black),
                    onTap: () {
                      if (selectedItems.isNotEmpty) {
                        setState(() {
                          var triedUpdatingFailed = false;
                          lonPressEnabled = false;
                          for (int i = 0; i < selectedItems.length; i++) {
                            if (failedTasks.contains(selectedItems[i])) {
                              triedUpdatingFailed = true;
                            } else {
                              databaseModel
                                  .updatingTaskStatus(selectedItems[i]);
                              callingOffShots(selectedItems[i]);
                              succeeded.add(selectedItems[i]);
                            }
                          }
                          triedUpdatingFailed = false;
                          selectedItems = [];
                          indexes = [];
                        });
                      }
                    })
              ],
            )
          : null
      /*
        Row(children: <Widget>[
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
                  child: const Icon(Icons.delete))
              ,
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
        ])*/
      ,
    ),
    onWillPop: () async {

      if(indexes.isNotEmpty){
        indexes = [];
        setState(() {
          
        });
        return false;
      }else{
        return true;
      }
      
    },
    );
  }

  //the following method actually returns the body of our main page which is the list of todos
  Widget content() {
    succeeded = [];
    underProcess = [];

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/add_todo_background.jpg"),
                fit: BoxFit.cover)),
        child: SafeArea(
          child: StreamBuilder(
            stream: databaseModel.queryingData().asStream(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (listOfValues.isEmpty) {
                return const Center(
                  child: Text('Not even a thing to pull off'),
                );
              } else {
                return NotificationListener<UserScrollNotification>(
                    onNotification: (notification) {
                      if (notification.direction == ScrollDirection.forward) {
                        //towards appbar
                        if (!isFabVisible) {
                          setState(() {
                            isFabVisible = true;
                          });
                        }
                      } else if (notification.direction ==
                          ScrollDirection.reverse) {
                        //towards bottomnavbar
                        if (isFabVisible) {
                          setState(() {
                            isFabVisible = false;
                          });
                        }
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: scrollerController,
                      itemBuilder: (context, index) {
                        //return MyCard(listOfValues[index], index);
                        return StatefulBuilder(builder: (context, setState) {
                          return Card(
                            key: UniqueKey(),
                            color: (indexes.contains(index))
                                ? Colors.red.withOpacity(0.5)
                                : Colors.transparent,
                            child: ListTile(
                              title: Text(listOfValues[index].todo),
                              subtitle: Text(
                                  'Planned on ${listOfValues[index].date}'),
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
                                      selectedItems
                                          .remove(listOfValues[index].id);
                                    } else {
                                      indexes.add(index);
                                      selectedItems.add(listOfValues[index].id);
                                    }
                                  }
                                });
                              },
                            ),
                          );
                        });
                      },
                      itemCount: listOfValues.length,
                    ));
              }
            },
          ),
        ));
  }

  refreshPage() {
    setState(() {});
  }

  Widget statusChecker(
      int id, int status, String timeOfEvent, String dateOfEvent) {
    int hour = int.parse(timeOfEvent.substring(0, 2));
    String minutes = timeOfEvent.substring(3, 5);
    String amORpm = timeOfEvent.substring(6, 8);
    String formattedTime;

    if (amORpm == 'PM') {
      if (hour == 12) {
        hour = 12;
      } else {
        hour = hour + 12;
      }
      formattedTime = '$dateOfEvent $hour:$minutes:00';
    } else if (hour == 12 && amORpm == 'AM') {
      formattedTime = '$dateOfEvent 00:$minutes:00';
    } else if (hour >= 10) {
      formattedTime = '$dateOfEvent $hour:$minutes:00';
    } else {
      formattedTime = '$dateOfEvent 0$hour:$minutes:00';
    }

    //now comparing target time with current time

    DateTime now = DateTime.now();
    DateTime targetTime = DateTime.parse(formattedTime);

    if (now.isAfter(targetTime) && status == 0) {
      failedTasks.add(id);

      //this is for 'failed' task
      return Image.asset(
        'assets/failed_task.png',
        width: 40.0,
        height: 40.0,
      );
      //return const Icon(Icons.dangerous_outlined);
    } else if (now.isBefore(targetTime) && status == 0) {
      //this is for 'under progress' task

      var hour1 = hour - now.hour;
      var durationMin = (int.parse(minutes) - now.minute) + (hour1 * 60);

      Future.delayed(Duration(minutes: durationMin), () {
        // setState(() {});
      });

      return Image.asset(
        'assets/hour_glass.png',
        width: 40.0,
        height: 40.0,
      );
    } else {
      //this is for 'completed' task
      return Image.asset(
        'assets/bulls_eye.png',
        width: 40.0,
        height: 40.0,
      );
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

    print('Day of Week is $dayOfWeek');
    print('Time of the day is $hour');

    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
          
         icon: "resource://mipmap/daily_dash_launcher",
          id: ids,
          channelKey: 'notificationTodo',
          title: 'DailyDash',
          body: todo,
          displayOnBackground: true,
          displayOnForeground: true,
          ),
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

  int findUnderProcess(
      int id, int status, String timeOfEvent, String dateOfEvent) {
    int hour = int.parse(timeOfEvent.substring(0, 2));
    String minutes = timeOfEvent.substring(3, 5);
    String amORpm = timeOfEvent.substring(6, 8);
    String formattedTime;

    if (amORpm == 'PM') {
      if (hour == 12) {
        hour = 12;
      } else {
        hour = hour + 12;
      }
      formattedTime = '$dateOfEvent $hour:$minutes:00';
    } else if (hour == 12 && amORpm == 'AM') {
      formattedTime = '$dateOfEvent 00:$minutes:00';
    } else if (hour >= 10) {
      formattedTime = '$dateOfEvent $hour:$minutes:00';
    } else {
      formattedTime = '$dateOfEvent 0$hour:$minutes:00';
    }

    //now comparing target time with current time

    DateTime now = DateTime.now();
    DateTime targetTime = DateTime.parse(formattedTime);

    if (now.isBefore(targetTime) && status == 0) {
      //this is for 'under progress' task
      if (!underProcess.contains(id)) {
        underProcess.add(id);
      }
    }

    if (underProcess.isEmpty) {
      return 00;
    }

    return underProcess.length;
  }
}

// ignore: must_be_immutable
class MyCard extends StatefulWidget {
  late Todo todo;
  late int index;
  MyCard(this.todo, this.index, {super.key});
  @override
  State<MyCard> createState() => MyCardState();
}

class MyCardState extends State<MyCard> {
  static bool isLonPressEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: (_MyHomePageState.indexes.contains(widget.index))
          ? Colors.blue.withOpacity(0.5)
          : Colors.transparent,
      child: ListTile(
        title: Text(widget.todo.todo),
        subtitle: Text('Planned on ${widget.todo.date}'),
        trailing: FittedBox(
          fit: BoxFit.fill,
          child: Row(
            children: <Widget>[
              Text(widget.todo.time),
              const SizedBox(
                width: 5,
              ),
              _MyHomePageState().statusChecker(widget.todo.id,
                  widget.todo.status, widget.todo.time, widget.todo.date)
            ],
          ),
        ),
        onLongPress: () {
          setState(() {
            isLonPressEnabled = true;
            if (!_MyHomePageState.indexes.contains(widget.index)) {
              _MyHomePageState.indexes.add(widget.index);
              _MyHomePageState.selectedItems.add(widget.todo.id);
            }
          });
        },
        onTap: () {
          setState(() {
            if (_MyHomePageState.indexes.isNotEmpty && isLonPressEnabled) {
              if (_MyHomePageState.indexes.contains(widget.index)) {
                _MyHomePageState.indexes.remove(widget.index);
                _MyHomePageState.selectedItems.remove(widget.todo.id);
              } else {
                _MyHomePageState.indexes.add(widget.index);
                _MyHomePageState.selectedItems.add(widget.todo.id);
              }
            }
          });
        },
      ),
    );
  }
  
}


