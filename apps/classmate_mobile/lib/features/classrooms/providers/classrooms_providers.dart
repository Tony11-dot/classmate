import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'classroom_order_prefs.dart';
import 'classrooms_repo_provider.dart';

final studentClassroomsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repo = ref.read(classroomsRepoProvider);
      return repo.list();
    });


final orderedStudentClassroomsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repo = ref.read(classroomsRepoProvider);
      final items = await repo.list();
      final saved = await loadSavedClassroomOrder();
      return applySavedClassroomOrder(items, saved);
    });

final classroomPeopleProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final repo = ref.read(classroomsRepoProvider);
      return repo.people(id);
    });

// NOT autoDispose — keeps the last fetched value in memory between visits so
// messages don't vanish when the user leaves and re-enters the classroom.
final classroomChatProvider =
    FutureProvider.family<Map<String, dynamic>, ({String id, int limit, String? cursor})>((
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

final classroomDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final repo = ref.read(classroomsRepoProvider);
      return repo.detail(id);
    });
