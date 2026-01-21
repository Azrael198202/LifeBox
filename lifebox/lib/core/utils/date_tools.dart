/// lib/core/utils/date_tools.dart
///
/// Date tools:
/// - normalizeDateToYMD: normalize many date formats to `yyyy-MM-dd`
/// - tryParseYMD: parse `yyyy-MM-dd` safely
///
/// Supported inputs (examples):
/// - 2026-01-20
/// - 2026/1/20
/// - 2026.01.20
/// - 1/20
/// - 01/20
/// - 2026年01月20日
/// - 2026年1月20日
/// - 1月20日
///
/// Rules:
/// - If year is missing, use current year.
/// - Invalid date -> returns null.

class DateTools {
  DateTools._();

  /// Normalize date string to `yyyy-MM-dd`.
  /// Returns null if cannot parse or invalid date.
  static String? normalizeDateToYMD(String? raw, {DateTime? now}) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;

    final base = now ?? DateTime.now();

    // 1) yyyy-MM-dd / yyyy/M/d / yyyy.M.d
    final regYMD = RegExp(r'^(\d{4})[-/\.](\d{1,2})[-/\.](\d{1,2})$');
    final m1 = regYMD.firstMatch(v);
    if (m1 != null) {
      return _safeYmd(
        int.parse(m1[1]!),
        int.parse(m1[2]!),
        int.parse(m1[3]!),
      );
    }

    // 2) MM/dd or M/d (no year -> current year)
    final regMD = RegExp(r'^(\d{1,2})[/-](\d{1,2})$');
    final m2 = regMD.firstMatch(v);
    if (m2 != null) {
      return _safeYmd(
        base.year,
        int.parse(m2[1]!),
        int.parse(m2[2]!),
      );
    }

    // 3) yyyy年MM月dd日 / yyyy年M月d日
    final regJPYMD = RegExp(r'^(\d{4})年(\d{1,2})月(\d{1,2})日?$');
    final m3 = regJPYMD.firstMatch(v);
    if (m3 != null) {
      return _safeYmd(
        int.parse(m3[1]!),
        int.parse(m3[2]!),
        int.parse(m3[3]!),
      );
    }

    // 4) MM月dd日 (no year -> current year)
    final regJPMD = RegExp(r'^(\d{1,2})月(\d{1,2})日?$');
    final m4 = regJPMD.firstMatch(v);
    if (m4 != null) {
      return _safeYmd(
        base.year,
        int.parse(m4[1]!),
        int.parse(m4[2]!),
      );
    }

    // 5) Fallback: DateTime.parse (only works for strict ISO-like)
    try {
      final dt = DateTime.parse(v);
      return formatYMD(dt);
    } catch (_) {
      return null;
    }
  }

  /// Parse `yyyy-MM-dd` safely. Returns null if invalid.
  static DateTime? tryParseYMD(String? ymd) {
    if (ymd == null) return null;
    final s = ymd.trim();
    if (s.isEmpty) return null;
    final reg = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!reg.hasMatch(s)) return null;

    try {
      final dt = DateTime.parse(s);
      // ensure not auto-rolled
      final parts = s.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      if (dt.year != y || dt.month != m || dt.day != d) return null;
      return dt;
    } catch (_) {
      return null;
    }
  }

  /// Format DateTime to `yyyy-MM-dd`.
  static String formatYMD(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd';
  }

  static String? _safeYmd(int y, int m, int d) {
    try {
      final dt = DateTime(y, m, d);
      // Prevent auto roll-over (e.g., 2026-02-31 -> 2026-03-03)
      if (dt.year != y || dt.month != m || dt.day != d) return null;
      return formatYMD(dt);
    } catch (_) {
      return null;
    }
  }
}
