import '../../core/api.dart';

class NotificationsApi {
  final Api api;
  NotificationsApi(this.api);

  Future<List<dynamic>> list() async {
    final x = await api.getAny('/notifications');
    if (x is List) return x;
    // accept wrapped payloads too
    if (x is Map && x['notifications'] is List)
      return (x['notifications'] as List).cast<dynamic>();
    return const [];
  }

  Future<void> markRead(String id) async {
    await api.postAny('/notifications/$id/read');
  }
}
