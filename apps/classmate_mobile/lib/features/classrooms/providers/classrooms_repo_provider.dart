import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_controller.dart';
import '../data/classrooms_repository.dart';

const _devStudentToken = 'dev-token-student@classmate.local';

final classroomsRepoProvider = Provider<ClassroomsRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();

  return ClassroomsRepository(token: token.isEmpty ? _devStudentToken : token);
});
