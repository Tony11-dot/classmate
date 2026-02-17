import '../../api/api_client.dart';
import 'notifications_models.dart';

class NotificationsApi {
  final ApiClient _c;
  const NotificationsApi(this._c);

  Future<List<AppNotification>> list({bool unread = false}) async {
    final res = await _c.get(
      '/notifications',
      queryParameters: unread ? {'unread': '1'} : null,
    );

    return (res.data as List)
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> markRead(String id) async {
    await _c.post('/notifications/$id/read');
  }
}
