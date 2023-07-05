import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/models/User.dart';
import 'package:location/state/AuthState.dart';
import 'package:provider/provider.dart';

class LinksRequests {
  // to complete
  final String endpoint =
      "https://fsz12ocgr6.execute-api.eu-west-1.amazonaws.com/prod/links";

  Future<bool?> createLink(String? invitationId,
      {required BuildContext context}) async {
    var authState = Provider.of<AuthState>(context, listen: false);

    final dio = Dio();

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: authState.user?.authorizationToken
    };

    final dataBody = {
      "invitation": {"invitationId": invitationId}
    };

    try {
      final response = await dio.post(endpoint,
          options: Options(headers: headers), data: jsonEncode(dataBody));

      // print("[${LinksRequests().runtimeType.toString()}] ${response.data}");
      return true;
    } on DioError catch (e) {
      print(e.error);
      print(e.message);
      print(e.stackTrace);
      print(e.response);
      return false;
    }
  }

  Future<String?> getLinks({required BuildContext context}) async {
    var authState = Provider.of<AuthState>(context, listen: false);

    final dio = Dio();

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: authState.user?.authorizationToken
    };

    try {
      final response = await dio.get(endpoint,
          options: Options(headers: headers),
          queryParameters: {"email": "${authState.user?.email}"});

      // print("[${LinksRequests().runtimeType.toString()}] ${response.data}");
      return jsonEncode(response.data);
    } on DioError catch (e) {
      print(e.error);
      print(e.message);
      print(e.stackTrace);
      print(e.response);
      return null;
    }
  }
}
