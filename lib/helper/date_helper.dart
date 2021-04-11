import 'package:intl/intl.dart';

class DateHelper {
  static String getStringDateHourTR(DateTime date) {
    var formatter = DateFormat.yMMMMd("tr_TR").add_Hms();
    return formatter.format(date);
  }
}
