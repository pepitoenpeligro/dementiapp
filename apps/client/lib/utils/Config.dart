import 'dart:ui';

import 'package:flutter/material.dart';

class Config {
  static final Config _Config = Config._internal();

  // int locationSendMillisecondsInterval = 5 * 1000;
  int locationSendMillisecondsInterval = 30 * 1000;

  Color cardColor = Colors.red;

  factory Config() {
    return _Config;
  }

  Config._internal();
}
