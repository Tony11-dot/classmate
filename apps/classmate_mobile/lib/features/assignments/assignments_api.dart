import '../../api/api_client.dart';
import 'assignments_models.dart';

class AssignmentsApi {
  final ApiClient _client;
  const AssignmentsApi(this._client);

  Future<List<Assignment>> list() async {
    final res = await _client.get('/assignments');
    final rows = (res as List).cast<dynamic>();
    return rows
        .map((e) => Assignment.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<Assignment> create({
    required String title,
    String? description,
    int? grade,
    String? subjectId,
    String? dueAt,
  }) async {
    final res = await _client.post(
      '/assignments',
      data: {
        'title': title,
        'description': description,
        'grade': grade,
        'subjectId': subjectId,
        'dueAt': dueAt,
      },
    );
    return Assignment.fromJson((res as Map).cast<String, dynamic>());
  }

  Future<AssignmentSubmission> submit({
    required String assignmentId,
    String? text,
    String? mediaUrl,
  }) async {
    final res = await _client.post(
      '/assignments/$assignmentId/submissions',
      data: {'text': text, 'mediaUrl': mediaUrl},
    );
    return AssignmentSubmission.fromJson((res as Map).cast<String, dynamic>());
  }

  Future<List<AssignmentSubmission>> submissions(String assignmentId) async {
    final res = await _client.get('/assignments/$assignmentId/submissions');
    final rows = (res as List).cast<dynamic>();
    return rows
        .map(
          (e) =>
              AssignmentSubmission.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();
  }
}
