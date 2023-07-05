import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:location/state/AuthState.dart';
import 'package:location/ui/Login.dart';
import 'package:location/utils/AuthStatusEnum.dart';
import 'package:lottie/lottie.dart';

import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    // print("[SplashScreen] initState");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer();
    });
    super.initState();
    // print(isAndroid);
    // print(isIOS);
    // print(isWindows);
    // print(isWeb);
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  void timer() async {
    Future.delayed(const Duration(milliseconds: 2400)).then((_) {
      while (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/OnBoardingScreen');
      deactivate();

      // var state = Provider.of<AuthState>(context, listen: false);
      // state.getCurrentUser(context: context);
    });
  }

  Widget _body() {
    var height = 150.0;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(50),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                height: 200,
                width: 200,
                child: Column(children: [
                  LottieBuilder.asset(
                      'assets/animations/ComposicionPepito.json',
                      width: 150,
                      height: 150,
                      frameRate: FrameRate.max),
                  // Image.asset(
                  //   'assets/graphics/icon.png',
                  //   width: 150,
                  //   height: 150,
                  // ),
                  Spacer(),
                  isIOS
                      ? CupertinoActivityIndicator(
                          radius: 35,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(1),
                        )
                      : CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(1),
                        ),
                ]),
              )
              // Image.asset(
              //   'assets/images/icon-480.png',
              //   height: 30,
              //   width: 30,
              // )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Scaffold(
        // backgroundColor: Colors.orange,
        backgroundColor:
            Theme.of(context).colorScheme.tertiary.withOpacity(0.75),
        body: state.authStatus != AuthStatus.LOGGED_IN ? _body() : _body()
        // : state.authStatus == AuthStatus.NOT_LOGGED_IN
        //     ? const OnBoar()
        //     : const SignIn(),
        );
  }
}
