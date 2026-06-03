import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/parent_models.dart';
import '../data/parent_repository.dart';
import '../data/viewed_student_context.dart';

class ParentNotificationsScreen extends ConsumerStatefulWidget {
  const ParentNotificationsScreen({super.key});

  @override
  ConsumerState<ParentNotificationsScreen> createState() => _ParentNotificationsScreenState();
}

class _ParentNotificationsScreenState extends ConsumerState<ParentNotificationsScreen> {
  /// false = the selected child's activity · true = the parent's own
  /// (announcements targeting them, DMs, …).
  bool _showingMine = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final listAsync = ref.watch(parentNotificationsProvider);
    final childId = ref.watch(viewedStudentIdProvider);
    final childName = ref.watch(parentChildrenProvider).maybeWhen(
          data: (kids) {
            final match = kids.where((k) => k.studentId == childId);
            if (match.isNotEmpty) return match.first.name.split(' ').first;
            return kids.isNotEmpty ? kids.first.name.split(' ').first : '';
          },
          orElse: () => '',
        );

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(parentNotificationsProvider),
        child: listAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(children: [
            const SizedBox(height: 120),
            Center(child: Text(l.commonErrorWith(e))),
          ]),
          data: (items) {
            // Split: child activity (studentId == selected child) vs the
            // parent's own (studentId null → broadcasts, DMs, parent-targeted).
            final childItems = items
                .where((n) => n.studentId != null && (childId == null || n.studentId == childId))
                .toList(growable: false);
            final mineItems = items.where((n) => n.studentId == null).toList(growable: false);
            final visible = _showingMine ? mineItems : childItems;
            final unread = items.where((n) => !n.seen).length;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                // ── Hero ──────────────────────────────────────────────
                LiquidGlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(26),
                  color: cs.primaryContainer,
                  border: Border.all(color: cs.outlineVariant),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.navNotifications,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.notificationsHeroSubtitleStudent,
                        style: TextStyle(color: cs.onPrimaryContainer, height: 1.35),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _MetricTile(icon: Icons.notifications_rounded, label: l.total, value: '${items.length}')),
                          const SizedBox(width: 10),
                          Expanded(child: _MetricTile(icon: Icons.markunread_rounded, label: l.unread, value: '$unread')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Two pills: child / you ────────────────────────────
                Row(
                  children: [
                    _Pill(
                      label: childName.isEmpty ? l.navGrades : l.parentNotifAbout(childName),
                      icon: Icons.child_care_rounded,
                      selected: !_showingMine,
                      onTap: () => setState(() => _showingMine = false),
                    ),
                    const SizedBox(width: 10),
                    _Pill(
                      label: l.parentNotifForYou,
                      icon: Icons.person_rounded,
                      selected: _showingMine,
                      onTap: () => setState(() => _showingMine = true),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(child: Text(l.parentNoNotificationsYet,
                        style: TextStyle(color: cs.onSurfaceVariant))),
                  )
                else
                  ...visible.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _NotificationTile(item: item),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primary : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? cs.onPrimary : cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onPrimaryContainer),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});
  final ParentNotification item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return LiquidGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      borderRadius: BorderRadius.circular(18),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 5,
            backgroundColor: item.seen ? cs.surfaceContainerHighest : cs.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.isEmpty ? AppLocalizations.of(context)!.notificationFallbackTitle : item.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: item.seen ? FontWeight.w500 : FontWeight.w800,
                  ),
                ),
                if (item.body.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(item.body, style: theme.textTheme.bodyMedium),
                  ),
                if ((item.studentName ?? '').isNotEmpty || (item.createdAt ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      [
                        if ((item.studentName ?? '').isNotEmpty) item.studentName!,
                        if ((item.createdAt ?? '').isNotEmpty) item.createdAt!,
                      ].join(' · '),
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
