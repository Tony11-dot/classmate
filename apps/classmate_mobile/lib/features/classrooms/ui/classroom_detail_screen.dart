// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../chat_core/controllers/classroom_chat_thread_controller.dart';
import '../../chat_core/policies/chat_action_policy.dart';
import '../../chat_core/ui/chat_thread_view.dart';
import '../data/classrooms_repository.dart';
import '../providers/classrooms_providers.dart';

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
    _chatController = ClassroomChatThreadController(
      ref: ref,
      courseId: widget.courseId,
      currentUserId: session.displayName.isNotEmpty
          ? session.displayName
          : (session.token ?? ''),
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
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
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
            final myId = session.displayName.isNotEmpty
                ? session.displayName
                : (session.token ?? '');
            return myId.toLowerCase() == teacherUserId.toLowerCase();
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
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
            Flexible(
              fit: FlexFit.loose,
              child: TabBarView(
                controller: _tabs,
                children: [
                  RefreshIndicator(
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
                      return _SimpleCard(
                        title: _pick(item, 'title',
                            fallback: l.classroomDetailAssignmentFallback),
                        subtitle: _pick(item, 'body'),
                        trailing: _friendlyDateTime(_pick(item, 'dueAt')),
                        onTap: assignmentId.isNotEmpty
                            ? () => context.push(
                                '/assignments/$assignmentId',
                                extra: <String, dynamic>{
                                  ...item is Map
                                      ? Map<String, dynamic>.from(item)
                                      : <String, dynamic>{},
                                  '_courseId': widget.courseId,
                                },
                              )
                            : null,
                      );
                    },
                  ),
                  _listTab(
                    value: materials,
                    emptyTitle: l.classroomDetailNoMaterialsTitle,
                    emptySubtitle: l.classroomDetailNoMaterialsSubtitle,
                    itemBuilder: (item) {
                      final url = _pick(item, 'url');
                      return _SimpleCard(
                        title: _pick(item, 'title',
                            fallback: l.classroomDetailMaterialFallback),
                        subtitle: _pick(item, 'description'),
                        trailing: _pick(item, 'mime'),
                        onTap: url.isNotEmpty ? () => _openUrl(url) : null,
                      );
                    },
                  ),
                  _listTab(
                    value: meetings,
                    emptyTitle: l.classroomDetailNoMeetingsTitle,
                    emptySubtitle: l.classroomDetailNoMeetingsSubtitle,
                    itemBuilder: (item) {
                      final link = _pick(item, 'link');
                      return _SimpleCard(
                        title: _pick(item, 'title',
                            fallback: l.classroomDetailMeetingFallback),
                        subtitle: _pick(item, 'agenda'),
                        trailing: _friendlyDateTime(_pick(item, 'startsAt')),
                        onTap: link.isNotEmpty ? () => _openUrl(link) : null,
                        actionLabel: link.isNotEmpty ? l.meetingsJoinAction : null,
                      );
                    },
                  ),
                  _peopleTab(people),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _peopleTab(AsyncValue<Map<String, dynamic>> people) {
    final l = AppLocalizations.of(context)!;
    return people.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _CenteredState(
        icon: Icons.group_outlined,
        title: l.classroomDetailCouldNotLoadPeople,
        subtitle: '$e',
      ),
      data: (m) {
        final items = (m['items'] is Map)
            ? Map<String, dynamic>.from(m['items'] as Map)
            : <String, dynamic>{};

        final raw = <Map<String, dynamic>>[];
        final teacher = items['teacher'];
        final teacherUserId = (items['teacherUserId'] ?? '').toString().trim();
        if (teacher is Map) {
          raw.add(<String, dynamic>{
            'id': teacherUserId,
            'name': (teacher['name'] ?? teacher['email'] ?? l.roleTeacher)
                .toString(),
            'email': (teacher['email'] ?? '').toString(),
          });
        }

        final students = (items['students'] is List)
            ? (items['students'] as List)
            : const <dynamic>[];
        for (final s in students) {
          if (s is Map) raw.add(Map<String, dynamic>.from(s));
        }

        if (raw.isEmpty) {
          return _CenteredState(
            icon: Icons.group_outlined,
            title: l.classroomDetailNoPeopleTitle,
            subtitle: l.classroomDetailNoPeopleSubtitle,
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
          itemBuilder: (context, index) {
            final item = raw[index];
            final name = _pick(item, 'name', fallback: l.student);
            final email = _pick(item, 'email');
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: _panelDecoration(context),
              child: Row(
                children: [
                  _InitialsAvatar(name: name),
                  const SizedBox(width: 2),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        if (email.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(email,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
      loading: () => const Center(child: CircularProgressIndicator()),
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
        blurSigma: 14,
        color: cs.surface.withValues(alpha: 0.88),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              tooltip: 'Back',
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.trim().isEmpty ? 'Classroom' : subject.trim(),
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
              tooltip: 'Leave classroom',
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
              tooltip: tabsCollapsed ? 'Show tabs' : 'Hide tabs',
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
          blurSigma: 12,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
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
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(6),
        borderRadius: BorderRadius.circular(14),
        blurSigma: 12,
        color: cs.surfaceContainerLow.withValues(alpha: 0.92),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
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
    this.actionLabel,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final card = LiquidGlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(14),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.84),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.trim().isEmpty ? 'Untitled' : title,
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
            blurSigma: 14,
            color: cs.surface.withValues(alpha: 0.82),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
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
        borderRadius: BorderRadius.circular(999),
        blurSigma: 8,
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
                TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: cs.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
  );
}

String _pick(dynamic item, String key, {String fallback = ''}) {
  if (item is Map) {
    final value = item[key];
    return (value ?? fallback).toString();
  }
  return fallback;
}

String _friendlyDateTime(String raw) {
  if (raw.trim().isEmpty) return '';
  final dt = DateTime.tryParse(raw)?.toLocal();
  if (dt == null) return raw;
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
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
