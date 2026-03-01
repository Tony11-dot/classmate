import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'solution_model.dart';
import 'solutions_filters.dart';
import 'solutions_repo.dart';

class SolutionsState {
  const SolutionsState({
    required this.items,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.nextCursor,
    required this.hasMore,
    required this.filters,
  });

  final List<Solution> items;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final String? nextCursor;
  final bool hasMore;
  final SolutionsFilters filters;

  SolutionsState copyWith({
    List<Solution>? items,
    bool? loading,
    bool? loadingMore,
    String? error,
    String? nextCursor,
    bool? hasMore,
    SolutionsFilters? filters,
  }) {
    return SolutionsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      filters: filters ?? this.filters,
    );
  }

  static const initial = SolutionsState(
    items: <Solution>[],
    loading: true,
    loadingMore: false,
    error: null,
    nextCursor: null,
    hasMore: true,
    filters: SolutionsFilters(),
  );
}

final solutionsControllerProvider =
    NotifierProvider<SolutionsController, SolutionsState>(SolutionsController.new);

class SolutionsController extends Notifier<SolutionsState> {
  static const int _pageSize = 20;

  @override
  SolutionsState build() {
    state = SolutionsState.initial;
    _loadFirst();
    return state;
  }

  Future<void> refresh() => _loadFirst();

  Future<void> setFilters(SolutionsFilters f) async {
    state = state.copyWith(filters: f);
    await _loadFirst();
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    final cursor = state.nextCursor;
    if (cursor == null || cursor.isEmpty) return;

    state = state.copyWith(loadingMore: true, error: null);
    try {
      final repo = ref.read(solutionsRepoProvider);
      final page = await repo.list(
        filters: state.filters,
        limit: _pageSize,
        cursor: cursor,
      );

      final merged = <Solution>[...state.items, ...page.items];
      state = state.copyWith(
        items: merged,
        loadingMore: false,
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    }
  }

  Future<void> _loadFirst() async {
    state = state.copyWith(
      loading: true,
      loadingMore: false,
      error: null,
      items: const <Solution>[],
      nextCursor: null,
      hasMore: true,
    );

    try {
      final repo = ref.read(solutionsRepoProvider);
      final page = await repo.list(
        filters: state.filters,
        limit: _pageSize,
        cursor: null,
      );
      state = state.copyWith(
        items: page.items,
        loading: false,
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
