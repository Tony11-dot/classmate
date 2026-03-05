import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'classrooms_repo_provider.dart';

final studentClassroomsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repo = ref.read(classroomsRepoProvider);
      return repo.list();
    });

final classroomPeopleProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final repo = ref.read(classroomsRepoProvider);
      return repo.people(id);
    });

final classroomChatProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, ({String id, int limit, String? cursor})>((
      ref,
      args,
    ) async {
      final repo = ref.read(classroomsRepoProvider);
      return repo.chat(args.id, limit: args.limit, cursor: args.cursor);
    });

final classroomAssignmentsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final repo = ref.read(classroomsRepoProvider);
      return repo.assignments(id);
    });

final classroomMaterialsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final repo = ref.read(classroomsRepoProvider);
      return repo.materials(id);
    });

final classroomMeetingsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final repo = ref.read(classroomsRepoProvider);
      return repo.meetings(id);
    });
