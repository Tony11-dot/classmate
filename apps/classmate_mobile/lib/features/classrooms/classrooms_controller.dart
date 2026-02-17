import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_client.dart';
import 'classrooms_api.dart';
import 'classrooms_models.dart';

final classroomsApiProvider = Provider((ref) => ClassroomsApi(ApiClient.instance));

final classroomsProvider =
    AsyncNotifierProvider<ClassroomsController, List<ClassroomListItem>>(
  ClassroomsController.new,
);

class ClassroomsController extends AsyncNotifier<List<ClassroomListItem>> {
  @override
  Future<List<ClassroomListItem>> build() async {
    return ref.read(classroomsApiProvider).listMine();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(classroomsApiProvider).listMine());
  }
}
