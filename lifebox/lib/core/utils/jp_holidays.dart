import 'package:holiday_jp/holiday_jp.dart' as holiday_jp;

class JpHolidays {
  /// holiday_jp page: https://pub.dev/packages/holiday_jp
  static String? holidayNameJa(DateTime localDate) {
    final d = DateTime.utc(localDate.year, localDate.month, localDate.day);
    final h = holiday_jp.getHoliday(d);
    return h?.name;/// null if not holiday
  }

  static bool isHoliday(DateTime localDate) {
    final d = DateTime.utc(localDate.year, localDate.month, localDate.day);
    return holiday_jp.isHoliday(d);
  }
}
