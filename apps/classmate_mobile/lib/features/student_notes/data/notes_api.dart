import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

final notesApiProvider = Provider<NotesApi>((ref) {
  final session = ref.watch(authSessionProvider);
  return NotesApi(token: (session.token ?? '').trim());
});

/// Student roster for the notes browser (name + grade + note count).
final notesStudentsProvider =
    FutureProvider.autoDispose<List<NoteStudent>>((ref) {
  return ref.watch(notesApiProvider).fetchStudents();
});

/// All notes for one student.
final studentNotesProvider = FutureProvider.autoDispose
    .family<StudentNotesPage, String>((ref, studentId) {
  return ref.watch(notesApiProvider).fetchNotes(studentId);
});

class NoteStudent {
  const NoteStudent({
    required this.studentId,
    required this.name,
    this.grade,
    this.cohortName,
    this.noteCount = 0,
  });

  final String studentId;
  final String name;
  final int? grade;
  final String? cohortName;
  final int noteCount;

  factory NoteStudent.fromJson(Map<String, dynamic> j) => NoteStudent(
        studentId: '${j['studentId'] ?? ''}',
        name: '${j['name'] ?? ''}',
        grade: (j['grade'] as num?)?.toInt(),
        cohortName: j['cohortName'] as String?,
        noteCount: (j['noteCount'] as num?)?.toInt() ?? 0,
      );
}

class StudentNote {
  const StudentNote({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.canEdit,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final String authorName;
  final bool canEdit;
  final DateTime updatedAt;

  factory StudentNote.fromJson(Map<String, dynamic> j) => StudentNote(
        id: '${j['id'] ?? ''}',
        title: '${j['title'] ?? ''}',
        body: '${j['body'] ?? ''}',
        authorName: '${j['authorName'] ?? ''}',
        canEdit: j['canEdit'] == true,
        updatedAt:
            DateTime.tryParse('${j['updatedAt'] ?? ''}')?.toLocal() ??
                DateTime.now(),
      );
}

class StudentNotesPage {
  const StudentNotesPage({required this.studentName, required this.notes});
  final String studentName;
  final List<StudentNote> notes;
}

class NotesApi {
  const NotesApi({this.token = ''});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<List<NoteStudent>> fetchStudents({String? q}) async {
    final raw = await _api.getJson(
      '/notes/students',
      query: (q == null || q.trim().isEmpty) ? null : {'q': q.trim()},
    );
    final list = (raw is Map ? raw['students'] : null) as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => NoteStudent.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<StudentNotesPage> fetchNotes(String studentId) async {
    final raw = await _api.getJson('/notes/students/$studentId');
    final map = raw is Map ? raw : const {};
    final student = map['student'];
    final list = map['notes'] as List? ?? const [];
    return StudentNotesPage(
      studentName:
          student is Map ? '${student['name'] ?? ''}' : '',
      notes: list
          .whereType<Map>()
          .map((e) => StudentNote.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Future<String?> createNote(String studentId,
      {String title = '', String body = ''}) async {
    final raw = await _api.postJson('/notes/students/$studentId',
        body: {'title': title, 'body': body});
    return raw is Map ? raw['noteId'] as String? : null;
  }

  Future<void> updateNote(String noteId, {String? title, String? body}) async {
    await _api.patchJson('/notes/$noteId', body: {
      if (title != null) 'title': title,
      if (body != null) 'body': body,
    });
  }

  Future<void> deleteNote(String noteId) async {
    await _api.deleteJson('/notes/$noteId');
  }
}
