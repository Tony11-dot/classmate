import '../../api/api_client.dart';
import 'classrooms_models.dart';

class ClassroomsApi {
  final ApiClient api;
  ClassroomsApi(this.api);

  Future<List<ClassroomListItem>> listMine() async {
    final r = await api.get('/classrooms');
    final data = r.data;
    if (data is List) {
      return data
          .whereType<dynamic>()
          .map((x) => ClassroomListItem.fromJson((x as Map).cast<String, dynamic>()))
          .toList();
    }
    return const <ClassroomListItem>[];
  }
}
