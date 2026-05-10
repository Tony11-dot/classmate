import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';

import '../domain/practice_models.dart';
import '../domain/practice_mode_behavior.dart';
import 'practice_mode_specs.dart';
import 'practice_display_text.dart';
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

const Map<String, List<String>> practiceCustomTopicExamples = {
  'Math': [
    'quadratics word problems',
    'limits with graphs',
    'function transformations',
  ],
  'Physics': [
    'laws of thermodynamics and heat transfer',
    'electrostatics basics',
    'optics with lenses',
  ],
  'Computer Science': [
    'if else branching practice',
    'arrays and loops basics',
    'boolean logic questions',
  ],
  'Chemistry': [
    'periodic table trends',
    'acids and bases in water',
    'chemical bonding basics',
  ],
  'Biology': [
    'dna and genetics basics',
    'cell organelles review',
    'photosynthesis steps',
  ],
  'English': [
    'reading comprehension passages about climate',
    'first conditional sentences',
    'grammar with verbs',
  ],
  'Arabic': [
    'فهم المقروء',
    'النحو في الجملة الفعلية',
    'مفردات المدرسة',
  ],
  'Hebrew': [
    'הבנת הנקרא',
    'דקדוק בזמנים',
    'אוצר מילים לבית הספר',
  ],
};

String practiceDifficultyLabel(
  BuildContext context,
  PracticeDifficulty difficulty,
) {
  final l = AppLocalizations.of(context)!;
  switch (difficulty) {
    case PracticeDifficulty.easy:
      return l.practiceSetupDifficultyEasy;
    case PracticeDifficulty.medium:
      return l.practiceSetupDifficultyMedium;
    case PracticeDifficulty.hard:
      return l.practiceSetupDifficultyHard;
    case PracticeDifficulty.olympiad:
      return l.practiceSetupDifficultyOlympiad;
    case PracticeDifficulty.adaptive:
      return l.practiceSetupDifficultyAdaptive;
  }
}

String _practiceModeLabel(BuildContext context, PracticeMode mode) {
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

String _practiceModeSubtitle(BuildContext context, PracticeMode mode) {
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

String _modeHelpText(BuildContext context, PracticeMode mode) {
  final l = AppLocalizations.of(context)!;
  switch (mode) {
    case PracticeMode.practice:
      return l.practiceSetupModeHelpPractice;
    case PracticeMode.flashcards:
      return l.practiceSetupModeHelpFlashcards;
    case PracticeMode.speedRound:
      return l.practiceSetupModeHelpSpeedRound;
    case PracticeMode.examPrep:
      return l.practiceSetupModeHelpExamPrep;
    case PracticeMode.conceptBuilder:
      return l.practiceSetupModeHelpConceptBuilder;
    case PracticeMode.adaptive:
      return l.practiceSetupModeHelpAdaptive;
    case PracticeMode.bagrut:
      return l.practiceSetupModeHelpBagrut;
  }
}

String _buildPracticePromptSummary(BuildContext context, PracticeFilter filter) {
  final l = AppLocalizations.of(context)!;
  final timing = filter.useAiTiming
      ? l.practiceSetupAiTiming
      : l.practiceSetupSecondsShort(filter.timePreferenceSeconds ?? 15);
  final lives = filter.hasInfiniteLives
      ? l.practiceSetupInfiniteLives
      : l.practiceSetupLivesCount(filter.maxLives);

  return [
    l.practiceSetupSummarySubject(
      localizedPracticeSubject(context, filter.subject),
    ),
    l.practiceSetupSummaryTopic(
      localizedPracticeTopicPath(context, filter.topicPath),
    ),
    l.practiceSetupSummaryMode(_practiceModeLabel(context, filter.mode)),
    l.practiceSetupSummaryDifficulty(
      practiceDifficultyLabel(context, filter.difficulty),
    ),
    l.practiceSetupSummaryQuestions(filter.questionCount),
    l.practiceSetupSummaryTiming(timing),
    l.practiceSetupSummaryLives(lives),
  ].join(' • ');
}

class PracticeSetupScreen extends ConsumerStatefulWidget {
  const PracticeSetupScreen({super.key});

  @override
  ConsumerState<PracticeSetupScreen> createState() =>
      _PracticeSetupScreenState();
}

enum _PracticeTopicInputMode { catalog, custom }

class _PracticeSetupScreenState extends ConsumerState<PracticeSetupScreen> {
  TimingMode _timingMode = TimingMode.ai;
  TimingScope _timingScope = TimingScope.perQuestion;
  int _customPerQuestionSeconds = 45;
  int _customExamMinutes = 20;
  late _PracticeTopicInputMode _topicInputMode;

  @override
  void initState() {
    super.initState();
    _topicInputMode = _resolveTopicInputMode(ref.read(practiceFilterProvider));
  }

  _PracticeTopicInputMode _resolveTopicInputMode(PracticeFilter filter) {
    final topicOptions = practiceSubjectCatalog[filter.subject];
    if (topicOptions == null) {
      return _PracticeTopicInputMode.custom;
    }
    return topicOptions.any((item) => _samePath(item, filter.topicPath))
        ? _PracticeTopicInputMode.catalog
        : _PracticeTopicInputMode.custom;
  }

  void _setTopicInputMode(
    _PracticeTopicInputMode next,
    PracticeFilterController filterCtl,
    PracticeFilter filter,
  ) {
    setState(() {
      _topicInputMode = next;
    });

    if (next != _PracticeTopicInputMode.catalog) {
      return;
    }

    final nextSubject = practiceSubjectCatalog.containsKey(filter.subject)
        ? filter.subject
        : practiceSubjectCatalog.keys.first;
    final nextTopics =
        practiceSubjectCatalog[nextSubject] ?? const <List<String>>[practiceGeneralTopicPath];
    final nextTopic = nextTopics.any((item) => _samePath(item, filter.topicPath))
        ? filter.topicPath
        : nextTopics.first;

    filterCtl.patch(subject: nextSubject, topicPath: nextTopic);
  }

  int _modeGridCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 420 ? 3 : 2;
  }

  double _modeChildAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 420 ? 1.28 : 1.18;
  }

  Future<void> _showModeInfoSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final l = AppLocalizations.of(context)!;

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
                        l.practiceSetupModeInfoTitle,
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
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: accent,
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
                                color: cs.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                practiceModeIcon(mode),
                                color: accent,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              _practiceModeLabel(context, mode),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              _practiceModeSubtitle(context, mode),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _modeHelpText(context, mode),
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
    final l = AppLocalizations.of(context)!;

    final filterCtl = ref.read(practiceFilterProvider.notifier);
    final sessionCtl = ref.read(practiceSessionProvider.notifier);
    final loading = ref.watch(practiceSessionLoadingProvider);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final subjectOptions = practiceSubjectCatalog.keys.toList(growable: true);
    if (!subjectOptions.contains(practiceGeneralKnowledgeSubject)) {
      subjectOptions.add(practiceGeneralKnowledgeSubject);
    }
    final inputMode = _resolveTopicInputMode(filter) == _PracticeTopicInputMode.custom
        ? _PracticeTopicInputMode.custom
        : _topicInputMode;
    final topicOptions =
        practiceSubjectCatalog[filter.subject] ??
        const <List<String>>[
          practiceGeneralTopicPath,
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
              title: l.practiceSetupHeroTitle,
              subtitle: l.practiceSetupHeroSubtitle,
              accent: cs.primary,
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
                          filter.subject,
                        ),
                      ),
                      _MiniPill(
                        label: localizedPracticeTopicPath(
                          context,
                          filter.topicPath,
                        ),
                      ),
                      _MiniPill(label: _practiceModeLabel(context, filter.mode)),
                      _MiniPill(
                        label: practiceDifficultyLabel(context, filter.difficulty),
                      ),
                      _MiniPill(
                        label: filter.hasInfiniteLives
                            ? l.practiceSetupInfiniteLives
                            : l.practiceSetupLivesCount(filter.maxLives),
                      ),
                      _MiniPill(
                        label: filter.useAiTiming
                            ? l.practiceSetupAiTiming
                            : l.practiceSetupSecondsShort(
                                filter.timePreferenceSeconds ?? 15,
                              ),
                      ),
                      _MiniPill(
                        label: l.practiceSetupQuestionsCount(
                          filter.questionCount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _buildPracticePromptSummary(context, filter),
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
              title: l.practiceSetupSectionSubjectTopic,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l.practiceSetupFieldTopic),
                          selected: inputMode == _PracticeTopicInputMode.catalog,
                          onSelected: (_) => _setTopicInputMode(
                            _PracticeTopicInputMode.catalog,
                            filterCtl,
                            filter,
                          ),
                        ),
                        ChoiceChip(
                          label: Text(l.practiceSetupFieldCustomTopic),
                          selected: inputMode == _PracticeTopicInputMode.custom,
                          onSelected: (_) => _setTopicInputMode(
                            _PracticeTopicInputMode.custom,
                            filterCtl,
                            filter,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (inputMode == _PracticeTopicInputMode.catalog) ...[
                    _LiquidField(
                      label: l.practiceSetupFieldSubject,
                      value: localizedPracticeSubject(context, filter.subject),
                      hint: l.practiceSetupFieldSubjectHint,
                      leading: Icons.menu_book_rounded,
                      onTap: () async {
                        final picked = await _pickString(
                          context,
                          title: l.practiceSetupChooseSubject,
                          items: subjectOptions,
                          labelFor: (item) =>
                            localizedPracticeSubject(context, item),
                        );
                        if (picked == null) return;
                        final nextTopics =
                            practiceSubjectCatalog[picked] ??
                            const <List<String>>[
                              practiceGeneralTopicPath,
                            ];
                        filterCtl.patch(
                          subject: picked,
                          topicPath: nextTopics.first,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _LiquidField(
                      label: l.practiceSetupFieldTopic,
                      value: localizedPracticeTopicPath(context, selectedTopicPath),
                      hint: l.practiceSetupFieldTopicHint,
                      leading: Icons.account_tree_rounded,
                      onTap: () async {
                        final picked = await _pickPath(
                          context,
                          title: l.practiceSetupChooseTopic,
                          items: topicOptions,
                          labelFor: (item) =>
                            localizedPracticeTopicPath(context, item),
                        );
                        if (picked == null) return;
                        filterCtl.patch(topicPath: picked);
                      },
                    ),
                  ] else ...[
                    _LiquidField(
                      label: l.practiceSetupFieldCustomSubject,
                      value: localizedPracticeSubject(context, filter.subject),
                      hint: l.practiceSetupFieldCustomSubjectHint,
                      leading: Icons.edit_note_rounded,
                      onTap: () async {
                        final controller = TextEditingController(
                          text: localizedPracticeSubject(context, filter.subject),
                        );
                        final result = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l.practiceSetupDialogCustomSubjectTitle),
                            content: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: l.practiceSetupDialogEnterSubject,
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (value) =>
                                  Navigator.of(context).pop(value),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(l.classroomsForwardCancel),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(controller.text),
                                child: Text(l.practiceSetupUseAction),
                              ),
                            ],
                          ),
                        );
                        final next = result?.trim();
                        if (next == null || next.isEmpty) return;
                        filterCtl.patch(
                          subject: next,
                          topicPath: practiceGeneralTopicPath,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _LiquidField(
                      label: l.practiceSetupFieldCustomTopic,
                      value: localizedPracticeTopicPath(context, filter.topicPath),
                      hint: l.practiceSetupFieldCustomTopicHint,
                      leading: Icons.edit_note_rounded,
                      onTap: () async {
                        final result = await _pickCustomTopic(
                          context,
                          title: l.practiceSetupDialogCustomTopicTitle,
                          initialText: localizedPracticeTopicPath(
                            context,
                            filter.topicPath,
                          ),
                          suggestions:
                              practiceCustomTopicExamples[filter.subject] ??
                              const <String>[],
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
                  if (inputMode == _PracticeTopicInputMode.custom) ...[
                    const SizedBox(height: 10),
                    _AIDisclaimerBanner(
                      icon: Icons.auto_awesome_rounded,
                      message: l.practiceCustomDisclaimer,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: l.practiceSetupSectionMode,
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
                  const SizedBox(height: 2),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: PracticeMode.values.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _modeGridCount(context),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: _modeChildAspectRatio(context),
                    ),
                    itemBuilder: (context, index) {
                      final mode = PracticeMode.values[index];
                      return _ModeTile(
                        mode: mode,
                        label: _practiceModeLabel(context, mode),
                        subtitle: _practiceModeSubtitle(context, mode),
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
              title: l.practiceSetupSectionDifficulty,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cs.outlineVariant,
                  ),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final difficulty in PracticeDifficulty.values)
                      _DifficultyPill(
                        label: practiceDifficultyLabel(context, difficulty),
                        selected: filter.difficulty == difficulty,
                        onTap: () => filterCtl.patch(difficulty: difficulty),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: l.practiceSetupSectionControls,
              child: Column(
                children: [
                  _StepperRow(
                    title: l.practiceSetupQuestionsTitle,
                    caption: l.practiceSetupQuestionsCaption,
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
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: cs.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.practiceSetupTimingTitle,
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.practiceSetupTimingCaption,
                            style: text.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ChoiceChip(
                                visualDensity: VisualDensity.compact,
                                label: Text(l.practiceSetupTimingScopePerQuestion),
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
                                visualDensity: VisualDensity.compact,
                                label: Text(l.practiceSetupTimingScopeWholeQuiz),
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
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ChoiceChip(
                                visualDensity: VisualDensity.compact,
                                label: Text(l.practiceSetupTimingModeAi),
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
                                visualDensity: VisualDensity.compact,
                                label: Text(l.practiceSetupTimingModeMyTime),
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
                                visualDensity: VisualDensity.compact,
                                label: Text(l.practiceSetupTimingModeInfinite),
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
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Text(
                              _timingMode == TimingMode.ai
                                  ? l.practiceSetupTimingCaption
                                  : _timingScope == TimingScope.perQuestion
                                  ? '$_customPerQuestionSeconds s / question'
                                  : '$_customExamMinutes min / quiz',
                              style: text.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (_timingMode == TimingMode.custom) ...[
                            const SizedBox(height: 8),
                            _StepperRow(
                              title: _timingScope == TimingScope.perQuestion
                                ? l.practiceSetupTimingCustomPerQuestionTitle
                                : l.practiceSetupTimingCustomQuizMinutesTitle,
                              caption: _timingScope == TimingScope.perQuestion
                                ? l.practiceSetupTimingCustomPerQuestionCaption
                                : l.practiceSetupTimingCustomQuizMinutesCaption,
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
                      title: l.practiceSetupInfiniteLivesTitle,
                      subtitle:
                          l.practiceSetupInfiniteLivesSubtitle,
                      value: filter.hasInfiniteLives,
                      onChanged: (value) {
                        if (!behavior.allowLives) return;
                        filterCtl.patch(hasInfiniteLives: value);
                      },
                    ),
                  if (!filter.hasInfiniteLives) ...[
                    const SizedBox(height: 12),
                    _StepperRow(
                      title: l.practiceSetupLivesTitle,
                      caption: l.practiceSetupLivesCaption,
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
                  tooltip: l.practiceSetupTooltipHistory,
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
                  tooltip: l.practiceSetupTooltipAnalytics,
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
                      label: Text(l.practiceSetupStopGenerating),
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
                                          mode: _practiceModeLabel(
                                            context,
                                            startFilter.mode,
                                          ),
                                          subject: localizedPracticeSubject(
                                            context,
                                            startFilter.subject,
                                          ),
                                          difficulty: practiceDifficultyLabel(
                                            context,
                                            startFilter.difficulty,
                                          ),
                                          tip: _modeHelpText(
                                            context,
                                            startFilter.mode,
                                          ),
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
                              if (!stillLoading && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l.practiceSessionNoQuestionsForFilter,
                                    ),
                                  ),
                                );
                              }
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
                    label: Text(
                      loading
                          ? l.practiceSetupGenerating
                          : l.practiceSetupStartSession,
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
    String Function(String item)? labelFor,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchPickerSheet<String>(
        title: title,
        items: items,
        labelFor: labelFor ?? (item) => item,
        searchHint: AppLocalizations.of(context)!.practiceSetupSearchHint,
      ),
    );
  }

  Future<List<String>?> _pickPath(
    BuildContext context, {
    required String title,
    required List<List<String>> items,
    String Function(List<String> item)? labelFor,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchPickerSheet<List<String>>(
        title: title,
        items: items,
        labelFor: labelFor ?? (item) => item.join(' · '),
        searchHint: AppLocalizations.of(context)!.practiceSetupSearchHint,
      ),
    );
  }

  Future<String?> _pickCustomTopic(
    BuildContext context, {
    required String title,
    required String initialText,
    required List<String> suggestions,
  }) {
    final l = AppLocalizations.of(context)!;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomTopicSheet(
        title: title,
        initialText: initialText,
        hintText: l.practiceSetupDialogEnterTopic,
        cancelLabel: l.classroomsForwardCancel,
        submitLabel: l.practiceSetupUseAction,
        suggestions: suggestions,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
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
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant),
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
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
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
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant,
              ),
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

class _CustomTopicSheet extends StatefulWidget {
  const _CustomTopicSheet({
    required this.title,
    required this.initialText,
    required this.hintText,
    required this.cancelLabel,
    required this.submitLabel,
    required this.suggestions,
  });

  final String title;
  final String initialText;
  final String hintText;
  final String cancelLabel;
  final String submitLabel;
  final List<String> suggestions;

  @override
  State<_CustomTopicSheet> createState() => _CustomTopicSheetState();
}

class _CustomTopicSheetState extends State<_CustomTopicSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 34,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) => Navigator.of(context).pop(value),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: widget.hintText,
                      prefixIcon: const Icon(Icons.edit_note_rounded),
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
                  if (widget.suggestions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final suggestion in widget.suggestions.take(4))
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              suggestion,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: () {
                              _controller
                                ..text = suggestion
                                ..selection = TextSelection.collapsed(
                                  offset: suggestion.length,
                                );
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(widget.cancelLabel),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(_controller.text),
                        child: Text(widget.submitLabel),
                      ),
                    ],
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
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTile({
    required this.mode,
    required this.label,
    required this.subtitle,
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
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: selected
                  ? tint
                  : cs.surfaceContainerHighest,
              border: Border.all(
                color: selected
                    ? accent
                    : cs.outlineVariant,
                width: selected ? 1.8 : 1,
              ),
            ),
            child: ClipRect(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected ? accent : cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    practiceModeIcon(mode),
                    size: 17,
                    color: selected ? Colors.white : accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.0,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(fit: FlexFit.loose, child: practiceModePreview(mode, accent)),
                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 3,
                    width: selected ? 52 : 28,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
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
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_circle_rounded, size: 16, color: cs.onPrimary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: selected ? cs.onPrimary : null,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
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
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
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
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextFormField(
                    key: ValueKey(value),
                    initialValue: value,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
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
                visualDensity: VisualDensity.compact,
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
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
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

// ── AI disclaimer banner ────────────────────────────────────────────────────

class _AIDisclaimerBanner extends StatelessWidget {
  const _AIDisclaimerBanner({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.tertiary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: cs.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onTertiaryContainer,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
