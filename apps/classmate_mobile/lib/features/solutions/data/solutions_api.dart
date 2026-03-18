import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

const _devStudentToken = 'dev-token-student@classmate.local';

final solutionsApiProvider = Provider<SolutionsApi>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return SolutionsApi(token: token.isEmpty ? _devStudentToken : token);
});

class SolutionsApi {
  const SolutionsApi({this.token = _devStudentToken});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<Map<String, dynamic>> fetchSubjects() async {
    final raw = await _api.getJson('/solutions/subjects');
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchBooks({String? subject}) async {
    final q = <String, String>{};
    if ((subject ?? '').trim().isNotEmpty) {
      q['subject'] = subject!.trim();
    }
    final raw = await _api.getJson('/solutions/books', query: q);
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchSolutions({
    String? subject,
    String? bookTitle,
    int? pageNumber,
    String? questionNumber,
    int page = 1,
    int limit = 12,
  }) async {
    final q = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if ((subject ?? '').trim().isNotEmpty) 'subject': subject!.trim(),
      if ((bookTitle ?? '').trim().isNotEmpty) 'bookTitle': bookTitle!.trim(),
      if (pageNumber != null) 'pageNumber': '$pageNumber',
      if ((questionNumber ?? '').trim().isNotEmpty)
        'questionNumber': questionNumber!.trim(),
    };

    final raw = await _api.getJson('/solutions', query: q);
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createSolution({
    required String subject,
    required String bookTitle,
    required int pageNumber,
    required String questionNumber,
    String? caption,
    String? uploaderName,
    String? uploaderInitials,
    required List<Map<String, dynamic>> files,
  }) async {
    final raw = await _api.postJson(
      '/solutions',
      body: <String, dynamic>{
        'subject': subject,
        'bookTitle': bookTitle,
        'pageNumber': pageNumber,
        'questionNumber': questionNumber,
        if ((caption ?? '').trim().isNotEmpty) 'caption': caption!.trim(),
        if ((uploaderName ?? '').trim().isNotEmpty)
          'uploaderName': uploaderName!.trim(),
        if ((uploaderInitials ?? '').trim().isNotEmpty)
          'uploaderInitials': uploaderInitials!.trim(),
        'files': files,
      },
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }
}
