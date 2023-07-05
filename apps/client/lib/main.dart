import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:location/state/AppState.dart';
import 'package:location/state/AuthState.dart';

import 'package:location/state/LinksState.dart';
import 'package:location/state/LiveNotificationState.dart';

import 'package:location/ui/SnackbarGlobal.dart';

import 'package:location/utils/MyCustomScrollBehavior.dart';

import 'package:provider/provider.dart';
import 'utils/Route.dart';
import 'color_schemes.g.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    print(details.toString());
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    print(error);
    print(stack);
    return true;
  };
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AppState>(create: (_) => AppState()),
    ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
    ChangeNotifierProvider<LinksState>(create: (_) => LinksState()),
    ChangeNotifierProvider<LiveNotificationState>(
        create: (_) => LiveNotificationState()),
  ], child: const MyApp()));
}
// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: SnackbarGlobal.key,
      // supportedLocales: const [
      //   Locale('de', 'DE'),
      //   Locale('en', 'US'),
      //   Locale('es', 'ES'),
      // ],
      // locale: const Locale('es'),
      title: 'DementiApp',
      // theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      // para darkTheme only
      // theme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
      theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
      darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      routes: Routes.route(),
      onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
      onUnknownRoute: (settings) => Routes.onUnknownRoute(settings),
      initialRoute: "SplashPage",
      scrollBehavior: MyCustomScrollBehavior(),
    );
  }
}
