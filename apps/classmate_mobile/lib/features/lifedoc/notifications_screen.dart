import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import '../../l10n/app_localizations.dart';
import 'notifications_models.dart';
import 'notifications_provider.dart';

String _friendlyNotificationDateTime(BuildContext context, DateTime value) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatMediumDate(value);
  final hh = value.hour.toString().padLeft(2, '0');
  final mm = value.minute.toString().padLeft(2, '0');
  return '$date • $hh:$mm';
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  static const String _allSources = '__all_sources__';
  static const String _allStates = '__all_states__';
  static const String _unreadState = '__unread__';
  static const String _readState = '__read__';

  String _selectedSource = _allSources;
  String _selectedState = _allStates;

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

  String _timeLabel(DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _sourceLabel(BuildContext context, String source) {
    final l = AppLocalizations.of(context)!;
    switch (source.trim().toLowerCase()) {
      case 'grades':
        return l.navGrades;
      case 'attendance':
        return l.navAttendance;
      case 'practice':
        return l.navPractice;
      case 'solutions':
        return l.navSolutions;
      case 'system':
        return l.notificationsSourceSystem;
      default:
        return source.trim().isEmpty ? l.notificationsSourceSystem : source.trim();
    }
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
      case 'system':
        return Icons.settings_suggest_rounded;
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

  List<StudentNotificationItem> _filtered(List<StudentNotificationItem> items) {
    return items.where((item) {
      final matchesSource =
          _selectedSource == _allSources || item.source == _selectedSource;
      final matchesState =
          _selectedState == _allStates ||
          (_selectedState == _unreadState && !item.isRead) ||
          (_selectedState == _readState && item.isRead);
      return matchesSource && matchesState;
    }).toList(growable: false);
  }

  void _clearFilters() {
    setState(() {
      _selectedSource = _allSources;
      _selectedState = _allStates;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notificationInboxProvider);
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final heroSubtitle = session.isTeacherLike
      ? l.notificationsHeroSubtitleTeacher
      : l.notificationsHeroSubtitleStudent;

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) {
          final sources = items.map((item) => item.source).toSet().toList()..sort();
          final safeSource = sources.contains(_selectedSource) ? _selectedSource : _allSources;
          if (safeSource != _selectedSource) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _selectedSource = safeSource);
            });
          }

          final filtered = _filtered(items);
          final unreadCount = items.where((item) => !item.isRead).length;
          final localCount = items.where((item) => item.isLocal).length;
          final remoteCount = items.length - localCount;
          final hasActiveFilters =
              safeSource != _allSources || _selectedState != _allStates;
          final grouped = <String, List<StudentNotificationItem>>{};
          for (final item in filtered) {
            grouped.putIfAbsent(_groupLabel(context, item.createdAt), () => <StudentNotificationItem>[]).add(item);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(notificationSyncServiceProvider).sync();
              ref.invalidate(notificationInboxProvider);
              await ref.read(notificationInboxProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                LiquidGlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(26),
                  blurSigma: 18,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primaryContainer.withValues(alpha: 0.90),
                      cs.surfaceContainerHigh.withValues(alpha: 0.78),
                    ],
                  ),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 26,
                      spreadRadius: -8,
                      offset: const Offset(0, 14),
                      color: cs.primary.withValues(alpha: 0.14),
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.navNotifications,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        heroSubtitle,
                        style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _MetricTile(icon: Icons.notifications_rounded, label: l.total, value: '${items.length}')),
                          const SizedBox(width: 10),
                          Expanded(child: _MetricTile(icon: Icons.markunread_rounded, label: l.unread, value: '$unreadCount')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _MetricTile(icon: Icons.phone_android_rounded, label: l.local, value: '$localCount')),
                          const SizedBox(width: 10),
                          Expanded(child: _MetricTile(icon: Icons.cloud_done_rounded, label: l.server, value: '$remoteCount')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: unreadCount == 0
                              ? null
                              : () => ref.read(notificationActionsProvider).markAllRead(items),
                          icon: const Icon(Icons.done_all_rounded),
                          label: Text(l.markAllRead),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isNotEmpty)
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(24),
                    blurSigma: 14,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.surface.withValues(alpha: 0.76),
                        cs.surfaceContainerLow.withValues(alpha: 0.72),
                      ],
                    ),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.filters, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(
                          l.notificationsFiltersSubtitle,
                          style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                        ),
                        const SizedBox(height: 14),
                        LiquidGlassDropdown<String>(
                          label: l.source,
                          value: safeSource,
                          items: [
                            LiquidGlassDropdownItem(
                              value: _allSources,
                              label: l.allSources,
                              icon: Icons.grid_view_rounded,
                            ),
                            ...sources.map(
                              (source) => LiquidGlassDropdownItem(
                                value: source,
                                label: _sourceLabel(context, source),
                                icon: _iconFor(source),
                              ),
                            ),
                          ],
                          onChanged: (value) => setState(() => _selectedSource = value),
                          searchHint: l.notificationsSearchSourcesHint,
                        ),
                        const SizedBox(height: 10),
                        LiquidGlassDropdown<String>(
                          label: l.state,
                          value: _selectedState,
                          items: [
                            LiquidGlassDropdownItem(
                              value: _allStates,
                              label: l.allStates,
                              icon: Icons.filter_alt_rounded,
                            ),
                            LiquidGlassDropdownItem(
                              value: _unreadState,
                              label: l.unread,
                              icon: Icons.markunread_rounded,
                            ),
                            LiquidGlassDropdownItem(
                              value: _readState,
                              label: l.read,
                              icon: Icons.done_rounded,
                            ),
                          ],
                          onChanged: (value) => setState(() => _selectedState = value),
                          searchHint: '${l.unread} / ${l.read}',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                l.notificationsShowingSummary(
                                  filtered.length,
                                  items.length,
                                ),
                                style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                              ),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(width: 12),
                              TextButton(onPressed: _clearFilters, child: Text(l.clear)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  _EmptyBody(
                    message: l.notificationsEmptyForAccount,
                  )
                else if (filtered.isEmpty)
                  _EmptyBody(
                    message: hasActiveFilters
                        ? l.notificationsEmptyFiltered
                        : l.notificationsEmpty,
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
                              child: LiquidGlassCard(
                                padding: EdgeInsets.zero,
                                borderRadius: BorderRadius.circular(20),
                                blurSigma: 10,
                                color: _tone(context, item.severity).withValues(alpha: 0.68),
                                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 22,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 12),
                                    color: Colors.black.withValues(alpha: 0.08),
                                  ),
                                ],
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      context.push(
                                        '/notifications/${Uri.encodeComponent(item.id)}',
                                        extra: item,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: LiquidGlassCard(
                                              borderRadius: BorderRadius.circular(999),
                                              blurSigma: 8,
                                              color: cs.surface.withValues(alpha: 0.9),
                                              border: Border.all(
                                                color: cs.outlineVariant.withValues(alpha: 0.14),
                                              ),
                                              child: Icon(_iconFor(item.source), size: 20),
                                            ),
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
                                                        item.title,
                                                        style: const TextStyle(fontWeight: FontWeight.w900),
                                                      ),
                                                    ),
                                                    if (!item.isRead)
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
                                                const SizedBox(height: 6),
                                                Text(
                                                  item.body,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                                                ),
                                                const SizedBox(height: 8),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    _MetaPill(label: _sourceLabel(context, item.source).toUpperCase()),
                                                    _MetaPill(label: _timeLabel(item.createdAt)),
                                                    _MetaPill(label: item.isLocal ? l.local.toUpperCase() : l.server.toUpperCase()),
                                                    if (!item.isRead) _MetaPill(label: l.notificationsNewBadge.toUpperCase()),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        l.openDetails,
                                                        style: TextStyle(
                                                          color: cs.primary,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                    if (!item.isRead)
                                                      TextButton.icon(
                                                        onPressed: () => ref.read(notificationActionsProvider).markRead(item),
                                                        icon: const Icon(Icons.done_rounded),
                                                        label: Text(l.markRead),
                                                      )
                                                    else
                                                      TextButton.icon(
                                                        onPressed: () => ref.read(notificationActionsProvider).markUnread(item),
                                                        icon: const Icon(Icons.markunread_rounded),
                                                        label: Text(l.markUnread),
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(18),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.78),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
    this.initialNotification,
  });

  final String notificationId;
  final StudentNotificationItem? initialNotification;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markReadIfNeeded(widget.initialNotification);
    });
  }

  Future<void> _markReadIfNeeded(StudentNotificationItem? item) async {
    if (item == null || item.isRead) return;
    await ref.read(notificationActionsProvider).markRead(item);
  }

  StudentNotificationItem? _resolveItem(List<StudentNotificationItem> items) {
    for (final item in items) {
      if (item.id == widget.notificationId) {
        return item;
      }
    }
    return widget.initialNotification;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notificationInboxProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: async.when(
        loading: () {
          final initial = widget.initialNotification;
          if (initial == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              LiquidGlassCard(
                padding: const EdgeInsets.all(18),
                borderRadius: BorderRadius.circular(28),
                blurSigma: 18,
                gradient: LinearGradient(
                  colors: [
                    _tone(context, initial.severity).withValues(alpha: 0.88),
                    cs.surfaceContainerHigh.withValues(alpha: 0.78),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.24),
                ),
                child: _NotificationDetailBody(item: initial),
              ),
            ],
          );
        },
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) {
          final item = _resolveItem(items);
          if (item == null) {
            return _EmptyBody(
              message: AppLocalizations.of(context)!.notificationsUnavailable,
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _markReadIfNeeded(item);
          });

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(notificationSyncServiceProvider).sync();
              ref.invalidate(notificationInboxProvider);
              await ref.read(notificationInboxProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                LiquidGlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(28),
                  blurSigma: 18,
                  gradient: LinearGradient(
                    colors: [
                      _tone(context, item.severity).withValues(alpha: 0.88),
                      cs.surfaceContainerHigh.withValues(alpha: 0.78),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.24),
                  ),
                  child: _NotificationDetailBody(item: item),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationDetailBody extends ConsumerWidget {
  const _NotificationDetailBody({required this.item});

  final StudentNotificationItem item;

  String _sourceLabel(BuildContext context, String source) {
    final l = AppLocalizations.of(context)!;
    switch (source.trim().toLowerCase()) {
      case 'grades':
        return l.navGrades;
      case 'attendance':
        return l.navAttendance;
      case 'practice':
        return l.navPractice;
      case 'solutions':
        return l.navSolutions;
      case 'system':
        return l.notificationsSourceSystem;
      default:
        return source.trim().isEmpty ? l.notificationsSourceSystem : source.trim();
    }
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
      case 'system':
        return Icons.settings_suggest_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  String _severityLabel(BuildContext context, StudentNotificationSeverity severity) {
    final l = AppLocalizations.of(context)!;
    switch (severity) {
      case StudentNotificationSeverity.critical:
        return l.notificationsSeverityCritical;
      case StudentNotificationSeverity.warning:
        return l.notificationsSeverityWarning;
      case StudentNotificationSeverity.info:
        return l.notificationsSeverityInfo;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    // For local notifications, watch localNotificationsProvider directly so
    // mark-read / mark-unread updates appear instantly without the full inbox reload.
    final freshItem = item.isLocal
        ? ref.watch(localNotificationsProvider).maybeWhen(
              data: (locals) => locals.firstWhere(
                (e) => e.id == item.id,
                orElse: () => item,
              ),
              orElse: () => item,
            )
        : item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: LiquidGlassCard(
            borderRadius: BorderRadius.circular(999),
            blurSigma: 10,
            color: cs.surface.withValues(alpha: 0.92),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
            child: Icon(_iconFor(freshItem.source), size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          freshItem.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaPill(label: _sourceLabel(context, freshItem.source).toUpperCase()),
            _MetaPill(label: _severityLabel(context, freshItem.severity).toUpperCase()),
            _MetaPill(label: freshItem.isLocal ? l.local.toUpperCase() : l.server.toUpperCase()),
            _MetaPill(label: freshItem.isRead ? l.read.toUpperCase() : l.unread.toUpperCase()),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          _friendlyNotificationDateTime(context, freshItem.createdAt),
          style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(22),
          blurSigma: 12,
          color: cs.surface.withValues(alpha: 0.62),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
          child: Text(
            freshItem.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (!freshItem.isRead)
              FilledButton.icon(
                onPressed: () =>
                    ref.read(notificationActionsProvider).markRead(freshItem),
                icon: const Icon(Icons.done_rounded),
                label: Text(l.markRead),
              )
            else
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(notificationActionsProvider).markUnread(freshItem),
                icon: const Icon(Icons.markunread_rounded),
                label: Text(l.markUnread),
              ),
          ],
        ),
      ],
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
      blurSigma: 8,
      color: cs.surface.withValues(alpha: 0.68),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.16)),
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      blurSigma: 12,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.46),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
      child: Text(
        message,
        style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
      ),
    );
  }
}
