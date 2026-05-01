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

String formatChatTime24(DateTime? dt) {
  if (dt == null) return '';
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
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
}) {
  if (dt == null) return fallback;
  final current = now ?? DateTime.now();
  final todayDate = DateTime(current.year, current.month, current.day);
  final that = DateTime(dt.year, dt.month, dt.day);
  final diff = todayDate.difference(that).inDays;

  if (diff == 0) return today;
  if (diff == 1) return yesterday;

  final base = '${_monthName(dt.month)} ${dt.day}';
  return includeYear ? '$base, ${dt.year}' : base;
}

String formatChatInboxTrailingLabel(
  DateTime? dt, {
  DateTime? now,
  String fallback = '',
  String yesterday = 'Yesterday',
}) {
  if (dt == null) return fallback.trim();

  final current = now ?? DateTime.now();
  final todayDate = DateTime(current.year, current.month, current.day);
  final that = DateTime(dt.year, dt.month, dt.day);
  final diff = todayDate.difference(that).inDays;

  if (diff == 0) return formatChatTime12(dt);
  if (diff == 1) return yesterday;
  return '${_monthName(dt.month)} ${dt.day}';
}
