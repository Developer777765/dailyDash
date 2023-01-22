import 'dart:async';
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
  List<Todo> listOfValues = [];
  List<int> indexes = [];
  List<int> selectedItems = [];
  bool gotData = false;
  bool lonPressEnabled = false;

  @override
  void initState() {
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    DatabaseModel data = DatabaseModel();
    data.queryingData().then((value) {
      //since we can't initialize or store our list inside this method we're making use of setter
      
        setState(() {
          if (value.isNotEmpty) {
            settingListOfValues = value;
            settingGotData = true;
          }
        });
      
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
        floatingActionButton: Row(children: <Widget>[
          FloatingActionButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddTask())).then((value) => refreshPage());
            },
            child: const Icon(Icons.add),
          ),
          ElevatedButton(
              onPressed: () {
                lonPressEnabled = false;
                DatabaseModel model = DatabaseModel();

                setState(() {
                  for (int i = 0; i < selectedItems.length; i++) {
                    model.deletingRecord(selectedItems[i]);
                  }
                });
              },
              child: const Text('Delete'))
        ]));
  }

  // a simple setter to initialize listOfValues
  set settingListOfValues(List<Todo> val) {
    listOfValues = val;
  }

  // the following setter ensures whether we've todos
  set settingGotData(bool gotData1) {
    gotData = gotData1;
  }

  //the following method actually returns the body of our main page which is the list of todos
  Widget content() {
    return SafeArea(
      child: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Card(
              color: (indexes.contains(index))
                  ? Colors.blue.withOpacity(0.5)
                  : Colors.transparent,
              child: ListTile(
                title: Text(listOfValues[index].todo),
                subtitle: Text('Planned on ${listOfValues[index].date}'),
                trailing: Text(listOfValues[index].time),
                onLongPress: () {
                  setState(() {
                    lonPressEnabled = true;
                    if (!indexes.contains(index)) {
                      indexes.add(index);
                      //selectedItems.add(listOfValues[index].id);
                    }
                  });
                },
                onTap: () {
                  setState(() {
                    if (lonPressEnabled) {
                      if (indexes.contains(index)) {
                        indexes.remove(index);
                        //selectedItems.remove(listOfValues[index].id);
                      } else {
                        indexes.add(index);
                        //selectedItems.add(listOfValues[index].id);
                      }
                    }
                  });
                },
              ),
            );
          },
          itemCount: listOfValues.length,  
        ),
      ),
    );
  }
   refreshPage() async {

    
    setState(() {
      //refreshing home page
      
    });
  
  }
}
