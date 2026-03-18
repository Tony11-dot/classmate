enum SolutionAssetKind { image, pdf }

class SolutionUploadAsset {
  final UploadState uploadState;
  final String id;
  final String name;
  final SolutionAssetKind kind;
  final String? filePath;
  final String? remoteUrl;

  const SolutionUploadAsset({
    required this.id,
    required this.name,
    required this.kind,
    this.uploadState = UploadState.queued,
    this.filePath,
    this.remoteUrl,
  });
}

class SolutionBook {
  final String id;
  final String title;
  final String subjectId;

  const SolutionBook({
    required this.id,
    required this.title,
    required this.subjectId,
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
  final String subjectId;
  final String bookId;
  final String pageNumber;
  final String questionNumber;
  final String caption;
  final bool verifiedByNova;
  final List<SolutionUploadAsset> assets;
  final DateTime createdAt;

  const QuestionSolutionCard({
    required this.id,
    required this.uploaderName,
    required this.uploaderInitials,
    required this.subjectId,
    required this.bookId,
    required this.pageNumber,
    required this.questionNumber,
    required this.caption,
    required this.verifiedByNova,
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
    final mathBooks = <SolutionBook>[
      const SolutionBook(
        id: 'math-book-1',
        title: 'Bagrut Algebra Workbook',
        subjectId: 'math',
      ),
      const SolutionBook(
        id: 'math-book-2',
        title: 'Functions and Calculus Prep',
        subjectId: 'math',
      ),
    ];

    final physicsBooks = <SolutionBook>[
      const SolutionBook(
        id: 'physics-book-1',
        title: 'Physics Mechanics Book',
        subjectId: 'physics',
      ),
      const SolutionBook(
        id: 'physics-book-2',
        title: 'Electricity and Circuits',
        subjectId: 'physics',
      ),
    ];

    final csBooks = <SolutionBook>[
      const SolutionBook(
        id: 'cs-book-1',
        title: 'Algorithms Basics',
        subjectId: 'cs',
      ),
      const SolutionBook(
        id: 'cs-book-2',
        title: 'Intro to C# and Logic',
        subjectId: 'cs',
      ),
    ];

    final subjects = <SolutionSubject>[
      SolutionSubject(id: 'math', title: 'Math', books: mathBooks),
      SolutionSubject(id: 'physics', title: 'Physics', books: physicsBooks),
      SolutionSubject(id: 'cs', title: 'Computer Science', books: csBooks),
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
