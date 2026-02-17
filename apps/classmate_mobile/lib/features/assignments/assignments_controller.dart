import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import 'assignments_api.dart';
import 'assignments_models.dart';

class AssignmentsState {
  final bool loading;
  final String? error;
  final List<Assignment> items;

  const AssignmentsState({
    this.loading = false,
    this.error,
    this.items = const [],
  });

  AssignmentsState copyWith({
    bool? loading,
    String? error,
    List<Assignment>? items,
  }) => AssignmentsState(
    loading: loading ?? this.loading,
    error: error,
    items: items ?? this.items,
  );
}

final assignmentsProvider =
    NotifierProvider<AssignmentsController, AssignmentsState>(
      AssignmentsController.new,
    );

class AssignmentsController extends Notifier<AssignmentsState> {
  AssignmentsApi get _api => AssignmentsApi(ApiClient.instance);

  @override
  AssignmentsState build() => const AssignmentsState();

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final rows = await _api.list();
      state = state.copyWith(loading: false, items: rows);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> create({
    required String title,
    String? description,
    int? grade,
    String? subjectId,
    String? dueAt,
  }) async {
    final a = await _api.create(
      title: title,
      description: description,
      grade: grade,
      subjectId: subjectId,
      dueAt: dueAt,
    );
    state = state.copyWith(items: [a, ...state.items]);
  }
}

final assignmentSubmissionsProvider =
    FutureProvider.family<List<AssignmentSubmission>, String>((
      ref,
      assignmentId,
    ) async {
      final api = AssignmentsApi(ApiClient.instance);
      return api.submissions(assignmentId);
    });
