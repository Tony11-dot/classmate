import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

const _devStudentToken = 'dev-token-student@classmate.local';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return ScheduleRepository(token: token.isEmpty ? _devStudentToken : token);
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

  Future<Map<String, dynamic>> getWeek(DateTime weekOf) async {
    final ymd = _weekYmd(weekOf);
    final requestedWeek = DateTime.parse('${ymd}T00:00:00.000Z');

    try {
      final raw = await _api.getJson(
        '/student/schedule/week',
        query: <String, String>{'weekOf': ymd},
      );
      final normalized = _normalizeWeek(raw, requestedWeek);

      final days = (normalized['days'] as List?) ?? const [];
      if (days.isNotEmpty) {
        return normalized;
      }
    } catch (_) {}

    return _devFallbackSchedule(weekOf: requestedWeek);
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

    if (rawDays.first is Map) {
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
                          return Map<String, dynamic>.from(rawItem);
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
      final item = rawItem is Map
          ? Map<String, dynamic>.from(rawItem)
          : <String, dynamic>{'title': rawItem.toString()};

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

  Map<String, dynamic> _devFallbackSchedule({required DateTime weekOf}) {
    final start = DateTime.utc(weekOf.year, weekOf.month, weekOf.day);

    String iso(int dayOffset, int hour, int minute) {
      return start
          .add(Duration(days: dayOffset, hours: hour, minutes: minute))
          .toIso8601String();
    }

    Map<String, dynamic> item({
      required String id,
      required String title,
      required String room,
      required String teacherName,
      required int dayOffset,
      required int startHour,
      required int startMinute,
      required int endHour,
      required int endMinute,
    }) {
      return <String, dynamic>{
        'id': id,
        'title': title,
        'subject': title,
        'room': room,
        'teacherName': teacherName,
        'startAt': iso(dayOffset, startHour, startMinute),
        'endAt': iso(dayOffset, endHour, endMinute),
      };
    }

    final days = <Map<String, dynamic>>[
      <String, dynamic>{
        'label': 'Monday',
        'date': start.toIso8601String(),
        'items': <Map<String, dynamic>>[
          item(
            id: 'm1',
            title: 'Mathematics',
            room: 'A-201',
            teacherName: 'Ms. Cohen',
            dayOffset: 0,
            startHour: 8,
            startMinute: 0,
            endHour: 8,
            endMinute: 45,
          ),
          item(
            id: 'm2',
            title: 'Physics',
            room: 'Lab 2',
            teacherName: 'Mr. Haddad',
            dayOffset: 0,
            startHour: 9,
            startMinute: 0,
            endHour: 9,
            endMinute: 45,
          ),
          item(
            id: 'm3',
            title: 'Computer Science',
            room: 'Tech 1',
            teacherName: 'Ms. Nasser',
            dayOffset: 0,
            startHour: 10,
            startMinute: 0,
            endHour: 10,
            endMinute: 45,
          ),
        ],
      },
      <String, dynamic>{
        'label': 'Tuesday',
        'date': start.add(const Duration(days: 1)).toIso8601String(),
        'items': <Map<String, dynamic>>[
          item(
            id: 't1',
            title: 'English',
            room: 'B-104',
            teacherName: 'Mrs. Levi',
            dayOffset: 1,
            startHour: 8,
            startMinute: 0,
            endHour: 8,
            endMinute: 45,
          ),
          item(
            id: 't2',
            title: 'Arabic',
            room: 'B-105',
            teacherName: 'Mr. Salim',
            dayOffset: 1,
            startHour: 9,
            startMinute: 0,
            endHour: 9,
            endMinute: 45,
          ),
        ],
      },
      <String, dynamic>{
        'label': 'Wednesday',
        'date': start.add(const Duration(days: 2)).toIso8601String(),
        'items': <Map<String, dynamic>>[
          item(
            id: 'w1',
            title: 'Chemistry',
            room: 'Lab 1',
            teacherName: 'Ms. Khoury',
            dayOffset: 2,
            startHour: 8,
            startMinute: 0,
            endHour: 8,
            endMinute: 45,
          ),
          item(
            id: 'w2',
            title: 'Biology',
            room: 'C-203',
            teacherName: 'Mr. George',
            dayOffset: 2,
            startHour: 9,
            startMinute: 0,
            endHour: 9,
            endMinute: 45,
          ),
        ],
      },
      <String, dynamic>{
        'label': 'Thursday',
        'date': start.add(const Duration(days: 3)).toIso8601String(),
        'items': <Map<String, dynamic>>[
          item(
            id: 'th1',
            title: 'History',
            room: 'A-109',
            teacherName: 'Ms. Hanna',
            dayOffset: 3,
            startHour: 8,
            startMinute: 0,
            endHour: 8,
            endMinute: 45,
          ),
          item(
            id: 'th2',
            title: 'Hebrew',
            room: 'B-205',
            teacherName: 'Mr. Ben David',
            dayOffset: 3,
            startHour: 9,
            startMinute: 0,
            endHour: 9,
            endMinute: 45,
          ),
        ],
      },
      <String, dynamic>{
        'label': 'Friday',
        'date': start.add(const Duration(days: 4)).toIso8601String(),
        'items': <Map<String, dynamic>>[
          item(
            id: 'f1',
            title: 'Homeroom',
            room: 'Main Hall',
            teacherName: 'Class Tutor',
            dayOffset: 4,
            startHour: 8,
            startMinute: 0,
            endHour: 8,
            endMinute: 30,
          ),
        ],
      },
    ];

    return <String, dynamic>{
      'weekOf': start.toIso8601String(),
      'startOfWeek': start.toIso8601String(),
      'title': 'Week Schedule',
      'days': days,
      'isEmpty': false,
      'source': 'dev-fallback',
    };
  }
}
