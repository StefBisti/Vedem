import 'package:intl/intl.dart';

class TimeUtils {
  static String minutesToString(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    String result = '';
    if (hours > 0) {
      result += '${hours}h';
    }
    if (minutes > 0 || hours == 0) {
      result += ' ${mins}m';
    }
    return result;
  }

  static String minutesToTimeString(int minutes, {bool use24h = true}) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;

    if (use24h) {
      final hh = hours.toString().padLeft(2, '0');
      final mm = mins.toString().padLeft(2, '0');
      return '$hh:$mm';
    } else {
      final h12 = hours % 12 == 0 ? 12 : hours % 12;
      final period = hours < 12 ? 'am' : 'pm';
      final mm = mins.toString().padLeft(2, '0');
      return '$h12:$mm $period';
    }
  }

  static int thisDayIndex = DateTime.now().day - 1;
  static int thisMonthIndex = DateTime.now().month - 1;
  static int thisYear = DateTime.now().year;

  static String thisDayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
  static String thisMonthId = DateFormat('yyyy-MM').format(DateTime.now());

  static String formatDayId(String dayId, {bool addYear = false}) {
    DateTime date = DateTime.parse(dayId);
    if (addYear) {
      return DateFormat('d MMM yyyy, EEEE').format(date);
    }
    return DateFormat('d MMM, EEEE').format(date);
  }
}
