// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/realtime/realtime_listener.dart';
import '../../../core/semester/school_semester.dart';
import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../../../ui/widgets/semester_filter_bar.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

class TeacherAssignmentsScreen extends ConsumerStatefulWidget {
  const TeacherAssignmentsScreen({super.key});

  @override
  ConsumerState<TeacherAssignmentsScreen> createState() =>
      _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState
    extends ConsumerState<TeacherAssignmentsScreen> {
  List<Map<String, dynamic>> _assignments = [];
  bool _loading = true;
  String? _error;
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref.read(teacherMobileRepositoryProvider).listTeacherAssignments();
      if (!mounted) return;
      setState(() {
        _assignments = items;
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

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l.teacherDeleteAssignmentTitle),
          content: Text(l.teacherDeleteAssignmentBody),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.commonCancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error, foregroundColor: Theme.of(ctx).colorScheme.onError),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.commonDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).deleteTeacherAssignmentV2(id);
      if (!mounted) return;
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Refresh when a student submits an assignment (assignment_created event)
    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'assignment_created') _load();
    });

    // Semester split (by due date, falling back to created date) — pills only
    // show when the school configured semesters.
    final semWindow = ref.watch(currentSemesterWindowProvider);
    final visible = visibleForSemester<Map<String, dynamic>>(
      _assignments,
      (a) => DateTime.tryParse(
        (a['dueAt'] as String?)?.trim().isNotEmpty == true
            ? a['dueAt'] as String
            : (a['createdAt'] as String? ?? ''),
      ),
      semWindow,
      _showingPrevious,
      _selectedPast,
    );

    final l = AppLocalizations.of(context)!;
    final publishedCount = _assignments.where((a) => a['published'] == true).length;

    return CmRefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Hero
          CmCard(
            tint: cs.secondary,
            radius: CmTokens.radiusXl,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.teacherAssignmentsScreenTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.teacherAssignmentsScreenSummary(_assignments.length, publishedCount),
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CmIconTile(icon: Icons.assignment_rounded, color: cs.secondary, size: 52, filled: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SemesterFilterBar(
            visible: semWindow != null,
            showingPrevious: _showingPrevious,
            selectedPast: _selectedPast,
            onPastChanged: (w) => setState(() => _selectedPast = w),
            onChanged: (v) => setState(() {
              _showingPrevious = v;
              if (!v) _selectedPast = null;
            }),
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 8, 8),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(CmTokens.radiusLg),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: TextStyle(color: cs.onErrorContainer))),
                    TextButton(onPressed: _load, child: Text(l.commonRetry)),
                  ],
                ),
              ),
            ),

          if (_loading && _assignments.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (!_loading && visible.isEmpty)
            CmEmptyState(icon: Icons.assignment_outlined, title: l.teacherAssignmentsScreenEmpty)
          else
            ...visible.map((a) {
              final id = a['id'] as String? ?? '';
              final title = a['title'] as String? ?? '';
              final published = a['published'] as bool? ?? false;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey('ta_$id'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    await _delete(id);
                    return false;
                  },
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsetsDirectional.only(end: 24),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(CmTokens.radiusLg),
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: cs.onErrorContainer),
                  ),
                  child: _AssignmentCard(
                    assignment: a,
                    now: now,
                    onTap: () => context.push(
                      '/teacher/assignments/$id/detail',
                      extra: title,
                    ).then((_) => _load()),
                    onEdit: () => context.push(
                      '/teacher/assignments/add',
                      extra: <String, dynamic>{'initialAssignment': a},
                    ).then((_) => _load()),
                    onPublish: published
                        ? null
                        : () async {
                            try {
                              await ref.read(teacherMobileRepositoryProvider).updateTeacherAssignment(id, {'published': true});
                              _load();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          },
                    onDelete: () => _delete(id),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.assignment,
    required this.now,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onPublish,
  });

  final Map<String, dynamic> assignment;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tk = CmTokens.of(context);
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final a = assignment;

    final title = a['title'] as String? ?? '';
    final subject = a['subject'] as String? ?? '';
    final courseName = a['courseName'] as String? ?? '';
    final dueAtRaw = a['dueAt'] as String? ?? '';
    final submissionsCount = a['submissionsCount'] as int? ?? 0;
    final gradedCount = a['gradedCount'] as int? ?? 0;
    final published = a['published'] as bool? ?? false;
    final dueDate = dueAtRaw.isNotEmpty ? DateTime.tryParse(dueAtRaw) : null;
    final overdue = dueDate != null && dueDate.isBefore(now);
    final dueColor = overdue ? cs.error : cs.secondary;
    final meta = [subject, courseName].where((s) => s.isNotEmpty).join(' · ');

    return CmCard(
      onTap: onTap,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 6, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dueDate != null)
                CmDateStub(date: dueDate, color: dueColor)
              else
                CmIconTile(icon: Icons.assignment_rounded, color: cs.secondary, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
                      ),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                      if (dueDate != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              overdue ? Icons.schedule_rounded : Icons.event_rounded,
                              size: 14,
                              color: overdue ? cs.error : cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              FriendlyDate.date(dueDate),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: overdue ? cs.error : cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 2, end: 4),
                child: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    CmPill(
                      icon: published ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                      label: published ? l.teacherMaterialPublished : l.teacherMaterialDraft,
                      color: published ? tk.good : tk.warn,
                    ),
                    if (submissionsCount > 0)
                      CmPill(
                        icon: Icons.upload_file_rounded,
                        label: l.teacherAssignmentsScreenSubmitted(submissionsCount),
                        color: cs.tertiary,
                      ),
                    if (gradedCount > 0)
                      CmPill(
                        icon: Icons.done_all_rounded,
                        label: l.teacherExamsScreenGradedCount(gradedCount),
                        color: cs.primary,
                      ),
                  ],
                ),
              ),
              CmIconAction(
                icon: Icons.edit_rounded,
                tooltip: l.teacherEditTooltip,
                onPressed: onEdit,
                color: cs.primary,
              ),
              if (onPublish != null)
                CmIconAction(
                  icon: Icons.publish_rounded,
                  tooltip: l.teacherPublishTooltip,
                  onPressed: onPublish,
                  color: cs.primary,
                ),
              CmIconAction(
                icon: Icons.delete_outline_rounded,
                tooltip: l.teacherDeleteTooltip,
                onPressed: onDelete,
                color: cs.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
