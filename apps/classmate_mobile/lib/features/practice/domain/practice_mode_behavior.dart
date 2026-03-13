import 'practice_models.dart';

class PracticeModeBehavior {
  const PracticeModeBehavior({
    required this.allowTimer,
    required this.allowLives,
    required this.aiTiming,
    required this.perQuestionTimingOnly,
    required this.perQuizTimingOnly,
  });

  final bool allowTimer;
  final bool allowLives;
  final bool aiTiming;
  final bool perQuestionTimingOnly;
  final bool perQuizTimingOnly;
}

final Map<PracticeMode, PracticeModeBehavior> practiceModeBehaviors = {
  PracticeMode.practice: const PracticeModeBehavior(
    allowTimer: true,
    allowLives: true,
    aiTiming: false,
    perQuestionTimingOnly: false,
    perQuizTimingOnly: false,
  ),

  PracticeMode.speedRound: const PracticeModeBehavior(
    allowTimer: true,
    allowLives: true,
    aiTiming: false,
    perQuestionTimingOnly: true,
    perQuizTimingOnly: false,
  ),

  PracticeMode.examPrep: const PracticeModeBehavior(
    allowTimer: true,
    allowLives: false,
    aiTiming: false,
    perQuestionTimingOnly: false,
    perQuizTimingOnly: true,
  ),

  PracticeMode.bagrut: const PracticeModeBehavior(
    allowTimer: true,
    allowLives: false,
    aiTiming: false,
    perQuestionTimingOnly: false,
    perQuizTimingOnly: true,
  ),

  PracticeMode.flashcards: const PracticeModeBehavior(
    allowTimer: false,
    allowLives: false,
    aiTiming: false,
    perQuestionTimingOnly: false,
    perQuizTimingOnly: false,
  ),

  PracticeMode.conceptBuilder: const PracticeModeBehavior(
    allowTimer: false,
    allowLives: false,
    aiTiming: false,
    perQuestionTimingOnly: false,
    perQuizTimingOnly: false,
  ),

  PracticeMode.adaptive: const PracticeModeBehavior(
    allowTimer: true,
    allowLives: true,
    aiTiming: true,
    perQuestionTimingOnly: false,
    perQuizTimingOnly: false,
  ),
};

PracticeModeBehavior behaviorForMode(PracticeMode mode) {
  return practiceModeBehaviors[mode]!;
}
