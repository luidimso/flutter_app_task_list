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
  List _taskList = [];

  @override
  Widget build(BuildContext context) {
    return Container();
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