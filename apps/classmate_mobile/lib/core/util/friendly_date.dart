import 'package:intl/intl.dart';

/// Shared date/time formatting so the app never shows raw ISO strings like
/// `2026-06-20T00:00:00.000Z` to users. The app-wide format is:
///   - date only      → `DD/MM/YYYY`            (e.g. 20/06/2026)
///   - date + time    → `DD/MM/YYYY HH:MM:SS`   (e.g. 20/06/2026 14:30:05)
///   - time only      → `HH:MM:SS`
///
/// All helpers accept either a [DateTime] or a [String] (ISO-8601 or any value
/// `DateTime.tryParse` understands) and render in the device's local time. When
/// the value can't be parsed the original trimmed string is returned, so a
/// non-timestamp value (e.g. a "08:00" clock string) is never blanked out.
class FriendlyDate {
  const FriendlyDate._();

  // Fixed, locale-independent patterns — the product wants one consistent
  // numeric format everywhere, not a locale-specific one.
  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final DateFormat _time = DateFormat('HH:mm:ss');

  static DateTime? _parse(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    final dt = DateTime.tryParse(s);
    return dt?.toLocal();
  }

  /// `DD/MM/YYYY`. Falls back to the raw string if unparseable.
  static String date(Object? value, [String? locale]) {
    final dt = _parse(value);
    if (dt == null) return value?.toString().trim() ?? '';
    return _date.format(dt);
  }

  /// `DD/MM/YYYY HH:MM:SS`. Falls back to the raw string if unparseable.
  static String dateTime(Object? value, [String? locale]) {
    final dt = _parse(value);
    if (dt == null) return value?.toString().trim() ?? '';
    return _dateTime.format(dt);
  }

  /// `HH:MM:SS` — time only.
  static String time(Object? value, [String? locale]) {
    final dt = _parse(value);
    if (dt == null) return value?.toString().trim() ?? '';
    return _time.format(dt);
  }
}
