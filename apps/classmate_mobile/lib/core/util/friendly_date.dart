import 'package:intl/intl.dart';

/// Shared, locale-aware date/time formatting so the app never shows raw ISO
/// strings like `2026-06-20T00:00:00.000Z` to users.
///
/// All helpers accept either a [DateTime] or a [String] (ISO-8601 or any
/// value `DateTime.tryParse` understands). When the value can't be parsed the
/// original trimmed string is returned, so nothing ever renders as blank.
class FriendlyDate {
  const FriendlyDate._();

  static DateTime? _parse(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    final dt = DateTime.tryParse(s);
    return dt?.toLocal();
  }

  /// "Jun 20, 2026" (locale-aware). Falls back to the raw string if unparseable.
  static String date(Object? value, [String? locale]) {
    final dt = _parse(value);
    if (dt == null) return value?.toString().trim() ?? '';
    return DateFormat.yMMMd(locale).format(dt);
  }

  /// "Jun 20, 2026 • 14:30" when the value carries a non-midnight time,
  /// otherwise just the date. Falls back to the raw string if unparseable.
  static String dateTime(Object? value, [String? locale]) {
    final dt = _parse(value);
    if (dt == null) return value?.toString().trim() ?? '';
    final hasTime = dt.hour != 0 || dt.minute != 0;
    if (!hasTime) return DateFormat.yMMMd(locale).format(dt);
    return '${DateFormat.yMMMd(locale).format(dt)} • ${DateFormat.Hm(locale).format(dt)}';
  }

  /// "14:30" — time only.
  static String time(Object? value, [String? locale]) {
    final dt = _parse(value);
    if (dt == null) return value?.toString().trim() ?? '';
    return DateFormat.Hm(locale).format(dt);
  }
}
