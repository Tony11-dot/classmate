// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/realtime/realtime_listener.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';

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
              style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
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
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();

    // Refresh when a student submits an assignment (assignment_created event)
    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'assignment_created') _load();
    });

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Hero
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.secondary),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assignments',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_assignments.length} total · ${_assignments.where((a) => a['published'] == true).length} published',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.assignment_rounded, size: 24, color: cs.onSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LiquidGlassCard(
                color: cs.errorContainer,
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: TextStyle(color: cs.onErrorContainer))),
                    TextButton(onPressed: _load, child: Text(AppLocalizations.of(context)!.commonRetry)),
                  ],
                ),
              ),
            ),

          if (_loading && _assignments.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (!_loading && _assignments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined, size: 48, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'No assignments yet.\nTap + to create one.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._assignments.map((a) {
              final id = a['id'] as String? ?? '';
              final title = a['title'] as String? ?? '';
              final subject = a['subject'] as String? ?? '';
              final courseName = a['courseName'] as String? ?? '';
              final dueAtRaw = a['dueAt'] as String? ?? '';
              final submissionsCount = a['submissionsCount'] as int? ?? 0;
              final published = a['published'] as bool? ?? false;

              DateTime? dueDate;
              if (dueAtRaw.isNotEmpty) dueDate = DateTime.tryParse(dueAtRaw);
              final overdue = dueDate != null && dueDate.isBefore(now);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey('ta_$id'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    await _delete(id);
                    return false;
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: cs.onErrorContainer),
                  ),
                  child: GestureDetector(
                    onTap: () => context.push(
                      '/teacher/assignments/$id/detail',
                      extra: title,
                    ).then((_) => _load()),
                    child: LiquidGlassCard(
                      border: Border.all(color: cs.outlineVariant),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cs.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.assignment_rounded, size: 22, color: cs.onSecondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                if (subject.isNotEmpty || courseName.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    [subject, courseName].where((s) => s.isNotEmpty).join(' · '),
                                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    // Published badge
                                    _Chip(
                                      label: published ? 'Published' : 'Draft',
                                      color: published ? cs.primary : cs.surfaceContainerHighest,
                                      textColor: published ? cs.onPrimary : cs.onSurfaceVariant,
                                    ),
                                    if (dueDate != null)
                                      _Chip(
                                        label: DateFormat.yMMMd(locale).format(dueDate),
                                        color: overdue ? cs.errorContainer : cs.secondaryContainer,
                                        textColor: overdue ? cs.onErrorContainer : cs.onSecondaryContainer,
                                      ),
                                    if (submissionsCount > 0)
                                      _Chip(
                                        label: '$submissionsCount submitted',
                                        color: cs.tertiaryContainer,
                                        textColor: cs.onTertiaryContainer,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
                            IconButton(
                              tooltip: AppLocalizations.of(context)!.teacherEditTooltip,
                              icon: Icon(Icons.edit_rounded, size: 16, color: cs.primary),
                              onPressed: () => context.push('/teacher/assignments/add', extra: <String, dynamic>{'initialAssignment': a}).then((_) => _load()),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
                            if (!published)
                              IconButton(
                                tooltip: AppLocalizations.of(context)!.teacherPublishTooltip,
                                icon: Icon(Icons.publish_rounded, size: 16, color: cs.primary),
                                onPressed: () async {
                                  try {
                                    await ref.read(teacherMobileRepositoryProvider).updateTeacherAssignment(id, {'published': true});
                                    _load();
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                  }
                                },
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
                            IconButton(
                              tooltip: AppLocalizations.of(context)!.teacherDeleteTooltip,
                              icon: Icon(Icons.delete_outline_rounded, size: 16, color: cs.error),
                              onPressed: () => _delete(id),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.textColor});
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
    );
  }
}
