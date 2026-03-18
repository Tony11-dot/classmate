import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../insights/providers/insights_providers.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(unifiedStudentInsightsProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (data) {
        final cards = <_AlertCard>[
          if ((data?.attendance.attendanceRate ?? 100) < 90)
            _AlertCard(
              tone: _AlertTone.warning,
              icon: Icons.warning_amber_rounded,
              title: 'Attendance needs attention',
              body:
                  'Your attendance rate is ${data!.attendance.attendanceRate!.toStringAsFixed(1)}%. A couple of missed lessons can snowball fast.',
            ),
          if ((data?.grades.weakestSubject ?? '').trim().isNotEmpty)
            _AlertCard(
              tone: _AlertTone.focus,
              icon: Icons.flag_rounded,
              title: 'Weakest subject signal',
              body:
                  '${data!.grades.weakestSubject} currently needs the most attention based on your latest grades.',
            ),
          if (data?.practice.weakTopics.isNotEmpty == true)
            _AlertCard(
              tone: _AlertTone.focus,
              icon: Icons.psychology_rounded,
              title: 'Practice weak area',
              body:
                  '${data!.practice.weakTopics.first.topicLabel} in ${data.practice.weakTopics.first.subject} is the clearest weak topic right now.',
            ),
          if ((data?.practice.trend?.deltaAccuracy ?? 0) < -5)
            _AlertCard(
              tone: _AlertTone.warning,
              icon: Icons.trending_down_rounded,
              title: 'Practice trend dropped',
              body:
                  'Your 7d performance is below your 30d baseline. Slow down and revisit fundamentals before pushing harder.',
            ),
        ];

        cards.sort((a, b) => a.tone == _AlertTone.warning ? -1 : 1);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.errorContainer.withValues(alpha: 0.86),
                    cs.tertiaryContainer.withValues(alpha: 0.66),
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
                    'Alerts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is the page for things that need attention now, not just general updates.',
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (cards.isEmpty)
              const _EmptyBody(
                message:
                    'You’re clear right now. When something needs urgent attention, it’ll show up here.',
              )
            else
              ...cards.map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AlertCardView(card: card),
                ),
              ),
          ],
        );
      },
    );
  }
}

enum _AlertTone { warning, focus }

class _AlertCard {
  const _AlertCard({
    required this.tone,
    required this.icon,
    required this.title,
    required this.body,
  });

  final _AlertTone tone;
  final IconData icon;
  final String title;
  final String body;
}

class _AlertCardView extends StatelessWidget {
  const _AlertCardView({required this.card});

  final _AlertCard card;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = card.tone == _AlertTone.warning
        ? cs.errorContainer.withValues(alpha: 0.72)
        : cs.primaryContainer.withValues(alpha: 0.72);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.surface.withValues(alpha: 0.7),
            child: Icon(card.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  card.body,
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.message});

  final String message;

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
      child: Text(
        message,
        style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
      ),
    );
  }
}
