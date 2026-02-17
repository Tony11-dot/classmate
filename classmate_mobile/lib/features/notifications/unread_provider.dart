import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import 'notifications_api.dart';

final apiProvider = Provider<Api>((ref) => Api());

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(ref.watch(apiProvider));
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final api = ref.watch(notificationsApiProvider);
  final items = await api.list();
  int unread = 0;
  for (final n in items) {
    // pilot_api uses seenAt (your UI does); treat missing as unread
    final seenAt = (n is Map) ? n['seenAt'] : null;
    if (seenAt == null) unread++;
  }
  return unread;
});
