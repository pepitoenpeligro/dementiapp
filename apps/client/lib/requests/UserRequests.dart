import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/models/User.dart';
import 'package:location/state/AuthState.dart';
import 'package:provider/provider.dart';

class UserRequests {
  // to complete
  final String endpoint =
      "https://fsz12ocgr6.execute-api.eu-west-1.amazonaws.com/prod/users";

  Future<bool?> updateUser(User user, {required BuildContext context}) async {
    var authState = Provider.of<AuthState>(context, listen: false);

    print("En UserRequests veo ");
    print(authState.user!.toJson().toString());
    final dio = Dio();
    // final locationObject = {
    //   "location": {
    //     "latitude": latitude,
    //     "longitude": longitude,
    //   }
    // };

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: authState.user?.authorizationToken
    };
    // print(headers);
    // print(jsonEncode(locationObject));
    try {
      var newUser = authState.user!;
      newUser.authorizationToken = '';
      newUser.notificationToken = '';
      var putUserEndpoint = "${endpoint}/${newUser.userId}";
      print("[1] Voy a enviar esto: ");
      print(newUser.toJson().toString());
      print("[2] Voy a enviar esto: ");
      print(newUser.toJson());
      print("[3] Voy a enviar esto: ");
      print(jsonEncode(newUser));
      final response = await dio.put(putUserEndpoint,
          options: Options(headers: headers), data: jsonEncode(newUser));

      print("[${UserRequests().runtimeType.toString()}] ${response.data}");
      return true;
    } on DioError catch (e) {
      print(e.error);
      print(e.message);
      print(e.stackTrace);
      print(e.response);
      return false;
    }
  }
}
