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
import 'package:location/ui/DataHome.dart';
import 'package:location/ui/Login.dart';
import 'package:location/ui/NavigationDrawer.dart';
import 'package:location/ui/about.dart';
import 'package:location/ui/LinksPage.dart';
import 'package:location/utils/fileHandler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class BasicHomePage extends StatefulWidget {
  const BasicHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<BasicHomePage> createState() => _BasicHomePageState();
}

class _BasicHomePageState extends State<BasicHomePage> {
  int _counter = 0;
  ProgramaticTimerService lts = ProgramaticTimerService(
      interval: const Duration(seconds: 3),
      codeToExecute: () => {print("Holaaaa")});

  // ProgramaticTimerService lts = ProgramaticTimerService(
  //     interval: const Duration(seconds: 4),
  //     codeToExecute: () => {print("Holaaaa")});

  Position? currentPosition;
  StreamSubscription<Position>? positionStream;
  List<PositionInterface>? positionRecollected = List.empty(growable: true);

  String locationsFileName = DateTime.now().millisecondsSinceEpoch.toString();

  bool statusRecording = false;

  bool showAnimationLocationTracking = false;

  int _selectedIndex = 0;

  void captureLocationProcess() {
    // lts.start();
    // print("[captureLocationProcess] ");
    // listenToLocationChanges();
    // captureLocation();
    // setState(() {
    //   statusRecording = true;
    //   // showAnimationLocationTracking = !showAnimationLocationTracking;
    // });
    // _recordPositionToJson();
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // pages to display
  final List<Widget> _pages = [
    // home page
    const BasicHomePage(
      title: 'HomeeePage',
    ),

    const LinksPage(),

    const AboutPage(),
  ];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    positionStream?.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lts.start();

    // lts.fire();

    _requestLocationServicePermissions();
    captureLocationProcess();
  }

  void _requestLocationServicePermissions() async {
    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      /// open app settings so that user changes permissions
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();

      return;
    }
  }

  void captureLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentPosition = position;
    });
  }

  void getLastKnownPosition() async {
    Position? position = await Geolocator.getLastKnownPosition();
  }

  void _goViewData() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DataHome(
              title: 'Json Raw Viewer',
            )));
  }

  void listenToLocationChanges() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        setState(() {
          currentPosition = position;

          if (statusRecording) {
            // enviar datos a api gateway con el timer
            PositionInterface newPosition = PositionInterface();
            newPosition.latitude = currentPosition?.latitude;
            newPosition.longitude = currentPosition?.longitude;
            newPosition.createdAt = DateTime.now().millisecondsSinceEpoch;
            positionRecollected?.add(newPosition);

            // lts.codeToExecute = () => {
            //       if (newPosition.latitude! != 0 && newPosition.longitude! != 0)
            //         {
            //           LocationRequests().sendLocation(
            //               newPosition.latitude!, newPosition.longitude!,
            //               context: context)
            //         }
            //     };
            // // @todo parametrizar
            // lts.interval = Duration(seconds: 3);

            FileHandler.writePositionsToFile(positionRecollected!);
          }
        });
      },
    );
  }

  void _recordPositionToJson() {
    listenToLocationChanges();
    captureLocation();
    setState(() {
      statusRecording = !statusRecording;
      showAnimationLocationTracking = !showAnimationLocationTracking;
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the BasicHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10.0),
            child: Container(
              height: 1.0,
              color: Colors.grey.withOpacity(0.5),
            )),
      ),
      drawer: const NavigationDrawerCustom(),

      bottomNavigationBar: BottomNavigationBarCustom(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                // color: Colors.red,
                child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Visibility(
                        visible: showAnimationLocationTracking,
                        child: Lottie.network(
                            'https://assets3.lottiefiles.com/packages/lf20_FtD13Z.json')))),
            Container(
                // color: Colors.yellow,
                child: Column(children: [
              const Text('Realtime LatLon:'),
              Text(currentPosition != null
                  ? 'Lat: ${currentPosition?.latitude}'
                  : 'no data'),
              Text(currentPosition != null
                  ? 'Lon: ${currentPosition?.longitude}'
                  : 'no data'),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.rocket_launch,
                  color: Colors.blue,
                  size: 24.0,
                  semanticLabel: 'Start recording location tracking',
                ),
                TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: _recordPositionToJson,
                    child: Text(statusRecording ? 'Stop' : 'Start'))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.delete,
                  color: Colors.orange,
                  size: 24.0,
                  semanticLabel: 'Erase recorded data',
                ),
                TextButton(
                    onPressed: () =>
                        {FileHandler.eraseData(), positionRecollected?.clear()},
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.orange),
                    ),
                    child: Text("Erase data"))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.data_array_rounded,
                  color: Colors.pink,
                  size: 24.0,
                  semanticLabel: 'View recorded data',
                ),
                TextButton(
                    onPressed: _goViewData,
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.pink),
                    ),
                    child: Text("View Data"))
              ]),
            ])),
            // Divider(),

            // showAnimationLocationTracking
            //     ? Lottie.network(
            //         'https://assets3.lottiefiles.com/packages/lf20_FtD13Z.json')
            //     : null

            // Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            //   Text('hola'),
            // ])
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _requestLocationServicePermissions,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
