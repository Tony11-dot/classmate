import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/practice_prompt_builder.dart';

import '../domain/practice_models.dart';
import '../providers/practice_providers.dart';
import 'practice_session_screen.dart';

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

Color practiceModeColor(PracticeMode mode) {
  switch (mode) {
    case PracticeMode.practice:
      return Colors.indigo;
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
      return const Color(0xFF2962FF);
  }
}

Widget practiceModePreview(BuildContext context, PracticeMode mode) {
  final accent = practiceModeColor(mode);

  switch (mode) {
    case PracticeMode.practice:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 6,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            width: 18,
            height: 6,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      );

    case PracticeMode.flashcards:
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 34,
            height: 20,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Positioned(
            left: 7,
            top: -3,
            child: Container(
              width: 34,
              height: 20,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );

    case PracticeMode.speedRound:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          4,
          (i) => Padding(
            padding: EdgeInsets.only(right: i == 3 ? 0 : 4),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18 + (i * 0.08)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      );

    case PracticeMode.examPrep:
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 20,
            height: 5,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      );

    case PracticeMode.conceptBuilder:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.40),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          ),
        ],
      );

    case PracticeMode.adaptive:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 14,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 10,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 18,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.46),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );

    case PracticeMode.bagrut:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 8,
              height: 2,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 24,
            height: 5,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      );
  }
}

String practiceModeSubtitle(PracticeMode mode) {
  switch (mode) {
    case PracticeMode.practice:
      return 'Standard practice';
    case PracticeMode.flashcards:
      return 'Quick concept review';
    case PracticeMode.speedRound:
      return 'Timed drills';
    case PracticeMode.examPrep:
      return 'Exam simulation';
    case PracticeMode.conceptBuilder:
      return 'Understand ideas';
    case PracticeMode.adaptive:
      return 'AI adjusts difficulty';
    case PracticeMode.bagrut:
      return 'Real Bagrut questions';
  }
}

String practiceModeLabel(PracticeMode mode) {
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

String practiceModeDescription(PracticeMode mode) {
  switch (mode) {
    case PracticeMode.practice:
      return 'Balanced daily practice with full feedback.';
    case PracticeMode.flashcards:
      return 'Reveal, self-check, and lock concepts into memory.';
    case PracticeMode.speedRound:
      return 'Fast arcade reps under pressure.';
    case PracticeMode.examPrep:
      return 'Formal school-style solving with calmer pacing.';
    case PracticeMode.conceptBuilder:
      return 'Learn the rule first, then answer.';
    case PracticeMode.adaptive:
      return 'Difficulty shifts with your performance.';
    case PracticeMode.bagrut:
      return 'Real Bagrut-style question flow.';
  }
}

String practiceModeBadge(PracticeMode mode) {
  switch (mode) {
    case PracticeMode.practice:
      return 'Daily';
    case PracticeMode.flashcards:
      return 'Memory';
    case PracticeMode.speedRound:
      return 'Arcade';
    case PracticeMode.examPrep:
      return 'Formal';
    case PracticeMode.conceptBuilder:
      return 'Learn';
    case PracticeMode.adaptive:
      return 'Smart';
    case PracticeMode.bagrut:
      return 'Exam';
  }
}

IconData practiceModeIcon(PracticeMode mode) {
  switch (mode) {
    case PracticeMode.practice:
      return Icons.tune_rounded;
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
    case PracticeMode.bagrut:
      return Icons.description_rounded;
  }
}

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

class PracticeSetupScreen extends ConsumerStatefulWidget {
  const PracticeSetupScreen({super.key});

  @override
  ConsumerState<PracticeSetupScreen> createState() =>
      _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends ConsumerState<PracticeSetupScreen> {
  int _modeGridCount(BuildContext context) {
    return 2;
  }

  double _modeChildAspectRatio(BuildContext context) {
    return 0.92;
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(practiceFilterProvider);
    final filterCtl = ref.read(practiceFilterProvider.notifier);
    final sessionCtl = ref.read(practiceSessionProvider.notifier);
    final loading = ref.watch(practiceSessionLoadingProvider);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final subjectOptions = practiceSubjectCatalog.keys.toList(growable: false);
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
      appBar: AppBar(centerTitle: true),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Mode',
              child: GridView.builder(
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
                    onTap: () => filterCtl.patch(mode: mode),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Difficulty',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final difficulty in PracticeDifficulty.values)
                    _DifficultyChip(
                      selected: filter.difficulty == difficulty,
                      label: practiceDifficultyLabel(difficulty),
                      onTap: () => filterCtl.patch(difficulty: difficulty),
                    ),
                ],
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
                  ),
                  const SizedBox(height: 12),
                  _GlassToggleRow(
                    title: 'AI timing',
                    subtitle: 'Let the generator choose time per question',
                    value: filter.useAiTiming,
                    onChanged: (value) => filterCtl.patch(useAiTiming: value),
                  ),
                  if (!filter.useAiTiming) ...[
                    const SizedBox(height: 12),
                    _StepperRow(
                      title: 'Seconds per question',
                      caption: 'Fixed timer for each question',
                      value: '${filter.timePreferenceSeconds ?? 15}s',
                      onMinus: () {
                        final current = filter.timePreferenceSeconds ?? 15;
                        final next = current > 5 ? current - 5 : 5;
                        filterCtl.patch(timePreferenceSeconds: next);
                      },
                      onPlus: () {
                        final current = filter.timePreferenceSeconds ?? 15;
                        final next = current < 300 ? current + 5 : 300;
                        filterCtl.patch(timePreferenceSeconds: next);
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  _GlassToggleRow(
                    title: 'Infinite lives',
                    subtitle: 'Never end the session because of wrong answers',
                    value: filter.hasInfiniteLives,
                    onChanged: (value) =>
                        filterCtl.patch(hasInfiniteLives: value),
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
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Exam timing',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Unlimited time'),
                    subtitle: const Text('Turn off countdown for the session'),
                    value: filter.timePreferenceSeconds == null,
                    onChanged: (v) {
                      filterCtl.patch(
                        timePreferenceSeconds: v ? null : 60,
                        useAiTiming: false,
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.hourglass_bottom_rounded),
                    title: const Text('Exam duration'),
                    subtitle: Text(
                      filter.timePreferenceSeconds == null
                          ? 'Not set yet'
                          : '${filter.timePreferenceSeconds! * filter.questionCount ~/ 60} min total',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final picked = await showDialog<int>(
                        context: context,
                        builder: (dialogContext) => SimpleDialog(
                          title: const Text('Choose total exam duration'),
                          children: [
                            for (final mins in [15, 30, 45, 60, 90, 120])
                              SimpleDialogOption(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(mins),
                                child: Text('$mins minutes'),
                              ),
                          ],
                        ),
                      );

                      if (picked == null) {
                        return;
                      }

                      final totalSeconds = picked * 60;
                      final perQuestion =
                          (totalSeconds /
                                  (filter.questionCount <= 0
                                      ? 1
                                      : filter.questionCount))
                              .round();

                      filterCtl.patch(
                        timePreferenceSeconds: perQuestion,
                        useAiTiming: false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: loading
                  ? null
                  : () async {
                      final startFilter = filter.mode == PracticeMode.bagrut
                          ? filter.copyWith(
                              questionCount: 1,
                              useAiTiming: false,
                              timePreferenceSeconds: null,
                              maxLives: 1,
                              hasInfiniteLives: true,
                            )
                          : filter;
                      await sessionCtl.start(startFilter);
                      if (!context.mounted) return;
                      await Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const PracticeSessionScreen(),
                        ),
                      );
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
          ],
        ),
      ),
    );
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
        labelFor: (x) => x,
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
        labelFor: (x) => x.join(' · '),
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
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
                  const SizedBox(height: 4),
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
