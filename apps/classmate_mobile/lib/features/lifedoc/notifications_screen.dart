import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../insights/providers/insights_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(unifiedStudentInsightsProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (data) {
        final items = <_NotificationItem>[
          if (data?.grades.latest.isNotEmpty == true)
            _NotificationItem(
              icon: Icons.grade_rounded,
              title: 'New grade signal',
              body:
                  'Latest result: ${data!.grades.latest.first.assessmentTitle} • ${data.grades.latest.first.grade.toStringAsFixed(0)}.',
            ),
          if (data?.attendance.latest.isNotEmpty == true)
            _NotificationItem(
              icon: Icons.how_to_reg_rounded,
              title: 'Attendance updated',
              body:
                  'Latest status: ${data!.attendance.latest.first.status} on ${data.attendance.latest.first.date}.',
            ),
          if (data?.practice.weakTopics.isNotEmpty == true)
            _NotificationItem(
              icon: Icons.psychology_alt_rounded,
              title: 'NOVA recommendation',
              body:
                  'Weak area detected in ${data!.practice.weakTopics.first.subject}: ${data.practice.weakTopics.first.topicLabel}.',
            ),
          if (data?.practice.trend?.deltaAccuracy != null)
            _NotificationItem(
              icon: Icons.timeline_rounded,
              title: 'Trend update',
              body:
                  'Your 7d vs 30d practice delta is ${data!.practice.trend!.deltaAccuracy!.toStringAsFixed(1)} points.',
            ),
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Today',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Academic updates, AI nudges, and fresh school activity in one clean feed.',
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const _EmptyBody(
                message:
                    'No new updates yet. As soon as something changes in your academic activity, it will appear here.',
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: cs.primaryContainer.withValues(
                            alpha: 0.9,
                          ),
                          child: Icon(item.icon, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.body,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
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
