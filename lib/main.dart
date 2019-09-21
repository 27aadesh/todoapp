import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';

void main() {
  return runApp(ClickCounter());
}

class TasksList {
  List<Task> list;

  TasksList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = new List<Task>();
      json['list'].forEach((v) {
        list.add(Task.fromJson(v));
      });
    }
  }
}

class ClickCounter extends StatefulWidget {
  const ClickCounter({Key key}) : super(key: key);

  @override
  _ClickCounterState createState() => _ClickCounterState();
}

class Task {
  String taskName;
  bool isCompleted;
  List<Task> taskslist;
  Task(this.taskName, this.isCompleted);

  Task.fromJson(Map<String, dynamic> json) {
    taskName = json['taskName'];
    isCompleted = json['isCompleted'];
  }
  Map toJson() => {"taskName": taskName, "isCompleted": isCompleted};
}

class _ClickCounterState extends State<ClickCounter> {
  List<Task> tasks = [];
  //TasksList tasks;
  final GlobalKey<AnimatedListState> _listKey = new GlobalKey();
  ScrollController _scrollController = new ScrollController();
  SharedPreferences pref;
  bool isButton = true;

  var _buttonIcon = Icons.add;
  var _buttonText = "Add Item";
  //int i = 0;
  void initState() {
    super.initState();
    //init();
    //tasks = [Task("Task1", false), Task("Task2", true)];

    TasksList tl;
    loadData().then((onValue) {
      tl = TasksList.fromJson(json.decode(onValue));
      tasks = tl.list;
      int i = 0;
      tasks.forEach((f) {
        _listKey.currentState.insertItem(
          i,
          duration: Duration(milliseconds: 600),
        );
        i++;
      });

      setState(() {});
    });
  }

  void dispose() {
    super.dispose();
    String t = json.encode(tasks);
    saveData(t);
  }

  Future<bool> saveData(String t) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(
        "com.aadeshjain.todotasks", "{\"list\":" + t + "}");
  }

  Future<String> loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("com.aadeshjain.todotasks");
  }

  void clearData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("com.aadeshjain.todotasks");
  }

  Widget buildItem(BuildContext context, Task t, Animation<double> animation) {
    return ScaleTransition(
      scale: animation,
      child: ListTile(
        dense: false,
        leading: t.isCompleted?Icon(Icons.radio_button_checked):Icon(Icons.radio_button_unchecked),
        onLongPress: () {
          setState(() {
            _listKey.currentState.removeItem(
                0, (context, animation) => buildItem(context, t, animation),
                duration: const Duration(milliseconds: 100));
          });
          tasks.remove(t);
          clearData();
          saveData(json.encode(tasks));
        },
        onTap: () {
          setState(() {
            t.isCompleted = !t.isCompleted;
            clearData();
            //TasksList tl;
            saveData(json.encode(tasks));
          });
        },
        title: t.isCompleted
            ? Text(
                t.taskName,
                style: TextStyle(decoration: TextDecoration.lineThrough),
              )
            : Text(
                t.taskName,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
                    child: Text(
                      "todo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Text(
                      "" + DateFormat("EEEE d MMM yyyy").format(DateTime.now()),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
                    child: SingleChildScrollView(
                      child: Container(
                        height: 150.0,
                        child: AnimatedList(
                          // shrinkWrap: true, //reverse: true,
                          initialItemCount: tasks.length,
                          controller: _scrollController,
                          key: _listKey,
                          itemBuilder: (context, index, animation) {
                            Task t = tasks[index];
                            return buildItem(context, t, animation);
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 80.0),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              child: child, scale: animation);
                        },
                        child: isButton
                            ? Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 50.0),
                                child: RaisedButton(
                                  color: Colors.black,
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(25.0)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        _buttonIcon,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        _buttonText,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isButton = false;
                                    });
                                  },
                                ),
                              )
                            : TextField(
                                onSubmitted: (String text) {
                                  isButton = true;
                                  _buttonText = "";
                                  _buttonIcon = Icons.done;
                                  Timer(
                                    Duration(seconds: 1),
                                    () {
                                      setState(() {
                                        _buttonIcon = Icons.add;
                                        _buttonText = "Add Item";
                                      });
                                    },
                                  );
                                  // print(json.encode(tasks));
                                  Task task = new Task(text, false);
                                  int length = tasks.length;
                                  print(length);
                                  tasks.insert(length, task);
                                  print(length);
                                  setState(() {});
                                  setState(() {
                                    _listKey.currentState.insertItem(
                                      length,
                                      duration: Duration(milliseconds: 600),
                                    );
                                  });

                                  tasks.forEach(
                                      (f) => print("onadd: " + f.taskName));
                                  //tasks.forEach((f) => print(f.taskName));

                                  Timer(
                                    Duration(milliseconds: 220),
                                    () {
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position.maxScrollExtent,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.ease,
                                      );
                                    },
                                  );
                                  clearData();
                                  //TasksList tl;
                                  saveData(json.encode(tasks));
                                },
                                cursorColor: Colors.black,
                                autofocus: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 25.0),
                                  suffixIcon: Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25.0)),
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25.0)),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 0.2),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
                    child: Text(
                      "What do you want to do today?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          // color: Colors.grey,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 2.0),
                    child: Text(
                      "Start by adding item to your to-do list.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          //   color: Colors.grey,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
