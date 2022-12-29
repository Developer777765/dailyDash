import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/addToDo.dart';
import 'package:todo/dataBase.dart';
import 'package:todo/todoModel.dart';

void main() async {
  runApp(const MyApp());
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
  List<String> listOfValues = [];
   bool gotData = false;

  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    DatabaseModel data = DatabaseModel();
    data.queryingData().then((value) {
      //since we can't initialize or store our list inside this method we're making use of setter

      if (listOfValues.isEmpty) {
        setState(() {
          if (value.isNotEmpty) {
            settingListOfValues = value;
            settingGotData = true;
          }
        });
      }
    });

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
                  width: 75,
                  padding: const EdgeInsets.only(top: 17),
                  color: Colors.black,
                  child: Column(children: const [Text('X'), Text('left')]))),
          Opacity(
              opacity: 0.7,
              child: Container(
                  padding: const EdgeInsets.only(top: 9),
                  color: Colors.black,
                  child: CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 5,
                    progressColor: Colors.purple,
                    percent: 0.5,
                    center: const Text('x'),
                  ))),
          Opacity(
              opacity: 0.7,
              child: Container(
                  width: 75,
                  padding: const EdgeInsets.only(top: 17),
                  color: Colors.black,
                  child:
                      Column(children: const [Text('Y'), Text('failed')]))),
        ],
      ),
//
      body: gotData
          ? content()
          : Container(
              child: const Center(
                child: Text('u got nothing'),
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTask()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // a simple setter to initialize listOfValues
  set settingListOfValues(List<String> val) {
    listOfValues = val;
  }
  // the following setter ensures whether we've todos
  set settingGotData(bool gotData1){
    gotData = gotData1;
  }
  //the following method actually returns the body of our main page which is the list of todos
  Widget content() {
    return SafeArea(
      child: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(extractingEvent(listOfValues[index])),
                    subtitle: Text(extractingDate(listOfValues[index])),
                    trailing: Text(extractingTime(listOfValues[index])),
                  ),
                ],
              ),
            );
          },
          itemCount: listOfValues.length,
        ),
      ),
    );
  }
  
  //following method extracts date of the planned event
   String extractingDate(String date){
    int startingIndex = date.length - 18;
    int endIndex = startingIndex + 10;
    String sliceOutDate = date.substring(startingIndex,endIndex);
    return 'Scheduled on $sliceOutDate';
  }

  //following method extracts name of the planned event
   String extractingEvent(String event){
    int startingIndex = 0;
    int endIndex = event.length - 18;
    String sliceOutEvent = event.substring(startingIndex,endIndex);
    return sliceOutEvent;
  }

   //following method extracts time of the planned event
   String extractingTime(String timeOfEvent){
    int index1 = timeOfEvent.length - 20;
    int index2 = timeOfEvent.length;
    String dateAndtime = timeOfEvent.substring(index1,index2);
    String timeOnly = dateAndtime.substring(12,dateAndtime.length);
    return timeOnly;
  }
  

}
