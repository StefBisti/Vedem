import 'package:intl/intl.dart';

class TimeUtils {
  static String minutesToString(int minutes) {
    int hours = minutes ~/ 60;
    int min = minutes % 60;
    String result = '';
    if (hours > 0) {
      result += '${hours}h';
    }
    if (minutes > 0 || hours == 0) {
      result += ' ${min}m';
    }
    return result;
  }

  static int thisDayIndex = DateTime.now().day - 1;
  static int thisMonthIndex = DateTime.now().month - 1;
  static int thisYear = DateTime.now().year;

  static String thisDayId = '2025-09-19';
  //static String thisDayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
  static String thisMonthId = DateFormat('yyyy-MM').format(DateTime.now());

  static String formatDayId(String dayId, {bool addYear = false}) {
    DateTime date = DateTime.parse(dayId);
    if (addYear) {
      return DateFormat('d MMM yyyy, EEEE').format(date);
    }
    return DateFormat('d MMM, EEEE').format(date);
  }
}
