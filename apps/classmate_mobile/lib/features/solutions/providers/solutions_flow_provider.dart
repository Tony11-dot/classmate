import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/solutions_api.dart';
import '../data/solutions_live_mapper.dart';
import '../domain/solutions_models.dart';

final solutionsFlowProvider =
    NotifierProvider<SolutionsFlowNotifier, SolutionsFlowState>(
      SolutionsFlowNotifier.new,
    );

final liveExactSolutionsPageProvider =
    FutureProvider.family<LiveSolutionsPage, int>((ref, page) async {
      final state = ref.watch(solutionsFlowProvider);
      final api = ref.watch(solutionsApiProvider);

      final subject = state.selectedSubject?.title.trim() ?? '';
      final bookTitle = state.selectedBook?.title.trim() ?? '';
      final pageNumber = int.tryParse(state.pageNumber.trim());
      final questionNumber = state.questionNumber.trim();

      if (subject.isEmpty ||
          bookTitle.isEmpty ||
          pageNumber == null ||
          questionNumber.isEmpty) {
        return LiveSolutionsPage.empty;
      }

      final raw = await api.fetchSolutions(
        subject: subject,
        bookTitle: bookTitle,
        pageNumber: pageNumber,
        questionNumber: questionNumber,
        page: page,
        limit: 12,
      );
      return SolutionsLiveMapper.pageFromJson(raw);
    });

final liveSamePageSolutionsPageProvider =
    FutureProvider.family<LiveSolutionsPage, int>((ref, page) async {
      final state = ref.watch(solutionsFlowProvider);
      final api = ref.watch(solutionsApiProvider);

      final subject = state.selectedSubject?.title.trim() ?? '';
      final bookTitle = state.selectedBook?.title.trim() ?? '';
      final pageNumber = int.tryParse(state.pageNumber.trim());

      if (subject.isEmpty || bookTitle.isEmpty || pageNumber == null) {
        return LiveSolutionsPage.empty;
      }

      final raw = await api.fetchSolutions(
        subject: subject,
        bookTitle: bookTitle,
        pageNumber: pageNumber,
        page: page,
        limit: 12,
      );
      return SolutionsLiveMapper.pageFromJson(raw);
    });

class SolutionsFlowNotifier extends Notifier<SolutionsFlowState> {
  @override
  SolutionsFlowState build() => SolutionsFlowState.initial();

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
