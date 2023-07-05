import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/models/User.dart';
import 'package:location/utils/AuthStatusEnum.dart';
// import 'package:location/utils/snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart';
import 'dart:developer';

import 'AppState.dart';
import 'dart:developer';

class AuthState extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  User? user;
  late String userId;

  void openSignUpPage() {
    print('opensignUpPage');
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    notifyListeners();
  }

  Future<bool?> confirm(String username, String code,
      {required BuildContext context}) async {
    try {
      isWorking = true;

      final dio = Dio();
      log("[Cognito] User Confirm start");
      final response = await dio.post(
          'https://uz7rggk5of.execute-api.eu-west-1.amazonaws.com/prod/auth/confirm_signup',
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: jsonEncode({"username": username, "code": code}));

      final statusConfirmed = response.data["confirmed"];
      if (statusConfirmed == true) {
        // usuario confirmado, lo llevamos de vuelta al login
        return statusConfirmed;
      }

      log("[Cognito] User Confirm ends");
    } on DioError catch (e) {
      if (e.response != null) {
        // Handle Error 404.
        // In case of `UserNotFoundException`
        if (e.response?.data["message"]["code"] == "NotAuthorizedException") {
          print("Ya estas confirmado paqui");
          // We should open a new interface in order to confirm cognito user
        }
        print(e.response?.data);
        print(e.response?.data["message"]["code"]);
        print(e.response?.headers);
        print(e.response?.requestOptions);
      } else {
        print(e.requestOptions);
        print(e.message);
      }
      return false;
    } finally {
      isWorking = false;
    }
  }

  Future<String?> signIn(String email, String password,
      {required BuildContext context}) async {
    try {
      isWorking = true;
      final dio = Dio();

      log("Cognito Signin start");
      final response = await dio.post(
          'https://uz7rggk5of.execute-api.eu-west-1.amazonaws.com/prod/auth/signin',
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: jsonEncode({"username": email, "password": password}));

      log("Cognito Signin end");

      log(response.data.toString());
      log(response.statusCode.toString());

      final String accessToken = response.data["token"]!;
      user = User(email: email, authorizationToken: accessToken);

      return accessToken;
    } on DioError catch (e) {
      if (e.response != null) {
        // Handle Error 404.
        // In case of `UserNotFoundException`
        if (e.response?.data["message"]["code"] ==
            "UserNotConfirmedException") {
          print("No estas confirmao paqui");
          return "UserNotConfirmedException";
          // We should open a new interface in order to confirm cognito user
        }
        print(e.response?.data);
        print(e.response?.data["message"]["code"]);
        print(e.response?.headers);
        print(e.response?.requestOptions);
      } else {
        print(e.requestOptions);
        print(e.message);
      }
      return e.message;
    } finally {
      isWorking = false;
    }
  }

  Future<bool?> signUp(String username, String email, String password,
      {required BuildContext context}) async {
    try {
      isWorking = true;
      final dio = Dio();
      print("VAMOS A COGNITO");
      final response = await dio.post(
          'https://uz7rggk5of.execute-api.eu-west-1.amazonaws.com/prod/auth/signup',
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: jsonEncode(
              {"username": username, "email": email, "password": password}));
      print("COGNIT TE DEVUELVE: ");
      print(response);
      // final String accessToken = response.data["token"]!;

      if (response.statusCode == 200) {
        return true;
      }
    } catch (error) {
      print("ERROR makeing post to sign up");
      print(error);
      return false;
    } finally {
      isWorking = false;
    }
  }

  Future<User?> getCurrentUser({required BuildContext context}) async {
    try {
      print("[getCurrentUser]");
      isWorking = true;

      final head = Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        'Authorization': user!.authorizationToken
      });

      final dio = Dio();
      final response = await dio.get(
          'https://uz7rggk5of.execute-api.eu-west-1.amazonaws.com/prod/auth/current_user',
          options: head);

      // print("Estableciendo dato a dato");
      // print(response.data);

      user?.userId = response.data["userId"];
      userId = response.data["userId"];
      user?.email = response.data["email"];
      user?.userName = response.data["userName"];
      user?.participation = response.data["participation"];
      user?.displayName = response.data["displayName"];
      user?.birthdate = response.data["birthdate"];
      user?.createdAt = response.data["createdAt"];
      user?.firstLogin = response.data["firstLogin"];
      user?.profilePic = response.data["profilePic"];

      if (user != null) {
        // await getProfileUser();
        authStatus = AuthStatus.LOGGED_IN;
        // userId = user?.userId!;
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      }
      isWorking = false;
      return user;
    } catch (error) {
      isWorking = false;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      return null;
    }
  }
}
