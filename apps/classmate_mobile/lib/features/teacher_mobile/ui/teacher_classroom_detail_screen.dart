// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../messages/providers/messages_repository_provider.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';

class TeacherClassroomDetailScreen extends ConsumerStatefulWidget {
  const TeacherClassroomDetailScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.subject,
    this.cohortName,
    this.grade,
  });

  final String courseId;
  final String courseName;
  final String subject;
  final String? cohortName;
  final int? grade;

  @override
  ConsumerState<TeacherClassroomDetailScreen> createState() =>
      _TeacherClassroomDetailScreenState();
}

class _TeacherClassroomDetailScreenState
    extends ConsumerState<TeacherClassroomDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);
  late final ClassroomChatThreadController _chatController;
  bool _tabsCollapsed = false;

  String get _collapsedKey =>
      'teacher_classroom_tabs_collapsed_${widget.courseId}';

  @override
  void initState() {
    super.initState();
    final session = ref.read(authSessionProvider);
    final realUserId = session.userId.isNotEmpty
        ? session.userId
        : (session.displayName.isNotEmpty ? session.displayName : (session.token ?? ''));
    _chatController = ClassroomChatThreadController(
      ref: ref,
      courseId: widget.courseId,
      currentUserId: realUserId,
    );
    _loadCollapsed();
    _tabs.addListener(() {
      if (!mounted) return;
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

  Future<void> _loadCollapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() => _tabsCollapsed = prefs.getBool(_collapsedKey) ?? false);
    } catch (_) {}
  }

  Future<void> _toggleCollapsed() async {
    setState(() => _tabsCollapsed = !_tabsCollapsed);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_collapsedKey, _tabsCollapsed);
    } catch (_) {}
  }

  String get _subtitle {
    final parts = <String>[];
    if ((widget.cohortName ?? '').isNotEmpty) parts.add(widget.cohortName!);
    if ((widget.grade ?? 0) > 0) parts.add('Grade ${widget.grade}');
    return parts.isEmpty ? widget.subject : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.courseName.isNotEmpty
        ? widget.courseName
        : widget.subject;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          _TopHeader(
            icon: _subjectIcon(widget.subject),
            subject: displayName,
            subtitle: _subtitle,
            tabsCollapsed: _tabsCollapsed,
            onBack: () {
              if (context.canPop()) context.pop();
            },
            onToggleTabs: _toggleCollapsed,
          ),
          if (!_tabsCollapsed) _CenteredTabs(controller: _tabs),
          const SizedBox(height: 2),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                ChatThreadView(
                  controller: _chatController,
                  policy: ChatActionPolicy.classroom(isTeacher: true),
                ),
                _AssignmentsTab(
                  courseId: widget.courseId,
                  subject: widget.subject,
                  cohortId: widget.cohortName ?? '',
                ),
                _MaterialsTab(
                  courseId: widget.courseId,
                  subject: widget.subject,
                  cohortId: widget.cohortName ?? '',
                ),
                _MeetingsTab(
                  courseId: widget.courseId,
                  subject: widget.subject,
                  cohortId: widget.cohortName ?? '',
                ),
                _PeopleTab(courseId: widget.courseId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — identical design to student, minus the Leave button
// ─────────────────────────────────────────────────────────────────────────────

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.icon,
    required this.subject,
    required this.subtitle,
    required this.tabsCollapsed,
    required this.onBack,
    required this.onToggleTabs,
  });

  final IconData icon;
  final String subject;
  final String subtitle;
  final bool tabsCollapsed;
  final VoidCallback onBack;
  final VoidCallback onToggleTabs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, topPad + 6, 12, 8),
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
              visualDensity:
                  const VisualDensity(horizontal: -2, vertical: -2),
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
              onPressed: onToggleTabs,
              icon: AnimatedRotation(
                turns: tabsCollapsed ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
              ),
              visualDensity:
                  const VisualDensity(horizontal: -2, vertical: -2),
              tooltip: tabsCollapsed ? 'Show tabs' : 'Hide tabs',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill tab bar — same glass pill style as student, 6 tabs
// ─────────────────────────────────────────────────────────────────────────────

class _CenteredTabs extends StatelessWidget {
  const _CenteredTabs({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
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
            Tab(child: _TabChipLabel(text: l.classroomDetailTabChat)),
            Tab(child: _TabChipLabel(text: l.navAssignments)),
            Tab(child: _TabChipLabel(text: l.classroomDetailTabMaterials)),
            Tab(child: _TabChipLabel(text: l.navMeetings)),
            Tab(child: _TabChipLabel(text: l.classroomDetailTabPeople)),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared card — same as student's _SimpleCard, + optional delete action
// ─────────────────────────────────────────────────────────────────────────────

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.actionLabel,
    this.onDelete,
    this.chips = const [],
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onDelete;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final card = LiquidGlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      borderRadius: BorderRadius.circular(16),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title.trim().isEmpty ? 'Untitled' : title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 18, color: cs.error),
                  onPressed: onDelete,
                  style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(32, 32)),
                ),
              ],
            ],
          ),
          if (subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, height: 1.4),
            ),
          ],
          if (trailing.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trailing,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onPrimaryContainer),
              ),
            ),
          ],
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: chips),
          ],
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ],
      ),
    );

    if (onTap != null && actionLabel == null) {
      return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: card);
    }
    return card;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Centered empty/error state — same glass-card style as student
// ─────────────────────────────────────────────────────────────────────────────

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
            border:
                Border.all(color: cs.outlineVariant),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: cs.onSurfaceVariant),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800),
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

// ─────────────────────────────────────────────────────────────────────────────
// Initials avatar — identical to student's _InitialsAvatar
// ─────────────────────────────────────────────────────────────────────────────

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name, this.isTeacher = false});
  final String name;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isTeacher ? cs.primary : _avatarColorForName(name);
    final fg = isTeacher
        ? cs.onPrimary
        : (ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
            ? Colors.white
            : Colors.black87);

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
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: fg),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Assignments tab
// ─────────────────────────────────────────────────────────────────────────────

class _AssignmentsTab extends ConsumerStatefulWidget {
  const _AssignmentsTab({required this.courseId, this.subject = '', this.cohortId = ''});
  final String courseId;
  final String subject;
  final String cohortId;

  @override
  ConsumerState<_AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends ConsumerState<_AssignmentsTab> {
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref
          .read(teacherMobileRepositoryProvider)
          .fetchClassroomAssignments(widget.courseId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _delete(String id, {String source = ''}) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherDeleteAssignment),
        content: Text(l.teacherDeleteAssignmentContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      if (source == 'teacher') {
        await repo.deleteTeacherAssignmentV2(id);
      } else {
        await repo.deleteClassroomAssignment(widget.courseId, id);
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _load,
      child: Stack(
        children: [
          if (_loading)
            const Center(child: CmLoading())
          else if (_error != null)
            _CenteredState(
                icon: Icons.error_outline_rounded,
                title: l.teacherCouldNotLoad,
                subtitle: _error!)
          else if (_items.isEmpty)
            _CenteredState(
              icon: Icons.assignment_outlined,
              title: l.teacherNoAssignmentsYet,
              subtitle: l.teacherNoAssignmentsSub,
            )
          else
            ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
              itemCount: _items.length,
              separatorBuilder: (context2, idx) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = _items[i];
                final id = (item['id'] ?? '').toString();
                final source = (item['_source'] ?? '').toString();
                final due = item['dueAt'] != null
                    ? DateTime.tryParse(item['dueAt'].toString())
                    : null;
                final description = (item['body'] ?? item['description'] ?? '').toString().trim();
                return _TeacherCard(
                  title: (item['title'] ?? '').toString(),
                  subtitle: description,
                  trailing: due != null
                      ? 'Due ${MaterialLocalizations.of(context).formatMediumDate(due)}'
                      : '',
                  onTap: id.isNotEmpty ? () => context.push('/teacher/assignments/$id/detail', extra: (item['title'] ?? '').toString()) : null,
                  onDelete: id.isNotEmpty ? () => _delete(id, source: source) : null,
                );
              },
            ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: FloatingActionButton.extended(
              heroTag: 'add_assignment',
              onPressed: () => context
                  .push(
                    '/teacher/assignments/add',
                    extra: <String, dynamic>{
                      'courseId': widget.courseId,
                      'subject': widget.subject,
                    },
                  )
                  .then((_) {
                if (mounted) _load();
              }),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.teacherAssignmentLabel),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Materials tab
// ─────────────────────────────────────────────────────────────────────────────

class _MaterialsTab extends ConsumerStatefulWidget {
  const _MaterialsTab({required this.courseId, this.subject = '', this.cohortId = ''});
  final String courseId;
  final String subject;
  final String cohortId;

  @override
  ConsumerState<_MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends ConsumerState<_MaterialsTab> {
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref
          .read(teacherMobileRepositoryProvider)
          .fetchClassroomMaterials(widget.courseId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _delete(String id, {String source = ''}) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherRemoveMaterial),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.actionRemove),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      if (source == 'teacher') {
        await repo.deleteTeacherMaterial(id);
      } else {
        await repo.deleteClassroomMaterial(widget.courseId, id);
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openUrl(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    // Local file paths are not launchable as URLs.
    if (trimmed.startsWith('/') || trimmed.startsWith('file:')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This file is not available — the teacher should re-upload it.')),
        );
      }
      return;
    }
    Uri? uri = Uri.tryParse(trimmed);
    if (uri != null && !uri.hasScheme && trimmed.contains('.')) {
      uri = Uri.tryParse('https://$trimmed');
    }
    if (uri == null || !uri.hasScheme) return;
    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    await launchUrl(
      uri,
      mode: isHttp ? LaunchMode.externalApplication : LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _load,
      child: Stack(
        children: [
          if (_loading)
            const Center(child: CmLoading())
          else if (_error != null)
            _CenteredState(
                icon: Icons.error_outline_rounded,
                title: l.teacherCouldNotLoad,
                subtitle: _error!)
          else if (_items.isEmpty)
            _CenteredState(
              icon: Icons.folder_open_rounded,
              title: l.teacherNoMaterialsYet,
              subtitle: l.teacherNoMaterialsSub,
            )
          else
            ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
              itemCount: _items.length,
              separatorBuilder: (context2, idx) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = _items[i];
                final id = (item['id'] ?? '').toString();
                final source = (item['_source'] ?? '').toString();
                final url = (item['url'] ?? '').toString();
                final fileName = url.isNotEmpty
                    ? url.split('/').last.split('?').first
                    : '';
                final isValidUrl = url.startsWith('http://') || url.startsWith('https://');
                return _TeacherCard(
                  title: (item['title'] ?? '').toString(),
                  subtitle: (item['description'] ?? '').toString().trim(),
                  trailing: '',
                  onDelete: id.isNotEmpty ? () => _delete(id, source: source) : null,
                  chips: url.isNotEmpty ? [
                    _AttachmentPill(
                      label: fileName.isNotEmpty ? fileName : (isValidUrl ? 'Open link' : url),
                      onTap: () => _openUrl(url),
                    ),
                  ] : [],
                );
              },
            ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: FloatingActionButton.extended(
              heroTag: 'add_material',
              onPressed: () => context
                  .push(
                    '/teacher/materials/add',
                    extra: <String, dynamic>{
                      'courseId': widget.courseId,
                      'subject': widget.subject,
                    },
                  )
                  .then((_) {
                if (mounted) _load();
              }),
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(l.teacherShareMaterialLabel),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meetings tab
// ─────────────────────────────────────────────────────────────────────────────

class _MeetingsTab extends ConsumerStatefulWidget {
  const _MeetingsTab({required this.courseId, this.subject = '', this.cohortId = ''});
  final String courseId;
  final String subject;
  final String cohortId;

  @override
  ConsumerState<_MeetingsTab> createState() => _MeetingsTabState();
}

class _MeetingsTabState extends ConsumerState<_MeetingsTab> {
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref
          .read(teacherMobileRepositoryProvider)
          .fetchClassroomMeetings(widget.courseId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _delete(String id, {String source = ''}) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherCancelMeetingTitle),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionKeep)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.teacherCancelMeetingAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      if (source == 'teacher') {
        await repo.deleteTeacherMeeting(id);
      } else {
        await repo.deleteClassroomMeeting(widget.courseId, id);
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _load,
      child: Stack(
        children: [
          if (_loading)
            const Center(child: CmLoading())
          else if (_error != null)
            _CenteredState(
                icon: Icons.error_outline_rounded,
                title: l.teacherCouldNotLoad,
                subtitle: _error!)
          else if (_items.isEmpty)
            _CenteredState(
              icon: Icons.video_call_outlined,
              title: l.teacherNoMeetingsScheduled,
              subtitle: l.teacherNoMeetingsSub,
            )
          else
            ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
              itemCount: _items.length,
              separatorBuilder: (context2, idx) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = _items[i];
                final id = (item['id'] ?? '').toString();
                final source = (item['_source'] ?? '').toString();
                final link = (item['link'] ?? '').toString();
                final startDt = item['startsAt'] != null
                    ? DateTime.tryParse(item['startsAt'].toString())
                    : null;
                final timeLabel = startDt != null
                    ? '${MaterialLocalizations.of(context).formatMediumDate(startDt)} · ${TimeOfDay.fromDateTime(startDt).format(context)}'
                    : '';
                return _TeacherCard(
                  title: (item['title'] ?? '').toString(),
                  subtitle: timeLabel,
                  trailing: '',
                  onTap: null,
                  actionLabel: link.isNotEmpty ? l.teacherJoinMeeting : null,
                  onDelete: id.isNotEmpty ? () => _delete(id, source: source) : null,
                  chips: link.isNotEmpty ? [
                    _AttachmentPill(
                      label: l.teacherJoinMeeting,
                      icon: Icons.video_call_rounded,
                      onTap: () async {
                        final uri = Uri.tryParse(link);
                        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                    ),
                  ] : [],
                );
              },
            ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: FloatingActionButton.extended(
              heroTag: 'add_meeting',
              onPressed: () => context
                  .push(
                    '/teacher/classroom/${widget.courseId}/meeting/add',
                    extra: <String, dynamic>{
                      'courseId': widget.courseId,
                      'subject': widget.subject,
                    },
                  )
                  .then((_) {
                if (mounted) _load();
              }),
              icon: const Icon(Icons.video_call_rounded),
              label: Text(l.actionScheduleVerb),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// People tab — uses same _InitialsAvatar + _panelDecoration as student
// ─────────────────────────────────────────────────────────────────────────────

class _PeopleTab extends ConsumerStatefulWidget {
  const _PeopleTab({required this.courseId});
  final String courseId;

  @override
  ConsumerState<_PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends ConsumerState<_PeopleTab> {
  Map<String, dynamic> _data = const {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ref.read(teacherMobileRepositoryProvider).fetchClassroomPeople(widget.courseId);
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // Derive stable 6-char uppercase code from courseId UUID.
  String get _classCode {
    final clean = widget.courseId.replaceAll('-', '');
    return clean.substring(0, clean.length >= 6 ? 6 : clean.length).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CmLoading());
    if (_error != null) {
      return _CenteredState(icon: Icons.error_outline_rounded, title: l.teacherCouldNotLoad, subtitle: _error!);
    }

    final items = _data['items'] is Map ? Map<String, dynamic>.from(_data['items'] as Map) : <String, dynamic>{};
    // teacher is returned at top level by fetchClassroomPeople
    final teacher = (_data['teacher'] is Map
            ? _data['teacher']
            : items['teacher'] is Map
                ? items['teacher']
                : null) as Map<String, dynamic>?;
    final students = items['students'] is List
        ? (items['students'] as List).map((s) => Map<String, dynamic>.from(s is Map ? s : {})).toList()
        : <Map<String, dynamic>>[];
    final enrolledIds = students.map((s) => (s['id'] ?? '').toString()).toSet();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 24 + MediaQuery.of(context).viewInsets.bottom),
        children: [

          // ── Join code card ────────────────────────────────────────────
          LiquidGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderRadius: BorderRadius.circular(18),
            color: cs.secondaryContainer,
            border: Border.all(color: cs.secondary),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: cs.secondary, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.vpn_key_rounded, size: 20, color: cs.onSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Classroom code', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(_classCode, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 3, color: cs.onSecondaryContainer)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy_rounded, size: 18, color: cs.onSecondaryContainer),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _classCode));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied'), duration: Duration(seconds: 2)),
                    );
                  },
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Teacher ───────────────────────────────────────────────────
          if (teacher != null) ...[
            Text(l.roleTeacher, style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: _panelDecoration(context),
              child: Row(
                children: [
                  _InitialsAvatar(name: (teacher['name'] ?? '').toString(), isTeacher: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((teacher['name'] ?? l.roleTeacher).toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                        if ((teacher['email'] ?? '').toString().isNotEmpty)
                          Text((teacher['email'] ?? '').toString(), style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: Text(l.roleTeacher, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onPrimaryContainer)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Students header ───────────────────────────────────────────
          Row(
            children: [
              Expanded(child: Text(l.teacherStudentsCount(students.length),
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant, fontSize: 12))),
              TextButton.icon(
                onPressed: () => _openStudentPicker(context, enrolledIds),
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: Text(l.actionAdd),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Student list ──────────────────────────────────────────────
          ...students.map((s) {
            final name = (s['name'] ?? '').toString();
            final email = (s['email'] ?? '').toString();
            final id = (s['id'] ?? '').toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: InkWell(
                onTap: id.isNotEmpty ? () => context.push('/teacher/student/$id', extra: <String, dynamic>{'name': name}) : null,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: _panelDecoration(context),
                  child: Row(
                    children: [
                      _InitialsAvatar(name: name),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name.isNotEmpty ? name : l.student,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(email, style: theme.textTheme.bodySmall),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.person_remove_rounded, size: 18, color: cs.error),
                        onPressed: () => _confirmRemoveStudent(context, id, name),
                        style: IconButton.styleFrom(padding: const EdgeInsets.all(4), minimumSize: const Size(32, 32)),
                        tooltip: l.teacherTooltipRemoveStudent,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _openStudentPicker(BuildContext context, Set<String> enrolledIds) async {
    // Load students: cohort-based first, then fall back to school-wide people.
    List<TeacherStudentWithLevel> allStudents = [];
    try {
      allStudents = await ref.read(teacherMobileRepositoryProvider).fetchAllStudents();
    } catch (_) {}

    // If cohort fetch returned nothing, load from the school-wide directory.
    if (allStudents.isEmpty) {
      try {
        final people = await ref.read(messagesRepositoryProvider).fetchSameSchoolPeople();
        allStudents = people
            .where((p) => p.role.toLowerCase() == 'student')
            .map((p) => TeacherStudentWithLevel(
                  studentId: p.userId,
                  name: p.displayName,
                  email: '',
                  gradeLevel: null,
                  cohortId: '',
                  cohortName: p.gradeLabel,
                  subjects: const [],
                  coursesBySubject: const {},
                ))
            .toList();
      } catch (_) {}
    }
    if (!mounted) return;

    final picked = await showModalBottomSheet<List<TeacherStudentWithLevel>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _StudentPickerSheet(
        students: allStudents.where((s) => !enrolledIds.contains(s.studentId)).toList(),
      ),
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    final l = AppLocalizations.of(context)!;
    int added = 0;
    final failed = <String>[];
    for (final s in picked) {
      try {
        final identifier = s.email.trim().isNotEmpty ? s.email.trim() : s.studentId;
        await ref.read(teacherMobileRepositoryProvider).addStudentToClassroom(widget.courseId, identifier);
        added++;
      } catch (e) {
        failed.add(s.name.isNotEmpty ? s.name : s.studentId);
      }
    }
    _load();
    if (!mounted) return;
    if (added > 0) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherStudentAdded)));
    if (failed.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not add: ${failed.join(', ')} — check their email address.'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  Future<void> _confirmRemoveStudent(BuildContext context, String studentId, String name) async {
    if (studentId.isEmpty) return;
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherRemoveStudentTitle(name)),
        content: Text(l.teacherRemoveStudentContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.actionRemove),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).removeStudentFromClassroom(widget.courseId, studentId);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Student picker bottom sheet — searchable, shows grade level
// ─────────────────────────────────────────────────────────────────────────────

class _StudentPickerSheet extends StatefulWidget {
  const _StudentPickerSheet({required this.students});
  final List<TeacherStudentWithLevel> students;

  @override
  State<_StudentPickerSheet> createState() => _StudentPickerSheetState();
}

class _StudentPickerSheetState extends State<_StudentPickerSheet> {
  String _query = '';
  final Set<String> _selected = {};

  List<TeacherStudentWithLevel> get _filtered {
    if (_query.isEmpty) return widget.students;
    final q = _query.toLowerCase();
    return widget.students.where((s) {
      if (s.name.toLowerCase().contains(q)) return true;
      if (s.email.toLowerCase().contains(q)) return true;
      if (s.gradeLevel != null && 'grade ${s.gradeLevel}'.contains(q)) return true;
      if (s.cohortName.toLowerCase().contains(q)) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final filtered = _filtered;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text('Add students', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (_selected.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
                    child: Text('${_selected.length} selected',
                        style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by name or grade…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('No students found', style: TextStyle(color: cs.onSurfaceVariant)))
                : ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final s = filtered[i];
                      final isSelected = _selected.contains(s.studentId);
                      final gradeLabel = s.gradeLevel != null
                          ? 'Grade ${s.gradeLevel}${s.cohortName.isNotEmpty ? " · ${s.cohortName}" : ""}'
                          : s.cohortName;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => setState(() {
                            if (isSelected) { _selected.remove(s.studentId); } else { _selected.add(s.studentId); }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(
                                    color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Center(child: Text(
                                    s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16,
                                        color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                                  )),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(s.name, style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w700, color: isSelected ? cs.primary : null)),
                                      if (gradeLabel.isNotEmpty)
                                        Text(gradeLabel, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => setState(() {
                                    if (isSelected) { _selected.remove(s.studentId); } else { _selected.add(s.studentId); }
                                  }),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: () {
                  final picked = widget.students.where((s) => _selected.contains(s.studentId)).toList();
                  Navigator.of(ctx).pop(picked);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_selected.isEmpty ? 'Done' : 'Add ${_selected.length} student${_selected.length == 1 ? "" : "s"}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers (mirrors student classroom_detail_screen.dart)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Attachment pill — pill button for material URLs and meeting links
// ─────────────────────────────────────────────────────────────────────────────

class _AttachmentPill extends StatelessWidget {
  const _AttachmentPill({required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.attach_file_rounded, size: 14, color: cs.onPrimaryContainer),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onPrimaryContainer),
              ),
            ),
          ],
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

IconData _subjectIcon(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('math')) return Icons.calculate_rounded;
  if (s.contains('physics')) return Icons.science_rounded;
  if (s.contains('chem')) return Icons.biotech_rounded;
  if (s.contains('bio')) return Icons.eco_rounded;
  if (s.contains('arabic') ||
      s.contains('hebrew') ||
      s.contains('english')) {
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
  final seed =
      name.trim().toLowerCase().runes.fold<int>(0, (a, b) => a + b);
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
