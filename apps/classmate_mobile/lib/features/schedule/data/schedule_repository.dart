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

  Future<Map<String, dynamic>> getWeek(DateTime weekOf) async {
    final iso = weekOf.toIso8601String();

    try {
      final raw = await _api.getJson(
        '/student/schedule/week',
        query: <String, String>{'weekOf': iso},
      );
      return _normalizeWeek(raw, weekOf);
    } catch (_) {
      final raw = await _api.getJson('/student/schedule/week');
      return _normalizeWeek(raw, weekOf);
    }
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
}
