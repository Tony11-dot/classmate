import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

final scheduleRepositoryProvider = Provider.autoDispose<ScheduleRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return ScheduleRepository(token: token);
});

class ScheduleRepository {
  ScheduleRepository({required this.token});

  final String token;

  CMApi get _api => CMApi(token: token);

  String _weekYmd(DateTime d) {
    final x = DateTime.utc(d.year, d.month, d.day);
    final y = x.year.toString().padLeft(4, '0');
    final m = x.month.toString().padLeft(2, '0');
    final day = x.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// Returns today's attendance keyed by "$period:$subject" (lowercased).
  /// Both keys allow matching against schedule items by period OR subject.
  Future<Map<String, String>> getTodayAttendance() async {
    try {
      final now = DateTime.now();
      final todayYmd =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final raw = await _api.getJson(
        '/student/attendance',
        query: <String, String>{'date': todayYmd},
      );
      final items = _extractList(raw);
      final result = <String, String>{};
      for (final item in items) {
        if (item is! Map) continue;
        final date = (item['date'] ?? '').toString().trim();
        if (!date.startsWith(todayYmd)) continue;
        final status = (item['status'] ?? '').toString().trim().toUpperCase();
        if (status.isEmpty) continue;
        final period = (item['period'] ?? 0).toString();
        final subject = (item['subject'] ?? item['courseName'] ?? '').toString().trim().toLowerCase();
        final courseId = (item['courseId'] ?? '').toString().trim();
        result['$period:$subject'] = status;
        if (courseId.isNotEmpty) result['course:$courseId'] = status;
        result['period:$period'] = status; // fallback by period alone
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  List _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      for (final key in ['items', 'attendance', 'data', 'records']) {
        final v = raw[key];
        if (v is List) return v;
      }
    }
    return [];
  }

  Future<Map<String, dynamic>> getWeek(DateTime weekOf) async {
    final ymd = _weekYmd(weekOf);
    final requestedWeek = DateTime.parse('${ymd}T00:00:00.000Z');
    final raw = await _api.getJson(
      '/student/schedule/week',
      query: <String, String>{'weekOf': ymd},
    );
    // API wraps response as { ok, items: { weekOf, days } } — unwrap items layer.
    final payload = (raw is Map && raw['items'] is Map) ? raw['items'] as Map<String, dynamic> : raw;
    return _normalizeWeek(payload, requestedWeek);
  }

  Map<String, dynamic> _normalizeWeek(dynamic raw, DateTime requestedWeek) {
    final weekIso = requestedWeek.toIso8601String();

    if (raw is Map<String, dynamic>) {
      final copy = Map<String, dynamic>.from(raw);
      copy['weekOf'] ??= weekIso;
      copy['startOfWeek'] ??= weekIso;

      final dynamic rawDays =
          copy['days'] ?? copy['week'] ?? copy['entries'] ?? copy['items'];

      if (rawDays is List) {
        copy['days'] = _normalizeDays(rawDays, requestedWeek);
      } else {
        copy['days'] = <Map<String, dynamic>>[];
      }

      copy['isEmpty'] = (copy['days'] as List).isEmpty;
      return copy;
    }

    if (raw is List) {
      return <String, dynamic>{
        'weekOf': weekIso,
        'startOfWeek': weekIso,
        'title': 'Week Schedule',
        'days': _normalizeDays(raw, requestedWeek),
        'isEmpty': raw.isEmpty,
      };
    }

    return <String, dynamic>{
      'weekOf': weekIso,
      'startOfWeek': weekIso,
      'title': 'Week Schedule',
      'days': <Map<String, dynamic>>[],
      'isEmpty': true,
    };
  }

  List<Map<String, dynamic>> _normalizeDays(
    List rawDays,
    DateTime requestedWeek,
  ) {
    if (rawDays.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final firstMap = rawDays.first;
    final isListOfDays = firstMap is Map &&
        (firstMap.containsKey('items') ||
            firstMap.containsKey('entries') ||
            firstMap.containsKey('lessons') ||
            firstMap.containsKey('slots'));

    if (isListOfDays) {
      return rawDays
          .map<Map<String, dynamic>>((dynamic rawDay) {
            final day = Map<String, dynamic>.from(rawDay as Map);

            final dynamic itemsRaw =
                day['items'] ??
                day['entries'] ??
                day['lessons'] ??
                day['slots'] ??
                const [];

            final items = itemsRaw is List
                ? itemsRaw
                      .map<Map<String, dynamic>>((dynamic rawItem) {
                        if (rawItem is Map) {
                          final item = Map<String, dynamic>.from(rawItem);
                          item['startsAt'] ??= item['startAt'] ?? item['startTime'];
                          item['endsAt'] ??= item['endAt'] ?? item['endTime'];
                          item['location'] ??= item['room'];
                          item['courseId'] ??= item['classroomId'];
                          return item;
                        }
                        return <String, dynamic>{'title': rawItem.toString()};
                      })
                      .toList(growable: false)
                : <Map<String, dynamic>>[];

            day['items'] = items;
            day['entries'] = items;
            day['lessons'] = items;
            day['label'] ??= day['title'] ?? day['name'] ?? '';
            day['date'] ??= day['day'] ?? requestedWeek.toIso8601String();
            return day;
          })
          .toList(growable: false);
    }

    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final rawItem in rawDays) {
      final Map<String, dynamic> item = rawItem is Map
          ? Map<String, dynamic>.from(rawItem)
          : <String, dynamic>{'title': rawItem.toString()};

      item['startsAt'] ??= item['startAt'] ?? item['startTime'];
      item['endsAt'] ??= item['endAt'] ?? item['endTime'];
      item['location'] ??= item['room'];
      item['courseId'] ??= item['classroomId'];

      final key = (item['date'] ?? item['day'] ?? item['label'] ?? 'Day')
          .toString();
      grouped.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(item);
    }

    return grouped.entries
        .map<Map<String, dynamic>>((entry) {
          return <String, dynamic>{
            'label': entry.key,
            'date': entry.key,
            'items': entry.value,
            'entries': entry.value,
            'lessons': entry.value,
          };
        })
        .toList(growable: false);
  }
}
