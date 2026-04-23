import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../common/widgets/cm_rich_content.dart';
import '../domain/practice_models.dart';
import '../providers/saved_questions_provider.dart';
import 'practice_display_text.dart';

String _modeLabel(BuildContext context, PracticeMode mode) {
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

String _difficultyLabel(BuildContext context, PracticeDifficulty difficulty) {
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

String _durationLabel(BuildContext context, int seconds) {
  final l = AppLocalizations.of(context)!;
  if (seconds >= 3600) {
    return l.savedQuestionsHoursTarget(seconds ~/ 3600);
  }
  if (seconds >= 60) {
    return l.savedQuestionsMinutesTarget((seconds / 60).round());
  }
  return l.savedQuestionsSecondsTarget(seconds);
}

class SavedQuestionsScreen extends ConsumerWidget {
  const SavedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final saved = ref.watch(savedQuestionsProvider);
    final savedController = ref.read(savedQuestionsProvider.notifier);
    final subjects = saved.map((item) => item.subject.trim()).where((item) => item.isNotEmpty).toSet();
    final topSubject = subjects.isEmpty
      ? l.savedQuestionsTopSubjectNone
      : localizedPracticeSubject(context, subjects.first);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer.withValues(alpha: 0.88),
                cs.secondaryContainer.withValues(alpha: 0.72),
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.navSavedQuestions,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                l.savedQuestionsHeroSubtitle,
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.bookmark_rounded,
                      label: l.savedQuestionsSavedMetric,
                      value: '${saved.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.menu_book_rounded,
                      label: l.savedQuestionsTopSubjectMetric,
                      value: topSubject,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: l.teacherQuickActions,
          subtitle: l.savedQuestionsQuickActionsSubtitle,
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.play_circle_fill_rounded,
                title: l.savedQuestionsOpenPractice,
                subtitle: l.savedQuestionsOpenPracticeSubtitle,
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.lightbulb_rounded,
                title: l.savedQuestionsOpenSolutions,
                subtitle: l.savedQuestionsOpenSolutionsSubtitle,
                onTap: () => context.go('/solutions'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: l.savedQuestionsQueueTitle,
          subtitle: l.savedQuestionsQueueSubtitle,
          child: saved.isEmpty
              ? _EmptyStateCard(
                  title: l.savedQuestionsEmptyTitle,
                  subtitle: l.savedQuestionsEmptySubtitle,
                )
              : Column(
                  children: [
                    ...saved.map(
                      (question) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SavedQuestionCard(
                          question: question,
                          onRemove: () => savedController.toggle(question),
                          onOpenPractice: () => context.go('/practice'),
                          onOpenSolutions: () => context.go('/solutions'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: saved.isEmpty ? null : savedController.clearAll,
                        icon: const Icon(Icons.clear_all_rounded),
                        label: Text(l.savedQuestionsClearAction),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SavedQuestionCard extends StatelessWidget {
  const _SavedQuestionCard({
    required this.question,
    required this.onRemove,
    required this.onOpenPractice,
    required this.onOpenSolutions,
  });

  final PracticeQuestion question;
  final VoidCallback onRemove;
  final VoidCallback onOpenPractice;
  final VoidCallback onOpenSolutions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  localizedPracticeSubject(context, question.subject),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.chatMediaPreviewRemoveAction,
                onPressed: onRemove,
                icon: const Icon(Icons.bookmark_remove_rounded),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            localizedPracticeTopicLabel(context, question.topicLabel),
            style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          CMRichContent(data: question.prompt),
          if (question.explanation.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.savedQuestionsWhyItWorks,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            CMRichContent(data: question.explanation),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.tune_rounded, label: _modeLabel(context, question.mode)),
              _MetaChip(icon: Icons.speed_rounded, label: _difficultyLabel(context, question.difficulty)),
              _MetaChip(icon: Icons.schedule_rounded, label: _durationLabel(context, question.recommendedTimeSeconds)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onOpenPractice,
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: Text(AppLocalizations.of(context)!.savedQuestionsOpenPractice),
              ),
              OutlinedButton.icon(
                onPressed: onOpenSolutions,
                icon: const Icon(Icons.lightbulb_rounded),
                label: Text(AppLocalizations.of(context)!.savedQuestionsOpenSolutions),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: cs.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cs.primaryContainer.withValues(alpha: 0.9),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
        ],
      ),
    );
  }
}
