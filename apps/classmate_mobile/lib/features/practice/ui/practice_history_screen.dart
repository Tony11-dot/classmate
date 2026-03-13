import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/math/math_view.dart';
import '../data/practice_history_repository.dart';
import '../domain/practice_history_models.dart';
import '../providers/practice_providers.dart';
import 'practice_history_review_screen.dart';
import 'practice_mode_specs.dart';

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
    final history = ref.watch(practiceHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Practice History'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Clear practice history?'),
                  content: const Text(
                    'This removes all saved practice sessions from this device.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Clear'),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No practice sessions yet.'));
          }

          final grouped = _groupSessions(sessions);

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
    List<PracticeHistorySession> sessions,
  ) {
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
        0 => 'Today',
        1 => 'Yesterday',
        _ => _formatDateHeader(date),
      };

      grouped.putIfAbsent(key, () => <PracticeHistorySession>[]).add(s);
    }

    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}';
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
        border: Border.all(color: accent.withValues(alpha: 0.25)),
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
          backgroundColor: accent.withValues(alpha: 0.15),
          child: Icon(practiceModeIcon(session.mode), color: accent, size: 18),
        ),
        title: MathView(
          '${session.subject} • ${session.topicLabel}',
          compact: true,
        ),
        subtitle: MathView(
          '${practiceModeLabel(session.mode)} • '
          '${session.correct}/${session.answered} • '
          '${session.accuracyPercent}% • '
          'XP ${session.xp}',
          compact: true,
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
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete this session?'),
                  content: const Text(
                    'This removes only this saved practice session.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Delete'),
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
            const PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Open review'),
                ],
              ),
            ),
            const PopupMenuItem(
              enabled: false,
              value: 'retry',
              child: Text('Retry session'),
            ),
            const PopupMenuItem(
              enabled: false,
              value: 'share',
              child: Text('Share result'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18),
                  SizedBox(width: 10),
                  Text('Delete session'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
