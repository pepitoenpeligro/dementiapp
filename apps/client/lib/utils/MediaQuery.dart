// import 'dart:js';

import 'package:flutter/widgets.dart';

class MQuery {
  double getWidth({required BuildContext context}) {
    return MediaQuery.of(context).size.width;
  }

  double getHeight({required BuildContext context}) {
    return MediaQuery.of(context).size.height;
  }
}
