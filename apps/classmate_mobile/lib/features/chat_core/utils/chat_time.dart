import 'package:intl/intl.dart';

DateTime? parseChatTimestamp(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;

  final iso = DateTime.tryParse(value);
  if (iso != null) return iso.toLocal();

  final epoch = int.tryParse(value);
  if (epoch != null) {
    final isSeconds = value.length <= 10;
    final millis = isSeconds ? epoch * 1000 : epoch;
    return DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
  }

  return null;
}

DateTime? parseFirstChatTimestamp(Iterable<String> rawValues) {
  for (final raw in rawValues) {
    final parsed = parseChatTimestamp(raw);
    if (parsed != null) return parsed;
  }
  return null;
}

bool sameLocalCalendarDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatChatTime12(DateTime? dt) {
  if (dt == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  var hour = dt.hour % 12;
  if (hour == 0) hour = 12;
  final suffix = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${two(dt.minute)} $suffix';
}

bool _isEnglish(String? locale) {
  final lang = (locale ?? '').split(RegExp('[-_]')).first.toLowerCase();
  return lang.isEmpty || lang == 'en';
}

/// Message/inbox clock in the reader's convention: English keeps "9:07 AM";
/// every other app language (Hebrew, Arabic, Russian, French, Pashto) uses the
/// 24-hour "09:07" — the English "AM" also got bidi-flipped to "AM 9:07" in RTL.
String formatChatClock(DateTime? dt, {String? locale}) {
  if (dt == null) return '';
  if (_isEnglish(locale)) return formatChatTime12(dt);
  return DateFormat('HH:mm').format(dt);
}

/// "Oct 9" / "Oct 9, 2026" — localized month names outside English.
String _monthDay(DateTime dt, String? locale, {bool year = false}) {
  if (!_isEnglish(locale)) {
    try {
      return (year ? DateFormat.yMMMd(locale) : DateFormat.MMMd(locale)).format(dt);
    } catch (_) {/* date symbols not loaded — fall back to English */}
  }
  final base = '${_monthName(dt.month)} ${dt.day}';
  return year ? '$base, ${dt.year}' : base;
}

String _monthName(int month) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > 12) return '';
  return months[month];
}

String formatChatDayChipLabel(
  DateTime? dt, {
  DateTime? now,
  bool includeYear = true,
  String fallback = 'Earlier',
  String today = 'Today',
  String yesterday = 'Yesterday',
  String? locale,
}) {
  if (dt == null) return fallback;
  final current = now ?? DateTime.now();
  final todayDate = DateTime(current.year, current.month, current.day);
  final that = DateTime(dt.year, dt.month, dt.day);
  final diff = todayDate.difference(that).inDays;

  if (diff == 0) return today;
  if (diff == 1) return yesterday;

  return _monthDay(dt, locale, year: includeYear);
}

String formatChatInboxTrailingLabel(
  DateTime? dt, {
  DateTime? now,
  String fallback = '',
  String yesterday = 'Yesterday',
  String? locale,
}) {
  if (dt == null) return fallback.trim();

  final current = now ?? DateTime.now();
  final todayDate = DateTime(current.year, current.month, current.day);
  final that = DateTime(dt.year, dt.month, dt.day);
  final diff = todayDate.difference(that).inDays;

  if (diff == 0) return formatChatClock(dt, locale: locale);
  if (diff == 1) return yesterday;
  return _monthDay(dt, locale);
}
