import 'package:flutter/material.dart';
import '../domain/practice_models.dart';

Color modeColor(PracticeMode mode, ColorScheme cs) {
  switch (mode) {
    case PracticeMode.practice:
      return cs.primary;
    case PracticeMode.flashcards:
      return Colors.purple;
    case PracticeMode.speedRound:
      return Colors.orange;
    case PracticeMode.examPrep:
      return Colors.redAccent;
    case PracticeMode.conceptBuilder:
      return Colors.green;
    case PracticeMode.adaptive:
      return Colors.deepPurple;
    case PracticeMode.bagrut:
      return Colors.amber.shade700;
  }
}

Color modeSurface(PracticeMode mode, ColorScheme cs) {
  switch (mode) {
    case PracticeMode.practice:
      return cs.primaryContainer.withValues(alpha: 0.35);
    case PracticeMode.flashcards:
      return Colors.purple.withValues(alpha: 0.14);
    case PracticeMode.speedRound:
      return Colors.orange.withValues(alpha: 0.14);
    case PracticeMode.examPrep:
      return Colors.redAccent.withValues(alpha: 0.12);
    case PracticeMode.conceptBuilder:
      return Colors.green.withValues(alpha: 0.12);
    case PracticeMode.adaptive:
      return Colors.deepPurple.withValues(alpha: 0.14);
    case PracticeMode.bagrut:
      return Colors.amber.withValues(alpha: 0.16);
  }
}

String modeLabel(PracticeMode mode) {
  switch (mode) {
    case PracticeMode.practice:
      return 'Practice';
    case PracticeMode.flashcards:
      return 'Flashcards';
    case PracticeMode.speedRound:
      return 'Speed round';
    case PracticeMode.examPrep:
      return 'Exam prep';
    case PracticeMode.conceptBuilder:
      return 'Concept builder';
    case PracticeMode.adaptive:
      return 'Adaptive';
    case PracticeMode.bagrut:
      return 'Bagrut';
  }
}
