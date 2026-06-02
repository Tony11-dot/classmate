import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/widgets/cm_ai_message.dart';

import '../domain/practice_models.dart';
import '../domain/practice_mode_behavior.dart';

import '../providers/practice_providers.dart';
import 'practice_display_text.dart';
import 'practice_mode_specs.dart';
import 'practice_setup_screen.dart';
import 'modes/mode_common.dart';
import 'modes/practice_mode_view.dart';
import 'modes/flashcards_mode_view.dart';
import 'modes/speed_round_mode_view.dart';
import 'modes/exam_prep_mode_view.dart';
import 'modes/concept_builder_mode_view.dart';
import 'modes/adaptive_mode_view.dart';
import 'modes/bagrut_mode_view.dart';
import '../../../ui/widgets/cm_loading.dart';

String _practiceSessionModeLabel(BuildContext context, PracticeMode mode) {
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

String _practiceSessionModeDescription(BuildContext context, PracticeMode mode) {
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

Color _sessionPanelBorder(ColorScheme cs) {
  return cs.brightness == Brightness.dark
      ? cs.outlineVariant
      : cs.outlineVariant;
}

Color _sessionPanelBg(ColorScheme cs, Color accent) {
  return cs.brightness == Brightness.dark
      ? Color.alphaBlend(
          accent,
          cs.surfaceContainerHigh,
        )
      : cs.surface;
}

PracticeMode _practiceModeFromLabel(BuildContext context, String modeLabel) {
  final normalized = modeLabel.trim().toLowerCase();
  for (final mode in PracticeMode.values) {
    if (_practiceSessionModeLabel(context, mode).toLowerCase() == normalized) {
      return mode;
    }
  }

  switch (normalized) {
    case 'practice':
      return PracticeMode.practice;
    case 'flashcards':
      return PracticeMode.flashcards;
    case 'speed round':
    case 'speedround':
      return PracticeMode.speedRound;
    case 'exam prep':
    case 'examprep':
      return PracticeMode.examPrep;
    case 'concept builder':
    case 'conceptbuilder':
      return PracticeMode.conceptBuilder;
    case 'adaptive':
      return PracticeMode.adaptive;
    case 'bagrut':
      return PracticeMode.bagrut;
    default:
      return PracticeMode.practice;
  }
}

String _friendlyModeLoadingTitle(BuildContext context, PracticeMode mode) {
  final l = AppLocalizations.of(context)!;
  switch (mode) {
    case PracticeMode.practice:
      return l.practiceSessionLoadingPractice;
    case PracticeMode.flashcards:
      return l.practiceSessionLoadingFlashcards;
    case PracticeMode.speedRound:
      return l.practiceSessionLoadingSpeedRound;
    case PracticeMode.examPrep:
      return l.practiceSessionLoadingExamPrep;
    case PracticeMode.conceptBuilder:
      return l.practiceSessionLoadingConceptBuilder;
    case PracticeMode.adaptive:
      return l.practiceSessionLoadingAdaptive;
    case PracticeMode.bagrut:
      return l.practiceSessionLoadingBagrut;
  }
}

class PracticeSessionRouteHelper {
  // MaterialPageRoute (not a custom PageRouteBuilder) so the global
  // CupertinoPageTransitionsBuilder applies — giving the session screen the
  // iOS edge-swipe-back gesture like every other pushed screen.
  static Route<void> get screen =>
      MaterialPageRoute<void>(builder: (_) => const PracticeSessionScreen());
}

enum _ReviewFilter { all, wrong, correct }

class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key});

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  int? _selectedIndex;
  bool _showExplanation = false;
  _ReviewFilter _reviewFilter = _ReviewFilter.all;
  bool _focusReview = false;
  int _reviewIndex = 0;

  void _resetTransientUi() {
    setState(() {
      _selectedIndex = null;
      _showExplanation = false;
    });
  }

  Widget _modeBody(ModeContextData d) {
    switch (d.state.filter.mode) {
      case PracticeMode.practice:
        return PracticeModeView(d: d);
      case PracticeMode.flashcards:
        return FlashcardsModeView(d: d);
      case PracticeMode.speedRound:
        return SpeedRoundModeView(d: d);
      case PracticeMode.examPrep:
        return ExamPrepModeView(d: d);
      case PracticeMode.conceptBuilder:
        return ConceptBuilderModeView(d: d);
      case PracticeMode.adaptive:
        return AdaptiveModeView(d: d);
      case PracticeMode.bagrut:
        return BagrutModeView(d: d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceSessionProvider);
    final sessionCtl = ref.read(practiceSessionProvider.notifier);
    final loading = ref.watch(practiceSessionLoadingProvider);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = practiceModeColor(state.filter.mode);
    final q = state.currentQuestion;
    final options = q?.options ?? const <String>[];

    final answered = state.stats.answered;
    final correct = state.stats.correct;
    final wrong = answered - correct;
    final total = state.questions.length;
    final accuracy = answered == 0 ? 0 : ((correct / answered) * 100).round();
    final behavior = behaviorForMode(state.filter.mode);

    if (loading && state.questions.isEmpty && !state.isComplete) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CmLoading(),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () async {
                    await sessionCtl.cancelGeneration();
                    if (!context.mounted) return;
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: Text(l.practiceSetupStopGenerating),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.isComplete) {
      final reviewQuestions = state.questions.where((question) {
        final result = state.answersByQuestionId[question.id];
        return switch (_reviewFilter) {
          _ReviewFilter.all => true,
          _ReviewFilter.wrong => result != null && !result.isCorrect,
          _ReviewFilter.correct => result != null && result.isCorrect,
        };
      }).toList();

      if (_reviewIndex >= reviewQuestions.length &&
          reviewQuestions.isNotEmpty) {
        _reviewIndex = reviewQuestions.length - 1;
      }
      if (reviewQuestions.isEmpty) {
        _reviewIndex = 0;
      }

      final reviewVisible = _focusReview && reviewQuestions.isNotEmpty
          ? <PracticeQuestion>[reviewQuestions[_reviewIndex]]
          : reviewQuestions;

      return Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _sessionPanelBorder(cs)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 54, color: accent),
                    const SizedBox(height: 12),
                    Text(
                      l.practiceSessionCompleteTitle(
                        _practiceSessionModeLabel(context, state.filter.mode),
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricPill(
                          label: l.practiceSessionMetricAnswered,
                          value: '$answered',
                        ),
                        _MetricPill(
                          label: l.practiceSessionMetricCorrect,
                          value: '$correct',
                        ),
                        _MetricPill(
                          label: l.practiceSessionMetricWrong,
                          value: '$wrong',
                        ),
                        _MetricPill(
                          label: l.practiceSessionMetricAccuracy,
                          value: '$accuracy%',
                        ),
                        _MetricPill(
                          label: l.practiceSessionMetricTotal,
                          value: '$total',
                        ),
                        _MetricPill(
                          label: l.practiceSessionMetricStreak,
                          value: '${state.stats.streak}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _practiceSessionModeDescription(
                        context,
                        state.filter.mode,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizedPracticeSubjectAndTopic(
                        context,
                        subject: state.filter.subject,
                        topicLabel: state.filter.topicLabel,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(l.practiceSessionReviewLayoutStacked),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(l.practiceSessionReviewLayoutFocus),
                        ),
                      ],
                      selected: {_focusReview},
                      onSelectionChanged: (v) {
                        setState(() {
                          _focusReview = v.first;
                          _reviewIndex = 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l.practiceSessionFilterAll),
                          selected: _reviewFilter == _ReviewFilter.all,
                          onSelected: (_) {
                            setState(() {
                              _reviewFilter = _ReviewFilter.all;
                              _reviewIndex = 0;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text(l.practiceSessionFilterWrong),
                          selected: _reviewFilter == _ReviewFilter.wrong,
                          onSelected: (_) {
                            setState(() {
                              _reviewFilter = _ReviewFilter.wrong;
                              _reviewIndex = 0;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text(l.practiceSessionFilterCorrect),
                          selected: _reviewFilter == _ReviewFilter.correct,
                          onSelected: (_) {
                            setState(() {
                              _reviewFilter = _ReviewFilter.correct;
                              _reviewIndex = 0;
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l.practiceSessionReviewTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (reviewQuestions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.outlineVariant,
                    ),
                  ),
                  child: Text(
                    l.practiceSessionNoQuestionsForFilter,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ...reviewVisible.map((question) {
                final result = state.answersByQuestionId[question.id];
                final selectedIndex = result?.selectedIndex;
                final selectedLabel =
                    (selectedIndex != null &&
                        selectedIndex >= 0 &&
                        selectedIndex < question.options.length)
                    ? question.options[selectedIndex]
                  : l.practiceSessionNoAnswer;
                final correctLabel =
                    (question.correctIndex >= 0 &&
                        question.correctIndex < question.options.length)
                    ? question.options[question.correctIndex]
                  : l.practiceSessionUnknownAnswer;
                final isCorrect = result?.isCorrect ?? false;
                final isFlashcards =
                    state.filter.mode == PracticeMode.flashcards;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green
                            : cs.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                localizedPracticeTopicLabel(
                                  context,
                                  question.topicLabel,
                                ),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Icon(
                              isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isCorrect
                                  ? Colors.green
                                  : cs.outlineVariant,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CMAiMessage(
                          question.prompt,
                          compact: true,
                          textStyle: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isFlashcards) ...[
                          Text(
                            l.practiceSessionReflectionTitle,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCorrect
                                ? l.practiceSessionReflectionKnewIt
                                : l.practiceSessionReflectionReviewAgain,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isCorrect
                                  ? Colors.green
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l.practiceSessionBackOfCard,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CMAiMessage(question.explanation, compact: true),
                        ] else ...[
                          Text(
                            l.practiceSessionYourAnswer,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CMAiMessage(selectedLabel, compact: true),
                          const SizedBox(height: 10),
                          Text(
                            l.practiceSessionCorrectAnswer,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CMAiMessage(correctLabel, compact: true),
                          const SizedBox(height: 10),
                          Text(
                            l.practiceSessionExplanation,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CMAiMessage(question.explanation, compact: true),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              if (_focusReview && reviewQuestions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: _reviewIndex > 0
                            ? () => setState(() => _reviewIndex--)
                            : null,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${_reviewIndex + 1} / ${reviewQuestions.length}',
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: _reviewIndex < reviewQuestions.length - 1
                            ? () => setState(() => _reviewIndex++)
                            : null,
                      ),
                    ],
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () {
                  sessionCtl.reset();
                  Navigator.of(context).maybePop();
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                label: Text(l.practiceSessionBackToSetup),
              ),
            ],
          ),
        ),
      );
    }
    final progress = state.questions.isEmpty
        ? 0.0
        : ((state.currentIndex + 1) / state.questions.length)
              .clamp(0.0, 1.0)
              .toDouble();

    final d = ModeContextData(
      context: context,
      ref: ref,
      state: state,
      sessionCtl: sessionCtl,
      q: q,
      options: options,
      selectedIndex: _selectedIndex,
      showExplanation: _showExplanation,
      onSelected: (v) => setState(() => _selectedIndex = v),
      onShowExplanation: (v) => setState(() => _showExplanation = v),
      resetTransientUi: _resetTransientUi,
    );

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.brightness == Brightness.dark
                    ? _sessionPanelBg(cs, accent)
                    : cs.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _sessionPanelBorder(cs)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MiniPill(
                        label: localizedPracticeSubject(
                          context,
                          state.filter.subject,
                        ),
                      ),
                      _MiniPill(
                        label: localizedPracticeTopicPath(
                          context,
                          state.filter.topicPath,
                        ).replaceAll(' · ', ' • '),
                      ),
                      _MiniPill(
                        label: practiceDifficultyLabel(
                          context,
                          state.filter.difficulty,
                        ),
                      ),
                      _MiniPill(
                        label: _practiceSessionModeLabel(
                          context,
                          state.filter.mode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l.practiceSessionQuestionProgress(
                      state.currentIndex + 1,
                      state.questions.length,
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (behavior.allowTimer)
                        _MetricPill(
                          label: l.practiceSessionMetricTime,
                          value: l.practiceSetupSecondsShort(
                            state.secondsRemaining,
                          ),
                        ),
                      _MetricPill(
                        label: l.practiceSessionMetricStreak,
                        value: '${state.stats.streak}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _modeBody(d),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.brightness == Brightness.dark
              ? cs.outlineVariant
              : cs.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: cs.brightness == Brightness.dark
              ? cs.outlineVariant
              : cs.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class PracticeSessionMatchmakingScreen extends StatelessWidget {
  const PracticeSessionMatchmakingScreen({
    super.key,
    required this.mode,
    required this.subject,
    required this.difficulty,
    required this.tip,
    required this.onCancel,
  });

  final String mode;
  final String subject;
  final String difficulty;
  final String tip;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentMode = _practiceModeFromLabel(context, mode);
    final accent = practiceModeColor(currentMode);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: cs.surfaceContainerLow),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: cs.surfaceContainerLow,
                        child: Icon(
                          practiceModeIcon(currentMode),
                          color: accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _friendlyModeLoadingTitle(context, currentMode),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$mode • $subject",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.practiceSessionMatchmakingDifficulty(difficulty),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            cs.surfaceContainerLow,
                            cs.surfaceContainerHighest,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          tip,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: cs.surfaceContainerLow,
                          ),
                        ),
                        onPressed: onCancel,
                        icon: Icon(Icons.close_rounded, color: accent),
                        label: Text(l.practiceSetupStopGenerating),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
