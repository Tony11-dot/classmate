import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/cm_ai_message.dart';
import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../data/practice_history_repository.dart';
import '../domain/practice_models.dart';
import '../domain/practice_history_models.dart';
import '../providers/practice_providers.dart';
import 'practice_display_text.dart';
import 'practice_history_review_screen.dart';
import 'practice_mode_specs.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_press.dart';
import '../../../core/theme/cm_tokens.dart';
import 'practice_review_widgets.dart';

import '../../../ui/widgets/cm_sub_bar.dart';
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
  return raw.isEmpty
      ? l.practiceHistoryLoadError
      : '${l.practiceHistoryErrorPrefix} $raw';
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
      appBar: CmSubBar(
        onBack: () => Navigator.of(context).maybePop(),
        title: l.practiceHistoryTitle,
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
            return _HistoryEmpty(text: l.practiceHistoryEmpty);
          }

          final grouped = _groupSessions(context, sessions);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
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
    return FriendlyDate.date(date);
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 30,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final String title;
  final List<PracticeHistorySession> sessions;

  const _HistorySection({required this.title, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(6, 18, 6, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
        ),
        for (final s in sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _HistoryCard(session: s),
          ),
      ],
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  final PracticeHistorySession session;

  const _HistoryCard({required this.session});

  void _openReview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PracticeHistoryReviewScreen(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = practiceModeColor(session.mode);
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;

    return CmPress(
      onTap: () => _openReview(context),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 4, 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(CmTokens.radiusLg),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.35),
            width: 0.8,
          ),
          boxShadow: CmTokens.of(context).shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: dark ? 0.22 : 0.13),
                borderRadius: BorderRadius.circular(CmTokens.radiusSm),
              ),
              child: Icon(
                practiceModeIcon(session.mode),
                color: accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CMAiMessage(
                    localizedPracticeSubjectAndTopic(
                      context,
                      subject: session.subject,
                      topicLabel: session.topicLabel,
                    ),
                    compact: true,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _practiceModeLabel(context, session.mode),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      PracticeScorePill(
                        correct: session.correct,
                        answered: session.answered,
                        percent: session.accuracyPercent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
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
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: Text(l.classroomsForwardCancel),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
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
                  _openReview(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_outlined, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.practiceHistoryOpenReview,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.practiceHistoryDeleteSession,
                      ),
                    ],
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
