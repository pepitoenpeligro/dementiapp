import 'package:intl/intl.dart';

class DateHelper {
  static String? timestampToDate(int? timestap) {
    if (timestap != null) {
      var dateUtc = DateTime.fromMillisecondsSinceEpoch(timestap, isUtc: true);
      var dateInMyTimezone = dateUtc.add(Duration(hours: 2));
      var formattedDate =
          DateFormat('yyyy-MM-dd – kk:mm').format(dateInMyTimezone);

      return formattedDate.toString();
    }
    return "";
  }
}
