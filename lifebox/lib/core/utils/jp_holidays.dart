import 'package:holiday_jp/holiday_jp.dart' as holiday_jp;

class JpHolidays {
  /// holiday_jp 示例多用 UTC 日期；为了不踩时区坑，这里统一用 UTC 日期去查询
  static String? holidayNameJa(DateTime localDate) {
    final d = DateTime.utc(localDate.year, localDate.month, localDate.day);
    final h = holiday_jp.getHoliday(d);
    return h?.name; // 日本語名
  }

  static bool isHoliday(DateTime localDate) {
    final d = DateTime.utc(localDate.year, localDate.month, localDate.day);
    return holiday_jp.isHoliday(d);
  }
}
