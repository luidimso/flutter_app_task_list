import 'dart:convert';
import 'dart:io';

import "package:flutter/material.dart";
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home()
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _taskController = TextEditingController();

  List _taskList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _readFile().then((value) {
      setState(() {
        _taskList = json.decode(value);
      });
    });
  }

  void _addTask() {
    setState(() {
      Map<String, dynamic> newTask = Map();
      newTask["title"] = _taskController.text;
      newTask["ok"] = false;
      _taskController.text = "";
      _taskList.add(newTask);
      _saveFile();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _taskList.sort((a, b) {
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return -1;
        else return 0;
      });

      _saveFile();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task List"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                        labelText: "New task",
                        labelStyle: TextStyle(
                            color: Colors.blueAccent
                        )
                    ),
                  )
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("Add"),
                  textColor: Colors.white,
                  onPressed: _addTask
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _taskList.length,
                  itemBuilder: buildItemList
              ),
            )
          )
        ],
      ),
    );
  }

  Widget buildItemList (BuildContext context, int index) {
    return Dismissible(
        key: Key(DateTime.now().millisecond.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0),
              child: Icon(Icons.delete,
                color: Colors.white
              )
            ),
          ),
        direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_taskList[index]["title"]),
        value: _taskList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_taskList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (checked) {
          setState(() {
            _taskList[index]["ok"] = checked;
            _saveFile();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_taskList[index]);
          _lastRemovedPosition = index;
          _taskList.removeAt(index);
          _saveFile();

          final snackBar = SnackBar(
            content: Text("Task ${_lastRemoved["title"]} removed!"),
            duration: Duration(
              seconds: 2
            ),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                setState(() {
                  _taskList.insert(_lastRemovedPosition, _lastRemoved);
                  _saveFile();
                });
              },
            ),
          );

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snackBar);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/tasks.json");
  }

  Future<File> _saveFile() async {
    String data = json.encode(_taskList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch(error) {
      print(error);
      return null;
    }
  }
}
