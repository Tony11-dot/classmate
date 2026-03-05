import '../../../core/http/cm_api.dart';

class ClassroomsRepository {
  ClassroomsRepository({required this.token});

  final String? token;

  CMApi _api() => CMApi(token: token);

  Future<List<Map<String, dynamic>>> list() async {
    final j = await _api().getJson('/api/classrooms');
    if (j is List) return j.cast<Map<String, dynamic>>();
    return const <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> people(String courseId) async {
    final j = await _api().getJson('/api/classrooms/$courseId/people');
    if (j is Map) return j.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> chat(
    String courseId, {
    int limit = 30,
    String? cursor,
  }) async {
    final q = <String, String>{'limit': '$limit'};
    if (cursor != null && cursor.isNotEmpty) q['cursor'] = cursor;
    final j = await _api().getJson('/api/classrooms/$courseId/chat', query: q);
    if (j is Map) return j.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> assignments(String courseId) async {
    final j = await _api().getJson('/api/classrooms/$courseId/assignments');
    if (j is Map) return j.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> materials(String courseId) async {
    final j = await _api().getJson('/api/classrooms/$courseId/materials');
    if (j is Map) return j.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> meetings(String courseId) async {
    final j = await _api().getJson('/api/classrooms/$courseId/meetings');
    if (j is Map) return j.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> sendChatText(
    String courseId,
    String text,
  ) async {
    final j = await _api().postJson(
      '/api/classrooms/$courseId/chat/text',
      body: {'text': text},
    );
    if (j is Map) return j.cast<String, dynamic>();
    return const <String, dynamic>{};
  }
}
