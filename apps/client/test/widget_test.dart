// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'dart:html';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:location/main.dart';
import 'package:location/state/AppState.dart';
import 'package:location/state/AuthState.dart';
import 'package:location/state/LinksState.dart';
import 'package:location/state/LiveNotificationState.dart';
import 'package:location/ui/Onboarding.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('DementiApp Launcher Test', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<AppState>(create: (_) => AppState()),
      ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
      ChangeNotifierProvider<LinksState>(create: (_) => LinksState()),
      ChangeNotifierProvider<LiveNotificationState>(
          create: (_) => LiveNotificationState()),
    ], child: const MyApp()));
    // await tester.pumpWidget(const MyApp());
    await tester.pump(Duration(seconds: 4));

    expect(find.text('DementiApp'), findsNothing);
  });

}
