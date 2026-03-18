import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/solutions_models.dart';

final solutionsFlowProvider =
    NotifierProvider<SolutionsFlowNotifier, SolutionsFlowState>(
      SolutionsFlowNotifier.new,
    );

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

  void addMockImageUpload() {
    final next = List<SolutionUploadAsset>.from(state.uploadFiles)
      ..add(
        SolutionUploadAsset(
          id: 'mock-image-${DateTime.now().microsecondsSinceEpoch}',
          name: 'photo_${state.uploadFiles.length + 1}.jpg',
          kind: SolutionAssetKind.image,
        ),
      );

    state = state.copyWith(uploadFiles: next);
  }

  void addMockPdfUpload() {
    final next = List<SolutionUploadAsset>.from(state.uploadFiles)
      ..add(
        SolutionUploadAsset(
          id: 'mock-pdf-${DateTime.now().microsecondsSinceEpoch}',
          name: 'solution_${state.uploadFiles.length + 1}.pdf',
          kind: SolutionAssetKind.pdf,
        ),
      );

    state = state.copyWith(uploadFiles: next);
  }

  void removeUploadAsset(String id) {
    state = state.copyWith(
      uploadFiles: state.uploadFiles.where((e) => e.id != id).toList(),
    );
  }

  void addUpload() {
    final subject = state.uploadSelectedSubject ?? state.selectedSubject;
    final book = state.uploadSelectedBook ?? state.selectedBook;
    final page = state.uploadPageNumber.trim();
    final question = state.uploadQuestionNumber.trim();

    if (subject == null || book == null || page.isEmpty || question.isEmpty) {
      return;
    }

    final newSolution = QuestionSolutionCard(
      id: 'solution-${DateTime.now().microsecondsSinceEpoch}',
      uploaderName: 'You',
      uploaderInitials: 'YO',
      subjectId: subject.id,
      bookId: book.id,
      pageNumber: page,
      questionNumber: question,
      caption: state.uploadCaption.trim().isEmpty
          ? 'Fresh upload from a classmate.'
          : state.uploadCaption.trim(),
      verifiedByNova: false,
      assets: state.uploadFiles.isEmpty
          ? <SolutionUploadAsset>[
              SolutionUploadAsset(
                id: 'fallback-${DateTime.now().microsecondsSinceEpoch}',
                name: 'solution.jpg',
                kind: SolutionAssetKind.image,
              ),
            ]
          : state.uploadFiles,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      allSolutions: <QuestionSolutionCard>[newSolution, ...state.allSolutions],
      uploadCaption: '',
      uploadPageNumber: '',
      uploadQuestionNumber: '',
      uploadFiles: const <SolutionUploadAsset>[],
      selectedSubject: subject,
      selectedBook: book,
      pageNumber: page,
      questionNumber: question,
    );

    _refreshPageContext(pageNumber: page, questionNumber: question);
  }

  int _sortableNumber(String value) {
    return int.tryParse(value.trim()) ?? 999999;
  }
}
