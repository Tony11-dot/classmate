// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/realtime/realtime_listener.dart';
import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/attachment_pill.dart';
import '../../chat_core/controllers/classroom_chat_thread_controller.dart';
import '../../chat_core/policies/chat_action_policy.dart';
import '../../chat_core/ui/chat_thread_view.dart';
import '../data/classrooms_repository.dart';
import '../providers/classrooms_repo_provider.dart';
import '../providers/classrooms_providers.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

class ClassroomDetailScreen extends ConsumerStatefulWidget {
  const ClassroomDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<ClassroomDetailScreen> createState() =>
      _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends ConsumerState<ClassroomDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);
  late final ClassroomChatThreadController _chatController;

  bool _classroomTabsCollapsed = false;
  int _activeClassroomTabIndex = 0;

  String get _classroomTabsCollapsedPrefsKey =>
      'classroom_tabs_collapsed_${widget.courseId}';

  @override
  void initState() {
    super.initState();
    final session = ref.read(authSessionProvider);
    // Strict: use ONLY the JWT sub for ownership comparisons. The previous
    // fallback to displayName / raw token could cause messages to render
    // as "mine" after a profile switch if JWT decode flickered, since the
    // displayName might still match the previously-cached value.
    _chatController = ClassroomChatThreadController(
      ref: ref,
      courseId: widget.courseId,
      currentUserId: session.userId,
    );

    _loadClassroomTabsCollapsed();
    _tabs.addListener(() {
      if (!mounted) return;
      if (!_tabs.indexIsChanging && _activeClassroomTabIndex != _tabs.index) {
        setState(() => _activeClassroomTabIndex = _tabs.index);
      }
      if (!_tabs.indexIsChanging && _tabs.index == 0) {
        Future.microtask(() => _chatController.markRead());
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadClassroomTabsCollapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_classroomTabsCollapsedPrefsKey) ?? false;
      if (!mounted) return;
      setState(() => _classroomTabsCollapsed = saved);
    } catch (_) {}
  }

  Future<void> _persistClassroomTabsCollapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        _classroomTabsCollapsedPrefsKey,
        _classroomTabsCollapsed,
      );
    } catch (_) {}
  }

  Future<void> _openUrl(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.startsWith('/') || trimmed.startsWith('file:')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.classroomFileNotAvailable)),
      );
      return;
    }
    Uri? uri = Uri.tryParse(trimmed);
    if (uri != null && !uri.hasScheme && trimmed.contains('.')) {
      uri = Uri.tryParse('https://$trimmed');
    }
    if (uri == null || !uri.hasScheme) return;
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.classroomsCouldNotOpenLink)),
      );
    }
  }

  void _goBackToClassrooms() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/classrooms');
    }
  }

  void _refreshAll() {
    ref.invalidate(classroomDetailProvider(widget.courseId));
    ref.invalidate(classroomPeopleProvider(widget.courseId));
    ref.invalidate(classroomAssignmentsProvider(widget.courseId));
    ref.invalidate(classroomMaterialsProvider(widget.courseId));
    ref.invalidate(classroomMeetingsProvider(widget.courseId));
  }

  bool _isCurrentUserTeacher(AsyncValue<Map<String, dynamic>> people) {
    return people.whenOrNull(
          data: (peopleData) {
            final items = (peopleData['items'] is Map)
                ? Map<String, dynamic>.from(peopleData['items'] as Map)
                : <String, dynamic>{};
            final teacherUserId =
                (items['teacherUserId'] ?? '').toString().trim();
            if (teacherUserId.isEmpty) return false;
            final session = ref.read(authSessionProvider);
            // userId is the JWT sub claim — the correct identifier for ownership checks
            final myId = session.userId.isNotEmpty ? session.userId : '';
            return myId.isNotEmpty && myId == teacherUserId;
          },
        ) ??
        false;
  }

  Future<void> _leaveClassroom() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.classroomDetailLeaveClassroomTitle),
        content: Text(l.classroomDetailLeaveClassroomBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomsForwardCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.classroomDetailLeaveAction),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await ClassroomsRepository().leaveClassroom(widget.courseId);
    ref.invalidate(classroomDetailProvider(widget.courseId));
    ref.invalidate(classroomPeopleProvider(widget.courseId));
    ref.invalidate(
      classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
    );
    // Crucial: also invalidate the list providers. Without this, the
    // home screen reads the cached list (still including this classroom)
    // and the user reports the classroom "still there" after leaving.
    ref.invalidate(studentClassroomsProvider);
    ref.invalidate(orderedStudentClassroomsProvider);

    if (!mounted) return;
    _goBackToClassrooms();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final detail = ref.watch(classroomDetailProvider(widget.courseId));
    final people = ref.watch(classroomPeopleProvider(widget.courseId));
    final assignments = ref.watch(
      classroomAssignmentsProvider(widget.courseId),
    );
    final materials = ref.watch(classroomMaterialsProvider(widget.courseId));
    final meetings = ref.watch(classroomMeetingsProvider(widget.courseId));

    // Live-refresh when teacher pushes new assignments/materials/meetings
    ref.listen(realtimeEventProvider, (_, event) {
      if (event == null) return;
      final cid = event.classroomId;
      if (cid != null && cid != widget.courseId) return;
      if (event.type == 'assignment_created') {
        ref.invalidate(classroomAssignmentsProvider(widget.courseId));
      } else if (event.type == 'material_created') {
        ref.invalidate(classroomMaterialsProvider(widget.courseId));
      } else if (event.type == 'meeting_created') {
        ref.invalidate(classroomMeetingsProvider(widget.courseId));
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            detail.when(
              loading: () => const _HeaderSkeleton(),
              error: (e, st) => _TopHeader(
                icon: Icons.book_rounded,
                subject: l.classroomsClassroomLabel,
                subtitle: widget.courseId,
                onRefresh: _refreshAll,
                onBack: _goBackToClassrooms,
                tabsCollapsed: _classroomTabsCollapsed,
                onToggleTabs: () async {
                  setState(() {
                    _classroomTabsCollapsed = !_classroomTabsCollapsed;
                  });
                  await _persistClassroomTabsCollapsed();
                },
                onLeave: _leaveClassroom,
              ),
              data: (m) => _TopHeader(
                icon: _subjectIcon((m['subject'] ?? '').toString()),
                subject: ((m['name'] ?? '').toString().trim().isNotEmpty
                        ? (m['name'] ?? '').toString()
                        : (m['subject'] ?? l.classroomsClassroomLabel).toString())
                    .trim(),
                subtitle: ((m['subject'] ?? '').toString().trim().isNotEmpty
                        ? (m['subject'] ?? '').toString()
                        : widget.courseId)
                    .trim(),
                onRefresh: _refreshAll,
                onBack: _goBackToClassrooms,
                tabsCollapsed: _classroomTabsCollapsed,
                onToggleTabs: () async {
                  setState(() {
                    _classroomTabsCollapsed = !_classroomTabsCollapsed;
                  });
                  await _persistClassroomTabsCollapsed();
                },
                onLeave: _leaveClassroom,
              ),
            ),
            const SizedBox(height: 0),
            if (!_classroomTabsCollapsed) _CenteredTabs(controller: _tabs),
            const SizedBox(height: 2),
            Expanded(
              child: Builder(builder: (_) {
                final tabChildren = <Widget>[
                  CmRefreshIndicator(
                    onRefresh: () async {
                      _chatController.invalidate();
                      _refreshAll();
                    },
                    child: ChatThreadView(
                      controller: _chatController,
                      policy: ChatActionPolicy.classroom(
                        isTeacher: _isCurrentUserTeacher(people),
                      ),
                    ),
                  ),
                  _listTab(
                    value: assignments,
                    emptyTitle: l.classroomDetailNoAssignmentsTitle,
                    emptySubtitle: l.classroomDetailNoAssignmentsSubtitle,
                    itemBuilder: (item) {
                      final assignmentId = _pick(item, 'id');
                      // Resolve classroom metadata for the assignment detail screen.
                      final detailMap = detail.whenOrNull(data: (d) => d) ?? const <String, dynamic>{};
                      final courseName = ((detailMap['name'] ?? '').toString().trim().isNotEmpty
                              ? detailMap['name']
                              : detailMap['subject'] ?? '')
                          .toString()
                          .trim();
                      final courseSubject = (detailMap['subject'] ?? '').toString().trim();
                      final peopleMap = people.whenOrNull(data: (d) => d) ?? const <String, dynamic>{};
                      final items2 = peopleMap['items'] is Map
                          ? Map<String, dynamic>.from(peopleMap['items'] as Map)
                          : const <String, dynamic>{};
                      final teacher = items2['teacher'] is Map
                          ? Map<String, dynamic>.from(items2['teacher'] as Map)
                          : const <String, dynamic>{};
                      final teacherName = (teacher['name'] ?? '').toString().trim();
                      return _SimpleCard(
                        title: _pick(item, 'title',
                            fallback: l.classroomDetailAssignmentFallback),
                        subtitle: _pickFirst(item, ['body', 'description', 'instructions']),
                        trailing: _friendlyDateTime(
                            _pickFirst(item, ['dueAt', 'dueDate', 'due', 'deadline'])),
                        leadingIcon: Icons.assignment_rounded,
                        onTap: assignmentId.isNotEmpty
                            ? () => context.push(
                                '/assignments/$assignmentId',
                                extra: <String, dynamic>{
                                  ...item is Map
                                      ? Map<String, dynamic>.from(item)
                                      : <String, dynamic>{},
                                  '_courseId': widget.courseId,
                                  '_courseName': courseName,
                                  '_subject': courseSubject,
                                  '_teacherName': teacherName,
                                },
                              )
                            : null,
                        // Show teacher-attached files directly in the list
                        attachmentPills: () {
                          final rawAtt = item is Map ? item['attachments'] : null;
                          if (rawAtt is! List || rawAtt.isEmpty) return null;
                          final pills = rawAtt.whereType<Map>()
                              .map((a) => Map<String, dynamic>.from(a)).toList();
                          return AttachmentPills(attachments: pills);
                        }(),
                      );
                    },
                  ),
                  _listTab(
                    value: materials,
                    emptyTitle: l.classroomDetailNoMaterialsTitle,
                    emptySubtitle: l.classroomDetailNoMaterialsSubtitle,
                    itemBuilder: (item) {
                      final url = _pickFirst(item, [
                        'url', 'fileUrl', 'link', 'attachmentUrl', 'downloadUrl',
                      ]);
                      final mime = _pickFirst(item, ['mime', 'mimeType', 'type']);
                      final id = _pick(item, 'id');
                      final isFile = mime.isNotEmpty ||
                          RegExp(r'\.(pdf|doc|docx|xls|xlsx|ppt|pptx|zip|mp4|mp3|jpg|png|jpeg)(\?|$)',
                                  caseSensitive: false)
                              .hasMatch(url);
                      final isTeacher = ref.read(authSessionProvider).isTeacherLike;
                      return _SimpleCard(
                        title: _pick(item, 'title',
                            fallback: l.classroomDetailMaterialFallback),
                        subtitle: _pick(item, 'description'),
                        trailing: mime.isNotEmpty ? mime : '',
                        leadingIcon: isFile
                            ? Icons.insert_drive_file_rounded
                            : Icons.link_rounded,
                        onTap: url.isNotEmpty ? () => _openUrl(url) : null,
                        onDelete: (isTeacher && id.isNotEmpty)
                            ? () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(AppLocalizations.of(ctx)!.classroomDeleteMaterialTitle),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx)!.commonCancel)),
                                      FilledButton(
                                        style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: Text(AppLocalizations.of(ctx)!.commonDelete),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok != true || !mounted) return;
                                try {
                                  await ref.read(classroomsRepoProvider).deleteClassroomMaterial(widget.courseId, id);
                                  ref.invalidate(classroomMaterialsProvider(widget.courseId));
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonErrorWith(e))));
                                }
                              }
                            : null,
                        // Render material attachments inline
                        attachmentPills: () {
                          final rawAtt = item is Map ? item['attachments'] : null;
                          if (rawAtt is! List || rawAtt.isEmpty) return null;
                          final pills = rawAtt.whereType<Map>()
                              .map((a) => Map<String, dynamic>.from(a)).toList();
                          return AttachmentPills(attachments: pills);
                        }(),
                      );
                    },
                  ),
                  _listTab(
                    value: meetings,
                    emptyTitle: l.classroomDetailNoMeetingsTitle,
                    emptySubtitle: l.classroomDetailNoMeetingsSubtitle,
                    itemBuilder: (item) {
                      final link = _pickFirst(item, [
                        'link', 'joinLink', 'meetingLink', 'url', 'joinUrl',
                      ]);
                      return _SimpleCard(
                        title: _pick(item, 'title',
                            fallback: l.classroomDetailMeetingFallback),
                        subtitle: _pickFirst(item, ['agenda', 'description', 'body']),
                        trailing: _friendlyDateTime(
                            _pickFirst(item, ['startsAt', 'startAt', 'date', 'scheduledAt'])),
                        leadingIcon: Icons.video_call_rounded,
                        onTap: link.isNotEmpty ? () => _openUrl(link) : null,
                        actionLabel: link.isNotEmpty ? l.meetingsJoinAction : null,
                      );
                    },
                  ),
                  _peopleTab(people),
                ];
                // Swipeable tabs with opaque backgrounds so the incoming and
                // outgoing tabs don't bleed through each other during a swipe.
                return TabBarView(
                  controller: _tabs,
                  children: tabChildren
                      .map((w) => ColoredBox(
                            color: Theme.of(context).colorScheme.surface,
                            child: w,
                          ))
                      .toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _peopleTab(AsyncValue<Map<String, dynamic>> people) {
    final l = AppLocalizations.of(context)!;
    return people.when(
      loading: () => const Center(child: CmLoading()),
      error: (e, st) => _CenteredState(
        icon: Icons.group_outlined,
        title: l.classroomDetailCouldNotLoadPeople,
        subtitle: '$e',
      ),
      data: (m) {
        // Normalise multiple server response shapes:
        //   {items: {teacher:…, students:[…]}}
        //   {items: [{name,email,role},…]}
        //   {teachers:[…], students:[…]}
        //   {members:[…]}
        Map<String, dynamic> asMapItems() {
          final v = m['items'];
          if (v is Map) return Map<String, dynamic>.from(v);
          return <String, dynamic>{};
        }

        List<dynamic> asList(dynamic v) =>
            v is List ? v : const <dynamic>[];

        final itemsMap = asMapItems();
        final raw = <Map<String, dynamic>>[];

        // Teacher(s) — handle both single teacher map and teachers list
        void addPerson(dynamic p, {bool isTeacher = false}) {
          if (p is! Map) return;
          final person = Map<String, dynamic>.from(p);
          if (isTeacher) person['_isTeacher'] = true;
          raw.add(person);
        }

        final teacher = itemsMap['teacher'] ?? m['teacher'];
        final teacherUserId = (itemsMap['teacherUserId'] ?? m['teacherUserId'] ?? '').toString().trim();
        if (teacher is Map) {
          final t = Map<String, dynamic>.from(teacher);
          t['id'] ??= teacherUserId;
          t['_isTeacher'] = true;
          raw.add(t);
        }
        for (final t in asList(itemsMap['teachers'] ?? m['teachers'])) {
          addPerson(t, isTeacher: true);
        }

        // Students
        for (final s in asList(itemsMap['students'] ?? m['students'])) {
          addPerson(s);
        }

        // Flat members list
        for (final p in asList(m['members'] ?? m['users'])) {
          if (p is Map) {
            final role = (p['role'] ?? p['type'] ?? '').toString().toLowerCase();
            addPerson(p, isTeacher: role.contains('teacher'));
          }
        }

        // If items is a flat list of people
        if (m['items'] is List) {
          for (final p in m['items'] as List) {
            addPerson(p,
                isTeacher: (p is Map &&
                    (p['role'] ?? p['type'] ?? '').toString().toLowerCase().contains('teacher')));
          }
        }

        if (raw.isEmpty) {
          return _CenteredState(
            icon: Icons.group_outlined,
            title: l.classroomDetailNoPeopleTitle,
            subtitle: l.classroomDetailNoPeopleSubtitle,
          );
        }

        final teachers = raw.where((p) => p['_isTeacher'] == true).toList();
        final students = raw.where((p) => p['_isTeacher'] != true).toList();

        // Derive a 6-char classroom code from the courseId UUID.
        final classCode = widget.courseId
            .replaceAll('-', '')
            .substring(0, widget.courseId.replaceAll('-', '').length >= 6 ? 6 : widget.courseId.replaceAll('-', '').length)
            .toUpperCase();

        Widget personTile(Map<String, dynamic> item) {
          final name = _pick(item, 'name', fallback: l.student);
          final email = _pick(item, 'email');
          final isT = item['_isTeacher'] == true;
          final cs = Theme.of(context).colorScheme;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: _panelDecoration(context),
            child: Row(
              children: [
                _InitialsAvatar(name: name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      if (email.trim().isNotEmpty)
                        Text(email,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (isT)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(l.roleTeacher,
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          );
        }

        Widget sectionHeader(String title, int count) {
          final cs = Theme.of(context).colorScheme;
          return Padding(
            padding: const EdgeInsetsDirectional.only(top: 12, bottom: 4, start: 4),
            child: Text(l.classroomDetailSectionHeader(title, count),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.6)),
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 24 + MediaQuery.of(context).viewInsets.bottom),
          children: [
            // ── Classroom code ───────────────────────────────────────────
            LiquidGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.secondaryContainer,
              border: Border.all(color: Theme.of(context).colorScheme.secondary),
              child: Row(children: [
                Icon(Icons.vpn_key_rounded, size: 16,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(AppLocalizations.of(context)!.classroomCodeLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700)),
                    Text(classCode,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Theme.of(context).colorScheme.onSecondaryContainer)),
                  ]),
                ),
              ]),
            ),
            if (teachers.isNotEmpty) ...[
              sectionHeader(l.classroomDetailTeacherSection, teachers.length),
              ...teachers.map(personTile),
            ],
            if (students.isNotEmpty) ...[
              sectionHeader(l.classroomDetailStudentsSection, students.length),
              ...students.map(personTile),
            ],
          ],
        );
      },
    );
  }

  Widget _listTab({
    required AsyncValue<Map<String, dynamic>> value,
    required String emptyTitle,
    required String emptySubtitle,
    required Widget Function(dynamic item) itemBuilder,
  }) {
    final l = AppLocalizations.of(context)!;
    return value.when(
      loading: () => const Center(child: CmLoading()),
      error: (e, st) => _CenteredState(
        icon: Icons.cloud_off_rounded,
        title: l.classroomDetailCouldNotLoadTab,
        subtitle: '$e',
      ),
      data: (m) {
        final raw = (m['items'] is List) ? (m['items'] as List) : const [];
        if (raw.isEmpty) {
          return _CenteredState(
            icon: Icons.inbox_outlined,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            12,
            8,
            12,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          itemCount: raw.length,
          separatorBuilder: (_, _) => const SizedBox(height: 2),
          itemBuilder: (context, index) => itemBuilder(raw[index]),
        );
      },
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.icon,
    required this.subject,
    required this.subtitle,
    required this.onRefresh,
    required this.onBack,
    required this.tabsCollapsed,
    required this.onToggleTabs,
    required this.onLeave,
  });

  final IconData icon;
  final String subject;
  final String subtitle;
  final VoidCallback onRefresh;
  final VoidCallback onBack;
  final bool tabsCollapsed;
  final VoidCallback onToggleTabs;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: BorderRadius.circular(16),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              tooltip: AppLocalizations.of(context)!.commonBack,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.trim().isEmpty
                        ? AppLocalizations.of(context)!.classroomDetailClassroomFallback
                        : subject.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.trim().isEmpty ? ' ' : subtitle.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onLeave,
              icon: const Icon(Icons.logout_rounded, size: 20),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              tooltip: AppLocalizations.of(context)!.tooltipLeaveClassroom,
            ),
            IconButton(
              onPressed: onToggleTabs,
              icon: AnimatedRotation(
                turns: tabsCollapsed ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
              ),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              tooltip: tabsCollapsed ? AppLocalizations.of(context)!.tooltipShowTabs : AppLocalizations.of(context)!.tooltipHideTabs,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: SizedBox(
        height: 84,
        child: LiquidGlassCard(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surface,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CenteredTabs extends StatelessWidget {
  const _CenteredTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(6),
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          labelColor: cs.onPrimaryContainer,
          unselectedLabelColor: cs.onSurfaceVariant,
          splashBorderRadius: BorderRadius.circular(28),
          tabs: [
            Tab(
              child: _TabChipLabel(
                  text: AppLocalizations.of(context)!.classroomDetailTabChat),
            ),
            Tab(
              child: _TabChipLabel(
                  text: AppLocalizations.of(context)!.navAssignments),
            ),
            Tab(
              child: _TabChipLabel(
                  text: AppLocalizations.of(context)!.classroomDetailTabMaterials),
            ),
            Tab(
              child: _TabChipLabel(
                  text: AppLocalizations.of(context)!.navMeetings),
            ),
            Tab(
              child: _TabChipLabel(
                  text: AppLocalizations.of(context)!.classroomDetailTabPeople),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChipLabel extends StatelessWidget {
  const _TabChipLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.onDelete,
    this.actionLabel,
    this.leadingIcon,
    this.attachmentPills,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? actionLabel;
  final IconData? leadingIcon;
  final Widget? attachmentPills;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final card = LiquidGlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(14),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(leadingIcon, size: 18, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.trim().isEmpty
                      ? AppLocalizations.of(context)!.classroomDetailUntitled
                      : title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ],
                if (trailing.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    trailing,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
                if (attachmentPills != null) ...[
                  const SizedBox(height: 8),
                  attachmentPills!,
                ],
              ],
            ),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!, style: const TextStyle(fontSize: 13)),
            ),
          ] else if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.open_in_new_rounded, size: 18, color: cs.primary),
          ],
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: 18, color: cs.error),
              onPressed: onDelete,
              tooltip: l.a11yDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              style: IconButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: card,
      );
    }
    return card;
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LiquidGlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(24),
            color: cs.surfaceContainerLow,
            border: Border.all(color: cs.outlineVariant),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: cs.onSurfaceVariant),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final bg = _avatarColorForName(name);
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return SizedBox(
      width: 36,
      height: 36,
      child: LiquidGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(999),
        color: bg,
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.25),
        ),
        child: Center(
          child: Text(
            _initialsForName(name),
            style:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: fg),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: cs.surfaceContainerLow,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: cs.outlineVariant),
  );
}

String _pick(dynamic item, String key, {String fallback = ''}) {
  if (item is Map) {
    final value = item[key];
    return (value ?? fallback).toString();
  }
  return fallback;
}

/// Tries each key in order; returns the first non-empty value found.
String _pickFirst(dynamic item, List<String> keys, {String fallback = ''}) {
  if (item is! Map) return fallback;
  for (final k in keys) {
    final v = item[k];
    if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
  }
  return fallback;
}

String _friendlyDateTime(String raw) {
  if (raw.trim().isEmpty) return '';
  return FriendlyDate.dateTime(raw);
}

IconData _subjectIcon(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('math')) return Icons.calculate_rounded;
  if (s.contains('physics')) return Icons.science_rounded;
  if (s.contains('chem')) return Icons.biotech_rounded;
  if (s.contains('bio')) return Icons.eco_rounded;
  if (s.contains('arabic') || s.contains('hebrew') || s.contains('english')) {
    return Icons.menu_book_rounded;
  }
  if (s.contains('history')) return Icons.history_edu_rounded;
  if (s.contains('geo')) return Icons.public_rounded;
  if (s.contains('cs') || s.contains('computer')) return Icons.memory_rounded;
  return Icons.book_rounded;
}

Color _avatarColorForName(String name) {
  const palette = <Color>[
    Color(0xFF9CCC65),
    Color(0xFF4FC3F7),
    Color(0xFFFFB74D),
    Color(0xFFBA68C8),
    Color(0xFFFF8A65),
    Color(0xFF4DB6AC),
    Color(0xFFA1887F),
    Color(0xFF7986CB),
  ];
  final seed = name.trim().toLowerCase().runes.fold<int>(0, (a, b) => a + b);
  return palette[seed % palette.length];
}

String _initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final v = parts.first.trim();
    return v.length >= 2 ? v.substring(0, 2).toUpperCase() : v.toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
