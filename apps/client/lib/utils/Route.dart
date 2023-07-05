// ignore_for_file: prefer_const_constructors

// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:location/ui/BasicHomePage.dart';

import 'package:location/ui/CreateAccount.dart';
import 'package:location/ui/Entrypoint.dart';
import 'package:location/ui/Login.dart';
import 'package:location/ui/Onboarding.dart';
import 'package:location/ui/Register.dart';
import 'package:location/ui/Splash.dart';
import 'package:location/ui/ConfirmUser.dart';

import 'package:location/utils/CustomRoute.dart';
import 'package:provider/provider.dart';

class Routes {
  static dynamic route() {
    return {
      'SplashPage': (BuildContext context) => const SplashPage(),
    };
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name!.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements.last) {
      case "OnBoardingScreen":
        return CustomRoute<bool>(
            settings: settings,
            builder: (BuildContext context) => OnBoardingScreen());
      case "SplashPage":
        return (CustomRoute<bool>(
            settings: settings,
            builder: (BuildContext context) => SplashPage()));
      case "SignUp":
        return CustomRoute<bool>(
            settings: settings, builder: (BuildContext context) => SignUp());
      case "SignIn":
        return CustomRoute<bool>(
            settings: settings, builder: (BuildContext context) => SignIn());
      case "ConfirmUser":
        return CustomRoute<bool>(
            settings: settings,
            builder: (BuildContext context) => ConfirmUser());
      case "CreateAccount":
        return CustomRoute<bool>(
            settings: settings,
            builder: (BuildContext context) => CreateAccount());
      case "Entrypoint":
        return CustomRoute<bool>(
            settings: settings,
            builder: (BuildContext context) => Entrypoint(title: 'DementiApp'));
      default:
        return onUnknownRoute(const RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(settings.name!.split('/')[1]),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name!.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}
