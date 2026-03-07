import 'dart:io';
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
    state = state.copyWith();
  }

  double _rankScore(Solution item) {
    final created = DateTime.tryParse(
      (item.createdAt ?? '').toString(),
    )?.toUtc();
    final ageHours = created == null
        ? 9999.0
        : DateTime.now().toUtc().difference(created).inMinutes / 60.0;
    final recencyBoost = ageHours <= 0 ? 24.0 : (24.0 / (1.0 + ageHours / 6.0));

    return item.likeCount * 3.0 + item.commentCount * 5.0 + recencyBoost;
  }

  List<Solution> _sortedFeed(List<Solution> items) {
    final next = [...items];
    next.sort((a, b) => _rankScore(b).compareTo(_rankScore(a)));
    return next;
  }

  @override
  SolutionsState build() {
    Future<void>.microtask(_loadInitial);
    return SolutionsState.initial;
  }

  Future<void> _loadInitial() async {
    final activeFilters = state.filters;

    state = state.copyWith(
      items: const <Solution>[],
      loading: true,
      loadingMore: false,
      error: null,
      nextCursor: null,
      hasMore: true,
      filters: activeFilters,
    );

    final repo = ref.read(solutionsRepoProvider);

    try {
      final page = await repo.list(
        filters: activeFilters,
        limit: _pageSize,
        cursor: null,
      );

      state = state.copyWith(
        items: _sortedFeed(page.items),
        loading: false,
        loadingMore: false,
        error: null,
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null,
        filters: activeFilters,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        loadingMore: false,
        error: e.toString(),
        filters: activeFilters,
      );
    }
  }

  Future<void> refresh() async {
    await _loadInitial();
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) {
      return;
    }

    final cursor = state.nextCursor;
    if (cursor == null || cursor.isEmpty) {
      return;
    }

    state = state.copyWith(loadingMore: true, error: null);

    final repo = ref.read(solutionsRepoProvider);

    try {
      final page = await repo.list(
        filters: state.filters,
        limit: _pageSize,
        cursor: cursor,
      );

      state = state.copyWith(
        items: _sortedFeed(<Solution>[...state.items, ...page.items]),
        loadingMore: false,
        error: null,
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    }
  }

  Future<void> setFilters(SolutionsFilters filters) async {
    state = state.copyWith(filters: filters);
    await _loadInitial();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(filters: const SolutionsFilters());
    await _loadInitial();
  }

  Future<void> toggleLike(String solutionId) async {
    final idx = state.items.indexWhere((e) => e.id == solutionId);
    if (idx == -1) {
      return;
    }

    final current = state.items[idx];
    final optimistic = current.copyWith(
      likedByMe: !current.likedByMe,
      likeCount: current.likedByMe
          ? (current.likeCount > 0 ? current.likeCount - 1 : 0)
          : current.likeCount + 1,
    );

    final items = [...state.items];
    items[idx] = optimistic;
    state = state.copyWith(items: _sortedFeed(items), error: null);

    final repo = ref.read(solutionsRepoProvider);

    try {
      if (current.likedByMe) {
        await repo.unlike(solutionId);
      } else {
        await repo.like(solutionId);
      }
    } catch (e) {
      final rollback = [...state.items];
      final ridx = rollback.indexWhere((e) => e.id == solutionId);
      if (ridx != -1) {
        rollback[ridx] = current;
      }
      state = state.copyWith(items: _sortedFeed(rollback), error: e.toString());
    }
  }

  Future<void> loadComments(String solutionId) async {
    _commentsBySolutionId[solutionId] = commentsStateFor(solutionId).copyWith(
      items: const <SolutionComment>[],
      nextCursor: null,
      loading: true,
      loadingMore: false,
      posting: false,
      error: null,
    );
    _bump();

    final repo = ref.read(solutionsRepoProvider);

    try {
      final page = await repo.getComments(solutionId, limit: 20, cursor: null);
      _commentsBySolutionId[solutionId] = commentsStateFor(solutionId).copyWith(
        items: page.items,
        nextCursor: page.nextCursor,
        loading: false,
        loadingMore: false,
        posting: false,
        error: null,
      );
      _bump();
    } catch (e) {
      _commentsBySolutionId[solutionId] = commentsStateFor(
        solutionId,
      ).copyWith(loading: false, error: e.toString());
      _bump();
    }
  }

  Future<void> loadMoreComments(String solutionId) async {
    final current = commentsStateFor(solutionId);
    if (current.loading || current.loadingMore) {
      return;
    }

    final cursor = current.nextCursor;
    if (cursor == null || cursor.isEmpty) {
      return;
    }

    _commentsBySolutionId[solutionId] = current.copyWith(
      loadingMore: true,
      error: null,
    );
    _bump();

    final repo = ref.read(solutionsRepoProvider);

    try {
      final page = await repo.getComments(
        solutionId,
        limit: 20,
        cursor: cursor,
      );
      _commentsBySolutionId[solutionId] = current.copyWith(
        items: [...current.items, ...page.items],
        nextCursor: page.nextCursor,
        loadingMore: false,
        error: null,
      );
      _bump();
    } catch (e) {
      _commentsBySolutionId[solutionId] = current.copyWith(
        loadingMore: false,
        error: e.toString(),
      );
      _bump();
    }
  }

  Future<void> addComment(String solutionId, String body) async {
    final text = body.trim();
    if (text.isEmpty) {
      return;
    }

    final current = commentsStateFor(solutionId);
    _commentsBySolutionId[solutionId] = current.copyWith(
      posting: true,
      error: null,
    );
    _bump();

    final repo = ref.read(solutionsRepoProvider);

    try {
      final created = await repo.addComment(solutionId, text);

      final nextComments = commentsStateFor(solutionId).copyWith(
        items: [created, ...commentsStateFor(solutionId).items],
        posting: false,
        error: null,
      );
      _commentsBySolutionId[solutionId] = nextComments;

      final idx = state.items.indexWhere((e) => e.id == solutionId);
      if (idx != -1) {
        final nextItems = [...state.items];
        nextItems[idx] = nextItems[idx].copyWith(
          commentCount: nextComments.items.length,
        );
        state = state.copyWith(items: _sortedFeed(nextItems), error: null);
      } else {
        _bump();
      }
    } catch (e) {
      _commentsBySolutionId[solutionId] = commentsStateFor(
        solutionId,
      ).copyWith(posting: false, error: e.toString());
      _bump();
    }
  }

  Future<void> createSolution({
    required String subject,
    required String sourceType,
    String? sourceName,
    int? page,
    String? questionNumber,
    String? title,
    String? notes,
    String? body,
  }) async {
    final repo = ref.read(solutionsRepoProvider);

    final created = await repo.create(
      subject: subject,
      sourceType: sourceType,
      sourceName: sourceName,
      page: page,
      questionNumber: questionNumber,
      title: title,
      notes: notes,
      body: body,
    );

    state = state.copyWith(
      items: _sortedFeed(<Solution>[created, ...state.items]),
      error: null,
    );
  }

  Future<void> createSolutionWithImages({
    required String subject,
    required String sourceType,
    String? sourceName,
    int? page,
    String? questionNumber,
    String? title,
    String? notes,
    String? body,
    required List<String> imagePaths,
  }) async {
    final repo = ref.read(solutionsRepoProvider);

    final created = await repo.create(
      subject: subject,
      sourceType: sourceType,
      sourceName: sourceName,
      page: page,
      questionNumber: questionNumber,
      title: title,
      notes: notes,
      body: body,
      forceStaffDevToken: true,
    );

    for (final path in imagePaths) {
      final upload = await repo.uploadImageFile(
        File(path),
        forceStaffDevToken: true,
      );
      await repo.attachImage(
        created.id,
        upload: upload,
        forceStaffDevToken: true,
      );
    }

    final refreshed = await repo.list(
      filters: state.filters,
      limit: _pageSize,
      cursor: null,
    );

    state = state.copyWith(
      items: _sortedFeed(refreshed.items),
      nextCursor: refreshed.nextCursor,
      hasMore: refreshed.nextCursor != null,
      error: null,
    );
  }
}
