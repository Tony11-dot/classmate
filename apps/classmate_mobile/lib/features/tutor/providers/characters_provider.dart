import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tutor_repository_provider.dart';

final charactersProvider = FutureProvider.family<List<dynamic>, String?>((
  ref,
  subject,
) async {
  final repo = ref.read(tutorRepositoryProvider);
  return repo.fetchCharacters(subject: subject);
});
