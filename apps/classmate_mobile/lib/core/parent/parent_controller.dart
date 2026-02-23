import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import 'parent_api.dart';
import 'parent_models.dart';

final parentControllerProvider =
    NotifierProvider<ParentController, ParentState>(ParentController.new);

class ParentState {
  const ParentState({
    required this.loading,
    required this.children,
    required this.selectedChildId,
    required this.overview,
    required this.error,
  });

  final bool loading;
  final List<ParentChild> children;
  final String? selectedChildId;
  final OverviewKpis? overview;
  final String? error;

  ParentState copyWith({
    bool? loading,
    List<ParentChild>? children,
    String? selectedChildId,
    OverviewKpis? overview,
    String? error,
  }) {
    return ParentState(
      loading: loading ?? this.loading,
      children: children ?? this.children,
      selectedChildId: selectedChildId ?? this.selectedChildId,
      overview: overview ?? this.overview,
      error: error,
    );
  }
}

class ParentController extends Notifier<ParentState> {
  @override
  ParentState build() {
    // whenever auth changes to authed parent, we can load.
    ref.listen(authControllerProvider, (prev, next) {
      final isParent = (next.role ?? '').toLowerCase() == 'parent';
      if (isParent && next.isAuthed && next.ready) {
        load();
      }
      if (!next.isAuthed) {
        state = state.copyWith(
          children: const [],
          selectedChildId: null,
          overview: null,
          error: null,
        );
      }
    });

    return const ParentState(
      loading: false,
      children: [],
      selectedChildId: null,
      overview: null,
      error: null,
    );
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    final auth = ref.read(authControllerProvider.notifier);
    final api = ParentApi.ofAuth(auth);

    final kids = await api.listChildren();

    final selected =
        state.selectedChildId ?? (kids.isNotEmpty ? kids.first.id : null);

    OverviewKpis? overview;
    if (selected != null) {
      overview = await api.getOverview(selected);
    }

    state = state.copyWith(
      loading: false,
      children: kids,
      selectedChildId: selected,
      overview: overview,
      error: null,
    );
  }

  Future<void> selectChild(String childId) async {
    state = state.copyWith(
      selectedChildId: childId,
      loading: true,
      error: null,
    );
    final auth = ref.read(authControllerProvider.notifier);
    final api = ParentApi.ofAuth(auth);
    final overview = await api.getOverview(childId);
    state = state.copyWith(loading: false, overview: overview, error: null);
  }
}
