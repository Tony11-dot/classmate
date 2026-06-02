import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/cm_ai_message.dart';
import '../../../l10n/app_localizations.dart';
import '../data/practice_history_repository.dart';
import '../domain/practice_models.dart';
import '../domain/practice_history_models.dart';
import '../providers/practice_providers.dart';
import 'practice_display_text.dart';
import 'practice_history_review_screen.dart';
import 'practice_mode_specs.dart';
import '../../../ui/widgets/cm_loading.dart';

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

String _friendlyError(BuildContext context, Object error) {
  final l = AppLocalizations.of(context)!;
  final raw = error.toString().replaceFirst('Exception: ', '').trim();
  return raw.isEmpty ? l.practiceHistoryLoadError : '${l.practiceHistoryErrorPrefix} $raw';
}

class PracticeHistoryScreen extends ConsumerWidget {
  const PracticeHistoryScreen({super.key});

  static Future<void> _rewriteWithout(PracticeHistorySession session) async {
    final repo = PracticeHistoryRepository();
    final sessions = (await repo.loadSessions()).toList();
    sessions.removeWhere((x) => x.id == session.id);
    await repo.clearAll();
    for (final s in sessions.reversed) {
      await repo.saveSession(s);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final history = ref.watch(practiceHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l.practiceHistoryTitle),
        actions: [
          IconButton(
            tooltip: l.practiceHistoryClearTooltip,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l.practiceHistoryClearConfirmTitle),
                  content: Text(l.practiceHistoryClearConfirmBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(l.classroomsForwardCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(l.clear),
                    ),
                  ],
                ),
              );

              if (confirmed != true) return;

              final repo = PracticeHistoryRepository();
              await repo.clearAll();
              ref.invalidate(practiceHistoryProvider);
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CmLoading()),
        error: (e, _) => Center(child: Text(_friendlyError(context, e))),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(child: Text(l.practiceHistoryEmpty));
          }

          final grouped = _groupSessions(context, sessions);

          return ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: grouped.entries.map((entry) {
              return _HistorySection(title: entry.key, sessions: entry.value);
            }).toList(),
          );
        },
      ),
    );
  }

  Map<String, List<PracticeHistorySession>> _groupSessions(
    BuildContext context,
    List<PracticeHistorySession> sessions,
  ) {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final grouped = <String, List<PracticeHistorySession>>{};

    for (final s in sessions) {
      final date = DateTime(
        s.completedAt.year,
        s.completedAt.month,
        s.completedAt.day,
      );
      final diff = today.difference(date).inDays;

      final key = switch (diff) {
        0 => l.today,
        1 => l.yesterday,
        _ => _formatDateHeader(context, date),
      };

      grouped.putIfAbsent(key, () => <PracticeHistorySession>[]).add(s);
    }

    return grouped;
  }

  String _formatDateHeader(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }
}

class _HistorySection extends StatelessWidget {
  final String title;
  final List<PracticeHistorySession> sessions;

  const _HistorySection({required this.title, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ...sessions.map((s) => _HistoryCard(session: s)),
      ],
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  final PracticeHistorySession session;

  const _HistoryCard({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = practiceModeColor(session.mode);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PracticeHistoryReviewScreen(session: session),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: accent,
          child: Icon(practiceModeIcon(session.mode), color: accent, size: 18),
        ),
        title: CMAiMessage(
          localizedPracticeSubjectAndTopic(
            context,
            subject: session.subject,
            topicLabel: session.topicLabel,
          ),
          compact: true,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: CMAiMessage(
          '${_practiceModeLabel(context, session.mode)} • '
          '${session.correct}/${session.answered} • '
          '${session.accuracyPercent}%',
          compact: true,
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          iconSize: 18,
          icon: Icon(
            Icons.more_horiz_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onSelected: (value) async {
            if (value == 'delete') {
              final l = AppLocalizations.of(context)!;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l.practiceHistoryDeleteConfirmTitle),
                  content: Text(l.practiceHistoryDeleteConfirmBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(l.classroomsForwardCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(l.chatContextDelete),
                    ),
                  ],
                ),
              );

              if (confirmed != true) return;
              if (!context.mounted) return;

              await PracticeHistoryScreen._rewriteWithout(session);
              ref.invalidate(practiceHistoryProvider);
            }

            if (value == 'open') {
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PracticeHistoryReviewScreen(session: session),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 18),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.practiceHistoryOpenReview),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 18),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.practiceHistoryDeleteSession),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
