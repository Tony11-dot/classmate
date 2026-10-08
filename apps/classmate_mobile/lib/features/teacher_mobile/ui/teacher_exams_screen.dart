// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../core/semester/school_semester.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/semester_filter_bar.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

class TeacherExamsScreen extends ConsumerStatefulWidget {
  const TeacherExamsScreen({super.key});

  @override
  ConsumerState<TeacherExamsScreen> createState() => _TeacherExamsScreenState();
}

class _TeacherExamsScreenState extends ConsumerState<TeacherExamsScreen> {
  List<Map<String, dynamic>> _exams = [];
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
      final exams = await ref.read(teacherMobileRepositoryProvider).listTeacherExams();
      if (!mounted) return;
      setState(() {
        _exams = exams;
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
        final lCtx = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(lCtx.teacherDeleteExamTitle),
          content: Text(lCtx.teacherDeleteExamBody),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(lCtx.actionCancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error, foregroundColor: Theme.of(ctx).colorScheme.onError),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(lCtx.actionDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).deleteTeacherExam(id);
      if (!mounted) return;
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _openExamGrades(Map<String, dynamic> exam) {
    final id = exam['id'] as String? ?? '';
    context.push('/teacher/exams/$id/grades', extra: exam).then((_) => _load());
  }

  void _openExamEdit(Map<String, dynamic> exam) {
    context.push('/teacher/exams/create', extra: exam).then((_) => _load());
  }

  Future<void> _publishExam(String id) async {
    try {
      await ref.read(teacherMobileRepositoryProvider).updateTeacherExam(id, {'published': true});
      if (!mounted) return;
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Semester split (by exam date) — pills only show when the school
    // configured semesters.
    final semWindow = ref.watch(currentSemesterWindowProvider);
    final visibleExams = visibleForSemester<Map<String, dynamic>>(
      _exams,
      (e) => DateTime.tryParse(e['date'] as String? ?? ''),
      semWindow,
      _showingPrevious,
      _selectedPast,
    );

    final upcoming = visibleExams.where((e) {
      final d = DateTime.tryParse(e['date'] as String? ?? '');
      return d != null && !d.isBefore(now);
    }).toList();
    final past = visibleExams.where((e) {
      final d = DateTime.tryParse(e['date'] as String? ?? '');
      return d != null && d.isBefore(now);
    }).toList();

    return CmRefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Hero
          CmCard(
            tint: cs.primary,
            radius: CmTokens.radiusXl,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.teacherExamsTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          CmPill(
                            icon: Icons.upcoming_rounded,
                            label: '${upcoming.length} ${l.teacherExamsUpcoming}',
                            color: cs.primary,
                          ),
                          CmPill(
                            icon: Icons.history_edu_rounded,
                            label: '${past.length} ${l.teacherExamsPast}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const CmIconTile(icon: Icons.quiz_rounded, size: 52, filled: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (semWindow != null) ...[
            SemesterFilterBar(
              showingPrevious: _showingPrevious,
              selectedPast: _selectedPast,
              onPastChanged: (w) => setState(() => _selectedPast = w),
              onChanged: (v) => setState(() {
                _showingPrevious = v;
                if (!v) _selectedPast = null;
              }),
            ),
            const SizedBox(height: 4),
          ],

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ErrorBanner(message: _error!, onRetry: _load),
            ),

          if (_loading && _exams.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (_exams.isEmpty)
            CmEmptyState(icon: Icons.quiz_outlined, title: l.teacherExamsEmpty)
          else ...[
            if (upcoming.isNotEmpty) ...[
              CmSectionHeader(
                label: l.teacherExamsUpcoming,
                icon: Icons.upcoming_rounded,
                count: upcoming.length,
                color: cs.primary,
              ),
              ...upcoming.map((e) => _ExamCard(
                    exam: e,
                    isUpcoming: true,
                    onTap: () => _openExamGrades(e),
                    onEdit: () => _openExamEdit(e),
                    onDelete: () => _delete(e['id'] as String? ?? ''),
                    onPublish: (e['published'] as bool? ?? true) ? null : () => _publishExam(e['id'] as String? ?? ''),
                  )),
              const SizedBox(height: 8),
            ],
            if (past.isNotEmpty) ...[
              CmSectionHeader(
                label: l.teacherExamsPast,
                icon: Icons.history_edu_rounded,
                count: past.length,
              ),
              ...past.map((e) => _ExamCard(
                    exam: e,
                    isUpcoming: false,
                    onTap: () => _openExamGrades(e),
                    onEdit: () => _openExamEdit(e),
                    onDelete: () => _delete(e['id'] as String? ?? ''),
                    onPublish: (e['published'] as bool? ?? true) ? null : () => _publishExam(e['id'] as String? ?? ''),
                  )),
            ],
          ],
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(CmTokens.radiusLg),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: cs.onErrorContainer))),
          TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.commonRetry)),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.exam,
    required this.isUpcoming,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onPublish,
  });

  final Map<String, dynamic> exam;
  final bool isUpcoming;
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

    final title = exam['title'] as String? ?? '';
    final subject = exam['subject'] as String? ?? '';
    final courseName = exam['courseName'] as String? ?? '';
    final published = exam['published'] as bool? ?? false;
    final gradedCount = exam['gradedCount'] as int? ?? 0;
    final maxGrade = exam['maxGrade'] as int?;
    final dateRaw = exam['date'] as String? ?? '';
    final date = dateRaw.isNotEmpty ? DateTime.tryParse(dateRaw) : null;
    final meta = [subject, courseName].where((s) => s.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CmCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(12, 12, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CmDateStub(
                  date: date,
                  color: isUpcoming ? cs.primary : cs.onSurfaceVariant,
                ),
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
                        if (date != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            FriendlyDate.date(date),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isUpcoming ? cs.primary : cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 4),
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
                      if (maxGrade != null)
                        CmPill(icon: Icons.grade_rounded, label: '/ $maxGrade'),
                      if (gradedCount > 0)
                        CmPill(
                          icon: Icons.done_all_rounded,
                          label: l.teacherExamsScreenGradedCount(gradedCount),
                          color: cs.tertiary,
                        ),
                    ],
                  ),
                ),
                if (!published && onPublish != null)
                  CmIconAction(
                    icon: Icons.publish_rounded,
                    tooltip: l.teacherPublishTooltip,
                    onPressed: onPublish,
                    color: cs.primary,
                  ),
                CmIconAction(icon: Icons.edit_rounded, tooltip: l.a11yEdit, onPressed: onEdit),
                CmIconAction(
                  icon: Icons.delete_outline_rounded,
                  tooltip: l.a11yDelete,
                  onPressed: onDelete,
                  color: cs.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
