import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/semester/school_semester.dart';
import '../../core/util/friendly_date.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import '../../ui/widgets/semester_filter_bar.dart';
import '../../l10n/app_localizations.dart';
import 'notifications_local_service.dart';
import 'notifications_models.dart';
import 'notifications_provider.dart';
import '../../ui/widgets/cm_loading.dart';

/// Translate a notification title when the item carries a known
/// template; fall back to the literal text for server-pushed items.
String _notificationTitleLocalized(
    BuildContext context, StudentNotificationItem item) {
  final t = item.template;
  if (t == null) return item.title;
  final l = AppLocalizations.of(context)!;
  switch (t) {
    case StudentNotificationTemplate.newGradePosted:
      return l.notificationNewGradePosted;
    case StudentNotificationTemplate.newGradePostedIn:
      return l.notificationNewGradePostedIn(
        (item.templateArgs['subject'] ?? '').toString(),
      );
  }
}

String _friendlyNotificationDateTime(BuildContext context, DateTime value) {
  return FriendlyDate.dateTime(value);
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
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;

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
    return FriendlyDate.time(date);
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
        return cs.errorContainer;
      case StudentNotificationSeverity.warning:
        return cs.tertiaryContainer;
      case StudentNotificationSeverity.info:
        return cs.surfaceContainerHighest;
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
        loading: () => const Center(child: CmLoading()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (allItems) {
          // Semester split (by notification date) — pills only show when the
          // school configured semesters.
          final semWindow = ref.watch(currentSemesterWindowProvider);
          final items = visibleForSemester<StudentNotificationItem>(
            allItems,
            (e) => e.createdAt,
            semWindow,
            _showingPrevious,
            _selectedPast,
          );
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
              padding: EdgeInsets.fromLTRB(
                  16, 16 + MediaQuery.paddingOf(context).top, 16, 28),
              children: [
                LiquidGlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(24),
                  color: cs.primaryContainer,
                  border: Border.all(color: cs.outlineVariant),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.navNotifications,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        heroSubtitle,
                        style: TextStyle(color: cs.onPrimaryContainer, height: 1.35),
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
                        alignment: AlignmentDirectional.centerStart,
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
                SemesterFilterBar(
                  visible: semWindow != null,
                  showingPrevious: _showingPrevious,
                  onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
                  selectedPast: _selectedPast,
                  onPastChanged: (w) => setState(() => _selectedPast = w),
                ),
                if (items.isNotEmpty)
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(24),

                    border: Border.all(color: cs.outlineVariant),
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
                                color: _tone(context, item.severity),
                                border: Border.all(color: cs.outlineVariant),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      // Always open the detail screen first; it
                                      // shows the full notification and a
                                      // "redirect" button to the relevant tab.
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
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: cs.surfaceContainerLow,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: cs.outlineVariant),
                                            ),
                                            child: Center(child: Icon(_iconFor(item.source), size: 20)),
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
                                                        _notificationTitleLocalized(context, item),
                                                        style: const TextStyle(fontWeight: FontWeight.w900),
                                                      ),
                                                    ),
                                                    if (!item.isRead)
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        margin: const EdgeInsetsDirectional.only(start: 8, top: 6),
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
                                                    if (!item.isRead) _MetaPill(label: l.notificationsNewBadge.toUpperCase()),
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
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
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

  /// "Open" button that redirects to the screen this notification is about
  /// (grades / meeting / assignment / announcement / …). Uses go() so the
  /// app shell resolves the destination — updating the drawer highlight, the
  /// top pill title, and showing the bottom nav when it's a core tab.
  Widget _redirectButton(StudentNotificationItem item) {
    final route = LocalNotificationsService.routeFromPayload(
      '${item.source}|${item.id}',
    );
    if (route.isEmpty || route == '/notifications') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => context.go(route),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(AppLocalizations.of(context)!.commonOpen),
        ),
      ),
    );
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
            return const Center(child: CmLoading());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              LiquidGlassCard(
                padding: const EdgeInsets.all(18),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: cs.outlineVariant,
                ),
                child: _NotificationDetailBody(item: initial),
              ),
              _redirectButton(initial),
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

          // Do NOT call _markReadIfNeeded here — it fires on every rebuild
          // (including after mark-unread), causing the unread state to flip
          // back to read immediately. initState handles the initial mark-read.

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
                  border: Border.all(
                    color: cs.outlineVariant,
                  ),
                  child: _NotificationDetailBody(item: item),
                ),
                _redirectButton(item),
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
            color: cs.surfaceContainerLow,
            border: Border.all(color: cs.outlineVariant),
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
          borderRadius: BorderRadius.circular(24),
          color: cs.surfaceContainerLow,
          border: Border.all(color: cs.outlineVariant),
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

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Text(
        message,
        style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
      ),
    );
  }
}
