import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tutor_repository_provider.dart';

final tutorSessionsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repo = ref.read(tutorRepositoryProvider);
  return repo.fetchSessions();
});

