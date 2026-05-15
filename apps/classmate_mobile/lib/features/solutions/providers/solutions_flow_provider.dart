import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/contracts/school_subject.dart';
import '../../../core/http/cm_api.dart';
import '../data/solutions_api.dart';
import '../domain/solutions_models.dart';

const _kCustomBooksKey = 'solutions_custom_books_v1';

final solutionsFlowProvider =
    NotifierProvider<SolutionsFlowNotifier, SolutionsFlowState>(
      SolutionsFlowNotifier.new,
    );

class SolutionsFlowNotifier extends Notifier<SolutionsFlowState> {
  @override
  SolutionsFlowState build() {
    // Try to populate the subject list from the user's school first, then
    // merge any locally-persisted custom books on top. Each step is async
    // and falls back gracefully if it fails (offline, no school, etc.).
    Future.microtask(() async {
      await _loadSchoolSubjects();
      await _loadCustomBooks();
    });
    return SolutionsFlowState.initial();
  }

  /// Replaces the subject list with the school's admin-defined subjects when
  /// available. Existing book lists (including custom-* persisted books) are
  /// preserved per-subject by matching on the sluggified subject id.
  Future<void> _loadSchoolSubjects() async {
    final session = ref.read(authSessionProvider);
    final token = (session.token ?? '').trim();
    if (token.isEmpty) return;

    final api = CMApi(token: token);
    Object? raw;
    try {
      raw = await api.getJson('/auth/me/subjects');
    } catch (_) {
      return;
    } finally {
      api.dispose();
    }

    if (raw is! Map) return;
    final list = raw['subjects'];
    if (list is! List || list.isEmpty) return;

    final schoolSubjects = list
        .map(SchoolSubject.fromJson)
        .where((s) => s.nameEn.isNotEmpty)
        .toList();
    if (schoolSubjects.isEmpty) return;

    // Build the new subject list, preserving book lists for any subject we
    // already had (matched by id).
    final existingById = {for (final s in state.subjects) s.id: s};
    final updated = <SolutionSubject>[];
    for (final ss in schoolSubjects) {
      final id = _slugify(ss.nameEn);
      final priorBooks = existingById[id]?.books ?? const <SolutionBook>[];
      updated.add(SolutionSubject(id: id, title: ss.nameEn, books: priorBooks));
    }
    state = state.copyWith(subjects: updated);
  }

  static String _slugify(String s) {
    final lower = s.toLowerCase();
    final ascii = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return ascii.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  // ── persistence ─────────────────────────────────────────────────────────

  Future<void> _loadCustomBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCustomBooksKey);
    if (raw == null || raw.isEmpty) return;

    final List<dynamic> decoded;
    try {
      decoded = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return;
    }

    // Each entry: { subjectId, bookId, bookTitle }
    if (decoded.isEmpty) return;
    var subjects = List<SolutionSubject>.from(state.subjects);
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final subjectId = entry['subjectId'] as String?;
      final bookId = entry['bookId'] as String?;
      final bookTitle = entry['bookTitle'] as String?;
      if (subjectId == null || bookId == null || bookTitle == null) continue;

      final idx = subjects.indexWhere((s) => s.id == subjectId);
      if (idx == -1) continue;

      // Skip if book already exists (e.g. loaded from server).
      final alreadyExists = subjects[idx].books.any((b) => b.id == bookId);
      if (alreadyExists) continue;

      final subject = subjects[idx];
      subjects[idx] = SolutionSubject(
        id: subject.id,
        title: subject.title,
        books: [...subject.books, SolutionBook(id: bookId, title: bookTitle, subjectId: subjectId)],
      );
    }
    state = state.copyWith(subjects: subjects);
  }

  Future<void> _persistCustomBooks() async {
    // Collect all books whose IDs start with 'custom-'.
    final customEntries = <Map<String, String>>[];
    for (final subject in state.subjects) {
      for (final book in subject.books) {
        if (book.id.startsWith('custom-')) {
          customEntries.add({
            'subjectId': subject.id,
            'bookId': book.id,
            'bookTitle': book.title,
          });
        }
      }
    }
    final prefs = await SharedPreferences.getInstance();
    if (customEntries.isEmpty) {
      await prefs.remove(_kCustomBooksKey);
    } else {
      await prefs.setString(_kCustomBooksKey, jsonEncode(customEntries));
    }
  }

  void search(String value) {
    state = state.copyWith(searchQuery: value);
  }

  List<SolutionSubject> filteredSubjects() {
    final q = state.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return state.subjects;
    return state.subjects
        .where((s) => s.title.toLowerCase().contains(q))
        .toList(growable: false);
  }

  void selectSubject(SolutionSubject subject) {
    state = state.copyWith(
      selectedSubject: subject,
      clearSelectedBook: true,
      pageNumber: '',
      questionNumber: '',
      selectedPageQuestions: const <String>[],
      selectedQuestionSolutions: const <QuestionSolutionCard>[],
      uploadSelectedSubject: subject,
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
    _refreshPageContext(
      pageNumber: value,
      questionNumber: state.questionNumber,
    );
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
    state = state.copyWith(
      uploadSelectedSubject: subject,
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

  void addBook(String subjectId, String bookTitle, {int pageCount = 500}) {
    final trimmed = bookTitle.trim();
    if (trimmed.isEmpty) return;
    final newBook = SolutionBook(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      title: trimmed,
      subjectId: subjectId,
      pageCount: pageCount.clamp(1, 9999),
    );
    final updatedSubjects = state.subjects
        .map((s) {
          if (s.id != subjectId) return s;
          return SolutionSubject(
            id: s.id,
            title: s.title,
            books: <SolutionBook>[...s.books, newBook],
          );
        })
        .toList(growable: false);
    state = state.copyWith(subjects: updatedSubjects);
    _persistCustomBooks();
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

  final subject = state.selectedSubject?.title;
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
