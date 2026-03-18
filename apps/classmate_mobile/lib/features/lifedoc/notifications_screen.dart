import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'announcements_models.dart';
import 'announcements_provider.dart';
import '../insights/providers/insights_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${value.day}/${value.month}/${value.year}';
  }

  String _groupLabel(DateTime value) {
    final now = DateTime.now();
    final d0 = DateTime(now.year, now.month, now.day);
    final d1 = DateTime(value.year, value.month, value.day);
    final diff = d0.difference(d1).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return 'This week';
    return 'Earlier';
  }

  IconData _iconForSource(String source) {
    switch (source) {
      case 'grades':
        return Icons.grade_rounded;
      case 'attendance':
        return Icons.how_to_reg_rounded;
      case 'practice':
        return Icons.psychology_alt_rounded;
      case 'solutions':
        return Icons.lightbulb_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _badgeColor(BuildContext context, AnnouncementSeverity severity) {
    final cs = Theme.of(context).colorScheme;
    switch (severity) {
      case AnnouncementSeverity.critical:
        return cs.errorContainer.withValues(alpha: 0.85);
      case AnnouncementSeverity.warning:
        return cs.tertiaryContainer.withValues(alpha: 0.85);
      case AnnouncementSeverity.info:
        return cs.primaryContainer.withValues(alpha: 0.85);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unifiedAsync = ref.watch(unifiedStudentInsightsProvider);
    final announcementItems = ref.watch(announcementsProvider);
    final cs = Theme.of(context).colorScheme;

    return unifiedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (data) {
        final derived = <_NotificationItem>[
          ...announcementItems.map(
            (a) => _NotificationItem(
              id: a.id,
              icon: _iconForSource(a.source),
              title: a.title,
              body: a.body,
              source: a.source,
              createdAt: a.createdAt,
              severity: a.severity,
            ),
          ),
          if (data?.grades.latest.isNotEmpty == true)
            _NotificationItem(
              id: 'latest-grade',
              icon: Icons.grade_rounded,
              title: 'New grade signal',
              body:
                  'Latest result: ${data!.grades.latest.first.assessmentTitle} • ${data.grades.latest.first.grade.toStringAsFixed(0)}.',
              source: 'grades',
              createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
              severity: AnnouncementSeverity.info,
            ),
          if (data?.attendance.latest.isNotEmpty == true)
            _NotificationItem(
              id: 'latest-attendance',
              icon: Icons.how_to_reg_rounded,
              title: 'Attendance updated',
              body:
                  'Latest status: ${data!.attendance.latest.first.status} on ${data.attendance.latest.first.date}.',
              source: 'attendance',
              createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
              severity: AnnouncementSeverity.info,
            ),
          if (data?.practice.weakTopics.isNotEmpty == true)
            _NotificationItem(
              id: 'nova-recommendation',
              icon: Icons.psychology_alt_rounded,
              title: 'NOVA recommendation',
              body:
                  'Weak area detected in ${data!.practice.weakTopics.first.subject}: ${data.practice.weakTopics.first.topicLabel}.',
              source: 'practice',
              createdAt: DateTime.now().subtract(const Duration(hours: 5)),
              severity: AnnouncementSeverity.info,
            ),
          if (data?.practice.trend?.deltaAccuracy != null)
            _NotificationItem(
              id: 'trend-update',
              icon: Icons.timeline_rounded,
              title: 'Trend update',
              body:
                  'Your 7d vs 30d practice delta is ${data!.practice.trend!.deltaAccuracy!.toStringAsFixed(1)} points.',
              source: 'practice',
              createdAt: DateTime.now().subtract(const Duration(hours: 8)),
              severity: AnnouncementSeverity.info,
            ),
        ];

        final deduped = <String, _NotificationItem>{};
        for (final item in derived) {
          deduped[item.id] = item;
        }

        final items = deduped.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final grouped = <String, List<_NotificationItem>>{};
        for (final item in items) {
          grouped.putIfAbsent(_groupLabel(item.createdAt), () => []).add(item);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
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
                    'Full history of academic updates, AI nudges, announcements, and fresh school activity.',
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const _EmptyBody(
                message:
                    'No notifications yet. Once school or AI signals arrive, the full history will appear here.',
              )
            else
              ...grouped.entries.expand(
                (entry) => <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 6),
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  ...entry.value.map(
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
                              backgroundColor: _badgeColor(
                                context,
                                item.severity,
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
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _MetaPill(
                                        label: item.source.toUpperCase(),
                                      ),
                                      _MetaPill(
                                        label: _timeAgo(item.createdAt),
                                      ),
                                      _MetaPill(
                                        label: item.severity.name.toUpperCase(),
                                      ),
                                    ],
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
              ),
          ],
        );
      },
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.source,
    required this.createdAt,
    required this.severity,
  });

  final String id;
  final IconData icon;
  final String title;
  final String body;
  final String source;
  final DateTime createdAt;
  final AnnouncementSeverity severity;
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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
