enum PracticeMode {
  practice,
  flashcards,
  speedRound,
  examPrep,
  conceptBuilder,
  adaptive,
  bagrut,
}

enum PracticeDifficulty { easy, medium, hard, olympiad, adaptive }

enum FlashcardReflection { again, hard, good, easy }

class PracticeTopicNode {
  const PracticeTopicNode({
    required this.label,
    this.children = const <PracticeTopicNode>[],
  });

  final String label;
  final List<PracticeTopicNode> children;
}

class PracticeFilter {
  const PracticeFilter({
    required this.subject,
    required this.mode,
    required this.difficulty,
    required this.topicPath,
    required this.questionCount,
    required this.timePreferenceSeconds,
    required this.useAiTiming,
    required this.maxLives,
    required this.hasInfiniteLives,
    this.grade,
  });

  final String subject;
  final PracticeMode mode;
  final PracticeDifficulty difficulty;
  final List<String> topicPath;
  final int questionCount;
  final int? timePreferenceSeconds;
  final bool useAiTiming;
  final int maxLives;
  final bool hasInfiniteLives;

  /// The student's school grade (1–12), used to calibrate AI question
  /// difficulty and which topics make sense. Null for staff or when unknown.
  final int? grade;

  String get topicLabel =>
      topicPath.isEmpty ? 'All topics' : topicPath.join(' · ');

  PracticeFilter copyWith({
    String? subject,
    PracticeMode? mode,
    PracticeDifficulty? difficulty,
    List<String>? topicPath,
    int? questionCount,
    int? timePreferenceSeconds,
    bool? useAiTiming,
    int? maxLives,
    bool? hasInfiniteLives,
    int? grade,
  }) {
    return PracticeFilter(
      subject: subject ?? this.subject,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      topicPath: topicPath ?? this.topicPath,
      questionCount: questionCount ?? this.questionCount,
      timePreferenceSeconds:
          timePreferenceSeconds ?? this.timePreferenceSeconds,
      useAiTiming: useAiTiming ?? this.useAiTiming,
      maxLives: maxLives ?? this.maxLives,
      hasInfiniteLives: hasInfiniteLives ?? this.hasInfiniteLives,
      grade: grade ?? this.grade,
    );
  }

  static const PracticeFilter defaults = PracticeFilter(
    subject: 'mathematics',
    mode: PracticeMode.practice,
    difficulty: PracticeDifficulty.medium,
    topicPath: <String>['Algebra'],
    questionCount: 10,
    timePreferenceSeconds: 15,
    useAiTiming: false,
    maxLives: 3,
    hasInfiniteLives: false,
  );
}

class PracticeQuestion {
  const PracticeQuestion({
    required this.id,
    required this.subject,
    required this.topicLabel,
    required this.mode,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.recommendedTimeSeconds,
  });

  final String id;
  final String subject;
  final String topicLabel;
  final PracticeMode mode;
  final PracticeDifficulty difficulty;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int recommendedTimeSeconds;
}

class PracticeAnswerResult {
  const PracticeAnswerResult({
    required this.selectedIndex,
    required this.isCorrect,
    required this.timeTakenSeconds,
  });

  final int selectedIndex;
  final bool isCorrect;
  final int timeTakenSeconds;
}

class PracticeStats {
  const PracticeStats({
    required this.answered,
    required this.correct,
    required this.xp,
    required this.streak,
  });

  final int answered;
  final int correct;
  final int xp;
  final int streak;

  PracticeStats copyWith({int? answered, int? correct, int? xp, int? streak}) {
    return PracticeStats(
      answered: answered ?? this.answered,
      correct: correct ?? this.correct,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
    );
  }

  double? get accuracy => answered == 0 ? null : (correct / answered) * 100.0;

  static const zero = PracticeStats(answered: 0, correct: 0, xp: 0, streak: 0);
}

class PracticeSessionState {
  const PracticeSessionState({
    required this.filter,
    required this.questions,
    required this.currentIndex,
    required this.answersByQuestionId,
    required this.stats,
    required this.secondsRemaining,
    required this.isComplete,
    required this.lastResult,
  });

  final PracticeFilter filter;
  final List<PracticeQuestion> questions;
  final int currentIndex;
  final Map<String, PracticeAnswerResult> answersByQuestionId;
  final PracticeStats stats;
  final int secondsRemaining;
  final bool isComplete;
  final PracticeAnswerResult? lastResult;

  PracticeQuestion? get currentQuestion =>
      currentIndex >= 0 && currentIndex < questions.length
      ? questions[currentIndex]
      : null;

  PracticeSessionState copyWith({
    PracticeFilter? filter,
    List<PracticeQuestion>? questions,
    int? currentIndex,
    Map<String, PracticeAnswerResult>? answersByQuestionId,
    PracticeStats? stats,
    int? secondsRemaining,
    bool? isComplete,
    PracticeAnswerResult? lastResult,
    bool clearLastResult = false,
  }) {
    return PracticeSessionState(
      filter: filter ?? this.filter,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answersByQuestionId: answersByQuestionId ?? this.answersByQuestionId,
      stats: stats ?? this.stats,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isComplete: isComplete ?? this.isComplete,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
    );
  }

  static PracticeSessionState initial(PracticeFilter filter) =>
      PracticeSessionState(
        filter: filter,
        questions: const <PracticeQuestion>[],
        currentIndex: 0,
        answersByQuestionId: <String, PracticeAnswerResult>{},
        stats: PracticeStats.zero,
        secondsRemaining: filter.useAiTiming
            ? 15
            : (filter.timePreferenceSeconds ?? 15),
        isComplete: false,
        lastResult: null,
      );
}

