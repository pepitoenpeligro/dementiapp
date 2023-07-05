import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/models/Position.dart';
import 'package:location/requests/LocationRequests.dart';
import 'package:location/state/AppState.dart';
import 'package:location/state/AuthState.dart';
import 'package:location/timer/LocationTimerService.dart';
import 'package:location/ui/BottomNavigationBar.dart';
import 'package:location/ui/Login.dart';
import 'package:location/ui/NavigationDrawer.dart';
import 'package:location/ui/about.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:location/utils/fileHandler.dart';

class DataHome extends StatefulWidget {
  const DataHome({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<DataHome> createState() => _DataHomeState();
}

class _DataHomeState extends State<DataHome> {
  String toShow = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FileHandler.readFile().then((value) => setState(() {
          toShow = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text(toShow)],
        ),
      ),
    );
  }
}
