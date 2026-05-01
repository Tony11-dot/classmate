// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../chat_core/controllers/classroom_chat_thread_controller.dart';
import '../../chat_core/policies/chat_action_policy.dart';
import '../../chat_core/ui/chat_thread_view.dart';
import '../data/teacher_mobile_repository.dart';

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
  late final TabController _tabs = TabController(length: 6, vsync: this);
  late final ClassroomChatThreadController _chatController;

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
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String get _subtitle {
    final parts = <String>[];
    if ((widget.cohortName ?? '').isNotEmpty) parts.add(widget.cohortName!);
    if ((widget.grade ?? 0) > 0) parts.add('Grade ${widget.grade}');
    return parts.isEmpty ? widget.subject : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.72),
                    cs.surfaceContainerHigh.withValues(alpha: 0.78),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surface.withValues(alpha: 0.6),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.courseName.isNotEmpty
                                  ? widget.courseName
                                  : widget.subject,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_subtitle.isNotEmpty)
                              Text(
                                _subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'Chat'),
                      Tab(text: 'Assignments'),
                      Tab(text: 'Materials'),
                      Tab(text: 'Meetings'),
                      Tab(text: 'People'),
                      Tab(text: 'Analytics'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tab content ───────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _ChatTab(
                    courseId: widget.courseId,
                    chatController: _chatController,
                  ),
                  _AssignmentsTab(courseId: widget.courseId),
                  _MaterialsTab(courseId: widget.courseId),
                  _MeetingsTab(courseId: widget.courseId),
                  _PeopleTab(courseId: widget.courseId),
                  _AnalyticsTab(
                    courseId: widget.courseId,
                    courseName: widget.courseName,
                    subject: widget.subject,
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

// ── Chat Tab ────────────────────────────────────────────────────────────────

class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.courseId, required this.chatController});

  final String courseId;
  final ClassroomChatThreadController chatController;

  @override
  Widget build(BuildContext context) {
    return ChatThreadView(
      controller: chatController,
      policy: ChatActionPolicy.classroom(isTeacher: true),
    );
  }
}

// ── Assignments Tab ─────────────────────────────────────────────────────────

class _AssignmentsTab extends ConsumerStatefulWidget {
  const _AssignmentsTab({required this.courseId});
  final String courseId;

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
    setState(() { _loading = true; _error = null; });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final items = await repo.fetchClassroomAssignments(widget.courseId);
      if (!mounted) return;
      setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _showCreateDialog() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    DateTime? dueDate;

    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(l.teacherNewAssignment, style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: l.teacherTitleFieldLabel, border: const OutlineInputBorder()),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyCtrl,
                  decoration: InputDecoration(labelText: l.teacherInstructionsLabel, border: const OutlineInputBorder()),
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setS(() => dueDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(ctx).colorScheme.outline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18),
                        const SizedBox(width: 10),
                        Text(dueDate == null
                            ? 'Due date (optional)'
                            : 'Due: ${MaterialLocalizations.of(ctx).formatMediumDate(dueDate!)}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionCreate)),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    final title = titleCtrl.text.trim();
    if (title.isEmpty) return;

    try {
      await ref.read(teacherMobileRepositoryProvider).createClassroomAssignment(
        courseId: widget.courseId,
        title: title,
        body: bodyCtrl.text.trim().isEmpty ? null : bodyCtrl.text.trim(),
        dueAt: dueDate?.toIso8601String(),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _delete(String id) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherDeleteAssignment),
        content: Text(l.teacherDeleteAssignmentContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).deleteClassroomAssignment(widget.courseId, id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _load,
      child: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            _CenteredMessage(icon: Icons.error_outline_rounded, title: AppLocalizations.of(context)!.teacherCouldNotLoad, subtitle: _error!)
          else if (_items.isEmpty)
            _CenteredMessage(
              icon: Icons.assignment_outlined,
              title: AppLocalizations.of(context)!.teacherNoAssignmentsYet,
              subtitle: AppLocalizations.of(context)!.teacherNoAssignmentsSub,
            )
          else
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _items.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = _items[i];
                final title = (item['title'] ?? '').toString();
                final body = (item['body'] ?? '').toString().trim();
                final dueAt = item['dueAt']?.toString();
                final id = (item['id'] ?? '').toString();
                final due = dueAt != null ? DateTime.tryParse(dueAt) : null;

                return LiquidGlassCard(
                  padding: const EdgeInsets.all(14),
                  borderRadius: BorderRadius.circular(18),
                  blurSigma: 10,
                  color: cs.surface.withValues(alpha: 0.82),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.assignment_rounded, size: 20, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                            if (body.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(body, maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                            ],
                            if (due != null) ...[
                              const SizedBox(height: 6),
                              Row(children: [
                                Icon(Icons.schedule_rounded, size: 14, color: cs.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Due ${MaterialLocalizations.of(context).formatMediumDate(due)}',
                                  style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w600),
                                ),
                              ]),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 20),
                        onPressed: id.isNotEmpty ? () => _delete(id) : null,
                        style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(36, 36)),
                      ),
                    ],
                  ),
                );
              },
            ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'add_assignment',
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add_rounded),
              label: Text(AppLocalizations.of(context)!.teacherAssignmentLabel),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Materials Tab ────────────────────────────────────────────────────────────

class _MaterialsTab extends ConsumerStatefulWidget {
  const _MaterialsTab({required this.courseId});
  final String courseId;

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
    setState(() { _loading = true; _error = null; });
    try {
      final items = await ref.read(teacherMobileRepositoryProvider).fetchClassroomMaterials(widget.courseId);
      if (!mounted) return;
      setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _showShareDialog() async {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherShareMaterialTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: l.teacherTitleFieldLabel, border: const OutlineInputBorder()),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
                decoration: InputDecoration(
                  labelText: l.teacherLinkUrlLabel,
                  border: const OutlineInputBorder(),
                  hintText: l.teacherLinkUrlHint,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(labelText: l.teacherDescriptionLabel, border: const OutlineInputBorder()),
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionShare)),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final title = titleCtrl.text.trim();
    final url = urlCtrl.text.trim();
    if (title.isEmpty || url.isEmpty) return;

    try {
      await ref.read(teacherMobileRepositoryProvider).createClassroomMaterial(
        courseId: widget.courseId,
        title: title,
        url: url,
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _delete(String id) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherRemoveMaterial),
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
      await ref.read(teacherMobileRepositoryProvider).deleteClassroomMaterial(widget.courseId, id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _load,
      child: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            _CenteredMessage(icon: Icons.error_outline_rounded, title: AppLocalizations.of(context)!.teacherCouldNotLoad, subtitle: _error!)
          else if (_items.isEmpty)
            _CenteredMessage(
              icon: Icons.folder_open_rounded,
              title: AppLocalizations.of(context)!.teacherNoMaterialsYet,
              subtitle: AppLocalizations.of(context)!.teacherNoMaterialsSub,
            )
          else
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _items.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = _items[i];
                final title = (item['title'] ?? '').toString();
                final desc = (item['description'] ?? '').toString().trim();
                final url = (item['url'] ?? '').toString();
                final mime = (item['mime'] ?? '').toString().trim();
                final id = (item['id'] ?? '').toString();

                return InkWell(
                  onTap: url.isNotEmpty ? () => _openUrl(url) : null,
                  borderRadius: BorderRadius.circular(18),
                  child: LiquidGlassCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(18),
                    blurSigma: 10,
                    color: cs.surface.withValues(alpha: 0.82),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            mime.contains('pdf') ? Icons.picture_as_pdf_rounded :
                            mime.contains('image') ? Icons.image_rounded :
                            Icons.insert_link_rounded,
                            size: 20,
                            color: cs.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                              if (desc.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                              ],
                              if (url.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(url, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11, color: cs.primary)),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (url.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.open_in_new_rounded, size: 18, color: cs.primary),
                                onPressed: () => _openUrl(url),
                                style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(32, 32)),
                              ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 18),
                              onPressed: id.isNotEmpty ? () => _delete(id) : null,
                              style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(32, 32)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'add_material',
              onPressed: _showShareDialog,
              icon: const Icon(Icons.add_link_rounded),
              label: Text(AppLocalizations.of(context)!.teacherShareMaterialLabel),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meetings Tab ─────────────────────────────────────────────────────────────

class _MeetingsTab extends ConsumerStatefulWidget {
  const _MeetingsTab({required this.courseId});
  final String courseId;

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
    setState(() { _loading = true; _error = null; });
    try {
      final items = await ref.read(teacherMobileRepositoryProvider).fetchClassroomMeetings(widget.courseId);
      if (!mounted) return;
      setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _showScheduleDialog() async {
    final titleCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    DateTime? startDate;
    TimeOfDay? startTime;

    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(l.teacherScheduleMeetingTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: l.teacherMeetingTitleLabel, border: const OutlineInputBorder()),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linkCtrl,
                  decoration: InputDecoration(
                    labelText: l.teacherMeetingLinkLabel,
                    border: const OutlineInputBorder(),
                    hintText: l.teacherMeetingLinkHint,
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setS(() => startDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(ctx).colorScheme.outline),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(startDate == null
                              ? 'Pick date'
                              : MaterialLocalizations.of(ctx).formatMediumDate(startDate!),
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (picked != null) setS(() => startTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(ctx).colorScheme.outline),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                              startTime == null ? 'Pick time' : startTime!.format(ctx),
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionScheduleVerb)),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    final title = titleCtrl.text.trim();
    final link = linkCtrl.text.trim();
    if (title.isEmpty || link.isEmpty) return;

    DateTime startsAt = DateTime.now().add(const Duration(days: 1));
    if (startDate != null) {
      final t = startTime ?? const TimeOfDay(hour: 9, minute: 0);
      startsAt = DateTime(startDate!.year, startDate!.month, startDate!.day, t.hour, t.minute);
    }

    try {
      await ref.read(teacherMobileRepositoryProvider).createClassroomMeeting(
        courseId: widget.courseId,
        title: title,
        link: link,
        startsAt: startsAt.toIso8601String(),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _delete(String id) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherCancelMeetingTitle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionKeep)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.teacherCancelMeetingAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).deleteClassroomMeeting(widget.courseId, id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _load,
      child: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            _CenteredMessage(icon: Icons.error_outline_rounded, title: AppLocalizations.of(context)!.teacherCouldNotLoad, subtitle: _error!)
          else if (_items.isEmpty)
            _CenteredMessage(
              icon: Icons.video_call_outlined,
              title: AppLocalizations.of(context)!.teacherNoMeetingsScheduled,
              subtitle: AppLocalizations.of(context)!.teacherNoMeetingsSub,
            )
          else
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _items.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = _items[i];
                final title = (item['title'] ?? '').toString();
                final link = (item['link'] ?? '').toString();
                final startsAt = item['startsAt']?.toString();
                final id = (item['id'] ?? '').toString();
                final startDt = startsAt != null ? DateTime.tryParse(startsAt) : null;

                return LiquidGlassCard(
                  padding: const EdgeInsets.all(14),
                  borderRadius: BorderRadius.circular(18),
                  blurSigma: 10,
                  color: cs.surface.withValues(alpha: 0.82),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.video_call_rounded, size: 20, color: cs.tertiary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                            if (startDt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${MaterialLocalizations.of(context).formatMediumDate(startDt)} · ${TimeOfDay.fromDateTime(startDt).format(context)}',
                                style: TextStyle(color: cs.primary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                            if (link.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              FilledButton.tonal(
                                onPressed: () async {
                                  final uri = Uri.tryParse(link);
                                  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(AppLocalizations.of(context)!.teacherJoinMeeting, style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 20),
                        onPressed: id.isNotEmpty ? () => _delete(id) : null,
                        style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(36, 36)),
                      ),
                    ],
                  ),
                );
              },
            ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'add_meeting',
              onPressed: _showScheduleDialog,
              icon: const Icon(Icons.video_call_rounded),
              label: Text(AppLocalizations.of(context)!.actionScheduleVerb),
            ),
          ),
        ],
      ),
    );
  }
}

// ── People Tab ───────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _CenteredMessage(icon: Icons.error_outline_rounded, title: AppLocalizations.of(context)!.teacherCouldNotLoad, subtitle: _error!);

    final items = _data['items'] is Map ? Map<String, dynamic>.from(_data['items'] as Map) : <String, dynamic>{};
    final teacher = items['teacher'] is Map ? Map<String, dynamic>.from(items['teacher'] as Map) : null;
    final students = items['students'] is List
        ? (items['students'] as List).map((s) => Map<String, dynamic>.from(s is Map ? s : {})).toList()
        : <Map<String, dynamic>>[];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          if (teacher != null) ...[
            Text(AppLocalizations.of(context)!.roleTeacher, style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 8),
            _PersonCard(name: (teacher['name'] ?? '').toString(), isTeacher: true),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(child: Text(AppLocalizations.of(context)!.teacherStudentsCount(students.length), style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant, fontSize: 12))),
              TextButton.icon(
                onPressed: () => _showAddStudentDialog(context),
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: Text(AppLocalizations.of(context)!.actionAdd),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...students.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                final id = (s['id'] ?? '').toString();
                final name = (s['name'] ?? '').toString();
                if (id.isNotEmpty) {
                  context.push('/teacher/student/$id', extra: <String, dynamic>{'name': name});
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: _PersonCardWithRemove(
                name: (s['name'] ?? '').toString(),
                onRemove: () => _confirmRemoveStudent(context, (s['id'] ?? '').toString(), (s['name'] ?? '').toString()),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _showAddStudentDialog(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final emailCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherAddStudentTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: emailCtrl,
          decoration: InputDecoration(labelText: l.teacherStudentEmailLabel, border: const OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionAdd)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final identifier = emailCtrl.text.trim();
    if (identifier.isEmpty) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).addStudentToClassroom(
        widget.courseId,
        identifier,
      );
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherStudentAdded)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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

// ── Shared helpers ───────────────────────────────────────────────────────────

class _PersonCardWithRemove extends StatelessWidget {
  const _PersonCardWithRemove({required this.name, required this.onRemove});
  final String name;
  final VoidCallback onRemove;

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: BorderRadius.circular(14),
      blurSigma: 8,
      color: cs.surface.withValues(alpha: 0.8),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.primaryContainer,
            child: Text(_initials(), style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name.isNotEmpty ? name : 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600))),
          IconButton(
            icon: Icon(Icons.person_remove_rounded, size: 18, color: cs.error),
            onPressed: onRemove,
            style: IconButton.styleFrom(padding: const EdgeInsets.all(4), minimumSize: const Size(32, 32)),
            tooltip: AppLocalizations.of(context)!.teacherTooltipRemoveStudent,
          ),
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.name, this.isTeacher = false});
  final String name;
  final bool isTeacher;

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: BorderRadius.circular(14),
      blurSigma: 8,
      color: cs.surface.withValues(alpha: 0.8),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isTeacher ? cs.primary : cs.primaryContainer,
            child: Text(
              _initials(),
              style: TextStyle(color: isTeacher ? cs.onPrimary : cs.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name.isNotEmpty ? name : 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600))),
          if (isTeacher) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(AppLocalizations.of(context)!.roleTeacher, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary)),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Analytics Tab (inline summary + link to full analytics) ─────────────────

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab({required this.courseId, required this.courseName, required this.subject});
  final String courseId;
  final String courseName;
  final String subject;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.bar_chart_rounded, size: 32, color: cs.primary),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.teacherClassroomAnalyticsTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'View grade distributions, attendance rates, and performance trends for this class.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/teacher/classroom/$courseId/analytics', extra: <String, dynamic>{
              'name': courseName,
              'subject': subject,
            }),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(AppLocalizations.of(context)!.teacherOpenAnalyticsAction),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
