import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tutor_repository_provider.dart';

final tutorStudentSubjectsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repo = ref.read(tutorRepositoryProvider);
  return repo.fetchStudentSubjects();
});

final tutorSessionsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repo = ref.read(tutorRepositoryProvider);
  return repo.fetchSessions();
});

final tutorCharactersProvider = FutureProvider.family
    .autoDispose<List<dynamic>, String?>((ref, subject) async {
      final repo = ref.read(tutorRepositoryProvider);
      return repo.fetchCharacters(subject: subject);
    });
