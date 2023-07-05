import 'dart:html';

import 'package:package_info_plus/package_info_plus.dart';

class MetadataProvider {
  static Future<String> version() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String> buildNumber() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }
}
