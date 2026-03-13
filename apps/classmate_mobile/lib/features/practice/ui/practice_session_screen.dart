import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/practice_models.dart';
import '../providers/practice_providers.dart';
import 'practice_mode_specs.dart';
import 'modes/mode_common.dart';
import 'modes/practice_mode_view.dart';
import 'modes/flashcards_mode_view.dart';
import 'modes/speed_round_mode_view.dart';
import 'modes/exam_prep_mode_view.dart';
import 'modes/concept_builder_mode_view.dart';
import 'modes/adaptive_mode_view.dart';
import 'modes/bagrut_mode_view.dart';

Color _sessionPanelBorder(ColorScheme cs) {
  return cs.brightness == Brightness.dark
      ? cs.outlineVariant.withValues(alpha: 0.32)
      : cs.outlineVariant.withValues(alpha: 0.44);
}

Color _sessionPanelBg(ColorScheme cs, Color accent) {
  return cs.brightness == Brightness.dark
      ? Color.alphaBlend(
          accent.withValues(alpha: 0.10),
          cs.surfaceContainerHigh,
        )
      : Color.alphaBlend(accent.withValues(alpha: 0.05), cs.surface);
}

String _friendlyModeLoadingTitle(String mode) {
  switch (mode.toLowerCase()) {
    case 'practice':
      return 'Building your practice session';
    case 'flashcards':
      return 'Shuffling your flashcards';
    case 'speed round':
    case 'speedround':
      return 'Starting the speed round';
    case 'exam prep':
    case 'examprep':
      return 'Preparing your exam session';
    case 'concept builder':
    case 'conceptbuilder':
      return 'Loading concept coach';
    case 'adaptive':
      return 'Personalizing your challenge';
    case 'bagrut':
      return 'Preparing your Bagrut set';
    default:
      return 'Preparing your session';
  }
}

Color _sessionAccentFromModeLabel(String mode) {
  switch (mode.toLowerCase()) {
    case 'practice':
      return const Color(0xFF2563EB);
    case 'flashcards':
      return const Color(0xFF7C3AED);
    case 'speed round':
    case 'speedround':
      return const Color(0xFFF59E0B);
    case 'exam prep':
    case 'examprep':
      return const Color(0xFF14B8A6);
    case 'concept builder':
    case 'conceptbuilder':
      return const Color(0xFF4F46E5);
    case 'adaptive':
      return const Color(0xFFEC4899);
    case 'bagrut':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF2563EB);
  }
}

class PracticeSessionRouteHelper {
  static Route<void> get screen => PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const PracticeSessionScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
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

    if (loading && state.questions.isEmpty && !state.isComplete) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Stacked')),
                          ButtonSegment(value: true, label: Text('Focus')),
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

                OutlinedButton.icon(
                  onPressed: () async {
                    await sessionCtl.cancelGeneration();
                    if (!context.mounted) return;
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Stop Generating'),
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.16),
                      accent.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _sessionPanelBorder(cs)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 54, color: accent),
                    const SizedBox(height: 12),
                    Text(
                      '${practiceModeLabel(state.filter.mode)} complete',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricPill(label: 'Answered', value: '$answered'),
                        _MetricPill(label: 'Correct', value: '$correct'),
                        _MetricPill(label: 'Wrong', value: '$wrong'),
                        _MetricPill(label: 'Accuracy', value: '$accuracy%'),
                        _MetricPill(label: 'Total', value: '$total'),
                        _MetricPill(label: 'XP', value: '${state.stats.xp}'),
                        _MetricPill(
                          label: 'Streak',
                          value: '${state.stats.streak}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      practiceModeDescription(state.filter.mode),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.filter.subject} • ${state.filter.topicLabel}',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _reviewFilter == _ReviewFilter.all,
                          onSelected: (_) {
                            setState(() {
                              _reviewFilter = _ReviewFilter.all;
                              _reviewIndex = 0;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Wrong'),
                          selected: _reviewFilter == _ReviewFilter.wrong,
                          onSelected: (_) {
                            setState(() {
                              _reviewFilter = _ReviewFilter.wrong;
                              _reviewIndex = 0;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Correct'),
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
                'Session review',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (reviewQuestions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Text(
                    'No questions match this filter yet.',
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
                    : 'No answer';
                final correctLabel =
                    (question.correctIndex >= 0 &&
                        question.correctIndex < question.options.length)
                    ? question.options[question.correctIndex]
                    : 'Unknown';
                final isCorrect = result?.isCorrect ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.withValues(alpha: 0.30)
                            : cs.outlineVariant.withValues(alpha: 0.32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                question.topicLabel,
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
                        MathView(
                          question.prompt,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your answer',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MathView(selectedLabel, compact: true),
                        const SizedBox(height: 10),
                        Text(
                          'Correct answer',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MathView(correctLabel, compact: true),
                        const SizedBox(height: 10),
                        Text(
                          'Explanation',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MathView(question.explanation, compact: true),
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
                label: const Text('Back to setup'),
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
                      _MiniPill(label: state.filter.subject),
                      _MiniPill(
                        label: state.filter.topicPath.isEmpty
                            ? 'General'
                            : state.filter.topicPath.join(' • '),
                      ),
                      _MiniPill(
                        label: state.filter.difficulty
                            .toString()
                            .split('.')
                            .last,
                      ),
                      _MiniPill(label: practiceModeLabel(state.filter.mode)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Question ${state.currentIndex + 1} of ${state.questions.length}',
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
                      _MetricPill(
                        label: 'Time',
                        value: '${state.secondsRemaining}s',
                      ),
                      _MetricPill(label: 'XP', value: '${state.stats.xp}'),
                      _MetricPill(
                        label: 'Streak',
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
        color: cs.surface.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.brightness == Brightness.dark
              ? cs.outlineVariant.withValues(alpha: 0.30)
              : cs.outlineVariant.withValues(alpha: 0.40),
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
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: cs.brightness == Brightness.dark
              ? cs.outlineVariant.withValues(alpha: 0.30)
              : cs.outlineVariant.withValues(alpha: 0.40),
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
    final accent = _sessionAccentFromModeLabel(mode);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(accent.withValues(alpha: .12), cs.surface),
                cs.surface,
                Color.alphaBlend(accent.withValues(alpha: .06), cs.surface),
              ],
            ),
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
                    color: cs.surface.withValues(alpha: .92),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: accent.withValues(alpha: .22)),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: .10),
                        blurRadius: 28,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: accent.withValues(alpha: .12),
                        child: Icon(
                          practiceModeIcon(
                            PracticeMode.values.firstWhere(
                              (m) =>
                                  practiceModeLabel(m).toLowerCase() ==
                                  mode.toLowerCase(),
                              orElse: () => PracticeMode.practice,
                            ),
                          ),
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
                        _friendlyModeLoadingTitle(mode),
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
                        "Difficulty: $difficulty",
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
                            accent.withValues(alpha: .08),
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
                            color: accent.withValues(alpha: .28),
                          ),
                        ),
                        onPressed: onCancel,
                        icon: Icon(Icons.close_rounded, color: accent),
                        label: const Text("Stop generating"),
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
