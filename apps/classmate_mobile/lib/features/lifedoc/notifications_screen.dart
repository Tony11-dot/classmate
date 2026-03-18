import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifications_models.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(now.year, now.month, now.day);
    final diff = t.difference(d).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff <= 7) return 'This week';
    return 'Earlier';
  }

  String _timeLabel(DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  IconData _iconFor(String source) {
    switch (source.trim().toLowerCase()) {
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

  Color _tone(BuildContext context, StudentNotificationSeverity severity) {
    final cs = Theme.of(context).colorScheme;
    switch (severity) {
      case StudentNotificationSeverity.critical:
        return cs.errorContainer.withValues(alpha: 0.82);
      case StudentNotificationSeverity.warning:
        return cs.tertiaryContainer.withValues(alpha: 0.82);
      case StudentNotificationSeverity.info:
        return cs.surfaceContainerHighest.withValues(alpha: 0.82);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mergedNotificationsProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (items) {
        final grouped = <String, List<StudentNotificationItem>>{};
        for (final item in items) {
          grouped.putIfAbsent(_groupLabel(item.createdAt), () => []).add(item);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(persistedNotificationsProvider);
            ref.invalidate(mergedNotificationsProvider);
            await ref.read(mergedNotificationsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      'Your full student history: grades, attendance, practice, solutions, and smart academic updates.',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const _EmptyBody(
                  message:
                      'No notifications yet. When school activity or study signals update, they will appear here.',
                )
              else
                ...grouped.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
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
                                color: _tone(context, item.severity),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: cs.outlineVariant.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: cs.surface.withValues(
                                      alpha: 0.9,
                                    ),
                                    child: Icon(
                                      _iconFor(item.source),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              label: _timeLabel(item.createdAt),
                                            ),
                                            if (!item.isRead)
                                              const _MetaPill(label: 'NEW'),
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
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
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
        color: cs.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
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
