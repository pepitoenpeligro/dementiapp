import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/state/AuthState.dart';
import 'package:provider/provider.dart';

class LocationRequests {
  final String endpoint =
      "https://fsz12ocgr6.execute-api.eu-west-1.amazonaws.com/prod/location";

  void sendLocation(double latitude, double longitude,
      {required BuildContext context}) async {
    var authState = Provider.of<AuthState>(context, listen: false);
    final dio = Dio();
    final locationObject = {
      "userId": authState.user?.userId,
      "location": {
        "latitude": latitude,
        "longitude": longitude,
      }
    };

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: authState.user?.authorizationToken
    };
    // print(headers);
    // print(jsonEncode(locationObject));
    try {
      final response = await dio.post(endpoint,
          options: Options(headers: headers), data: jsonEncode(locationObject));

      print("[${LocationRequests().runtimeType.toString()}] ${response.data}");
    } on DioError catch (e) {
      print(e.error);
      print(e.message);
      print(e.stackTrace);
      print(e.response);
      //   if (e.response != null) {
      //     // Handle Error 404.
      //     // In case of `UserNotFoundException`
      //     if (e.response?.data["message"]["code"] == "NotAuthorizedException") {
      //       print("Ya estas confirmado paqui");
      //       // We should open a new interface in order to confirm cognito user
      //     }
      //   }
      // }
    }
  }

  Future<String?> getLocations(String userId,
      {required BuildContext context}) async {
    var authState = Provider.of<AuthState>(context, listen: false);
    final dio = Dio();

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: authState.user?.authorizationToken
    };

    final requestEndpoint = "$endpoint/$userId";

    try {
      final response =
          await dio.get(requestEndpoint, options: Options(headers: headers));

      return jsonEncode(response.data);
    } on DioError catch (e) {
      print(e.error);
      print(e.message);
      print(e.stackTrace);
      print(e.response);

      return e.message;
    }
  }
}
