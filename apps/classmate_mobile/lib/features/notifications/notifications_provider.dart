import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import 'notifications_api.dart';
import 'notifications_models.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(
      NotificationsController.new,
    );

class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  NotificationsApi get api => NotificationsApi(ApiClient.instance);

  @override
  Future<List<AppNotification>> build() async {
    return api.list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => api.list());
  }

  Future<void> markRead(String id) async {
    await api.markRead(id);
    await refresh();
  }
}
