import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'solution_model.dart';
import 'solutions_filters.dart';
import 'solutions_repo.dart';

@immutable
class SolutionCommentsState {
  const SolutionCommentsState({
    required this.items,
    required this.nextCursor,
    required this.loading,
    required this.loadingMore,
    required this.posting,
    required this.error,
  });

  final List<SolutionComment> items;
  final String? nextCursor;
  final bool loading;
  final bool loadingMore;
  final bool posting;
  final String? error;

  static const empty = SolutionCommentsState(
    items: <SolutionComment>[],
    nextCursor: null,
    loading: false,
    loadingMore: false,
    posting: false,
    error: null,
  );

  SolutionCommentsState copyWith({
    List<SolutionComment>? items,
    String? nextCursor,
    bool? loading,
    bool? loadingMore,
    bool? posting,
    String? error,
  }) {
    return SolutionCommentsState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      posting: posting ?? this.posting,
      error: error,
    );
  }
}

@immutable
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

  static const initial = SolutionsState(
    items: <Solution>[],
    loading: true,
    loadingMore: false,
    error: null,
    nextCursor: null,
    hasMore: true,
    filters: SolutionsFilters(),
  );

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
}

final solutionsControllerProvider =
    NotifierProvider<SolutionsController, SolutionsState>(
      SolutionsController.new,
    );

class SolutionsController extends Notifier<SolutionsState> {
  static const int _pageSize = 20;

  final Map<String, SolutionCommentsState> _commentsBySolutionId =
      <String, SolutionCommentsState>{};

  SolutionCommentsState commentsStateFor(String solutionId) {
    return _commentsBySolutionId[solutionId] ?? SolutionCommentsState.empty;
  }

  void _bump() {
    state = state; // notify listeners
  }

  @override
  SolutionsState build() {
    state = SolutionsState.initial;
    _loadInitial();
    return state;
  }

  Future<void> _loadInitial() async {
    state = state.copyWith(
      loading: true,
      loadingMore: false,
      error: null,
      items: const <Solution>[],
      nextCursor: null,
      hasMore: true,
    );

    final repo = ref.read(solutionsRepoProvider);
    try {
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

  Future<void> refresh() => _loadInitial();

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    final cursor = state.nextCursor;
    if (cursor == null || cursor.isEmpty) return;

    state = state.copyWith(loadingMore: true, error: null);
    final repo = ref.read(solutionsRepoProvider);

    try {
      final page = await repo.list(
        filters: state.filters,
        limit: _pageSize,
        cursor: cursor,
      );
      state = state.copyWith(
        items: <Solution>[...state.items, ...page.items],
        loadingMore: false,
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    }
  }

  Future<void> setFilters(SolutionsFilters f) async {
    state = state.copyWith(filters: f);
    await _loadInitial();
  }

  Future<void> toggleLike(Solution item) async {
    final repo = ref.read(solutionsRepoProvider);

    final idx = state.items.indexWhere((x) => x.id == item.id);
    if (idx == -1) return;

    final cur = state.items[idx];
    final optimisticLiked = !cur.likedByMe;
    final optimisticLikeCount = cur.likeCount + (optimisticLiked ? 1 : -1);

    final updatedOptimistic = cur.copyWith(
      likedByMe: optimisticLiked,
      likeCount: optimisticLikeCount < 0 ? 0 : optimisticLikeCount,
    );

    final next = [...state.items];
    next[idx] = updatedOptimistic;
    state = state.copyWith(items: next);

    try {
      final m = optimisticLiked
          ? await repo.like(cur.id)
          : await repo.unlike(cur.id);
      final likeCount = (m['likeCount'] is int)
          ? m['likeCount'] as int
          : updatedOptimistic.likeCount;
      final commentCount = (m['commentCount'] is int)
          ? m['commentCount'] as int
          : updatedOptimistic.commentCount;
      final likedByMe = (m['likedByMe'] is bool)
          ? m['likedByMe'] as bool
          : updatedOptimistic.likedByMe;

      final fixed = updatedOptimistic.copyWith(
        likeCount: likeCount,
        commentCount: commentCount,
        likedByMe: likedByMe,
      );
      final next2 = [...state.items];
      next2[idx] = fixed;
      state = state.copyWith(items: next2);
    } catch (_) {
      final rollback = [...state.items];
      rollback[idx] = cur;
      state = state.copyWith(items: rollback);
    }
  }

  Future<void> loadComments(Solution solution, {int limit = 20}) async {
    final repo = ref.read(solutionsRepoProvider);
    final id = solution.id;

    final cur = commentsStateFor(id);
    _commentsBySolutionId[id] = cur.copyWith(loading: true, error: null);
    _bump();

    try {
      final page = await repo.getComments(id, limit: limit, cursor: null);
      _commentsBySolutionId[id] = SolutionCommentsState(
        items: page.items,
        nextCursor: page.nextCursor,
        loading: false,
        loadingMore: false,
        posting: false,
        error: null,
      );
      _bump();
    } catch (e) {
      _commentsBySolutionId[id] = cur.copyWith(
        loading: false,
        error: e.toString(),
      );
      _bump();
    }
  }

  Future<void> loadMoreComments(Solution solution, {int limit = 20}) async {
    final repo = ref.read(solutionsRepoProvider);
    final id = solution.id;

    final cur = commentsStateFor(id);
    final cursor = cur.nextCursor;
    if (cur.loadingMore || cursor == null || cursor.isEmpty) return;

    _commentsBySolutionId[id] = cur.copyWith(loadingMore: true, error: null);
    _bump();

    try {
      final page = await repo.getComments(id, limit: limit, cursor: cursor);
      final merged = <SolutionComment>[...cur.items, ...page.items];
      _commentsBySolutionId[id] = cur.copyWith(
        items: merged,
        nextCursor: page.nextCursor,
        loadingMore: false,
        error: null,
      );
      _bump();
    } catch (e) {
      _commentsBySolutionId[id] = cur.copyWith(
        loadingMore: false,
        error: e.toString(),
      );
      _bump();
    }
  }

  Future<void> addComment(Solution solution, String body) async {
    final repo = ref.read(solutionsRepoProvider);
    final id = solution.id;

    final cur = commentsStateFor(id);
    final text = body.trim();
    if (cur.posting || text.isEmpty) return;

    _commentsBySolutionId[id] = cur.copyWith(posting: true, error: null);
    _bump();

    try {
      final created = await repo.addComment(id, text);
      final updated = <SolutionComment>[created, ...cur.items];
      _commentsBySolutionId[id] = cur.copyWith(
        items: updated,
        posting: false,
        error: null,
      );
      _bump();

      // bump commentCount in feed list (list drives counts; /:id may not)
      final idx = state.items.indexWhere((x) => x.id == id);
      if (idx != -1) {
        final curSol = state.items[idx];
        final nextItems = [...state.items];
        nextItems[idx] = curSol.copyWith(commentCount: curSol.commentCount + 1);
        state = state.copyWith(items: nextItems);
      }
    } catch (e) {
      _commentsBySolutionId[id] = cur.copyWith(
        posting: false,
        error: e.toString(),
      );
      _bump();
    }
  }
}
