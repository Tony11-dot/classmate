import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import 'solution_models.dart';
import 'solutions_api.dart';

class SolutionsFilters {
  final String query;
  final int? grade; // null = All
  final String? subjectId; // null = All

  const SolutionsFilters({this.query = '', this.grade, this.subjectId});

  SolutionsFilters copyWith({
    String? query,
    int? grade,
    String? subjectId,
    bool clearGrade = false,
    bool clearSubject = false,
  }) {
    return SolutionsFilters(
      query: query ?? this.query,
      grade: clearGrade ? null : (grade ?? this.grade),
      subjectId: clearSubject ? null : (subjectId ?? this.subjectId),
    );
  }
}

class SolutionsState {
  final bool loading;
  final String? error;
  final List<SolutionItem> items;
  final SolutionsFilters filters;

  const SolutionsState({
    required this.loading,
    required this.items,
    required this.filters,
    this.error,
  });

  SolutionsState copyWith({
    bool? loading,
    String? error,
    List<SolutionItem>? items,
    SolutionsFilters? filters,
  }) {
    return SolutionsState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
      filters: filters ?? this.filters,
    );
  }
}

final solutionsProvider = NotifierProvider<SolutionsController, SolutionsState>(
  SolutionsController.new,
);

class SolutionsController extends Notifier<SolutionsState> {
  @override
  SolutionsState build() {
    final initial = const SolutionsState(
      loading: true,
      items: [],
      filters: SolutionsFilters(),
    );
    _load(initial.filters);
    return initial;
  }

  Future<void> refresh() async => _load(state.filters);

  Future<void> setFilters(SolutionsFilters f) async {
    state = state.copyWith(loading: true, error: null, filters: f);
    await _load(f);
  }

  Future<void> _load(SolutionsFilters f) async {
    try {
      final api = SolutionsApi(ApiClient.instance);
      final items = await api.feed(
        q: f.query,
        grade: f.grade,
        subjectId: f.subjectId,
      );
      state = state.copyWith(
        loading: false,
        items: items,
        error: null,
        filters: f,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
