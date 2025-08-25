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

  static String getDayName(int year, int month, int day) {
    DateTime date = DateTime(year, month, day);
    return DateFormat('EEEE').format(date);
  }

  static String getFullMonthName(int monthIndex) {
    DateTime date = DateTime(2000, monthIndex);
    return DateFormat('MMMM').format(date);
  }

  static String getAbbreviatedMonthName(int monthIndex) {
    DateTime date = DateTime(2000, monthIndex);
    return DateFormat('MMM').format(date);
  }

  static int thisDayIndex = DateTime.now().day - 1;
  static int thisMonthIndex = DateTime.now().month - 1;
  static int thisYear = DateTime.now().year;
  static int thisMonthDaysCount = daysInMonth(thisMonthIndex + 1, thisYear);

  static int daysInMonth(int year, int month) {
    if (month == 12) {
      year += 1;
      month = 1;
    } else {
      month += 1;
    }

    DateTime lastDayOfMonth = DateTime(
      year,
      month,
      1,
    ).subtract(Duration(days: 1));
    return lastDayOfMonth.day;
  }
}
