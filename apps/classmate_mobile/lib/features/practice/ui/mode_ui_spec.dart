import 'package:flutter/material.dart';

enum PracticeAnswerLayout {
  standardList,
  flashcards,
  speedGrid,
  examSheet,
  conceptBlocks,
  adaptiveStack,
  bagrutSheet,
}

class PracticeModeUiSpec {
  final String key;
  final Color accent;
  final Color surfaceTint;
  final Gradient headerGradient;
  final Gradient optionGradient;
  final double cardRadius;
  final PracticeAnswerLayout answerLayout;
  final bool showTimerBar;
  final bool showLives;
  final bool showDifficultyMeter;
  final bool showExamHeader;
  final bool showFlipCardHint;
  final bool showProgressChips;

  const PracticeModeUiSpec({
    required this.key,
    required this.accent,
    required this.surfaceTint,
    required this.headerGradient,
    required this.optionGradient,
    required this.cardRadius,
    required this.answerLayout,
    required this.showTimerBar,
    required this.showLives,
    required this.showDifficultyMeter,
    required this.showExamHeader,
    required this.showFlipCardHint,
    required this.showProgressChips,
  });

  static PracticeModeUiSpec fromMode(Object? mode) {
    final key = mode.toString().split('.').last;

    switch (key) {
      case 'flashcards':
        return const PracticeModeUiSpec(
          key: 'flashcards',
          accent: Color(0xFFFF8A00),
          surfaceTint: Color(0x1AFF8A00),
          headerGradient: LinearGradient(
            colors: [Color(0xFFFFC266), Color(0xFFFF8A00)],
          ),
          optionGradient: LinearGradient(
            colors: [Color(0x1AFFC266), Color(0x12FF8A00)],
          ),
          cardRadius: 26,
          answerLayout: PracticeAnswerLayout.flashcards,
          showTimerBar: false,
          showLives: false,
          showDifficultyMeter: false,
          showExamHeader: false,
          showFlipCardHint: true,
          showProgressChips: true,
        );

      case 'speedRound':
        return const PracticeModeUiSpec(
          key: 'speedRound',
          accent: Color(0xFFFF5A36),
          surfaceTint: Color(0x1AFF5A36),
          headerGradient: LinearGradient(
            colors: [Color(0xFFFF8A6B), Color(0xFFFF5A36)],
          ),
          optionGradient: LinearGradient(
            colors: [Color(0x22FF8A6B), Color(0x14FF5A36)],
          ),
          cardRadius: 18,
          answerLayout: PracticeAnswerLayout.speedGrid,
          showTimerBar: true,
          showLives: true,
          showDifficultyMeter: false,
          showExamHeader: false,
          showFlipCardHint: false,
          showProgressChips: true,
        );

      case 'examPrep':
        return const PracticeModeUiSpec(
          key: 'examPrep',
          accent: Color(0xFF7C4DFF),
          surfaceTint: Color(0x1A7C4DFF),
          headerGradient: LinearGradient(
            colors: [Color(0xFFA88CFF), Color(0xFF7C4DFF)],
          ),
          optionGradient: LinearGradient(
            colors: [Color(0x227C4DFF), Color(0x147C4DFF)],
          ),
          cardRadius: 16,
          answerLayout: PracticeAnswerLayout.examSheet,
          showTimerBar: true,
          showLives: false,
          showDifficultyMeter: false,
          showExamHeader: true,
          showFlipCardHint: false,
          showProgressChips: false,
        );

      case 'conceptBuilder':
        return const PracticeModeUiSpec(
          key: 'conceptBuilder',
          accent: Color(0xFF14B8A6),
          surfaceTint: Color(0x1A14B8A6),
          headerGradient: LinearGradient(
            colors: [Color(0xFF6EE7D8), Color(0xFF14B8A6)],
          ),
          optionGradient: LinearGradient(
            colors: [Color(0x2214B8A6), Color(0x1414B8A6)],
          ),
          cardRadius: 24,
          answerLayout: PracticeAnswerLayout.conceptBlocks,
          showTimerBar: false,
          showLives: false,
          showDifficultyMeter: false,
          showExamHeader: false,
          showFlipCardHint: false,
          showProgressChips: true,
        );

      case 'adaptive':
        return const PracticeModeUiSpec(
          key: 'adaptive',
          accent: Color(0xFF4F46E5),
          surfaceTint: Color(0x1A4F46E5),
          headerGradient: LinearGradient(
            colors: [Color(0xFF8B83FF), Color(0xFF4F46E5)],
          ),
          optionGradient: LinearGradient(
            colors: [Color(0x224F46E5), Color(0x144F46E5)],
          ),
          cardRadius: 22,
          answerLayout: PracticeAnswerLayout.adaptiveStack,
          showTimerBar: false,
          showLives: false,
          showDifficultyMeter: true,
          showExamHeader: false,
          showFlipCardHint: false,
          showProgressChips: true,
        );

      case 'bagrut':
        return const PracticeModeUiSpec(
          key: 'bagrut',
          accent: Color(0xFF2962FF),
          surfaceTint: Color(0x1A2962FF),
          headerGradient: LinearGradient(
            colors: [Color(0xFF7AA2FF), Color(0xFF2962FF)],
          ),
          optionGradient: LinearGradient(
            colors: [Color(0x222962FF), Color(0x142962FF)],
          ),
          cardRadius: 14,
          answerLayout: PracticeAnswerLayout.bagrutSheet,
          showTimerBar: true,
          showLives: false,
          showDifficultyMeter: false,
          showExamHeader: true,
          showFlipCardHint: false,
          showProgressChips: false,
        );

      case 'practice':
      default:
        return const PracticeModeUiSpec(
          key: 'practice',
          accent: Color(0xFF2563EB),
          surfaceTint: Color(0x1A2563EB),
          headerGradient: LinearGradient(
            colors: [Color(0xFF7DB3FF), Color(0xFF2563EB)],
          ),
          optionGradient: LinearGradient(
            colors: [Color(0x222563EB), Color(0x142563EB)],
          ),
          cardRadius: 20,
          answerLayout: PracticeAnswerLayout.standardList,
          showTimerBar: false,
          showLives: false,
          showDifficultyMeter: false,
          showExamHeader: false,
          showFlipCardHint: false,
          showProgressChips: true,
        );
    }
  }

  EdgeInsets get questionPadding {
    switch (answerLayout) {
      case PracticeAnswerLayout.flashcards:
        return const EdgeInsets.fromLTRB(16, 16, 16, 20);
      case PracticeAnswerLayout.speedGrid:
        return const EdgeInsets.fromLTRB(14, 12, 14, 16);
      case PracticeAnswerLayout.examSheet:
      case PracticeAnswerLayout.bagrutSheet:
        return const EdgeInsets.fromLTRB(18, 18, 18, 24);
      case PracticeAnswerLayout.conceptBlocks:
        return const EdgeInsets.fromLTRB(16, 14, 16, 20);
      case PracticeAnswerLayout.adaptiveStack:
        return const EdgeInsets.fromLTRB(16, 12, 16, 18);
      case PracticeAnswerLayout.standardList:
        return const EdgeInsets.fromLTRB(16, 14, 16, 18);
    }
  }

  bool get useTwoColumnAnswers =>
      answerLayout == PracticeAnswerLayout.speedGrid;

  bool get useExamAnswerChrome =>
      answerLayout == PracticeAnswerLayout.examSheet ||
      answerLayout == PracticeAnswerLayout.bagrutSheet;
}
