import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/practice_models.dart';

class PracticeModeSpec {
  final PracticeMode mode;
  final String label;
  final String shortLabel;
  final String subtitle;
  final String description;
  final String flow;
  final String bestFor;
  final IconData icon;
  final Color accent;

  const PracticeModeSpec({
    required this.mode,
    required this.label,
    required this.shortLabel,
    required this.subtitle,
    required this.description,
    required this.flow,
    required this.bestFor,
    required this.icon,
    required this.accent,
  });
}

const Map<PracticeMode, PracticeModeSpec> practiceModeSpecs = {
  PracticeMode.practice: PracticeModeSpec(
    mode: PracticeMode.practice,
    label: 'Practice',
    shortLabel: 'Daily',
    subtitle: 'Balanced daily practice',
    description: 'Balanced solving with instant checking and feedback.',
    flow: 'Pick answer → Check answer → Review explanation → Next.',
    bestFor: 'Daily reps and steady improvement.',
    icon: Icons.tune_rounded,
    accent: Color(0xFF2563EB),
  ),
  PracticeMode.flashcards: PracticeModeSpec(
    mode: PracticeMode.flashcards,
    label: 'Flashcards',
    shortLabel: 'Memory',
    subtitle: 'Reveal and self-recall',
    description: 'Memory-first mode built for quick recall and retention.',
    flow: 'Think first → Reveal/check → Short feedback → Auto-next.',
    bestFor: 'Definitions, formulas, vocabulary, and recall.',
    icon: Icons.style_rounded,
    accent: Color(0xFF7C3AED),
  ),
  PracticeMode.speedRound: PracticeModeSpec(
    mode: PracticeMode.speedRound,
    label: 'Speed round',
    shortLabel: 'Arcade',
    subtitle: 'Fast pressure drill',
    description: 'Fast, low-friction, timed pressure reps.',
    flow: 'Tap fast → Check instantly → Auto-next quickly.',
    bestFor: 'Speed, focus, and pressure handling.',
    icon: Icons.flash_on_rounded,
    accent: Color(0xFFF59E0B),
  ),
  PracticeMode.examPrep: PracticeModeSpec(
    mode: PracticeMode.examPrep,
    label: 'Exam prep',
    shortLabel: 'Formal',
    subtitle: 'Calm exam-style flow',
    description: 'Formal exam-feel solving with less gamified pacing.',
    flow: 'Answer questions calmly → Review after each or at the end.',
    bestFor: 'School tests and realistic exam rehearsal.',
    icon: Icons.assignment_rounded,
    accent: Color(0xFF14B8A6),
  ),
  PracticeMode.conceptBuilder: PracticeModeSpec(
    mode: PracticeMode.conceptBuilder,
    label: 'Concept builder',
    shortLabel: 'Learn',
    subtitle: 'Concept first, solve later',
    description: 'Understand the idea first, then solve with context.',
    flow: 'Read concept → Solve → Review concept-based explanation.',
    bestFor: 'Weak concepts and first-time learning.',
    icon: Icons.school_rounded,
    accent: Color(0xFF4F46E5),
  ),
  PracticeMode.adaptive: PracticeModeSpec(
    mode: PracticeMode.adaptive,
    label: 'Adaptive',
    shortLabel: 'Smart',
    subtitle: 'Difficulty shifts live',
    description: 'Difficulty shifts based on how you perform.',
    flow: 'Solve → Difficulty adapts → Keep climbing.',
    bestFor: 'Stretching your level without manual tuning.',
    icon: Icons.auto_awesome_rounded,
    accent: Color(0xFFEC4899),
  ),
  PracticeMode.bagrut: PracticeModeSpec(
    mode: PracticeMode.bagrut,
    label: 'Bagrut',
    shortLabel: 'Exam',
    subtitle: 'Strict official style',
    description: 'Official-style single-question formal Bagrut flow.',
    flow: 'Solve formally → Review official-style solution.',
    bestFor: 'Real Bagrut preparation.',
    icon: Icons.description_rounded,
    accent: Color(0xFFDC2626),
  ),
};

PracticeModeSpec practiceModeSpec(PracticeMode mode) =>
    practiceModeSpecs[mode]!;

Color practiceModeColor(PracticeMode mode) => practiceModeSpec(mode).accent;
String practiceModeLabel(BuildContext context, PracticeMode mode) {
  final l = AppLocalizations.of(context)!;
  switch (mode) {
    case PracticeMode.practice:
      return l.practiceSetupModeLabelPractice;
    case PracticeMode.flashcards:
      return l.practiceSetupModeLabelFlashcards;
    case PracticeMode.speedRound:
      return l.practiceSetupModeLabelSpeedRound;
    case PracticeMode.examPrep:
      return l.practiceSetupModeLabelExamPrep;
    case PracticeMode.conceptBuilder:
      return l.practiceSetupModeLabelConceptBuilder;
    case PracticeMode.adaptive:
      return l.practiceSetupModeLabelAdaptive;
    case PracticeMode.bagrut:
      return l.practiceSetupModeLabelBagrut;
  }
}

String practiceModeSubtitle(BuildContext context, PracticeMode mode) {
  final l = AppLocalizations.of(context)!;
  switch (mode) {
    case PracticeMode.practice:
      return l.practiceSetupModeSubtitlePractice;
    case PracticeMode.flashcards:
      return l.practiceSetupModeSubtitleFlashcards;
    case PracticeMode.speedRound:
      return l.practiceSetupModeSubtitleSpeedRound;
    case PracticeMode.examPrep:
      return l.practiceSetupModeSubtitleExamPrep;
    case PracticeMode.conceptBuilder:
      return l.practiceSetupModeSubtitleConceptBuilder;
    case PracticeMode.adaptive:
      return l.practiceSetupModeSubtitleAdaptive;
    case PracticeMode.bagrut:
      return l.practiceSetupModeSubtitleBagrut;
  }
}

String practiceModeDescription(BuildContext context, PracticeMode mode) {
  final l = AppLocalizations.of(context)!;
  switch (mode) {
    case PracticeMode.practice:
      return l.practiceSessionModeDescriptionPractice;
    case PracticeMode.flashcards:
      return l.practiceSessionModeDescriptionFlashcards;
    case PracticeMode.speedRound:
      return l.practiceSessionModeDescriptionSpeedRound;
    case PracticeMode.examPrep:
      return l.practiceSessionModeDescriptionExamPrep;
    case PracticeMode.conceptBuilder:
      return l.practiceSessionModeDescriptionConceptBuilder;
    case PracticeMode.adaptive:
      return l.practiceSessionModeDescriptionAdaptive;
    case PracticeMode.bagrut:
      return l.practiceSessionModeDescriptionBagrut;
  }
}

String practiceModeBadge(BuildContext context, PracticeMode mode) =>
    practiceModeLabel(context, mode);
IconData practiceModeIcon(PracticeMode mode) => practiceModeSpec(mode).icon;

Color practiceModeTint(ColorScheme cs, PracticeMode mode) {
  return cs.brightness == Brightness.dark ? cs.surfaceContainerHigh : cs.surfaceContainerLow;
}

// ============================================================
// MODE TILE PREVIEW WIDGET
// ============================================================

Widget practiceModePreview(PracticeMode mode, Color accent) {
  switch (mode) {
    case PracticeMode.speedRound:
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: List.generate(
          4,
          (_) => Container(
            width: 18,
            height: 12,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );

    case PracticeMode.flashcards:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 18,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 26,
            height: 18,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ],
      );

    case PracticeMode.examPrep:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 3,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 38,
            height: 3,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 30,
            height: 3,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      );

    case PracticeMode.bagrut:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsetsDirectional.only(end: 3),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );

    case PracticeMode.conceptBuilder:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lightbulb_rounded, size: 14, color: accent),
          const SizedBox(width: 6),
          Container(
            width: 22,
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      );

    case PracticeMode.adaptive:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 18,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 26,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      );

    case PracticeMode.practice:
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          3,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i == 2 ? 0 : 2),
            child: Container(
              width: 42 - (i * 4),
              height: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      );
  }
}
