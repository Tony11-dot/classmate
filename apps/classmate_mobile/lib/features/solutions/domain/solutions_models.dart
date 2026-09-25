import 'dart:typed_data';

import 'solution_subjects.dart';

enum SolutionAssetKind { image, pdf }

class SolutionUploadAsset {
  final UploadState uploadState;
  final String id;
  final String name;
  final SolutionAssetKind kind;
  final String? filePath;
  /// In-memory bytes for web, where picked files have no filesystem path.
  final Uint8List? bytes;
  final String? remoteUrl;

  const SolutionUploadAsset({
    required this.id,
    required this.name,
    required this.kind,
    this.uploadState = UploadState.queued,
    this.filePath,
    this.bytes,
    this.remoteUrl,
  });
}

class SolutionBook {
  final String id;
  final String title;
  final String subjectId;
  /// Total number of pages in the book; used to bound the page drum picker.
  final int pageCount;
  /// Optional cover image (full URL) set by the admin/teacher.
  final String? coverUrl;

  const SolutionBook({
    required this.id,
    required this.title,
    required this.subjectId,
    this.pageCount = 500,
    this.coverUrl,
  });
}

class SolutionSubject {
  final String id;
  final String title;
  final List<SolutionBook> books;

  const SolutionSubject({
    required this.id,
    required this.title,
    required this.books,
  });
}

class QuestionSolutionCard {
  final String id;
  final String uploaderName;
  final String uploaderInitials;
  /// Poster's grade + school — shown on every card (feed is global).
  final int? grade;
  final String? schoolName;
  final String subjectId;
  final String bookId;
  final String pageNumber;
  final String questionNumber;
  final String caption;
  final bool verifiedByNova;
  final String verificationStatus;
  final String? verificationNote;
  final String moderationStatus;
  final List<SolutionUploadAsset> assets;
  final DateTime createdAt;

  const QuestionSolutionCard({
    required this.id,
    required this.uploaderName,
    required this.uploaderInitials,
    this.grade,
    this.schoolName,
    required this.subjectId,
    required this.bookId,
    required this.pageNumber,
    required this.questionNumber,
    required this.caption,
    required this.verifiedByNova,
    required this.verificationStatus,
    required this.verificationNote,
    required this.moderationStatus,
    required this.assets,
    required this.createdAt,
  });
}

class SolutionsFlowState {
  final String searchQuery;
  final List<SolutionSubject> subjects;
  final List<QuestionSolutionCard> allSolutions;

  final SolutionSubject? selectedSubject;
  final SolutionBook? selectedBook;
  final String pageNumber;
  final String questionNumber;
  final List<String> selectedPageQuestions;
  final List<QuestionSolutionCard> selectedQuestionSolutions;

  final String uploadCaption;
  final String uploadPageNumber;
  final String uploadQuestionNumber;
  final SolutionSubject? uploadSelectedSubject;
  final SolutionBook? uploadSelectedBook;
  final List<SolutionUploadAsset> uploadFiles;

  const SolutionsFlowState({
    required this.searchQuery,
    required this.subjects,
    required this.allSolutions,
    required this.selectedSubject,
    required this.selectedBook,
    required this.pageNumber,
    required this.questionNumber,
    required this.selectedPageQuestions,
    required this.selectedQuestionSolutions,
    required this.uploadCaption,
    required this.uploadPageNumber,
    required this.uploadQuestionNumber,
    required this.uploadSelectedSubject,
    required this.uploadSelectedBook,
    required this.uploadFiles,
  });

  factory SolutionsFlowState.initial() {
    // Canonical, app-wide subject list (keys). Books are loaded from the API
    // (admin/teacher-managed) — never hardcoded and never student-created.
    final subjects = <SolutionSubject>[
      for (final key in kSolutionSubjectKeys)
        SolutionSubject(
          id: key,
          title: kSolutionSubjectEnglish[key] ?? key,
          books: const <SolutionBook>[],
        ),
    ];

    return SolutionsFlowState(
      searchQuery: '',
      subjects: subjects,
      allSolutions: const <QuestionSolutionCard>[],
      selectedSubject: null,
      selectedBook: null,
      pageNumber: '',
      questionNumber: '',
      selectedPageQuestions: const <String>[],
      selectedQuestionSolutions: const <QuestionSolutionCard>[],
      uploadCaption: '',
      uploadPageNumber: '',
      uploadQuestionNumber: '',
      uploadSelectedSubject: null,
      uploadSelectedBook: null,
      uploadFiles: const <SolutionUploadAsset>[],
    );
  }

  SolutionsFlowState copyWith({
    String? searchQuery,
    List<SolutionSubject>? subjects,
    List<QuestionSolutionCard>? allSolutions,
    SolutionSubject? selectedSubject,
    bool clearSelectedSubject = false,
    SolutionBook? selectedBook,
    bool clearSelectedBook = false,
    String? pageNumber,
    String? questionNumber,
    List<String>? selectedPageQuestions,
    List<QuestionSolutionCard>? selectedQuestionSolutions,
    String? uploadCaption,
    String? uploadPageNumber,
    String? uploadQuestionNumber,
    SolutionSubject? uploadSelectedSubject,
    bool clearUploadSelectedSubject = false,
    SolutionBook? uploadSelectedBook,
    bool clearUploadSelectedBook = false,
    List<SolutionUploadAsset>? uploadFiles,
  }) {
    return SolutionsFlowState(
      searchQuery: searchQuery ?? this.searchQuery,
      subjects: subjects ?? this.subjects,
      allSolutions: allSolutions ?? this.allSolutions,
      selectedSubject: clearSelectedSubject
          ? null
          : (selectedSubject ?? this.selectedSubject),
      selectedBook: clearSelectedBook
          ? null
          : (selectedBook ?? this.selectedBook),
      pageNumber: pageNumber ?? this.pageNumber,
      questionNumber: questionNumber ?? this.questionNumber,
      selectedPageQuestions:
          selectedPageQuestions ?? this.selectedPageQuestions,
      selectedQuestionSolutions:
          selectedQuestionSolutions ?? this.selectedQuestionSolutions,
      uploadCaption: uploadCaption ?? this.uploadCaption,
      uploadPageNumber: uploadPageNumber ?? this.uploadPageNumber,
      uploadQuestionNumber: uploadQuestionNumber ?? this.uploadQuestionNumber,
      uploadSelectedSubject: clearUploadSelectedSubject
          ? null
          : (uploadSelectedSubject ?? this.uploadSelectedSubject),
      uploadSelectedBook: clearUploadSelectedBook
          ? null
          : (uploadSelectedBook ?? this.uploadSelectedBook),
      uploadFiles: uploadFiles ?? this.uploadFiles,
    );
  }
}

enum UploadState { queued, uploading, uploaded, failed }
