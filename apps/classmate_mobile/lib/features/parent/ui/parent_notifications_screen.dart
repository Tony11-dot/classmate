import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/friendly_date.dart';
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

  // ── Date grouping (mirrors the student notifications screen) ──────────────
  String _groupLabel(BuildContext context, DateTime date) {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(now.year, now.month, now.day);
    final diff = t.difference(d).inDays;
    if (diff <= 0) return l.today;
    if (diff == 1) return l.yesterday;
    if (diff <= 7) return l.thisWeek;
    return l.earlier;
  }

  /// Bucket notifications into Today / Yesterday / This week / Earlier,
  /// preserving the (newest-first) order the server returned.
  Map<String, List<ParentNotification>> _grouped(
      BuildContext context, List<ParentNotification> items) {
    final l = AppLocalizations.of(context)!;
    final out = <String, List<ParentNotification>>{};
    for (final n in items) {
      final dt = DateTime.tryParse(n.createdAt ?? '')?.toLocal();
      final key = dt != null ? _groupLabel(context, dt) : l.earlier;
      (out[key] ??= <ParentNotification>[]).add(n);
    }
    return out;
  }

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
          error: (e, _) => ListView(
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            children: [
              const SizedBox(height: 120),
              Center(child: Text(l.commonErrorWith(e))),
            ],
          ),
          data: (items) {
            // Split: child activity (studentId == selected child) vs the
            // parent's own (studentId null → broadcasts, DMs, parent-targeted).
            final childItems = items
                .where((n) => n.studentId != null && (childId == null || n.studentId == childId))
                .toList(growable: false);
            final mineItems = items.where((n) => n.studentId == null).toList(growable: false);
            final visible = _showingMine ? mineItems : childItems;
            final unread = items.where((n) => !n.seen).length;
            final grouped = _grouped(context, visible);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                  16, 16 + MediaQuery.paddingOf(context).top, 16, 28),
              children: [
                // ── Hero ──────────────────────────────────────────────
                LiquidGlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(28),
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
                const SizedBox(height: 16),

                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(child: Text(l.parentNoNotificationsYet,
                        style: TextStyle(color: cs.onSurfaceVariant))),
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
                            child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w900)),
                          ),
                          ...entry.value.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _NotificationTile(item: item),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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

// ── Per-type visual mapping (mirrors the student notifications screen) ───────

IconData _iconForType(String? type) {
  switch ((type ?? '').toUpperCase()) {
    case 'GRADE_POSTED':
      return Icons.grade_rounded;
    case 'ATTENDANCE_RECORDED':
    case 'ATTENDANCE_ALERT':
      return Icons.how_to_reg_rounded;
    case 'NEW_ASSIGNMENT':
      return Icons.assignment_rounded;
    case 'NEW_MATERIAL':
      return Icons.description_rounded;
    case 'NEW_MEETING':
      return Icons.video_call_rounded;
    case 'NEW_EXAM':
      return Icons.fact_check_rounded;
    case 'NEW_FORM':
      return Icons.dynamic_form_rounded;
    case 'NEW_DIPLOMA':
      return Icons.workspace_premium_rounded;
    case 'NEW_MESSAGE':
      return Icons.chat_bubble_rounded;
    case 'ANNOUNCEMENT':
      return Icons.campaign_rounded;
    default:
      return Icons.notifications_active_rounded;
  }
}

/// Subtle background tint matching the student screen's severity tones:
/// attendance reads as a soft warning; everything else stays neutral.
Color _toneForType(BuildContext context, String? type) {
  final cs = Theme.of(context).colorScheme;
  switch ((type ?? '').toUpperCase()) {
    case 'ATTENDANCE_RECORDED':
    case 'ATTENDANCE_ALERT':
      return cs.tertiaryContainer;
    default:
      return cs.surfaceContainerHighest;
  }
}

String? _timeLabel(String? iso) {
  final dt = DateTime.tryParse(iso ?? '')?.toLocal();
  if (dt == null) return null;
  return FriendlyDate.time(dt);
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});
  final ParentNotification item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final time = _timeLabel(item.createdAt);

    return LiquidGlassCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      color: _toneForType(context, item.type),
      border: Border.all(color: cs.outlineVariant),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Center(child: Icon(_iconForType(item.type), size: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title.isEmpty ? l.notificationFallbackTitle : item.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (!item.seen)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(left: 8, top: 6),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (item.body.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if ((item.studentName ?? '').isNotEmpty)
                        _MetaPill(label: item.studentName!.toUpperCase()),
                      if (time != null) _MetaPill(label: time),
                      if (!item.seen) _MetaPill(label: l.notificationsNewBadge.toUpperCase()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: BorderRadius.circular(999),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
