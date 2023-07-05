import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:location/models/ModelProvider.dart';
import 'package:location/state/AuthState.dart';
import 'package:location/state/LiveNotificationState.dart';
import 'package:location/ui/BottomNavigationBar.dart';
import 'package:location/ui/CustomHome.dart';
import 'package:location/ui/LinksPage.dart';
import 'package:location/ui/NavigationDrawer.dart';
import 'package:location/ui/about.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:location/models/Notification.dart';
import 'package:location/amplifyconfiguration.dart';
import 'package:location/utils/AuthStatusEnum.dart';
import 'package:provider/provider.dart';

class Entrypoint extends StatefulWidget {
  const Entrypoint({super.key, required this.title});

  final String title;

  @override
  State<Entrypoint> createState() => _EntrypointState();
}

class _EntrypointState extends State<Entrypoint> {
  static late StreamController<int> notificationStreamController;
  bool _isAmplifyConfigured = false;

  late List<Widget> _pages;

  // StreamController<int> _controller = StreamController<int>();

  @override
  void initState() {
    // TODO: implement initState

    // var authState = Provider.of<AuthState>(context, listen: false);
    // if (Provider.of<AuthState>(context, listen: false)
    //     .user
    //     ?.authorizationToken.isNotEmpty) {
    //   _configureAmplify();
    //   subscribe();
    // }

    _configureAmplify();
    // subscribe();
    notificationStreamController = StreamController<int>.broadcast();

    _pages = [
      // home page
      CustomHome(
        stream: notificationStreamController.stream,
      ),

      const LinksPage(),

      const AboutPage(),
    ];
    super.initState();
  }

  bool _amplifyConfigured = false;
  int _selectedPageIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  Future<void> _configureAmplify() async {
    await Amplify.addPlugins([
      AmplifyAPI(modelProvider: ModelProvider.instance),
    ]);
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print(
        'Amplify was already configured. Looks like app restarted on android.',
      );
    }
    setState(() {
      _isAmplifyConfigured = true;
    });

    subscribe();
    // final api = AmplifyAPI(modelProvider: ModelProvider.instance);
    // try {
    //   await Amplify.addPlugin(api);
    // } on PluginError {
    //   print("Amplify error to add plugin");
    // }
    // try {
    //   await Amplify.configure(amplifyconfig);
    // } on AmplifyAlreadyConfiguredException {
    //   print("Amplify was already configured");
    // }
    // // try {
    // //   // await Amplify.configure(amplifyconfig);
    // // } on AmplifyAlreadyConfiguredException {
    // //   safePrint(
    // //       'Tried to reconfigure Amplify; this can occur when your app restarts on Android.');
    // // }
  }

  Future<void> subscribe() async {
    final graphQLDocument = '''
subscription Notifications {
  onCreateNotification(filter: {userId: {eq: "${Provider.of<AuthState>(context, listen: false).user?.userId}" }}) {
    id
    title
    message
    userId
    timestamp
  }
}
''';
    final Stream<GraphQLResponse<String>> operation = Amplify.API.subscribe(
      GraphQLRequest<String>(document: graphQLDocument),
      onEstablished: () => print('Subscription established'),
    );

    try {
      // Retrieve 5 events from the subscription
      var i = 0;
      await for (var event in operation) {
        i++;
        print('Subscription event data received: ${event.data}');
        var decodificado = jsonDecode(event.data!)["onCreateNotification"];
        print("Decificiao");
        print(decodificado);

        // print(jdecodificado as NotificationModel);
        NotificationModel realData = NotificationModel.fromJson(decodificado);

        print("Lo que capturo");
        print(realData);
        Provider.of<LiveNotificationState>(context, listen: false)
            .addItem(realData);
        notificationStreamController.sink.add(0);

        // Necesito notificar al CustomHome

        if (i == 5) {
          break;
        }
      }
    } on Exception catch (e) {
      print('Error in subscription stream: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    print("[Entrypoint] disposed");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
        body: _pages[_selectedPageIndex]
        // body: IndexedStack(
        //   index: _selectedPageIndex,
        //   children: _pages,
        // ),
        );
  }
}
