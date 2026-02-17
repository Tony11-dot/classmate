import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import 'notifications_api.dart';

final notificationsUnreadCountProvider = FutureProvider<int>((ref) async {
  final api = NotificationsApi(ApiClient.instance);
  final rows = await api.list(unread: true);
  return rows.length;
});
