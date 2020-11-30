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
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: _taskList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
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
                );
              }
            )
          )
        ],
      ),
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
