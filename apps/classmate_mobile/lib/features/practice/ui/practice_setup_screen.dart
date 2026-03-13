import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/practice_prompt_builder.dart';

import '../domain/practice_models.dart';
import '../domain/practice_mode_behavior.dart';
import 'practice_mode_specs.dart';
import '../providers/practice_providers.dart';
import '../domain/timing_mode.dart';
import 'practice_session_screen.dart';
import 'practice_history_screen.dart';
import 'practice_analytics_debug_screen.dart';

const Map<String, List<List<String>>> practiceSubjectCatalog = {
  'Math': [
    ['Algebra'],
    ['Algebra', 'Linear equations'],
    ['Algebra', 'Quadratic equations'],
    ['Algebra', 'Functions'],
    ['Geometry'],
    ['Geometry', 'Triangles'],
    ['Geometry', 'Circles'],
    ['Geometry', 'Analytic geometry'],
    ['Trigonometry'],
    ['Probability'],
    ['Statistics'],
    ['Sequences'],
    ['Calculus', 'Limits'],
    ['Calculus', 'Derivatives'],
  ],
  'Physics': [
    ['Mechanics'],
    ['Mechanics', 'Kinematics'],
    ['Mechanics', 'Newton laws'],
    ['Mechanics', 'Forces'],
    ['Mechanics', 'Energy'],
    ['Mechanics', 'Momentum'],
    ['Electricity'],
    ['Electricity', 'Electric field'],
    ['Electricity', 'Circuits'],
    ['Waves'],
    ['Optics'],
    ['Thermodynamics'],
  ],
  'Computer Science': [
    ['Conditions'],
    ['Conditions', 'Boolean logic'],
    ['Conditions', 'if / else'],
    ['Conditions', 'Nested conditions'],
    ['Loops'],
    ['Functions'],
    ['Variables'],
    ['Arrays'],
    ['Strings'],
    ['Algorithms'],
    ['Complexity'],
    ['Recursion'],
  ],
  'Chemistry': [
    ['Atoms'],
    ['Periodic table'],
    ['Chemical bonds'],
    ['Reactions'],
    ['Stoichiometry'],
    ['Acids and bases'],
    ['Organic chemistry'],
  ],
  'Biology': [
    ['Cells'],
    ['Genetics'],
    ['Human body'],
    ['Ecology'],
    ['Evolution'],
    ['Systems'],
  ],
  'English': [
    ['Grammar'],
    ['Reading comprehension'],
    ['Vocabulary'],
    ['Tenses'],
    ['Writing'],
  ],
  'Arabic': [
    ['Grammar'],
    ['Reading comprehension'],
    ['بلاغة'],
    ['Vocabulary'],
    ['Writing'],
  ],
  'Hebrew': [
    ['Grammar'],
    ['Reading comprehension'],
    ['Vocabulary'],
    ['Writing'],
  ],
};

String practiceDifficultyLabel(PracticeDifficulty difficulty) {
  switch (difficulty) {
    case PracticeDifficulty.easy:
      return 'Easy';
    case PracticeDifficulty.medium:
      return 'Medium';
    case PracticeDifficulty.hard:
      return 'Hard';
    case PracticeDifficulty.olympiad:
      return 'Olympiad';
    case PracticeDifficulty.adaptive:
      return 'Adaptive';
  }
}

String _modeHelpText(PracticeMode mode) {
  switch (mode) {
    case PracticeMode.practice:
      return 'Balanced mode: solve, check, explain, then keep moving.';
    case PracticeMode.flashcards:
      return 'Flashcards work best when you try to recall before revealing.';
    case PracticeMode.speedRound:
      return 'Speed Round trains fast recall. Move quickly and trust strong instincts.';
    case PracticeMode.examPrep:
      return 'Exam Prep is calmer and more formal, like a real school session.';
    case PracticeMode.conceptBuilder:
      return 'Concept Builder teaches the idea first, then asks you to apply it.';
    case PracticeMode.adaptive:
      return 'Adaptive mode changes the challenge level based on your performance.';
    case PracticeMode.bagrut:
      return 'Bagrut mode focuses on strict exam-style solving and review.';
  }
}

class PracticeSetupScreen extends ConsumerStatefulWidget {
  const PracticeSetupScreen({super.key});

  @override
  ConsumerState<PracticeSetupScreen> createState() =>
      _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends ConsumerState<PracticeSetupScreen> {
  TimingMode _timingMode = TimingMode.ai;
  TimingScope _timingScope = TimingScope.perQuestion;
  int _customPerQuestionSeconds = 45;
  int _customExamMinutes = 20;

  int _modeGridCount(BuildContext context) {
    return 2;
  }

  double _modeChildAspectRatio(BuildContext context) {
    return 1.08;
  }

  Future<void> _showModeInfoSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'How each mode works',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: PracticeMode.values.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final mode = PracticeMode.values[index];
                      final accent = practiceModeColor(mode);

                      return Container(
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            accent.withValues(alpha: 0.08),
                            cs.surface,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Theme(
                          data: theme.copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              14,
                              0,
                              14,
                              14,
                            ),
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                practiceModeIcon(mode),
                                color: accent,
                              ),
                            ),
                            title: Text(
                              practiceModeLabel(mode),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              practiceModeSubtitle(mode),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _modeHelpText(mode),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(practiceFilterProvider);
    final behavior = behaviorForMode(filter.mode);

    final filterCtl = ref.read(practiceFilterProvider.notifier);
    final sessionCtl = ref.read(practiceSessionProvider.notifier);
    final loading = ref.watch(practiceSessionLoadingProvider);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final subjectOptions = practiceSubjectCatalog.keys.toList(growable: true);
    if (!subjectOptions.contains('General Knowledge')) {
      subjectOptions.add('General Knowledge');
    }
    final topicOptions =
        practiceSubjectCatalog[filter.subject] ??
        const <List<String>>[
          ['General'],
        ];

    final selectedTopicPath =
        topicOptions.any((x) => _samePath(x, filter.topicPath))
        ? filter.topicPath
        : topicOptions.first;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            _HeroCard(
              title: 'Start a session',
              subtitle: 'Choose a mode, timing, and difficulty.',
              accent: cs.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MiniPill(label: filter.subject),
                      _MiniPill(label: filter.topicLabel),
                      _MiniPill(label: practiceModeLabel(filter.mode)),
                      _MiniPill(
                        label: practiceDifficultyLabel(filter.difficulty),
                      ),
                      _MiniPill(
                        label: filter.hasInfiniteLives
                            ? 'Infinite lives'
                            : '${filter.maxLives} lives',
                      ),
                      _MiniPill(
                        label: filter.useAiTiming
                            ? 'AI timing'
                            : '${filter.timePreferenceSeconds ?? 15}s',
                      ),
                      _MiniPill(label: '${filter.questionCount} questions'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    buildPracticePromptSummary(filter),
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Subject & topic',
              child: Column(
                children: [
                  _LiquidField(
                    label: 'Subject',
                    value: filter.subject,
                    hint: 'Pick the subject',
                    leading: Icons.menu_book_rounded,
                    onTap: () async {
                      final picked = await _pickString(
                        context,
                        title: 'Choose subject',
                        items: subjectOptions,
                      );
                      if (picked == null) return;
                      final nextTopics =
                          practiceSubjectCatalog[picked] ??
                          const <List<String>>[
                            ['General'],
                          ];
                      filterCtl.patch(
                        subject: picked,
                        topicPath: nextTopics.first,
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  _LiquidField(
                    label: 'Custom subject',
                    value: filter.subject,
                    hint: 'Type your own subject',
                    leading: Icons.edit_note_rounded,
                    onTap: () async {
                      final controller = TextEditingController(
                        text: filter.subject,
                      );
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Custom subject'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Enter subject',
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                Navigator.of(context).pop(value),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(controller.text),
                              child: const Text('Use'),
                            ),
                          ],
                        ),
                      );
                      final next = result?.trim();
                      if (next == null || next.isEmpty) return;
                      filterCtl.patch(
                        subject: next,
                        topicPath: const ['General'],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _LiquidField(
                    label: 'Topic',
                    value: selectedTopicPath.join(' · '),
                    hint: 'Pick sub-topic',
                    leading: Icons.account_tree_rounded,
                    onTap: () async {
                      final picked = await _pickPath(
                        context,
                        title: 'Choose topic',
                        items: topicOptions,
                      );
                      if (picked == null) return;
                      filterCtl.patch(topicPath: picked);
                    },
                  ),
                  const SizedBox(height: 6),
                  _LiquidField(
                    label: 'Custom topic',
                    value: filter.topicPath.join(' · '),
                    hint: 'Type your own topic',
                    leading: Icons.edit_note_rounded,
                    onTap: () async {
                      final controller = TextEditingController(
                        text: filter.topicPath.join(' · '),
                      );
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Custom topic'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Enter topic',
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                Navigator.of(context).pop(value),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(controller.text),
                              child: const Text('Use'),
                            ),
                          ],
                        ),
                      );
                      final next = result?.trim();
                      if (next == null || next.isEmpty) return;

                      final parsedPath = next
                          .split(RegExp(r'\s*(?:>|/|\\|·|•|-)\s*'))
                          .map((x) => x.trim())
                          .where((x) => x.isNotEmpty)
                          .toList();

                      filterCtl.patch(
                        topicPath: parsedPath.isEmpty ? [next] : parsedPath,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Mode',
              trailing: GestureDetector(
                onTap: () => _showModeInfoSheet(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: PracticeMode.values.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _modeGridCount(context),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: _modeChildAspectRatio(context),
                    ),
                    itemBuilder: (context, index) {
                      final mode = PracticeMode.values[index];
                      return _ModeTile(
                        mode: mode,
                        selected: filter.mode == mode,
                        onTap: () {
                          final nextBehavior = behaviorForMode(mode);

                          setState(() {
                            if (!nextBehavior.allowTimer) {
                              _timingMode = TimingMode.infinite;
                            } else if (nextBehavior.aiTiming) {
                              _timingMode = TimingMode.ai;
                            } else if (nextBehavior.perQuestionTimingOnly) {
                              _timingScope = TimingScope.perQuestion;
                              if (_timingMode == TimingMode.ai) {
                                _timingMode = TimingMode.custom;
                              }
                            } else if (nextBehavior.perQuizTimingOnly) {
                              _timingScope = TimingScope.exam;
                              if (_timingMode == TimingMode.ai) {
                                _timingMode = TimingMode.custom;
                              }
                            }

                            if (!nextBehavior.allowLives) {
                              filterCtl.patch(
                                hasInfiniteLives: true,
                                maxLives: 3,
                              );
                            }
                          });

                          filterCtl.patch(mode: mode);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Difficulty',
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.18),
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final difficulty in PracticeDifficulty.values)
                      _DifficultyPill(
                        label: practiceDifficultyLabel(difficulty),
                        selected: filter.difficulty == difficulty,
                        onTap: () => filterCtl.patch(difficulty: difficulty),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Session controls',
              child: Column(
                children: [
                  _StepperRow(
                    title: 'Questions',
                    caption: 'How many generated questions to include',
                    value: '${filter.questionCount}',
                    onMinus: () {
                      final next = filter.questionCount > 1
                          ? filter.questionCount - 1
                          : 1;
                      filterCtl.patch(questionCount: next);
                    },
                    onPlus: () {
                      final next = filter.questionCount < 25
                          ? filter.questionCount + 1
                          : 25;
                      filterCtl.patch(questionCount: next);
                    },
                    onSubmitted: (raw) {
                      final parsed = int.tryParse(raw.trim());
                      if (parsed == null) return;
                      final next = parsed.clamp(1, 25);
                      filterCtl.patch(questionCount: next);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (behavior.allowTimer) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.26),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Timing',
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose scope first, then AI, your own time, or infinite.',
                            style: text.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Per question'),
                                selected:
                                    _timingScope == TimingScope.perQuestion,
                                onSelected: behavior.perQuizTimingOnly
                                    ? null
                                    : (_) {
                                        setState(() {
                                          _timingScope =
                                              TimingScope.perQuestion;
                                        });
                                      },
                              ),
                              ChoiceChip(
                                label: const Text('Whole quiz'),
                                selected: _timingScope == TimingScope.exam,
                                onSelected: behavior.perQuestionTimingOnly
                                    ? null
                                    : (_) {
                                        setState(() {
                                          _timingScope = TimingScope.exam;
                                        });
                                      },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('AI'),
                                selected: _timingMode == TimingMode.ai,
                                onSelected: behavior.aiTiming
                                    ? (_) {
                                        setState(() {
                                          _timingMode = TimingMode.ai;
                                        });
                                      }
                                    : null,
                              ),
                              ChoiceChip(
                                label: const Text('My time'),
                                selected: _timingMode == TimingMode.custom,
                                onSelected: behavior.aiTiming
                                    ? null
                                    : (_) {
                                        setState(() {
                                          _timingMode = TimingMode.custom;
                                        });
                                      },
                              ),
                              ChoiceChip(
                                label: const Text('Infinite'),
                                selected: _timingMode == TimingMode.infinite,
                                onSelected: behavior.aiTiming
                                    ? null
                                    : (_) {
                                        setState(() {
                                          _timingMode = TimingMode.infinite;
                                        });
                                      },
                              ),
                            ],
                          ),
                          if (_timingMode == TimingMode.custom) ...[
                            const SizedBox(height: 12),
                            _StepperRow(
                              title: _timingScope == TimingScope.perQuestion
                                  ? 'Seconds per question'
                                  : 'Quiz minutes',
                              caption: _timingScope == TimingScope.perQuestion
                                  ? 'Your own timer for each question'
                                  : 'Your own timer for the whole quiz',
                              value: _timingScope == TimingScope.perQuestion
                                  ? '$_customPerQuestionSeconds'
                                  : '$_customExamMinutes',
                              onMinus: () {
                                setState(() {
                                  if (_timingScope == TimingScope.perQuestion) {
                                    _customPerQuestionSeconds =
                                        _customPerQuestionSeconds > 5
                                        ? _customPerQuestionSeconds - 5
                                        : 5;
                                  } else {
                                    _customExamMinutes = _customExamMinutes > 5
                                        ? _customExamMinutes - 5
                                        : 5;
                                  }
                                });
                              },
                              onPlus: () {
                                setState(() {
                                  if (_timingScope == TimingScope.perQuestion) {
                                    _customPerQuestionSeconds =
                                        _customPerQuestionSeconds < 600
                                        ? _customPerQuestionSeconds + 5
                                        : 600;
                                  } else {
                                    _customExamMinutes =
                                        _customExamMinutes < 300
                                        ? _customExamMinutes + 5
                                        : 300;
                                  }
                                });
                              },
                              onSubmitted: (raw) {
                                final parsed = int.tryParse(raw.trim());
                                if (parsed == null) return;
                                setState(() {
                                  if (_timingScope == TimingScope.perQuestion) {
                                    _customPerQuestionSeconds = parsed.clamp(
                                      5,
                                      600,
                                    );
                                  } else {
                                    _customExamMinutes = parsed.clamp(5, 300);
                                  }
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (behavior.allowLives)
                    _GlassToggleRow(
                      title: 'Infinite lives',
                      subtitle:
                          'Never end the session because of wrong answers',
                      value: filter.hasInfiniteLives,
                      onChanged: (value) {
                        if (!behavior.allowLives) return;
                        filterCtl.patch(hasInfiniteLives: value);
                      },
                    ),
                  if (!filter.hasInfiniteLives) ...[
                    const SizedBox(height: 12),
                    _StepperRow(
                      title: 'Lives',
                      caption: 'Mistakes allowed before the session ends',
                      value: '${filter.maxLives}',
                      onMinus: () {
                        final next = filter.maxLives > 1
                            ? filter.maxLives - 1
                            : 1;
                        filterCtl.patch(maxLives: next);
                      },
                      onPlus: () {
                        final next = filter.maxLives < 99
                            ? filter.maxLives + 1
                            : 99;
                        filterCtl.patch(maxLives: next);
                      },
                      onSubmitted: (raw) {
                        final parsed = int.tryParse(raw.trim());
                        if (parsed == null) return;
                        filterCtl.patch(maxLives: parsed.clamp(1, 99));
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                IconButton(
                  tooltip: 'Practice history',
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => const PracticeHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_rounded),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Practice analytics',
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => const PracticeAnalyticsDebugScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics_rounded),
                ),
                const SizedBox(width: 8),
                if (loading) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await sessionCtl.cancelGeneration();
                      },
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Stop Generating'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: loading
                        ? null
                        : () async {
                            var startFilter = _resolvedFilterForStart(filter)
                                .copyWith(
                                  hasInfiniteLives: filter.hasInfiniteLives,
                                  maxLives: filter.maxLives,
                                );

                            if (filter.mode == PracticeMode.bagrut) {
                              startFilter = startFilter.copyWith(
                                questionCount: 1,
                                useAiTiming: false,
                                timePreferenceSeconds: null,
                                maxLives: 1,
                                hasInfiniteLives: true,
                              );
                            }
                            Navigator.of(context, rootNavigator: true).push(
                              PageRouteBuilder<void>(
                                opaque: false,
                                barrierDismissible: false,
                                barrierColor: Colors.transparent,
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        PracticeSessionMatchmakingScreen(
                                          mode: practiceModeLabel(
                                            startFilter.mode,
                                          ),
                                          subject: startFilter.subject,
                                          difficulty: practiceDifficultyLabel(
                                            startFilter.difficulty,
                                          ),
                                          tip: _modeHelpText(startFilter.mode),
                                          onCancel: () async {
                                            await sessionCtl.cancelGeneration();
                                            if (context.mounted) {
                                              Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).pop();
                                            }
                                          },
                                        ),
                              ),
                            );

                            try {
                              await sessionCtl.start(startFilter);
                            } catch (e) {
                              if (context.mounted &&
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).canPop()) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              }
                              rethrow;
                            }

                            if (!context.mounted) return;

                            if (Navigator.of(
                              context,
                              rootNavigator: true,
                            ).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            final nextState = ref.read(practiceSessionProvider);
                            final stillLoading = ref.read(
                              practiceSessionLoadingProvider,
                            );
                            if (stillLoading || nextState.questions.isEmpty) {
                              return;
                            }

                            await Navigator.of(
                              context,
                              rootNavigator: true,
                            ).push(PracticeSessionRouteHelper.screen);
                          },
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(loading ? 'Generating...' : 'Start session'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PracticeFilter _resolvedFilterForStart(PracticeFilter filter) {
    return switch ((_timingScope, _timingMode)) {
      (TimingScope.perQuestion, TimingMode.ai) => filter.copyWith(
        useAiTiming: true,
        timePreferenceSeconds: null,
      ),
      (TimingScope.perQuestion, TimingMode.infinite) => filter.copyWith(
        useAiTiming: false,
        timePreferenceSeconds: null,
      ),
      (TimingScope.perQuestion, TimingMode.custom) => filter.copyWith(
        useAiTiming: false,
        timePreferenceSeconds: _customPerQuestionSeconds,
      ),
      (TimingScope.exam, TimingMode.ai) => filter.copyWith(
        useAiTiming: true,
        timePreferenceSeconds: null,
      ),
      (TimingScope.exam, TimingMode.infinite) => filter.copyWith(
        useAiTiming: false,
        timePreferenceSeconds: null,
      ),
      (TimingScope.exam, TimingMode.custom) => filter.copyWith(
        useAiTiming: false,
        timePreferenceSeconds:
            ((_customExamMinutes * 60) /
                    (filter.questionCount <= 0 ? 1 : filter.questionCount))
                .round(),
      ),
    };
  }

  Future<String?> _pickString(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchPickerSheet<String>(
        title: title,
        items: items,
        labelFor: (item) => item,
        searchHint: 'Search...',
      ),
    );
  }

  Future<List<String>?> _pickPath(
    BuildContext context, {
    required String title,
    required List<List<String>> items,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchPickerSheet<List<String>>(
        title: title,
        items: items,
        labelFor: (item) => item.join(' · '),
        searchHint: 'Search...',
      ),
    );
  }

  static bool _samePath(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.16),
            cs.surfaceContainerHighest.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  static List<Widget> _maybeTrailing(Widget? trailing) {
    return trailing == null ? const <Widget>[] : <Widget>[trailing];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ..._maybeTrailing(trailing),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LiquidField extends StatelessWidget {
  const _LiquidField({
    required this.label,
    required this.value,
    required this.hint,
    required this.leading,
    required this.onTap,
  });

  final String label;
  final String value;
  final String hint;
  final IconData leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.76),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(leading, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isEmpty ? hint : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.search_rounded),
          ],
        ),
      ),
    );
  }
}

class _SearchPickerSheet<T> extends StatefulWidget {
  const _SearchPickerSheet({
    required this.title,
    required this.items,
    required this.labelFor,
    required this.searchHint,
  });

  final String title;
  final List<T> items;
  final String Function(T item) labelFor;
  final String searchHint;

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = widget.items
        .where((item) {
          final label = widget.labelFor(item).toLowerCase();
          return _query.trim().isEmpty ||
              label.contains(_query.trim().toLowerCase());
        })
        .toList(growable: false);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.28),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                  color: Colors.black.withValues(alpha: 0.10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withValues(
                        alpha: 0.65,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final label = widget.labelFor(item);
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          tileColor: cs.surfaceContainerHighest.withValues(
                            alpha: 0.55,
                          ),
                          title: Text(label),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final PracticeMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = practiceModeColor(mode);
    final tint = practiceModeTint(cs, mode);

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1.0 : 0.985,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: selected
                  ? tint
                  : cs.surfaceContainerHighest.withValues(alpha: 0.58),
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.90)
                    : cs.outlineVariant.withValues(alpha: 0.24),
                width: selected ? 1.8 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withValues(alpha: 0.18)
                        : accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(practiceModeIcon(mode), size: 18, color: accent),
                ),
                const SizedBox(height: 6),
                Text(
                  practiceModeLabel(mode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  practiceModeSubtitle(mode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.0,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 6),
                practiceModePreview(mode, accent),
                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 3,
                    width: selected ? 52 : 28,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: selected ? 0.95 : 0.30),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  const _DifficultyPill({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.16) : cs.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: selected ? cs.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassToggleRow extends StatelessWidget {
  const _GlassToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.26)),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.title,
    required this.caption,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.onSubmitted,
  });

  final String title;
  final String caption;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.26)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: onMinus,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 88,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextFormField(
                    initialValue: value,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: onSubmitted,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onPlus,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              caption,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.34)),
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
