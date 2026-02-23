import 'dart:convert';

import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../config/env.dart';
import 'parent_models.dart';

class ParentApi {
  ParentApi(this._tokenProvider);

  final Future<String?> Function() _tokenProvider;

  ApiClient _api() =>
      ApiClient(baseUrl: Env.apiBaseUrl, tokenProvider: _tokenProvider);

  Future<List<ParentChild>> listChildren() async {
    final res = await _api().get('/api/parent/children');
    if (res.statusCode < 200 || res.statusCode >= 300) return const [];
    final j = jsonDecode(res.body);
    final items = (j is List)
        ? j
        : (j is Map && j['children'] is List)
        ? (j['children'] as List)
        : const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(ParentChild.fromJson)
        .toList();
  }

  Future<OverviewKpis?> getOverview(String studentId) async {
    final res = await _api().get('/api/parent/overview?studentId=$studentId');
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    final j = jsonDecode(res.body);
    final data = (j is Map && j['overview'] is Map)
        ? (j['overview'] as Map)
        : j;
    return OverviewKpis.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<dynamic> scheduleToday(String studentId) async {
    final res = await _api().get(
      '/api/parent/schedule/today?studentId=$studentId',
    );
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    return jsonDecode(res.body);
  }

  Future<dynamic> scheduleWeek(String studentId, {String? weekOf}) async {
    final q = weekOf == null ? '' : '&weekOf=${Uri.encodeComponent(weekOf)}';
    final res = await _api().get(
      '/api/parent/schedule/week?studentId=$studentId$q',
    );
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    return jsonDecode(res.body);
  }

  Future<dynamic> attendanceToday(String studentId) async {
    final res = await _api().get(
      '/api/parent/attendance/today?studentId=$studentId',
    );
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    return jsonDecode(res.body);
  }

  Future<dynamic> attendanceWeek(String studentId, {String? weekOf}) async {
    final q = weekOf == null ? '' : '&weekOf=${Uri.encodeComponent(weekOf)}';
    final res = await _api().get(
      '/api/parent/attendance/week?studentId=$studentId$q',
    );
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    return jsonDecode(res.body);
  }

  Future<dynamic> notifications({
    String? studentId,
    int take = 30,
    String? cursor,
    bool unseenOnly = false,
  }) async {
    final qs = <String>[
      'take=$take',
      if (studentId != null && studentId.trim().isNotEmpty)
        'studentId=${Uri.encodeComponent(studentId)}',
      if (cursor != null && cursor.isNotEmpty)
        'cursor=${Uri.encodeComponent(cursor)}',
      if (unseenOnly) 'unseenOnly=true',
    ].join('&');

    final res = await _api().get('/api/parent/notifications?$qs');
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    return jsonDecode(res.body);
  }

  static ParentApi ofAuth(AuthController a) => ParentApi(a.token);
}
