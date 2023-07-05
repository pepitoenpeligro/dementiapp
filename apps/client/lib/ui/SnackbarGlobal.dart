import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackbarGlobal {
  static GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>(debugLabel: '[SnackbarGlobal] key');

  static void show(String message) {
    key.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static successSnackBar(BuildContext context, String msg) {
    var awc = AwesomeSnackbarContent(
      title: 'Success',
      message: msg,
      contentType: ContentType.success,
      inMaterialBanner: true,
    );

    final materialBanner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: awc,
      actions: const [SizedBox.shrink()],
    );

    // muestra el snackbar
    if (key.currentState?.mounted == true) {
      key.currentState!
        ..hideCurrentSnackBar()
        ..showMaterialBanner(materialBanner);

      // oculta el snackbar
      Future.delayed(Duration(milliseconds: 1050), () {
        print("[Quitamos el snackbar]");
        key.currentState!.hideCurrentMaterialBanner();
      });
    }
  }

  static errorSnackBar(BuildContext context, String msg) {
    final materialBanner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: msg,
        contentType: ContentType.failure,
        inMaterialBanner: true,
      ),
      actions: const [SizedBox.shrink()],
    );

    if (key.currentState?.mounted == true) {
      key.currentState!
        ..hideCurrentSnackBar()
        ..showMaterialBanner(materialBanner);

      // oculta el snackbar
      Future.delayed(Duration(milliseconds: 1050), () {
        print("[Quitamos el snackbar]");
        key.currentState!.hideCurrentMaterialBanner();
      });
    }
  }
}
