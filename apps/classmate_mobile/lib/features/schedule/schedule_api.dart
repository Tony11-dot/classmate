import '../../api/api_client.dart';

class ScheduleEntry {
  final String id;
  final String subjectId;
  final DateTime startAt;
  final DateTime endAt;
  final String? room;
  final String? teacher;

  ScheduleEntry({
    required this.id,
    required this.subjectId,
    required this.startAt,
    required this.endAt,
    this.room,
    this.teacher,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> j) {
    return ScheduleEntry(
      id: j['id'],
      subjectId: j['subjectId'],
      startAt: DateTime.parse(j['startAt']),
      endAt: DateTime.parse(j['endAt']),
      room: j['room'],
      teacher: j['teacher'],
    );
  }
}

class ScheduleApi {
  final ApiClient _c;
  const ScheduleApi(this._c);

  Future<List<ScheduleEntry>> list({
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await _c.get(
      '/schedule/v2',
      queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      },
    );

    return (res.data as List)
        .map((e) => ScheduleEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
