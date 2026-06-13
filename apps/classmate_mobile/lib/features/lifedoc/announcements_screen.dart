import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/realtime/realtime_listener.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/attachment_pill.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import 'announcements_models.dart';
import 'announcements_provider.dart';
import '../../ui/widgets/cm_loading.dart';

final announcementReadStateProvider =
    NotifierProvider<AnnouncementReadController, Set<String>>(
      AnnouncementReadController.new,
    );

const String _readStateUnread = '__unread__';
const String _readStateRead = '__read__';

class AnnouncementReadController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return const <String>{};
  }

  static const String _prefsKey = 'lifedoc_announcement_read_ids_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? const <String>[];
    state = saved
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  Future<void> _persist(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, ids.toList()..sort());
  }

  Future<void> markRead(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty || state.contains(cleanId)) return;
    final next = <String>{...state, cleanId};
    state = next;
    await _persist(next);
    // Sync to server for real announcements (UUIDs from /announcements/feed).
    // Locally-generated insight IDs are silently ignored by the server.
    ref.read(announcementsApiProvider).markSeen(cleanId).ignore();
  }

  Future<void> markUnread(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty || !state.contains(cleanId)) return;
    final next = <String>{...state}..remove(cleanId);
    state = next;
    await _persist(next);
  }

  Future<void> markAllRead(Iterable<String> ids) async {
    final cleaned = ids
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
    if (cleaned.isEmpty) return;
    final next = <String>{...state, ...cleaned};
    if (next.length == state.length) return;
    state = next;
    await _persist(next);
  }
}

String _friendlyDateTime(BuildContext context, DateTime value) {
  final material = MaterialLocalizations.of(context);
  final use24Hour = MediaQuery.maybeOf(context)?.alwaysUse24HourFormat ?? false;
  final date = material.formatMediumDate(value);
  final time = material.formatTimeOfDay(
    TimeOfDay.fromDateTime(value),
    alwaysUse24HourFormat: use24Hour,
  );
  return '$date • $time';
}

String _sourceLabel(BuildContext context, String source) {
  final l = AppLocalizations.of(context)!;
  switch (source.trim()) {
    case 'grades':
      return l.navGrades;
    case 'attendance':
      return l.navAttendance;
    case 'practice':
      return l.navPractice;
    case 'solutions':
      return l.navSolutions;
    default:
      return l.notificationsSourceSystem;
  }
}

IconData _sourceIcon(String source) {
  switch (source.trim()) {
    case 'grades':
      return Icons.leaderboard_rounded;
    case 'attendance':
      return Icons.fact_check_rounded;
    case 'practice':
      return Icons.bolt_rounded;
    case 'solutions':
      return Icons.menu_book_rounded;
    default:
      return Icons.campaign_rounded;
  }
}

Color _severityTone(BuildContext context, AnnouncementSeverity severity) {
  final cs = Theme.of(context).colorScheme;
  switch (severity) {
    case AnnouncementSeverity.critical:
      return cs.errorContainer;
    case AnnouncementSeverity.warning:
      return cs.tertiaryContainer;
    case AnnouncementSeverity.info:
      return cs.secondaryContainer;
  }
}

/// Translates the title of a system-generated announcement. Falls back to
/// the literal text stored on the item for free-form posts (template == null).
String _announcementTitleLocalized(BuildContext context, AnnouncementItem item) {
  final t = item.template;
  if (t == null) return item.title;
  final l = AppLocalizations.of(context)!;
  switch (t) {
    case AnnouncementTemplate.gradeRisk:
      return l.announcementGradeRiskTitle;
    case AnnouncementTemplate.weakSubject:
      return l.announcementWeakSubjectTitle;
    case AnnouncementTemplate.lowAttendance:
      return l.announcementLowAttendanceTitle;
    case AnnouncementTemplate.lateness:
      return l.announcementRepeatedLatenessTitle;
    case AnnouncementTemplate.practiceWeakTopic:
      return l.announcementPracticeWeaknessTitle;
    case AnnouncementTemplate.practiceDrop:
      return l.announcementPracticeTrendDroppedTitle;
    case AnnouncementTemplate.solutionsActivity:
      return l.announcementSolutionsActivityTitle;
    case AnnouncementTemplate.allGood:
      return l.announcementAllGoodTitle;
  }
}

String _announcementBodyLocalized(BuildContext context, AnnouncementItem item) {
  final t = item.template;
  if (t == null) return item.body;
  final l = AppLocalizations.of(context)!;
  final args = item.templateArgs;
  switch (t) {
    case AnnouncementTemplate.gradeRisk:
      return l.announcementGradeRiskBody;
    case AnnouncementTemplate.weakSubject:
      return l.announcementWeakSubjectBody((args['subject'] ?? '').toString());
    case AnnouncementTemplate.lowAttendance:
      return l.announcementLowAttendanceBody;
    case AnnouncementTemplate.lateness:
      return l.announcementLatenessBody;
    case AnnouncementTemplate.practiceWeakTopic:
      return l.announcementPracticeWeakTopicBody(
        (args['topic'] ?? '').toString(),
        (args['subject'] ?? '').toString(),
      );
    case AnnouncementTemplate.practiceDrop:
      return l.announcementPracticeDropBody;
    case AnnouncementTemplate.solutionsActivity:
      return l.announcementSolutionsActivityBody(
        (args['page'] as int?) ?? 0,
        (args['question'] as int?) ?? 0,
      );
    case AnnouncementTemplate.allGood:
      return l.announcementAllGoodBody;
  }
}

String _severityLabelLocalized(BuildContext context, AnnouncementSeverity severity) {
  final l = AppLocalizations.of(context)!;
  switch (severity) {
    case AnnouncementSeverity.critical:
      return l.notificationsSeverityCritical;
    case AnnouncementSeverity.warning:
      return l.notificationsSeverityWarning;
    case AnnouncementSeverity.info:
      return l.notificationsSeverityInfo;
  }
}

String _friendlyError(BuildContext context, Object error) {
  final l = AppLocalizations.of(context)!;
  final raw = error.toString().replaceFirst('Exception: ', '').trim();
  if (raw.isEmpty) return l.announcementsLoadError;
  final lowered = raw.toLowerCase();
  if (lowered.contains('timeout')) return l.announcementsLoadTimeout;
  if (lowered.contains('socket') || lowered.contains('network')) {
    return l.announcementsLoadNetwork;
  }
  return raw;
}

String _audienceLabel(BuildContext context, bool isTeacherLike) {
  final l = AppLocalizations.of(context)!;
  return isTeacherLike ? l.announcementsAudienceTeacher : l.announcementsAudienceAccount;
}

String _workspaceLabel(BuildContext context, bool isTeacherLike) {
  final l = AppLocalizations.of(context)!;
  return isTeacherLike
      ? l.announcementsAudienceTeacherWorkspace
      : l.announcementsAudienceAccount;
}

String _readStateLabel(BuildContext context, bool isRead) {
  final l = AppLocalizations.of(context)!;
  return isRead ? l.read : l.unread;
}

String _readStateLabelFromValue(BuildContext context, String value) {
  if (value == _readStateRead) return AppLocalizations.of(context)!.read;
  if (value == _readStateUnread) return AppLocalizations.of(context)!.unread;
  return AppLocalizations.of(context)!.allStates;
}

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

enum _AnnouncementsView { received, published }

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  static const String _allSources = '__all_sources__';
  static const String _allReadStates = '__all_read_states__';

  String _selectedSource = _allSources;
  String _selectedReadState = _allReadStates;
  _AnnouncementsView _view = _AnnouncementsView.received;
  Timer? _realtimeDebounce;

  @override
  void dispose() {
    _realtimeDebounce?.cancel();
    super.dispose();
  }

  List<AnnouncementItem> _filteredItems(
    List<AnnouncementItem> items,
    Set<String> readIds,
  ) {
    return items.where((item) {
      final isRead = readIds.contains(item.id);
      final sourceMatches =
          _selectedSource == _allSources || item.source == _selectedSource;
      final readMatches =
          _selectedReadState == _allReadStates ||
          (_selectedReadState == _readStateRead && isRead) ||
          (_selectedReadState == _readStateUnread && !isRead);
      return sourceMatches && readMatches;
    }).toList(growable: false);
  }

  String _filterSummaryLabel(
    BuildContext context,
    int filteredCount,
    int totalCount,
    String source,
    String readState,
  ) {
    final l = AppLocalizations.of(context)!;
    final sourceSegment = source == _allSources
        ? ''
        : l.announcementsSummarySourceSegment(_sourceLabel(context, source));
    final stateSegment = readState == _allReadStates
        ? ''
        : l.announcementsSummaryStateSegment(
            _readStateLabelFromValue(context, readState),
          );
    return l.announcementsShowingSummary(
      filteredCount,
      totalCount,
      sourceSegment,
      stateSegment,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedSource = _allSources;
      _selectedReadState = _allReadStates;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final isTeacher = session.isTeacherLike;
    final showPublished = isTeacher && _view == _AnnouncementsView.published;
    final announcementsAsync = showPublished
        ? ref.watch(myAnnouncementsProvider)
        : ref.watch(publishedAnnouncementsProvider);
    final readIds = ref.watch(announcementReadStateProvider);
    final accountLabel = _audienceLabel(context, session.isTeacherLike);
    final myId = session.userId;

    // Refresh when a new announcement is created (real-time push)
    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'notification') {
        // Debounce rapid events (e.g. bulk announcements) to avoid multiple fetches
        _realtimeDebounce?.cancel();
        _realtimeDebounce = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          ref.invalidate(publishedAnnouncementsProvider);
          ref.invalidate(myAnnouncementsProvider);
        });
      }
    });

    // Teacher Received/Published toggle is rendered ABOVE the async content so
    // it stays visible (and switchable) even while a tab's data is loading.
    return Scaffold(
      body: Column(
        children: [
          if (isTeacher)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _ViewToggle(
                view: _view,
                receivedLabel: l.announcementsTabReceived,
                publishedLabel: l.announcementsTabPublished,
                onChanged: (v) => setState(() => _view = v),
              ),
            ),
          Expanded(
            child: announcementsAsync.when(
              loading: () => const Center(child: CmLoading()),
              error: (error, _) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _EmptyStateCard(
                    title: l.announcementsLoadFailedTitle,
                    subtitle: _friendlyError(context, error),
                    hint: l.announcementsLoadFailedHint,
                  ),
                ],
              ),
              data: (rawAnnouncements) {
        // "Received" excludes the teacher's own published posts (those live
        // on the Published tab); system-generated rows have an empty
        // createdBy and always stay in Received.
        final announcements = showPublished
            ? rawAnnouncements
            : rawAnnouncements
                .where((item) => item.createdBy.isEmpty || item.createdBy != myId)
                .toList(growable: false);

        final sources = announcements.map((item) => item.source).toSet().toList()..sort();
        final safeSource = sources.contains(_selectedSource) ? _selectedSource : _allSources;
        if (safeSource != _selectedSource) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _selectedSource = safeSource);
          });
        }

        final filtered = _filteredItems(announcements, readIds);
        final unreadCount = announcements.where((item) => !readIds.contains(item.id)).length;
        final readCount = announcements.length - unreadCount;
        final hasUnread = unreadCount > 0;
        final latest = announcements.isEmpty ? null : announcements.first;
        final hasActiveFilters =
            safeSource != _allSources || _selectedReadState != _allReadStates;

        return RefreshIndicator(
            onRefresh: () async {
              if (showPublished) {
                ref.invalidate(myAnnouncementsProvider);
                await ref.read(myAnnouncementsProvider.future);
              } else {
                ref.invalidate(publishedAnnouncementsProvider);
                await ref.read(publishedAnnouncementsProvider.future);
              }
            },
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _HeroCard(
                  title: l.navAnnouncements,
                  subtitle: l.announcementsHeroSubtitle(accountLabel),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.campaign_rounded,
                              label: l.total,
                              value: '${announcements.length}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.markunread_rounded,
                              label: l.unread,
                              value: '$unreadCount',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.done_all_rounded,
                              label: l.read,
                              value: '$readCount',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: latest == null
                                  ? Icons.campaign_rounded
                                  : _sourceIcon(latest.source),
                              label: l.announcementsLatestSourceLabel,
                              value: latest == null
                                  ? l.announcementsNone
                                  : _sourceLabel(context, latest.source),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SignalBanner(
                        icon: hasUnread
                            ? Icons.notification_important_rounded
                            : Icons.task_alt_rounded,
                        title: hasUnread
                            ? l.announcementsUnreadCountTitle(unreadCount)
                            : l.announcementsAllReadTitle,
                        body: latest == null
                            ? l.announcementsEmptyForAudience(accountLabel)
                            : l.announcementsLatestBody(_announcementTitleLocalized(context, latest)),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: hasUnread
                              ? () => ref
                                  .read(announcementReadStateProvider.notifier)
                                  .markAllRead(announcements.map((item) => item.id))
                              : null,
                          icon: const Icon(Icons.done_all_rounded),
                          label: Text(l.markAllRead),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: l.filters,
                  subtitle: l.announcementsFiltersSubtitle,
                  child: Column(
                    children: [
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
                              icon: _sourceIcon(source),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedSource = value);
                        },
                        searchHint: l.notificationsSearchSourcesHint,
                      ),
                      const SizedBox(height: 10),
                      LiquidGlassDropdown<String>(
                        label: l.state,
                        value: _selectedReadState,
                        items: [
                          LiquidGlassDropdownItem(
                            value: _allReadStates,
                            label: l.announcementsAllAnnouncements,
                            icon: Icons.filter_alt_rounded,
                          ),
                          LiquidGlassDropdownItem(
                            value: _readStateUnread,
                            label: l.unread,
                            icon: Icons.markunread_rounded,
                          ),
                          LiquidGlassDropdownItem(
                            value: _readStateRead,
                            label: l.read,
                            icon: Icons.done_rounded,
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedReadState = value);
                        },
                        searchHint: l.announcementsSearchStatesHint,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _filterSummaryLabel(
                                context,
                                filtered.length,
                                announcements.length,
                                safeSource,
                                _selectedReadState,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                          if (hasActiveFilters) ...[
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: _clearFilters,
                              child: Text(l.clear),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  _EmptyStateCard(
                    title: hasActiveFilters
                        ? l.announcementsNoMatchTitle
                        : l.announcementsNoPublishedTitle,
                    subtitle: hasActiveFilters
                        ? l.announcementsNoMatchSubtitle
                        : l.announcementsEmptyForAudience(accountLabel),
                    hint: hasActiveFilters
                        ? l.announcementsClearFiltersHint
                        : l.announcementsPullToRefreshHint,
                  )
                else
                  _SectionCard(
                    title: l.announcementsInboxTitle,
                    subtitle: l.announcementsInboxSubtitle,
                    child: Column(
                      children: filtered
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AnnouncementCard(
                                announcement: item,
                                isRead: readIds.contains(item.id),
                                onTap: () async {
                                  await ref
                                      .read(announcementReadStateProvider.notifier)
                                      .markRead(item.id);
                                  if (!context.mounted) return;
                                  context.push('/announcements/${item.id}');
                                },
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
              ],
            ),
          );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementDetailScreen extends ConsumerStatefulWidget {
  const AnnouncementDetailScreen({super.key, required this.announcementId});

  final String announcementId;

  @override
  ConsumerState<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends ConsumerState<AnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(announcementReadStateProvider.notifier).markRead(widget.announcementId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(publishedAnnouncementsProvider);
    final readIds = ref.watch(announcementReadStateProvider);

    return announcementsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CmLoading()),
      ),
      error: (error, _) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailTopBar(onBack: () => context.pop()),
                const SizedBox(height: 24),
                _EmptyStateCard(
                  title: AppLocalizations.of(context)!.announcementsLoadFailedTitle,
                  subtitle: _friendlyError(context, error),
                  hint: AppLocalizations.of(context)!.announcementsDetailLoadFailedHint,
                ),
              ],
            ),
          ),
        ),
      ),
      data: (announcements) {
        final session = ref.watch(authSessionProvider);
        final accountLabel = _workspaceLabel(context, session.isTeacherLike);
        // Teachers may open an announcement they published that isn't in
        // their received feed (e.g. targeted only at students). Merge in
        // their "Published" list so the detail still resolves.
        final published = session.isTeacherLike
            ? ref.watch(myAnnouncementsProvider).maybeWhen(
                  data: (v) => v,
                  orElse: () => const <AnnouncementItem>[],
                )
            : const <AnnouncementItem>[];
        final pool = <AnnouncementItem>[...announcements, ...published];
        final announcement = pool.cast<AnnouncementItem?>().firstWhere(
          (item) => item?.id == widget.announcementId,
          orElse: () => null,
        );

        if (announcement == null) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailTopBar(onBack: () => context.pop()),
                    const SizedBox(height: 24),
                    _EmptyStateCard(
                      title: AppLocalizations.of(context)!.announcementsUnavailableTitle,
                      subtitle: AppLocalizations.of(context)!
                          .announcementsUnavailableSubtitle(accountLabel),
                      hint: AppLocalizations.of(context)!.announcementsUnavailableHint,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isRead = readIds.contains(announcement.id);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            _DetailTopBar(onBack: () => context.pop()),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _Chip(
                                        label: _severityLabelLocalized(
                                          context,
                                          announcement.severity,
                                        ),
                                        backgroundColor: _severityTone(context, announcement.severity),
                                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      _Chip(
                                        label: _sourceLabel(context, announcement.source),
                                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _announcementTitleLocalized(context, announcement),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _SignalBanner(
                                    icon: _sourceIcon(announcement.source),
                                    title: _friendlyDateTime(context, announcement.createdAt),
                                    body: AppLocalizations.of(context)!
                                        .announcementsPublishedReadStateBody(accountLabel),
                                  ),
                                ],
                              ),
                            ),
                            // Detail metadata rows (source / severity / state /
                            // created / id) were removed — they duplicated the
                            // header chips + date banner and made the sheet
                            // feel cluttered. The body speaks for itself.
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: AppLocalizations.of(context)!
                                  .announcementsFullContentTitle,
                              subtitle: '',
                              child: Text(
                                _announcementBodyLocalized(context, announcement),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.55,
                                ),
                              ),
                            ),
                            if (announcement.attachments.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: AppLocalizations.of(context)!.teacherMaterialAttachmentsTitle,
                                subtitle: AppLocalizations.of(context)!.studentFilesSharedWithAnnouncement,
                                child: AttachmentPills(attachments: announcement.attachments),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .announcementsReadStateTitle,
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isRead
                                        ? AppLocalizations.of(context)!
                                            .announcementsReadStateBodyRead
                                        : AppLocalizations.of(context)!
                                            .announcementsReadStateBodyUnread,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: () {
                                final notifier = ref.read(announcementReadStateProvider.notifier);
                                if (isRead) {
                                  notifier.markUnread(announcement.id);
                                } else {
                                  notifier.markRead(announcement.id);
                                }
                              },
                              icon: Icon(isRead ? Icons.markunread_rounded : Icons.done_rounded),
                              label: Text(
                                isRead
                                    ? AppLocalizations.of(context)!.markUnread
                                    : AppLocalizations.of(context)!.markRead,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.isRead,
    required this.onTap,
  });

  final AnnouncementItem announcement;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(24),
        color: isRead ? cs.surfaceContainerLowest : cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(_sourceIcon(announcement.source), color: cs.onSurface),
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
                          _announcementTitleLocalized(context, announcement),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!isRead)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(
                        label: _readStateLabel(context, isRead),
                        backgroundColor: isRead ? cs.secondaryContainer : cs.tertiaryContainer,
                        foregroundColor: cs.onSurface,
                      ),
                      _Chip(
                        label: _sourceLabel(context, announcement.source),
                        backgroundColor: cs.surface,
                        foregroundColor: cs.onSurface,
                      ),
                      _Chip(
                        label: _friendlyDateTime(context, announcement.createdAt),
                        backgroundColor: cs.surface,
                        foregroundColor: cs.onSurfaceVariant,
                      ),
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

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.view,
    required this.receivedLabel,
    required this.publishedLabel,
    required this.onChanged,
  });

  final _AnnouncementsView view;
  final String receivedLabel;
  final String publishedLabel;
  final ValueChanged<_AnnouncementsView> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget seg(String label, _AnnouncementsView v, IconData icon) {
      final selected = view == v;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? cs.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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

    return LiquidGlassCard(
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(999),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Row(
        children: [
          seg(receivedLabel, _AnnouncementsView.received, Icons.inbox_rounded),
          seg(publishedLabel, _AnnouncementsView.published, Icons.campaign_rounded),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      color: cs.primaryContainer,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: cs.onPrimaryContainer.withValues(alpha: 0.75), height: 1.35),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

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

class _SignalBanner extends StatelessWidget {
  const _SignalBanner({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: cs.onSurfaceVariant, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: cs.outlineVariant),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foregroundColor ?? cs.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.hint,
  });

  final String title;
  final String subtitle;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
          const SizedBox(height: 10),
          Text(
            hint,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ],
    );
  }
}

