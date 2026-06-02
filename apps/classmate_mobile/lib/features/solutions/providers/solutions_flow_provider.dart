import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../data/solutions_api.dart';
import '../domain/solutions_models.dart';

/// Turns a relative `/uploads/...` path into a full URL; passes absolute
/// http(s) URLs through unchanged.
String _resolveUrl(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return s;
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  final base = Env.apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  return '$base${s.startsWith('/') ? s : '/$s'}';
}

final solutionsFlowProvider =
    NotifierProvider<SolutionsFlowNotifier, SolutionsFlowState>(
      SolutionsFlowNotifier.new,
    );

class SolutionsFlowNotifier extends Notifier<SolutionsFlowState> {
  @override
  SolutionsFlowState build() {
    // Subjects are a fixed canonical list (see SolutionsFlowState.initial).
    // Books are admin/teacher-managed and come from the API — load them once
    // and group by subject so counts + the books screen are ready instantly.
    Future.microtask(_loadBooks);
    return SolutionsFlowState.initial();
  }

  /// Fetches every admin-managed book and assigns them to their subjects.
  Future<void> _loadBooks() async {
    final api = ref.read(solutionsApiProvider);
    Object? raw;
    try {
      raw = await api.fetchBooks();
    } catch (_) {
      return;
    }
    if (raw is! Map) return;
    final list = raw['books'];
    if (list is! List) return;

    final bySubject = <String, List<SolutionBook>>{};
    for (final b in list) {
      if (b is! Map) continue;
      final subjectKey = '${b['subject'] ?? ''}'.trim();
      final id = '${b['id'] ?? ''}'.trim();
      final title = '${b['title'] ?? ''}'.trim();
      final pagesRaw = b['pages'];
      final pages = pagesRaw is int ? pagesRaw : int.tryParse('${pagesRaw ?? ''}') ?? 0;
      final cover = '${b['coverUrl'] ?? ''}'.trim();
      if (subjectKey.isEmpty || id.isEmpty || title.isEmpty) continue;
      (bySubject[subjectKey] ??= <SolutionBook>[]).add(
        SolutionBook(
          id: id,
          title: title,
          subjectId: subjectKey,
          pageCount: pages <= 0 ? 500 : pages,
          coverUrl: cover.isEmpty ? null : _resolveUrl(cover),
        ),
      );
    }

    final updated = state.subjects
        .map((s) => SolutionSubject(id: s.id, title: s.title, books: bySubject[s.id] ?? const <SolutionBook>[]))
        .toList(growable: false);

    SolutionSubject? findById(SolutionSubject? prev) =>
        prev == null ? null : updated.firstWhere((s) => s.id == prev.id, orElse: () => prev);

    state = state.copyWith(
      subjects: updated,
      selectedSubject: findById(state.selectedSubject),
      uploadSelectedSubject: findById(state.uploadSelectedSubject),
    );
  }

  /// Public hook so screens can refresh the book lists (e.g. after a teacher
  /// adds/edits a book in the management screen).
  Future<void> reloadBooks() => _loadBooks();

  void search(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void selectSubject(SolutionSubject subject) {
    // Use the canonical subject from state (with its loaded books).
    final canonical = state.subjects.firstWhere((s) => s.id == subject.id, orElse: () => subject);
    state = state.copyWith(
      selectedSubject: canonical,
      clearSelectedBook: true,
      pageNumber: '',
      questionNumber: '',
      selectedPageQuestions: const <String>[],
      selectedQuestionSolutions: const <QuestionSolutionCard>[],
      uploadSelectedSubject: canonical,
      clearUploadSelectedBook: true,
    );
  }

  List<SolutionBook> booksForSelectedSubject() {
    return state.selectedSubject?.books ?? const <SolutionBook>[];
  }

  void selectBook(SolutionBook book) {
    state = state.copyWith(
      selectedBook: book,
      pageNumber: '',
      questionNumber: '',
      selectedPageQuestions: const <String>[],
      selectedQuestionSolutions: const <QuestionSolutionCard>[],
      uploadSelectedBook: book,
    );
  }

  void setPageNumber(String value) {
    state = state.copyWith(pageNumber: value);
    _refreshPageContext(pageNumber: value, questionNumber: state.questionNumber);
  }

  void setQuestionNumber(String value) {
    state = state.copyWith(questionNumber: value);
    _refreshPageContext(pageNumber: state.pageNumber, questionNumber: value);
  }

  void selectQuestion({String? pageNumber, String? questionNumber}) {
    _refreshPageContext(
      pageNumber: pageNumber ?? state.pageNumber,
      questionNumber: questionNumber ?? state.questionNumber,
    );
  }

  List<QuestionSolutionCard> _solutionsFor({
    String? subjectId,
    String? bookId,
    String? pageNumber,
    String? questionNumber,
  }) {
    return state.allSolutions
        .where((solution) {
          if ((subjectId ?? '').isNotEmpty && solution.subjectId != subjectId) {
            return false;
          }
          if ((bookId ?? '').isNotEmpty && solution.bookId != bookId) {
            return false;
          }
          if ((pageNumber ?? '').isNotEmpty &&
              solution.pageNumber != pageNumber?.trim()) {
            return false;
          }
          if ((questionNumber ?? '').isNotEmpty &&
              solution.questionNumber != questionNumber?.trim()) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  void _refreshPageContext({
    required String pageNumber,
    required String questionNumber,
  }) {
    final subjectId = state.selectedSubject?.id;
    final bookId = state.selectedBook?.id;

    final samePage = _solutionsFor(
      subjectId: subjectId,
      bookId: bookId,
      pageNumber: pageNumber.trim(),
    );

    final questions =
        samePage.map((e) => e.questionNumber).toSet().toList(growable: false)
          ..sort((a, b) => _sortableNumber(a).compareTo(_sortableNumber(b)));

    final exact = _solutionsFor(
      subjectId: subjectId,
      bookId: bookId,
      pageNumber: pageNumber.trim(),
      questionNumber: questionNumber.trim(),
    );

    state = state.copyWith(
      pageNumber: pageNumber,
      questionNumber: questionNumber,
      selectedPageQuestions: questions,
      selectedQuestionSolutions: exact,
    );
  }

  List<QuestionSolutionCard> currentQuestionSolutions() {
    return state.selectedQuestionSolutions;
  }

  List<QuestionSolutionCard> samePageSolutions() {
    final items = _solutionsFor(
      subjectId: state.selectedSubject?.id,
      bookId: state.selectedBook?.id,
      pageNumber: state.pageNumber.trim(),
    );

    return items
        .where((e) => e.questionNumber != state.questionNumber.trim())
        .toList(growable: false);
  }

  void setUploadCaption(String value) {
    state = state.copyWith(uploadCaption: value);
  }

  void setUploadPageNumber(String value) {
    state = state.copyWith(uploadPageNumber: value);
  }

  void setUploadQuestionNumber(String value) {
    state = state.copyWith(uploadQuestionNumber: value);
  }

  void setUploadSelectedSubject(SolutionSubject subject) {
    final canonical = state.subjects.firstWhere((s) => s.id == subject.id, orElse: () => subject);
    state = state.copyWith(
      uploadSelectedSubject: canonical,
      clearUploadSelectedBook: true,
    );
  }

  void setUploadSelectedBook(SolutionBook book) {
    state = state.copyWith(uploadSelectedBook: book);
  }

  void setUploadFiles(List<SolutionUploadAsset> files) {
    state = state.copyWith(uploadFiles: files);
  }

  void removeUploadAsset(String id) {
    state = state.copyWith(
      uploadFiles: state.uploadFiles.where((e) => e.id != id).toList(),
    );
  }

  void addUploadLocally(QuestionSolutionCard newSolution) {
    state = state.copyWith(
      allSolutions: <QuestionSolutionCard>[newSolution, ...state.allSolutions],
      uploadCaption: '',
      uploadPageNumber: '',
      uploadQuestionNumber: '',
      uploadFiles: const <SolutionUploadAsset>[],
      selectedSubject: state.uploadSelectedSubject ?? state.selectedSubject,
      selectedBook: state.uploadSelectedBook ?? state.selectedBook,
      pageNumber: newSolution.pageNumber,
      questionNumber: newSolution.questionNumber,
    );

    _refreshPageContext(
      pageNumber: newSolution.pageNumber,
      questionNumber: newSolution.questionNumber,
    );
  }

  int _sortableNumber(String value) {
    return int.tryParse(value.trim()) ?? 999999;
  }
}

final liveSolutionsPreviewProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final state = ref.watch(solutionsFlowProvider);
  final api = ref.watch(solutionsApiProvider);

  final subject = state.selectedSubject?.id;
  final bookTitle = state.selectedBook?.title;
  final pageNumber = int.tryParse(state.pageNumber.trim());
  final questionNumber = state.questionNumber;

  if ((subject ?? '').trim().isEmpty ||
      (bookTitle ?? '').trim().isEmpty ||
      pageNumber == null ||
      questionNumber.trim().isEmpty) {
    return <String, dynamic>{};
  }

  return api.fetchSolutions(
    subject: subject,
    bookTitle: bookTitle,
    pageNumber: pageNumber,
    questionNumber: questionNumber,
    page: 1,
    limit: 12,
  );
});
