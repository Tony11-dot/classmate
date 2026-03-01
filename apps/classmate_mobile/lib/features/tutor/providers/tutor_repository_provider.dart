import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/auth/auth_controller.dart';
import '../data/tutor_repository.dart';

final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  final session = ref.read(authSessionProvider);
  return TutorRepository(
    Env.apiBaseUrl,
    () async => session.token,
  );
});
