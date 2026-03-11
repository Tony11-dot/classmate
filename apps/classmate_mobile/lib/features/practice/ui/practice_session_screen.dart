import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/math/math_view.dart';
import '../domain/practice_models.dart';
import '../providers/practice_providers.dart';
import '../providers/saved_questions_provider.dart';
import '../theme/mode_theme.dart';
import '../../tutor/ui/nova_chat_screen.dart';

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
        return 'Adaptive';
      case PracticeMode.practice:
        return 'Practice';
      case PracticeMode.bagrut:
        return 'Bagrut';
    }
  }

  String _modeHint(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.flashcards:
        return 'Reveal-first study mode. Check yourself, then continue.';
      case PracticeMode.speedRound:
        return 'Arcade sprint. Fast answers, quick transition, high energy.';
      case PracticeMode.examPrep:
        return 'Formal exam rhythm with cleaner, calmer solving.';
      case PracticeMode.conceptBuilder:
        return 'Explanation-first learning. Slow down and absorb the rule.';
      case PracticeMode.adaptive:
        return 'Dynamic challenge with shifting pressure and pacing.';
      case PracticeMode.practice:
        return 'Balanced daily practice with full feedback.';
      case PracticeMode.bagrut:
        return 'One real exam-style question. No timer pressure, no lives.';
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
        return Icons.auto_awesome_rounded;
      case PracticeMode.practice:
        return Icons.tune_rounded;
      case PracticeMode.bagrut:
        return Icons.description_rounded;
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
If the learner uploads a photo later, compare their work against the official solution.
''';
  }

  Future<void> _openNova(
    BuildContext context,
    PracticeQuestion? q,
    PracticeSessionState state,
  ) async {
    if (q == null) {
      return;
    }

    final prompt = _buildNovaPrompt(q, state);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            NovaChatScreen(initialTitle: q.topicLabel, initialPrompt: prompt),
      ),
    );
  }

  void _bindQuestion(PracticeQuestion? q) {
    final currentQuestionId = q?.id.toString();
    if (currentQuestionId == null) return;
    if (_boundQuestionId == currentQuestionId) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
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
      if (!mounted) {
        return;
      }
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
    final q = state.currentQuestion;
    final mode = state.filter.mode;
    final accent = modeColor(mode, cs);
    final tinted = modeSurface(mode, cs);

    if (state.questions.isEmpty && !state.isComplete) {
      return Scaffold(
        appBar: null,
        bottomNavigationBar: null,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (state.isComplete) {
      return Scaffold(
        appBar: null,
        bottomNavigationBar: null,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: tinted,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: accent.withValues(alpha: 0.28)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 54, color: accent),
                    const SizedBox(height: 12),
                    Text(
                      mode == PracticeMode.bagrut
                          ? 'Bagrut question complete'
                          : 'Practice complete',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Answered ${state.stats.answered} • Correct ${state.stats.correct} • XP ${state.stats.xp}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back to setup'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    _bindQuestion(q);

    final options = _optionsOf(q);
    final isFlashcards = mode == PracticeMode.flashcards;
    final isBagrut = mode == PracticeMode.bagrut;
    final isSpeed = mode == PracticeMode.speedRound;
    final isConcept = mode == PracticeMode.conceptBuilder;
    final isExam = mode == PracticeMode.examPrep;

    return Scaffold(
      appBar: null,
      bottomNavigationBar: null,
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tinted,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withValues(alpha: 0.26)),
                  boxShadow: isSpeed
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.18),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_modeIcon(mode), color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _modeHeadline(mode),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _modeHint(mode),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('End'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (!isBagrut)
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: state.questions.isEmpty
                                ? 0
                                : (state.currentIndex + 1) /
                                      state.questions.length,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${state.currentIndex + 1}/${state.questions.length}',
                        ),
                      ],
                    ),
                  if (!isBagrut) const SizedBox(height: 14),
                  if (!isBagrut)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TopPill(label: state.filter.subject),
                        _TopPill(
                          label: q?.topicLabel ?? state.filter.topicLabel,
                        ),
                        if (!state.filter.hasInfiniteLives && !isFlashcards)
                          _TopPill(label: '${state.filter.maxLives} lives'),
                        if (!isBagrut)
                          _TopPill(label: '${state.secondsRemaining}s'),
                      ],
                    ),
                  const SizedBox(height: 14),
                  Container(
                    padding: EdgeInsets.all(isBagrut ? 22 : 18),
                    decoration: BoxDecoration(
                      color: isExam || isBagrut
                          ? cs.surface
                          : tinted.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(isBagrut ? 28 : 24),
                      border: Border.all(
                        color: accent.withValues(alpha: isBagrut ? 0.30 : 0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isBagrut)
                          Row(
                            children: [
                              Icon(Icons.menu_book_rounded, color: accent),
                              const SizedBox(width: 8),
                              Text(
                                'Real Bagrut question',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        if (isBagrut) const SizedBox(height: 14),
                        isBagrut
                            ? MathView(
                                _promptOf(q),
                                textStyle: theme.textTheme.titleMedium
                                    ?.copyWith(
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    ),
                              )
                            : SelectableText(
                                _promptOf(q),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: isConcept
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  height: 1.4,
                                ),
                              ),
                        if (isConcept) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Concept mode: pause and explain the rule before you answer.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isFlashcards) ...[
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _flashcardRevealed = true;
                          _showExplanation = true;
                        });
                      },
                      icon: const Icon(Icons.visibility_rounded),
                      label: Text(
                        _flashcardRevealed ? 'Revealed' : 'Reveal answer',
                      ),
                    ),
                    if (_flashcardRevealed) ...[
                      const SizedBox(height: 12),
                      _AnswerCard(
                        accent: accent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Correct answer',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(options[q?.correctIndex ?? 0]),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: q == null
                                        ? null
                                        : () => _submitFlashcard(
                                            sessionCtl,
                                            q,
                                            knewIt: true,
                                          ),
                                    child: const Text('I knew it'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: q == null
                                        ? null
                                        : () => _submitFlashcard(
                                            sessionCtl,
                                            q,
                                            knewIt: false,
                                          ),
                                    child: const Text('Need review'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else if (isBagrut) ...[
                    _AnswerCard(
                      accent: accent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bagrut actions',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () async {
                              await _openNova(context, q, state);
                            },
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: const Text('Take to NOVA'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showExplanation = true;
                              });
                            },
                            icon: const Icon(Icons.rule_folder_rounded),
                            label: const Text('Show official solution'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: q == null
                                ? null
                                : () {
                                    savedCtl.toggle(q);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Saved for later'),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.bookmark_add_rounded),
                            label: const Text('Save for later'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    
if (isSpeed) ...[
  GridView.count(
    shrinkWrap: true,
    crossAxisCount: 2,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.4,
    physics: NeverScrollableScrollPhysics(),
    children: List.generate(options.length, (index) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: hasAnswered ? null : () {
          setState(() { _selectedIndex = index; });
          sessionCtl.submit(index);
        },
        child: Text(options[index], textAlign: TextAlign.center),
      );
    }),
  ),
] else if (isExam) ...[
  ...List.generate(options.length, (index) {
    return RadioListTile(
      value: index,
      groupValue: _selectedIndex,
      onChanged: hasAnswered ? null : (v) {
        setState(() { _selectedIndex = index; });
        sessionCtl.submit(index);
      },
      title: Text(options[index]),
    );
  }),
] else if (isAdaptive) ...[
  Wrap(
    spacing: 10,
    runSpacing: 10,
    children: List.generate(options.length, (index) {
      return ChoiceChip(
        label: Text(options[index]),
        selected: _selectedIndex == index,
        onSelected: hasAnswered ? null : (_) {
          setState(() { _selectedIndex = index; });
          sessionCtl.submit(index);
        },
      );
    }),
  ),
] else ...[
  ...List.generate(options.length, (index) {

                      final isSelected = _selectedIndex == index;
                      final hasAnswered = state.lastResult != null;
                      final isCorrect = q != null && index == q.correctIndex;
                      final showCorrect = hasAnswered && isCorrect;
                      final showWrong = hasAnswered && isSelected && !isCorrect;

                      Color? bg;
                      if (showCorrect) {
                        bg = Colors.green.withValues(alpha: 0.14);
                      }
                      if (showWrong) {
                        bg = Colors.red.withValues(alpha: 0.12);
                      }
                      if (!hasAnswered && isSelected) {
                        bg = accent.withValues(alpha: 0.12);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: hasAnswered || q == null
                              ? null
                              : () {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                  sessionCtl.submit(index);
                                  _showExplanation = true;
                                  if (isSpeed) {
                                    _queueNext(sessionCtl);
                                  }
                                },
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: bg ?? cs.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: showCorrect
                                    ? Colors.green
                                    : showWrong
                                    ? Colors.redAccent
                                    : accent.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: accent.withValues(
                                    alpha: 0.14,
                                  ),
                                  child: Text(String.fromCharCode(65 + index)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    options[index],
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: isExam
                                          ? FontWeight.w500
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 12),
                  if (_showExplanation && q != null)
                    _AnswerCard(
                      accent: accent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBagrut ? 'Official solution' : 'Explanation',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (isBagrut)
                            MathView(_explanationOf(q))
                          else
                            SelectableText(
                              _explanationOf(q),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: () async {
                                  await _openNova(context, q, state);
                                },
                                icon: const Icon(Icons.auto_awesome_rounded),
                                label: const Text('Ask NOVA'),
                              ),
                              if (!isFlashcards && !isBagrut)
                                OutlinedButton.icon(
                                  onPressed: () => sessionCtl.nextQuestion(),
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('Next'),
                                ),
                            ],
                          ),
                        ],
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
}

class _TopPill extends StatelessWidget {
  final String label;
  const _TopPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final Widget child;
  final Color accent;

  const _AnswerCard({required this.child, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: child,
    );
  }
}
