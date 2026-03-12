import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/practice_models.dart';
import '../providers/practice_providers.dart';
import '../providers/saved_questions_provider.dart';
import '../../tutor/ui/nova_chat_screen.dart';

Color _modeAccent(PracticeMode mode) {
  switch (mode) {
    case PracticeMode.practice:
      return const Color(0xFF2563EB);
    case PracticeMode.flashcards:
      return const Color(0xFFF59E0B);
    case PracticeMode.speedRound:
      return const Color(0xFFEF4444);
    case PracticeMode.examPrep:
      return const Color(0xFF7C3AED);
    case PracticeMode.conceptBuilder:
      return const Color(0xFF14B8A6);
    case PracticeMode.adaptive:
      return const Color(0xFF4F46E5);
    case PracticeMode.bagrut:
      return const Color(0xFF16A34A);
  }
}

class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key});

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  int? _selectedIndex;
  bool _showExplanation = false;
  bool _flashcardRevealed = false;
  String? _boundQuestionId;
  Timer? _autoNextTimer;

  @override
  void dispose() {
    _autoNextTimer?.cancel();
    super.dispose();
  }

  String _promptOf(PracticeQuestion? q) => (q?.prompt ?? 'Question').toString();

  String _explanationOf(PracticeQuestion? q) {
    final txt = (q?.explanation ?? '').toString().trim();
    return txt.isEmpty ? 'No explanation available yet.' : txt;
  }

  List<String> _optionsOf(PracticeQuestion? q) {
    final raw = q?.options ?? const <String>[];
    return raw.map((e) => e.toString()).toList(growable: false);
  }

  String _modeHeadline(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.flashcards:
        return 'Flashcards';
      case PracticeMode.speedRound:
        return 'Speed round';
      case PracticeMode.examPrep:
        return 'Exam prep';
      case PracticeMode.conceptBuilder:
        return 'Concept builder';
      case PracticeMode.adaptive:
      case PracticeMode.bagrut:
        return 'Adaptive';
      case PracticeMode.practice:
        return 'Practice';
    }
  }

  String _modeHint(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.flashcards:
        return 'Memory-first mode. Reveal, self-check, then rate yourself.';
      case PracticeMode.speedRound:
        return 'Fast pressure reps. Lock in quickly and auto-move on.';
      case PracticeMode.examPrep:
        return 'Formal school-style solving with calmer pacing.';
      case PracticeMode.conceptBuilder:
        return 'Learn the rule first, then answer.';
      case PracticeMode.adaptive:
      case PracticeMode.bagrut:
        return 'Mixed challenge mode that shifts by topic feel and pacing.';
      case PracticeMode.practice:
        return 'Balanced daily practice with full feedback.';
    }
  }

  IconData _modeIcon(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.flashcards:
        return Icons.style_rounded;
      case PracticeMode.speedRound:
        return Icons.flash_on_rounded;
      case PracticeMode.examPrep:
        return Icons.assignment_rounded;
      case PracticeMode.conceptBuilder:
        return Icons.school_rounded;
      case PracticeMode.adaptive:
      case PracticeMode.bagrut:
        return Icons.auto_awesome_rounded;
      case PracticeMode.practice:
        return Icons.tune_rounded;
    }
  }

  Color _modeTint(ColorScheme cs, PracticeMode mode) {
    switch (mode) {
      case PracticeMode.flashcards:
        return cs.tertiary.withValues(alpha: 0.18);
      case PracticeMode.speedRound:
        return cs.error.withValues(alpha: 0.14);
      case PracticeMode.examPrep:
        return cs.primary.withValues(alpha: 0.18);
      case PracticeMode.conceptBuilder:
        return cs.secondary.withValues(alpha: 0.18);
      case PracticeMode.adaptive:
      case PracticeMode.bagrut:
        return cs.secondaryContainer.withValues(alpha: 0.30);
      case PracticeMode.practice:
        return cs.surfaceContainerHighest.withValues(alpha: 0.45);
    }
  }

  String _buildNovaPrompt(PracticeQuestion q, PracticeSessionState state) {
    final optionsText = q.options
        .asMap()
        .entries
        .map((e) => '${String.fromCharCode(65 + e.key)}. ${e.value}')
        .join('\n');

    return '''
You are helping with a ClassMate practice question.

Subject: ${state.filter.subject}
Topic: ${state.filter.topicPath.isEmpty ? 'General' : state.filter.topicPath.join(' • ')}
Mode: ${state.filter.mode.name}
Difficulty: ${state.filter.difficulty.name}

Question:
${q.prompt}

Options:
$optionsText

Reference explanation:
${q.explanation}

Give a helpful step-by-step explanation.
If this is bagrut mode, solve it formally like a school exam solution.
If the learner made a mistake, point out exactly what was wrong.
''';
  }

  Future<void> _openNova(
    BuildContext context,
    PracticeQuestion? q,
    PracticeSessionState state,
  ) async {
    if (q == null) return;

    final prompt = _buildNovaPrompt(q, state);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NovaChatScreen(
          initialTitle: (q.topicLabel).toString(),
          initialPrompt: prompt,
        ),
      ),
    );
  }

  void _bindQuestion(PracticeQuestion? q) {
    final currentQuestionId = q?.id.toString();
    if (currentQuestionId == null) return;
    if (_boundQuestionId == currentQuestionId) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _boundQuestionId = currentQuestionId;
        _selectedIndex = null;
        _showExplanation = false;
        _flashcardRevealed = false;
      });
    });
  }

  void _queueNext(PracticeSessionController sessionCtl) {
    _autoNextTimer?.cancel();
    _autoNextTimer = Timer(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      sessionCtl.nextQuestion();
      setState(() {
        _selectedIndex = null;
        _showExplanation = false;
        _flashcardRevealed = false;
      });
    });
  }

  void _submitFlashcard(
    PracticeSessionController sessionCtl,
    PracticeQuestion q, {
    required bool knewIt,
  }) {
    final wrongIndex = q.options.isEmpty
        ? 0
        : (q.correctIndex + 1) % q.options.length;

    sessionCtl.submit(knewIt ? q.correctIndex : wrongIndex);

    setState(() {
      _showExplanation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceSessionProvider);
    final sessionCtl = ref.read(practiceSessionProvider.notifier);
    final savedCtl = ref.read(savedQuestionsProvider.notifier);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final mode = state.filter.mode;
    final accent = _modeAccent(mode);
    if (state.questions.isEmpty && !state.isComplete) {
      return Scaffold(
        backgroundColor: Color.alphaBlend(
          accent.withValues(alpha: 0.04),
          cs.surface,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
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
      return Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _modeTint(cs, mode),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.32),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 54, color: accent),
                    const SizedBox(height: 12),
                    Text(
                      'Practice complete',
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
                          label: 'Answered',
                          value: '${state.stats.answered}',
                        ),
                        _MetricPill(
                          label: 'Correct',
                          value: '${state.stats.correct}',
                        ),
                        _MetricPill(label: 'XP', value: '${state.stats.xp}'),
                        _MetricPill(
                          label: 'Streak',
                          value: '${state.stats.streak}',
                        ),
                        _MetricPill(
                          label: 'Mode',
                          value: _modeHeadline(state.filter.mode),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          setState(() {
                            _selectedIndex = null;
                            _showExplanation = false;
                            _flashcardRevealed = false;
                          });
                          await sessionCtl.start(state.filter);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Run again'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final q = state.currentQuestion;
    _bindQuestion(q);

    final options = _optionsOf(q);
    final isSaved = q != null && savedCtl.isSaved(q.id);
    final progress = state.questions.isEmpty
        ? 0.0
        : ((state.currentIndex + 1) / state.questions.length).clamp(0.0, 1.0);

    final answered = q != null && state.answersByQuestionId.containsKey(q.id);
    final result = q == null ? null : state.answersByQuestionId[q.id];
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _modeTint(cs, mode),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniPill(label: state.filter.subject),
                      _MiniPill(
                        label: state.filter.topicPath.isEmpty
                            ? 'General'
                            : state.filter.topicPath.join(' • '),
                      ),
                      _MiniPill(label: state.filter.difficulty.name),
                      _MiniPill(label: _modeHeadline(mode)),
                      _MiniPill(
                        label: state.filter.useAiTiming
                            ? 'AI timing'
                            : '${state.filter.timePreferenceSeconds ?? 20}s / q',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(_modeIcon(mode), color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _modeHint(mode),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Question ${state.currentIndex + 1} of ${state.questions.length}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'End Quiz',
                        onPressed: () async {
                          final shouldEnd = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('End quiz?'),
                              content: const Text(
                                'Your current progress will be closed.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('End Quiz'),
                                ),
                              ],
                            ),
                          );
                          if (shouldEnd == true && context.mounted) {
                            Navigator.of(context).maybePop();
                          }
                        },
                        icon: Icon(Icons.flag_rounded, color: accent),
                      ),
                    ],
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
                      if (mode != PracticeMode.examPrep)
                        _MetricPill(
                          label: 'Time',
                          value: '${state.secondsRemaining}s',
                        ),
                      _MetricPill(label: 'XP', value: '${state.stats.xp}'),
                      _MetricPill(
                        label: 'Correct',
                        value: '${state.stats.correct}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  accent.withValues(alpha: 0.06),
                  cs.surfaceContainerHigh,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mode == PracticeMode.examPrep)
                    Text(
                      'Bagrut-style prompt',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                      ),
                    ),
                  if (mode == PracticeMode.examPrep) const SizedBox(height: 8),
                  Text(
                    _promptOf(q),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  if (mode == PracticeMode.conceptBuilder) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          accent.withValues(alpha: 0.10),
                          cs.secondaryContainer.withValues(alpha: 0.55),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Text(
                        _explanationOf(q),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (q != null && mode == PracticeMode.flashcards)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    accent.withValues(alpha: 0.04),
                    cs.surfaceContainerHigh,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.28),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _flashcardRevealed = true;
                          });
                        },
                        icon: const Icon(Icons.visibility_rounded),
                        label: Text(
                          _flashcardRevealed
                              ? 'Answer revealed'
                              : 'Reveal answer',
                        ),
                      ),
                    ),
                    if (_flashcardRevealed) ...[
                      const SizedBox(height: 16),
                      ...options.asMap().entries.map((entry) {
                        final i = entry.key;
                        final isCorrect = i == q.correctIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AnswerTile(
                            mode: mode,
                            label: entry.value,
                            selected: isCorrect,
                            correct: isCorrect,
                            onTap: null,
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: answered
                                  ? null
                                  : () => _submitFlashcard(
                                      sessionCtl,
                                      q,
                                      knewIt: false,
                                    ),
                              icon: const Icon(Icons.close_rounded),
                              label: const Text("Didn't know it"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: answered
                                  ? null
                                  : () => _submitFlashcard(
                                      sessionCtl,
                                      q,
                                      knewIt: true,
                                    ),
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Knew it'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                ),
                child: mode == PracticeMode.speedRound
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: options.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.8,
                            ),
                        itemBuilder: (context, index) {
                          final entry = options[index];
                          return _AnswerTile(
                            label: entry,
                            mode: mode,
                            selected: _selectedIndex == index,
                            correct: answered
                                ? (index == q.correctIndex)
                                : null,
                            onTap: answered
                                ? null
                                : () {
                                    setState(() {
                                      _selectedIndex = index;
                                      _showExplanation = true;
                                    });
                                    sessionCtl.submit(index);
                                    _queueNext(sessionCtl);
                                  },
                          );
                        },
                      )
                    : Column(
                        children: [
                          for (final entry in options.asMap().entries)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _AnswerTile(
                                mode: mode,
                                label: entry.value,
                                selected: _selectedIndex == entry.key,
                                correct: answered
                                    ? (entry.key == q.correctIndex)
                                    : null,
                                onTap: answered
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedIndex = entry.key;
                                          _showExplanation = true;
                                        });
                                        sessionCtl.submit(entry.key);
                                      },
                              ),
                            ),
                        ],
                      ),
              ),
            if ((answered || _showExplanation) &&
                mode != PracticeMode.flashcards) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: (result?.isCorrect ?? false)
                      ? accent.withValues(alpha: 0.12)
                      : cs.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (result?.isCorrect ?? false) ? 'Nice.' : 'Review',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _explanationOf(q),
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
            if (answered && mode == PracticeMode.flashcards) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: (result?.isCorrect ?? false)
                      ? accent.withValues(alpha: 0.12)
                      : cs.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  _explanationOf(q),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: q == null
                        ? null
                        : () {
                            savedCtl.toggle(q);
                          },
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                    label: Text(isSaved ? 'Saved' : 'Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: q == null
                        ? null
                        : () => _openNova(context, q, state),
                    icon: const Icon(Icons.psychology_alt_rounded),
                    label: const Text('Open in NOVA'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.currentIndex > 0
                        ? () {
                            sessionCtl.previousQuestion();
                            setState(() {
                              _selectedIndex = null;
                              _showExplanation = false;
                              _flashcardRevealed = false;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (!answered && mode != PracticeMode.flashcards)
                        ? null
                        : () {
                            sessionCtl.nextQuestion();
                            setState(() {
                              _selectedIndex = null;
                              _showExplanation = false;
                              _flashcardRevealed = false;
                            });
                          },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      state.currentIndex + 1 >= state.questions.length
                          ? 'Finish'
                          : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.mode,
    this.correct,
  });

  final String label;
  final bool selected;
  final bool? correct;
  final VoidCallback? onTap;
  final PracticeMode mode;

  Color _accent(ColorScheme cs) {
    switch (mode) {
      case PracticeMode.speedRound:
        return const Color(0xFFFF6B3D);
      case PracticeMode.flashcards:
        return const Color(0xFFF59E0B);
      case PracticeMode.examPrep:
      case PracticeMode.bagrut:
        return const Color(0xFF7C3AED);
      case PracticeMode.conceptBuilder:
        return const Color(0xFF10B981);
      case PracticeMode.adaptive:
        return const Color(0xFF4F46E5);
      case PracticeMode.practice:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = _accent(cs);

    final Color bg = switch (correct) {
      true => accent.withValues(alpha: 0.18),
      false => cs.error.withValues(alpha: 0.14),
      null =>
        selected
            ? accent.withValues(alpha: 0.10)
            : cs.surfaceContainerHigh.withValues(alpha: 0.45),
    };

    final Color border = switch (correct) {
      true => accent,
      false => cs.error,
      null => selected ? accent : cs.outlineVariant.withValues(alpha: 0.34),
    };

    final Color textColor = switch (correct) {
      true => accent,
      false => cs.error,
      null => cs.onSurface,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border, width: selected ? 1.6 : 1.0),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
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
        color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
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
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
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
