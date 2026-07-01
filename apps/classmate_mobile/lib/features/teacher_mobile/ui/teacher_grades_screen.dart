// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../../../ui/widgets/weight_formats_field.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'teacher_student_grade_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data helpers
// ─────────────────────────────────────────────────────────────────────────────

/// A student graded in a subject, with their average in it.
class _GradedStudent {
  const _GradedStudent({required this.student, required this.average, required this.count});
  final TeacherStudentWithLevel student;
  final int average; // rounded mean of their grades in the subject
  final int count; // how many grades
}

/// One subject the teacher has graded, with the students graded in it.
class _SubjectGroup {
  const _SubjectGroup({
    required this.subject,
    required this.students,
    required this.average,
    required this.assessments,
  });
  final String subject;
  final List<_GradedStudent> students;
  final int? average; // subject-wide mean (rounded), null when no grades
  final List<TeacherAssessment> assessments; // the graded items in this subject
}

// ─────────────────────────────────────────────────────────────────────────────
//  Grades hub — subjects first (like the classrooms inbox)
// ─────────────────────────────────────────────────────────────────────────────

class TeacherGradesScreen extends ConsumerStatefulWidget {
  const TeacherGradesScreen({super.key});

  @override
  ConsumerState<TeacherGradesScreen> createState() => _TeacherGradesScreenState();
}

class _TeacherGradesScreenState extends ConsumerState<TeacherGradesScreen> {
  List<_SubjectGroup> _groups = [];
  int _studentCount = 0;
  bool _loading = true;
  String? _error;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait<dynamic>([
        repo.fetchAllStudents(),
        repo.fetchAssessments(),
      ]);
      final allStudents = results[0] as List<TeacherStudentWithLevel>;
      final bundle = results[1] as TeacherAssessmentBundle;
      final studentById = {for (final s in allStudents) s.studentId: s};
      final courseById = {for (final c in bundle.courses) c.id: c};

      final published = bundle.assessments.where((a) => a.published).toList();
      final gradeResults = await Future.wait(
        published.map((a) async {
          try {
            return (assessment: a, grades: await repo.fetchAssessmentGrades(a.id));
          } catch (_) {
            return null;
          }
        }),
      );

      // subject → studentId → list of grades, and subject → assessments
      final bySubject = <String, Map<String, List<int>>>{};
      final bySubjectAssessments = <String, List<TeacherAssessment>>{};
      for (final r in gradeResults) {
        if (r == null) continue;
        final course = courseById[r.assessment.courseId];
        final subject = r.assessment.subject.isNotEmpty
            ? r.assessment.subject
            : (course?.subject ?? r.assessment.title);
        bySubjectAssessments.putIfAbsent(subject, () => []).add(r.assessment);
        for (final g in r.grades) {
          final val = g.grade;
          if (val == null) continue;
          bySubject.putIfAbsent(subject, () => {}).putIfAbsent(g.studentId, () => []).add(val);
        }
      }

      final groups = <_SubjectGroup>[];
      final allGradedStudentIds = <String>{};
      for (final entry in bySubject.entries) {
        final students = <_GradedStudent>[];
        final allGrades = <int>[];
        for (final se in entry.value.entries) {
          final st = studentById[se.key];
          if (st == null) continue;
          allGradedStudentIds.add(se.key);
          final grades = se.value;
          allGrades.addAll(grades);
          final avg = (grades.reduce((a, b) => a + b) / grades.length).round();
          students.add(_GradedStudent(student: st, average: avg, count: grades.length));
        }
        if (students.isEmpty) continue;
        students.sort((a, b) => a.student.name.compareTo(b.student.name));
        final subjAvg = allGrades.isEmpty ? null : (allGrades.reduce((a, b) => a + b) / allGrades.length).round();
        final assessments = (bySubjectAssessments[entry.key] ?? [])
          ..sort((a, b) => b.date.compareTo(a.date));
        groups.add(_SubjectGroup(subject: entry.key, students: students, average: subjAvg, assessments: assessments));
      }
      groups.sort((a, b) => a.subject.compareTo(b.subject));

      if (!mounted) return;
      setState(() {
        _groups = groups;
        _studentCount = allGradedStudentIds.length;
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

  List<_SubjectGroup> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _groups;
    return _groups.where((g) => g.subject.toLowerCase().contains(q)).toList();
  }

  Future<void> _openSubject(_SubjectGroup g) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(builder: (_) => _SubjectGradesScreen(group: g)),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final filtered = _filtered;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            color: cs.primaryContainer,
            border: Border.all(color: cs.outlineVariant),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.navGrades,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.gradesHubSummary(_groups.length, _studentCount),
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.grade_rounded, size: 24, color: cs.onSecondaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: l.gradesHubSearchSubjects,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchCtrl.clear();
                        FocusScope.of(context).unfocus();
                      },
                    ),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null) ...[
            LiquidGlassCard(color: cs.errorContainer, child: Text(_error!, style: TextStyle(color: cs.onErrorContainer))),
            const SizedBox(height: 12),
          ],
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(l.gradesHubEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
              ),
            )
          else
            ...filtered.map((g) => _SubjectCard(group: g, onTap: () => _openSubject(g))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Subject card — two-band, like the classrooms inbox
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.group, required this.onTap});
  final _SubjectGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: cs.primaryContainer,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 20, color: cs.onPrimaryContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          group.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800, color: cs.onPrimaryContainer),
                        ),
                      ),
                      if (group.average != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(999)),
                          child: Text('${group.average}',
                              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, color: cs.primary)),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: cs.surfaceContainerLow,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.people_alt_rounded, size: 15, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.gradesHubStudentCount(group.students.length),
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
                    ],
                  ),
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
//  Subject detail — full screen, students graded in this subject
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectGradesScreen extends ConsumerStatefulWidget {
  const _SubjectGradesScreen({required this.group});
  final _SubjectGroup group;

  @override
  ConsumerState<_SubjectGradesScreen> createState() => _SubjectGradesScreenState();
}

class _SubjectGradesScreenState extends ConsumerState<_SubjectGradesScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final g = widget.group;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(g.subject, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          bottom: TabBar(
            tabs: [
              Tab(text: l.gradesSubjectStudentsTab),
              Tab(text: l.gradesSubjectGradesTab),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push('/teacher/grades/add', extra: <String, dynamic>{
              'studentIds': g.students.map((s) => s.student.studentId).toList(),
              'subject': g.subject,
            });
            if (mounted) Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.add),
          label: Text(l.adminScheduleAddGrade),
        ),
        body: TabBarView(
          children: [
            // ── Students ─────────────────────────────────────────────────
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                for (final gs in g.students)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TeacherStudentGradeDetailScreen(student: gs.student),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: LiquidGlassCard(
                        borderRadius: BorderRadius.circular(16),
                        color: cs.surfaceContainerLow,
                        border: Border.all(color: cs.outlineVariant),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                gs.student.name.isNotEmpty ? gs.student.name[0].toUpperCase() : '?',
                                style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(gs.student.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                  if (gs.student.cohortName.isNotEmpty)
                                    Text(gs.student.cohortName,
                                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            _GradeBadge(value: gs.average),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // ── Grades (the assessments) — edit / set % ───────────────────
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                if (g.assessments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text(l.gradesSubjectNoGrades, style: TextStyle(color: cs.onSurfaceVariant))),
                  )
                else
                  for (final a in g.assessments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => _editAssessment(a),
                        borderRadius: BorderRadius.circular(16),
                        child: LiquidGlassCard(
                          borderRadius: BorderRadius.circular(16),
                          color: cs.surfaceContainerLow,
                          border: Border.all(color: cs.outlineVariant),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _assessmentSubtitle(l, a),
                                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.tune_rounded, size: 18, color: cs.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _assessmentSubtitle(AppLocalizations l, TeacherAssessment a) {
    final parts = <String>[FriendlyDate.date(a.date)];
    final weights = readWeights({'weightPercents': a.weightPercents, 'weightPercent': a.weightPercent});
    if (weights.isNotEmpty) parts.add(weights.map((w) => '$w%').join(' / '));
    if (a.semester != null) parts.add(l.adminSchoolSemesterN('${a.semester}'));
    return parts.join(' · ');
  }

  Future<void> _editAssessment(TeacherAssessment a) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _EditAssessmentSheet(assessment: a),
    );
    if (changed == true && mounted) {
      Navigator.of(context).maybePop(); // back to hub, which reloads
    }
  }
}

// ── Edit / set-% sheet for an assessment ──────────────────────────────────────

class _EditAssessmentSheet extends ConsumerStatefulWidget {
  const _EditAssessmentSheet({required this.assessment});
  final TeacherAssessment assessment;

  @override
  ConsumerState<_EditAssessmentSheet> createState() => _EditAssessmentSheetState();
}

class _EditAssessmentSheetState extends ConsumerState<_EditAssessmentSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _maxCtrl;
  late List<int> _weights;
  int? _semester;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final a = widget.assessment;
    _titleCtrl = TextEditingController(text: a.title);
    _maxCtrl = TextEditingController(text: a.maxGrade != null ? '${a.maxGrade}' : '');
    _weights = readWeights({'weightPercents': a.weightPercents, 'weightPercent': a.weightPercent});
    _semester = a.semester;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(teacherMobileRepositoryProvider).updateAssessment(
            assessmentId: widget.assessment.id,
            title: _titleCtrl.text.trim().isEmpty ? widget.assessment.title : _titleCtrl.text.trim(),
            date: widget.assessment.date,
            maxGrade: int.tryParse(_maxCtrl.text.trim()),
            weightPercents: _weights,
            semester: _semester,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.gradeDeleteTitle),
        content: Text(l.gradeDeleteConfirm(widget.assessment.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.averagesDelete)),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(teacherMobileRepositoryProvider).deleteAssessment(widget.assessment.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(22)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l.gradesEditGradeTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                    onPressed: _busy ? null : _delete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: l.averagesFieldTitle, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _maxCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.teacherAssignmentMaxGrade, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              WeightFormatsField(value: _weights, onChanged: (w) => _weights = w),
              const SizedBox(height: 12),
              LiquidGlassSelectField<int>(
                label: l.gradeSemesterLabel,
                value: _semester ?? 0,
                items: [
                  LiquidGlassDropdownItem(value: 0, label: l.gradeSemesterAuto),
                  LiquidGlassDropdownItem(value: 1, label: l.adminSchoolSemesterN('1')),
                  LiquidGlassDropdownItem(value: 2, label: l.adminSchoolSemesterN('2')),
                ],
                onChanged: (v) => setState(() => _semester = v == 0 ? null : v),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l.averagesSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    if (value >= 80) {
      bg = cs.secondaryContainer;
      fg = cs.onSecondaryContainer;
    } else if (value >= 60) {
      bg = const Color(0xFFFFF3CD);
      fg = const Color(0xFF7B5E00);
    } else {
      bg = cs.errorContainer;
      fg = cs.onErrorContainer;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text('$value', style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 15)),
    );
  }
}
