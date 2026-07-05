// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../core/semester/school_semester.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/semester_filter_bar.dart';

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
              style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
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

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Hero
          LiquidGlassCard(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.outlineVariant),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.teacherExamsTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${upcoming.length} ${l.teacherExamsUpcoming}  ·  ${past.length} ${l.teacherExamsPast}',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.quiz_rounded, size: 24, color: cs.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (semWindow != null) ...[
            SemesterFilterBar(
              showingPrevious: _showingPrevious,
              selectedPast: _selectedPast,
              onPastChanged: (w) => setState(() => _selectedPast = w),
              onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
            ),
            const SizedBox(height: 4),
          ],

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

          if (_loading && _exams.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (_exams.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.quiz_outlined, size: 48, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(l.teacherExamsEmpty, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else ...[
            if (upcoming.isNotEmpty) ...[
              _SectionHeader(label: l.teacherExamsUpcoming, icon: Icons.upcoming_rounded, color: cs.primary),
              const SizedBox(height: 8),
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
              _SectionHeader(label: l.teacherExamsPast, icon: Icons.history_edu_rounded, color: cs.secondary),
              const SizedBox(height: 8),
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
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final accentColor = isUpcoming ? cs.primary : cs.secondary;

    final title = exam['title'] as String? ?? '';
    final subject = exam['subject'] as String? ?? '';
    final courseName = exam['courseName'] as String? ?? '';
    final published = exam['published'] as bool? ?? false;
    final gradedCount = exam['gradedCount'] as int? ?? 0;
    final maxGrade = exam['maxGrade'] as int?;
    final dateRaw = exam['date'] as String? ?? '';
    DateTime? date = dateRaw.isNotEmpty ? DateTime.tryParse(dateRaw) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: LiquidGlassCard(
          border: Border.all(color: cs.outlineVariant),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isUpcoming ? Icons.upcoming_rounded : Icons.history_edu_rounded, size: 22, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: published ? cs.primaryContainer : cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            published ? AppLocalizations.of(context)!.teacherMaterialPublished : AppLocalizations.of(context)!.teacherMaterialDraft,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: published ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                          ),
                        ),
                      ],
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
                        if (date != null)
                          _Chip(label: FriendlyDate.date(date), color: accentColor),
                        if (maxGrade != null)
                          _Chip(label: '/ $maxGrade', color: cs.tertiary),
                        if (gradedCount > 0)
                          _GradedChip(label: AppLocalizations.of(context)!.teacherExamsScreenGradedCount(gradedCount), cs: cs),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!published && onPublish != null)
                    IconButton(
                      icon: Icon(Icons.publish_rounded, size: 16, color: cs.primary),
                      tooltip: AppLocalizations.of(context)!.teacherPublishTooltip,
                      onPressed: onPublish,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  IconButton(
                    tooltip: l.a11yEdit,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    onPressed: onEdit,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                  IconButton(
                    tooltip: l.a11yDelete,
                    icon: Icon(Icons.delete_outline_rounded, size: 16, color: cs.error),
                    onPressed: onDelete,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: color, letterSpacing: 0.3),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

class _GradedChip extends StatelessWidget {
  const _GradedChip({required this.label, required this.cs});
  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onTertiaryContainer)),
    );
  }
}
