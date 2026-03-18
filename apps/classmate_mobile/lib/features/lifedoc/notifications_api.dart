import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';
import 'notifications_models.dart';

const _devStudentToken = 'dev-token-student@classmate.local';

final notificationsApiProvider = Provider<StudentNotificationsApi>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return StudentNotificationsApi(
    token: token.isEmpty ? _devStudentToken : token,
  );
});

class StudentNotificationsApi {
  const StudentNotificationsApi({this.token = _devStudentToken});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<List<StudentNotificationItem>> list({int limit = 50}) async {
    final raw = await _api.getJson(
      '/notifications',
      query: {'limit': '$limit'},
    );

    final list = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : const <dynamic>[];

    return list
        .whereType<Map>()
        .map((e) {
          final map = e.map((k, v) => MapEntry(k.toString(), v));
          final severityRaw = '${map['severity'] ?? 'info'}'
              .trim()
              .toLowerCase();
          final severity = switch (severityRaw) {
            'critical' => StudentNotificationSeverity.critical,
            'warning' => StudentNotificationSeverity.warning,
            _ => StudentNotificationSeverity.info,
          };

          return StudentNotificationItem(
            id: '${map['id'] ?? ''}',
            title: '${map['title'] ?? ''}',
            body: '${map['body'] ?? ''}',
            source: '${map['source'] ?? 'system'}',
            createdAt:
                DateTime.tryParse('${map['createdAt'] ?? ''}') ??
                DateTime.now(),
            severity: severity,
            isRead: map['isRead'] == true,
          );
        })
        .toList(growable: false);
  }
}
