import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_controller.dart';
import '../data/classrooms_repository.dart';

final classroomsRepoProvider = Provider<ClassroomsRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  return ClassroomsRepository(token: session.token);
});
