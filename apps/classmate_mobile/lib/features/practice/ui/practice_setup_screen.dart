import 'package:classmate_mobile/ui/widgets/cm_press.dart';
import 'package:flutter/material.dart';
import 'package:classmate_mobile/core/theme/cm_tokens.dart';

import '../../../ui/widgets/cm_search_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/auth/auth_controller.dart';
import '../domain/practice_models.dart';
import '../domain/practice_subjects.dart';
import '../domain/practice_mode_behavior.dart';
import 'practice_mode_specs.dart';
import 'practice_display_text.dart';
import '../providers/practice_providers.dart';
import '../domain/timing_mode.dart';
import 'practice_session_screen.dart';
import 'practice_history_screen.dart';
import 'practice_analytics_debug_screen.dart';
import '../../../ui/widgets/cm_loading.dart';

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
    // Snap the selected topic to one that actually exists for this student's
    // grade — otherwise a default like "Algebra" would be sent to the AI for a
    // 3rd grader. Runs once after first frame so we can touch the provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final filter = ref.read(practiceFilterProvider);
      final key = practiceSubjectKeyOf(filter.subject);
      if (key == null) return;
      final topics = practiceTopicsFor(key, _grade);
      final matches = topics.any((t) => _samePath(t, filter.topicPath));
      if (!matches && topics.isNotEmpty) {
        ref
            .read(practiceFilterProvider.notifier)
            .patch(subject: key, topicPath: topics.first);
      }
    });
  }

  /// The signed-in student's grade (1–12); null for staff / unknown. Drives
  /// which topics the catalog exposes.
  int? get _grade => ref.read(authSessionProvider).grade;

  _PracticeTopicInputMode _resolveTopicInputMode(PracticeFilter filter) {
    final key = practiceSubjectKeyOf(filter.subject);
    if (key == null) {
      return _PracticeTopicInputMode.custom;
    }
    final topicOptions = practiceTopicsFor(key, _grade);
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

    final nextSubject =
        practiceSubjectKeyOf(filter.subject) ?? kPracticeSubjectKeys.first;
    final nextTopics = practiceTopicsFor(nextSubject, _grade);
    final nextTopic = nextTopics.any((item) => _samePath(item, filter.topicPath))
        ? filter.topicPath
        : nextTopics.first;

    filterCtl.patch(subject: nextSubject, topicPath: nextTopic);
  }

  int _modeGridCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 420 ? 3 : 2;
  }

  Future<void> _showModeInfoSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
                      tooltip: l.a11yClose,
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
                                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35), width: 0.8),
                                boxShadow: CmTokens.of(context).shadowSm,
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
                                alignment: AlignmentDirectional.centerStart,
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

    final grade = _grade;
    final subjectOptions = <String>[
      ...kPracticeSubjectKeys,
      practiceGeneralKnowledgeSubject,
    ];
    final inputMode = _resolveTopicInputMode(filter) == _PracticeTopicInputMode.custom
        ? _PracticeTopicInputMode.custom
        : _topicInputMode;
    final subjectKey = practiceSubjectKeyOf(filter.subject);
    final topicOptions = subjectKey == null
        ? const <List<String>>[practiceGeneralTopicPath]
        : practiceTopicsFor(subjectKey, grade);

    final selectedTopicPath =
        topicOptions.any((x) => _samePath(x, filter.topicPath))
        ? filter.topicPath
        : topicOptions.first;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + MediaQuery.paddingOf(context).bottom),
          children: [
            _HeroCard(
              title: l.practiceSetupHeroTitle,
              subtitle: l.practiceSetupHeroSubtitle,
              accent: cs.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MiniPill(
                        icon: Icons.menu_book_rounded,
                        label: localizedPracticeSubject(
                          context,
                          filter.subject,
                        ),
                      ),
                      _MiniPill(
                        icon: Icons.account_tree_rounded,
                        label: localizedPracticeTopicPath(
                          context,
                          filter.topicPath,
                        ),
                      ),
                      _MiniPill(
                        icon: Icons.style_rounded,
                        label: _practiceModeLabel(context, filter.mode),
                      ),
                      _MiniPill(
                        icon: Icons.speed_rounded,
                        label: practiceDifficultyLabel(context, filter.difficulty),
                      ),
                      _MiniPill(
                        icon: Icons.favorite_rounded,
                        label: filter.hasInfiniteLives
                            ? l.practiceSetupInfiniteLives
                            : l.practiceSetupLivesCount(filter.maxLives),
                      ),
                      _MiniPill(
                        icon: Icons.timer_outlined,
                        label: filter.useAiTiming
                            ? l.practiceSetupAiTiming
                            : l.practiceSetupSecondsShort(
                                filter.timePreferenceSeconds ?? 15,
                              ),
                      ),
                      _MiniPill(
                        icon: Icons.format_list_numbered_rounded,
                        label: l.practiceSetupQuestionsCount(
                          filter.questionCount,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: l.practiceSetupSectionSubjectTopic,
              icon: Icons.menu_book_rounded,
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
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
                        final pickedKey = practiceSubjectKeyOf(picked);
                        final nextTopics = pickedKey == null
                            ? const <List<String>>[practiceGeneralTopicPath]
                            : practiceTopicsFor(pickedKey, grade);
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
                          suggestions: subjectKey == null
                              ? const <String>[]
                              : practiceCustomTopicExamplesFor(subjectKey, grade),
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
              icon: Icons.style_rounded,
              trailing: Semantics(
                button: true,
                label: l.a11yInfo,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showModeInfoSheet(context),
                  // 44 wide × the header's 30 tall — the icon keeps its spot
                  // at the end, the tap area no longer stops at its glyph.
                  child: SizedBox(
                    width: 44,
                    height: 30,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  _ModeRows(
                    columns: _modeGridCount(context),
                    itemCount: PracticeMode.values.length,
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
                            } else {
                              // Adaptive is AI-paced by design; the other
                              // timed modes now OFFER AI timing too but keep
                              // whatever the student already picked.
                              if (mode == PracticeMode.adaptive) {
                                _timingMode = TimingMode.ai;
                              } else if (!nextBehavior.aiTiming &&
                                  _timingMode == TimingMode.ai) {
                                _timingMode = TimingMode.custom;
                              }
                              if (nextBehavior.perQuestionTimingOnly) {
                                _timingScope = TimingScope.perQuestion;
                              } else if (nextBehavior.perQuizTimingOnly) {
                                _timingScope = TimingScope.exam;
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
              icon: Icons.speed_rounded,
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
            const SizedBox(height: 16),
            _SectionCard(
              title: l.practiceSetupSectionControls,
              icon: Icons.tune_rounded,
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
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.35),
                          width: 0.8,
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
                              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              _timingMode == TimingMode.ai
                                  ? l.practiceSetupTimingCaption
                                  : _timingScope == TimingScope.perQuestion
                                  ? '$_customPerQuestionSeconds ${l.practiceTimingSecPerQuestion}'
                                  : '$_customExamMinutes ${l.practiceTimingMinPerQuiz}',
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
                                          questionCount:
                                              startFilter.questionCount,
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
                                  Navigator.of(context, rootNavigator: true).canPop()) {
                                Navigator.of(context, rootNavigator: true).pop();
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(
                                    e.toString().contains('socket') || e.toString().contains('connection')
                                        ? l.practiceNoInternet
                                        : l.practiceGenerationFailed,
                                  )),
                                );
                              }
                              return; // Don't rethrow — the user already sees the error message
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
                        ? const CmLoading(size: 18)
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
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
      useRootNavigator: true,
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
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            Color.alphaBlend(
                cs.primary.withValues(alpha: 0.16), cs.primaryContainer),
          ],
        ),
        borderRadius: BorderRadius.circular(CmTokens.radiusXl),
        boxShadow: CmTokens.of(context).shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: cs.onPrimary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
    this.icon,
  });

  final String title;
  final IconData? icon;
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
        borderRadius: BorderRadius.circular(CmTokens.radiusXl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3), width: 0.8),
        boxShadow: CmTokens.of(context).shadowSm,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ..._maybeTrailing(trailing),
            ],
          ),
          const SizedBox(height: 14),
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
    // Own Material so the Ink fill paints above the section card.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45), width: 0.8),
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
              child: Icon(leading, size: 20, color: cs.onPrimaryContainer),
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
            Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
          ],
        ),
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
                  CmSearchField(
                    controller: _controller,
                    hint: widget.searchHint,
                    onChanged: (v) => setState(() => _query = v),
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: selected
                  ? tint
                  : cs.surface,
              border: Border.all(
                color: selected
                    ? accent
                    : cs.outlineVariant.withValues(alpha: 0.5),
                width: selected ? 1.8 : 0.8,
              ),
            ),
            child: ClipRect(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected ? accent : accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    practiceModeIcon(mode),
                    size: 17,
                    color: selected ? Colors.white : accent,
                  ),
                ),
                const SizedBox(height: 10),
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
                    height: 1.2,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                practiceModePreview(mode, accent),
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
    final fg = selected ? cs.onPrimary : cs.onSurfaceVariant;
    // Use a plain Container (not Ink) so the selected fill paints correctly
    // even when there's no Material ancestor providing the canvas. A custom
    // primaryTextTheme override in this app made labels on Ink-backed pills
    // collapse to surface-on-surface in light mode.
    return Material(
      color: Colors.transparent,
      child: CmPress(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 14, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
              ),
            ],
          ),
        ),),
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
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35), width: 0.8),
        boxShadow: CmTokens.of(context).shadowSm,
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
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35), width: 0.8),
        boxShadow: CmTokens.of(context).shadowSm,
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
                tooltip: l.a11yRemove,
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
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextFormField(
                    key: ValueKey(value),
                    initialValue: value,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: onSubmitted,
                    decoration: const InputDecoration(filled: false, 
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
                tooltip: l.a11yAdd,
                onPressed: onPlus,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Align(
            alignment: AlignmentDirectional.centerStart,
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

/// A compact "info chip" used in the hero card summary.
///
/// Earlier versions of the screen rendered the summary as a row of
/// rounded chips with a border — visually identical to a [ChoiceChip]
/// or a button. Users repeatedly tapped them expecting to change the
/// setting, which never worked. The new shape is deliberately quieter:
/// a leading icon, no border, subdued background, smaller text — so
/// the chip reads as a status badge, not an actionable control.
class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: cs.primary),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onPrimaryContainer,
                  fontSize: 12,
                ),
          ),
        ],
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

/// Two-column (or N-column) rows whose height follows the tallest tile in the
/// row — no fixed aspect ratio, so tiles never carry dead space or overflow.
class _ModeRows extends StatelessWidget {
  const _ModeRows({
    required this.columns,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int columns;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;
    final rows = <Widget>[];
    for (var start = 0; start < itemCount; start += columns) {
      if (start > 0) rows.add(const SizedBox(height: gap));
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) const SizedBox(width: gap),
              Expanded(
                child: start + c < itemCount
                    ? itemBuilder(context, start + c)
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ));
    }
    return Column(children: rows);
  }
}
