import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isWorking = false;

  bool get isWorking => _isWorking;

  set isWorking(bool value) {
    if (value != _isWorking) {
      _isWorking = value;
      notifyListeners();
    }
  }
}
