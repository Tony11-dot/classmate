import 'package:classmate_mobile/core/theme/cm_tokens.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/widgets/cm_ai_message.dart';

import '../domain/practice_models.dart';
import '../domain/practice_mode_behavior.dart';

import '../providers/practice_providers.dart';
import 'practice_display_text.dart';
import 'practice_mode_specs.dart';
import 'practice_review_widgets.dart';
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

String _practiceSessionModeDescription(
  BuildContext context,
  PracticeMode mode,
) {
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
              _CompletionHero(
                accent: accent,
                title: l.practiceSessionCompleteTitle(
                  _practiceSessionModeLabel(context, state.filter.mode),
                ),
                description: _practiceSessionModeDescription(
                  context,
                  state.filter.mode,
                ),
                subjectLine: localizedPracticeSubjectAndTopic(
                  context,
                  subject: state.filter.subject,
                  topicLabel: state.filter.topicLabel,
                ),
                accuracy: accuracy,
                accuracyLabel: l.practiceSessionMetricAccuracy,
                metrics: [
                  _MetricPill(
                    icon: Icons.edit_note_rounded,
                    label: l.practiceSessionMetricAnswered,
                    value: '$answered',
                  ),
                  _MetricPill(
                    icon: Icons.check_circle_rounded,
                    tone: Colors.green,
                    label: l.practiceSessionMetricCorrect,
                    value: '$correct',
                  ),
                  _MetricPill(
                    icon: Icons.cancel_rounded,
                    tone: Colors.red,
                    label: l.practiceSessionMetricWrong,
                    value: '$wrong',
                  ),
                  _MetricPill(
                    icon: Icons.format_list_numbered_rounded,
                    label: l.practiceSessionMetricTotal,
                    value: '$total',
                  ),
                  _MetricPill(
                    icon: Icons.local_fire_department_rounded,
                    label: l.practiceSessionMetricStreak,
                    value: '${state.stats.streak}',
                  ),
                ],
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
                    borderRadius: BorderRadius.circular(CmTokens.radiusLg),
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
                      borderRadius: BorderRadius.circular(CmTokens.radiusLg),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                      boxShadow: CmTokens.of(context).shadowSm,
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
                            ReviewStatusDot(
                              answered: result != null,
                              correct: isCorrect,
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
                                  ? CmTokens.of(context).good
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
                          ReviewAnswerBox(
                            tone: result == null
                                ? null
                                : (isCorrect ? Colors.green : Colors.red),
                            child: CMAiMessage(selectedLabel, compact: true),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l.practiceSessionCorrectAnswer,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ReviewAnswerBox(
                            tone: Colors.green,
                            child: CMAiMessage(correctLabel, compact: true),
                          ),
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
                        tooltip: l.a11yPrevious,
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
                        tooltip: l.a11yNext,
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: _reviewIndex < reviewQuestions.length - 1
                            ? () => setState(() => _reviewIndex++)
                            : null,
                      ),
                    ],
                  ),
                ),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
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
            _SessionHeader(
              accent: accent,
              icon: practiceModeIcon(state.filter.mode),
              modeLabel: _practiceSessionModeLabel(context, state.filter.mode),
              title: l.practiceSessionQuestionProgress(
                state.currentIndex + 1,
                state.questions.length,
              ),
              progress: progress,
              chips: [
                localizedPracticeSubject(context, state.filter.subject),
                localizedPracticeTopicPath(
                  context,
                  state.filter.topicPath,
                ).replaceAll(' · ', ' • '),
                practiceDifficultyLabel(context, state.filter.difficulty),
              ],
              metrics: [
                if (behavior.allowTimer)
                  _MetricPill(
                    icon: Icons.timer_outlined,
                    label: l.practiceSessionMetricTime,
                    value: l.practiceSetupSecondsShort(state.secondsRemaining),
                    dense: true,
                  ),
                _MetricPill(
                  icon: Icons.local_fire_department_rounded,
                  label: l.practiceSessionMetricStreak,
                  value: '${state.stats.streak}',
                  dense: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _modeBody(d),
          ],
        ),
      ),
    );
  }
}

Color _onAccentColor(Color accent) =>
    accent.computeLuminance() < 0.5 ? Colors.white : Colors.black87;

/// In-session header: mode badge + "Question x of y", context chips, an
/// animated progress bar and the live metrics (timer / streak).
class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.accent,
    required this.icon,
    required this.modeLabel,
    required this.title,
    required this.progress,
    required this.chips,
    required this.metrics,
  });

  final Color accent;
  final IconData icon;
  final String modeLabel;
  final String title;
  final double progress;
  final List<String> chips;
  final List<Widget> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(CmTokens.radiusSm + 2),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: _onAccentColor(accent), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            for (final m in metrics) ...[const SizedBox(width: 6), m],
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in chips.where((c) => c.trim().isNotEmpty)) ...[
                _MiniPill(label: c),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: CmTokens.medium,
            curve: CmTokens.easeOut,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ),
      ],
    );
  }
}

/// Results hero: trophy, title, a big accuracy ring and a metric grid.
class _CompletionHero extends StatelessWidget {
  const _CompletionHero({
    required this.accent,
    required this.title,
    required this.description,
    required this.subjectLine,
    required this.accuracy,
    required this.accuracyLabel,
    required this.metrics,
  });

  final Color accent;
  final String title;
  final String description;
  final String subjectLine;
  final int accuracy;
  final String accuracyLabel;
  final List<Widget> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = CmTokens.of(context);
    final ringColor = accuracy >= 80
        ? Colors.green
        : accuracy >= 50
        ? tokens.warn
        : cs.error;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CmTokens.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(
              alpha: cs.brightness == Brightness.dark ? 0.26 : 0.14,
            ),
            cs.surfaceContainerLow,
          ],
        ),
        boxShadow: tokens.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_rounded, size: 22, color: accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subjectLine,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: accuracy / 100),
                  duration: const Duration(milliseconds: 900),
                  curve: CmTokens.easeOut,
                  builder: (_, v, _) => CircularProgressIndicator(
                    value: v,
                    strokeWidth: 11,
                    strokeCap: StrokeCap.round,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$accuracy%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        accuracyLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              const gap = 8.0;
              final w = (c.maxWidth - gap * 2) / 3;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                alignment: WrapAlignment.center,
                children: [
                  for (final m in metrics) SizedBox(width: w, child: m),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    this.icon,
    this.tone,
    this.dense = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? tone;

  /// Header variant: icon + value only (label kept for screen readers).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final iconColor = tone ?? cs.onSurfaceVariant;
    if (dense) {
      return Semantics(
        label: '$label $value',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: iconColor),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(CmTokens.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class PracticeSessionMatchmakingScreen extends StatefulWidget {
  const PracticeSessionMatchmakingScreen({
    super.key,
    required this.mode,
    required this.subject,
    required this.difficulty,
    required this.tip,
    required this.onCancel,
    this.questionCount = 5,
  });

  final String mode;
  final String subject;
  final String difficulty;
  final String tip;
  final VoidCallback onCancel;
  final int questionCount;

  @override
  State<PracticeSessionMatchmakingScreen> createState() =>
      _PracticeSessionMatchmakingScreenState();
}

class _PracticeSessionMatchmakingScreenState
    extends State<PracticeSessionMatchmakingScreen> {
  Timer? _ticker;
  int _elapsed = 0;

  // Estimate seeded from the requested question count. Generation is ~2-4s per
  // question on the current model, so we show a live countdown across that
  // range and gracefully switch to "almost ready" if it runs long.
  late final int _estMin = (widget.questionCount * 2).clamp(6, 120);
  late final int _estMax = (widget.questionCount * 4).clamp(10, 180);

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += 1);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentMode = _practiceModeFromLabel(context, widget.mode);
    final accent = practiceModeColor(currentMode);
    final l = AppLocalizations.of(context)!;

    final remaining = (_estMax - _elapsed);
    final overrun = remaining <= 0;
    // Determinate-ish progress, capped so it never reads "100%" before the
    // questions actually arrive.
    final progress = (_elapsed / _estMax).clamp(0.0, 0.95);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
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
                    boxShadow: CmTokens.of(context).shadowMd,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: accent.withValues(
                          alpha: cs.brightness == Brightness.dark ? 0.22 : 0.12,
                        ),
                        child: Icon(
                          practiceModeIcon(currentMode),
                          color: accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Branded animated loader + live ETA countdown.
                      CmLoading(size: 52, color: accent),
                      const SizedBox(height: 14),
                      Text(
                        overrun
                            ? l.practiceGenAlmostReady
                            : l.practiceGenRemaining(remaining),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.practiceGenEstimate(_estMin, _estMax),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: overrun ? null : progress,
                          minHeight: 6,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
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
                        "${widget.mode} • ${widget.subject}",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.practiceSessionMatchmakingDifficulty(
                          widget.difficulty,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          widget.tip,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.tonalIcon(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.close_rounded),
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
