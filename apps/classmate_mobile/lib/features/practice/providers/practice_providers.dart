import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/practice_generator.dart';
import '../domain/practice_models.dart';

PracticeFilter _defaultFilter() {
  return const PracticeFilter(
    subject: 'Math',
    mode: PracticeMode.practice,
    difficulty: PracticeDifficulty.medium,
    topicPath: ['Algebra'],
    questionCount: 10,
    timePreferenceSeconds: null,
    useAiTiming: true,
    maxLives: 3,
    hasInfiniteLives: false,
  );
}

final practiceSessionLoadingProvider =
    NotifierProvider<PracticeSessionLoadingController, bool>(
      PracticeSessionLoadingController.new,
    );

class PracticeSessionLoadingController extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}

final practiceFilterProvider =
    NotifierProvider<PracticeFilterController, PracticeFilter>(
      PracticeFilterController.new,
    );

class PracticeFilterController extends Notifier<PracticeFilter> {
  @override
  PracticeFilter build() => _defaultFilter();

  void setFilter(PracticeFilter next) {
    state = next;
  }

  void patch({
    String? subject,
    PracticeMode? mode,
    PracticeDifficulty? difficulty,
    List<String>? topicPath,
    int? questionCount,
    int? timePreferenceSeconds,
    bool? useAiTiming,
    int? maxLives,
    bool? hasInfiniteLives,
  }) {
    state = state.copyWith(
      subject: subject ?? state.subject,
      mode: mode ?? state.mode,
      difficulty: difficulty ?? state.difficulty,
      topicPath: topicPath ?? state.topicPath,
      questionCount: questionCount ?? state.questionCount,
      timePreferenceSeconds:
          timePreferenceSeconds ?? state.timePreferenceSeconds,
      useAiTiming: useAiTiming ?? state.useAiTiming,
      maxLives: maxLives ?? state.maxLives,
      hasInfiniteLives: hasInfiniteLives ?? state.hasInfiniteLives,
    );
  }

  void reset() {
    state = _defaultFilter();
  }
}

final practiceSessionProvider =
    NotifierProvider<PracticeSessionController, PracticeSessionState>(
      PracticeSessionController.new,
    );

class PracticeSessionController extends Notifier<PracticeSessionState> {
  final PracticeGenerator _generator = PracticeGenerator();
  Timer? _timer;
  Timer? _autoAdvanceTimer;

  @override
  PracticeSessionState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _autoAdvanceTimer?.cancel();
    });
    return PracticeSessionState.initial(ref.read(practiceFilterProvider));
  }

  void selectOnlyFilter(PracticeFilter next) {
    ref.read(practiceFilterProvider.notifier).setFilter(next);
    _timer?.cancel();
    _autoAdvanceTimer?.cancel();
    state = PracticeSessionState.initial(next);
  }

  Future<void> start([PracticeFilter? override]) async {
    final PracticeFilter base = override ?? ref.read(practiceFilterProvider);
    final PracticeFilter filter = base.mode == PracticeMode.bagrut
        ? base.copyWith(
            questionCount: 1,
            useAiTiming: false,
            timePreferenceSeconds: null,
            hasInfiniteLives: true,
            maxLives: 9999,
          )
        : base;

    ref.read(practiceSessionLoadingProvider.notifier).setLoading(true);
    _timer?.cancel();
    _autoAdvanceTimer?.cancel();
    state = PracticeSessionState.initial(filter);

    try {
      final questions = await _generator.generate(filter);
      final firstQuestion = questions.isEmpty ? null : questions.first;

      state = state.copyWith(
        filter: filter,
        questions: questions,
        currentIndex: 0,
        secondsRemaining: _resolveTime(filter, firstQuestion),
        isComplete: questions.isEmpty,
        stats: PracticeStats.zero,
      );

      if (questions.isNotEmpty && filter.mode != PracticeMode.bagrut) {
        _startTimer();
      }
    } finally {
      ref.read(practiceSessionLoadingProvider.notifier).setLoading(false);
    }
  }

  void submit(int answerIndex) {
    final q = state.currentQuestion;
    if (q == null || state.isComplete) return;
    if (state.answersByQuestionId.containsKey(q.id)) return;

    _autoAdvanceTimer?.cancel();

    final isCorrect = answerIndex == q.correctIndex;
    const timeTaken = 0;

    final nextAnswers = {
      ...state.answersByQuestionId,
      q.id: PracticeAnswerResult(
        selectedIndex: answerIndex,
        isCorrect: isCorrect,
        timeTakenSeconds: timeTaken,
      ),
    };

    final outOfHearts = state.filter.hasInfiniteLives
        ? false
        : (_wrongAnswersCount(nextAnswers) >= state.filter.maxLives);

    state = state.copyWith(
      answersByQuestionId: nextAnswers,
      stats: state.stats.copyWith(
        answered: state.stats.answered + 1,
        correct: state.stats.correct + (isCorrect ? 1 : 0),
        streak: isCorrect ? state.stats.streak + 1 : 0,
        xp: state.filter.mode == PracticeMode.bagrut
            ? state.stats.xp
            : state.stats.xp + (isCorrect ? _xpFor(q, state.filter) : 0),
      ),
      lastResult: PracticeAnswerResult(
        selectedIndex: answerIndex,
        isCorrect: isCorrect,
        timeTakenSeconds: timeTaken,
      ),
      isComplete: state.filter.mode == PracticeMode.bagrut ? true : outOfHearts,
    );

    if (state.isComplete) {
      _timer?.cancel();
      _autoAdvanceTimer?.cancel();
      return;
    }

    if (state.filter.mode == PracticeMode.speedRound) {
      _queueAutoAdvance(const Duration(milliseconds: 700));
    } else if (state.filter.mode == PracticeMode.flashcards) {
      _queueAutoAdvance(const Duration(milliseconds: 950));
    }
  }

  void previousQuestion() {
    if (state.currentIndex <= 0) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  void nextQuestion() {
    _autoAdvanceTimer?.cancel();
    final nextIndex = state.currentIndex + 1;

    if (nextIndex >= state.questions.length) {
      _timer?.cancel();
      state = state.copyWith(isComplete: true);
      return;
    }

    final q = state.questions[nextIndex];
    state = state.copyWith(
      currentIndex: nextIndex,
      secondsRemaining: _resolveTime(state.filter, q),
      clearLastResult: true,
    );
    if (state.filter.mode != PracticeMode.bagrut) {
      _startTimer();
    }
  }

  void skip() {
    if (state.filter.mode == PracticeMode.flashcards ||
        state.filter.mode == PracticeMode.bagrut) {
      return;
    }
    nextQuestion();
  }

  void endWithoutRewards() {
    _timer?.cancel();
    _autoAdvanceTimer?.cancel();
    state = state.copyWith(isComplete: true, stats: PracticeStats.zero);
  }

  void reset() {
    _timer?.cancel();
    _autoAdvanceTimer?.cancel();
    state = PracticeSessionState.initial(ref.read(practiceFilterProvider));
  }

  void _queueAutoAdvance(Duration delay) {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(delay, () {
      if (!state.isComplete && state.lastResult != null) {
        nextQuestion();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();

    final q = state.currentQuestion;
    if (q == null) return;

    final total = _resolveTime(state.filter, q);
    if (total <= 0) return;

    state = state.copyWith(secondsRemaining: total);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining <= 1) {
        timer.cancel();

        if (state.filter.mode == PracticeMode.flashcards) {
          submit(state.currentQuestion!.correctIndex);
          return;
        }

        nextQuestion();
        return;
      }

      state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
    });
  }

  int _wrongAnswersCount(Map<String, PracticeAnswerResult> answers) {
    return answers.values.where((x) => !x.isCorrect).length;
  }

  int _resolveTime(PracticeFilter filter, PracticeQuestion? q) {
    if (filter.mode == PracticeMode.bagrut) return 3600;
    if (q == null) {
      return filter.useAiTiming ? 15 : (filter.timePreferenceSeconds ?? 15);
    }
    return filter.useAiTiming
        ? q.recommendedTimeSeconds
        : (filter.timePreferenceSeconds ?? q.recommendedTimeSeconds);
  }

  int _xpFor(PracticeQuestion q, PracticeFilter filter) {
    final base = switch (filter.difficulty) {
      PracticeDifficulty.easy => 8,
      PracticeDifficulty.medium => 12,
      PracticeDifficulty.hard => 18,
      PracticeDifficulty.olympiad => 28,
      PracticeDifficulty.adaptive => 16,
    };

    final modeBonus = switch (filter.mode) {
      PracticeMode.practice => 0,
      PracticeMode.flashcards => 2,
      PracticeMode.speedRound => 4,
      PracticeMode.examPrep => 5,
      PracticeMode.conceptBuilder => 3,
      PracticeMode.adaptive => 6,
      PracticeMode.bagrut => 0,
    };

    return base + modeBonus;
  }
}
