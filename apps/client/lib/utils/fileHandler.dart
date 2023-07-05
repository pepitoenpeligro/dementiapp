import 'dart:io';

import 'package:location/models/Position.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  static Future<File> writePositionsToFile(List<PositionInterface> data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(data.toString());
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static void eraseData() async {
    final file = await _localFile;
    if (await file.exists()) {
      file.delete();
    }
  }

  static Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/locationsFileName.json');
  }

  static Future<String> readFile() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "-";
    }
  }
}
