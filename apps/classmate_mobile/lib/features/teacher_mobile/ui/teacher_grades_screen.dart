// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import 'teacher_averages_screen.dart';
import '../../../core/semester/school_semester.dart';
import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/student_multi_select_sheet.dart';
import '../../../ui/widgets/weight_formats_field.dart';
import '../../../ui/widgets/semester_select_field.dart';
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
      // Two ATOMIC calls in parallel — each either loads fully or throws, so a
      // transient failure never yields partial data (no vanishing subjects).
      final results = await Future.wait<dynamic>([
        repo.fetchAllStudents(),
        repo.fetchGradesFull(),
      ]);
      final allStudents = results[0] as List<TeacherStudentWithLevel>;
      final full = results[1] as List<({TeacherAssessment assessment, List<TeacherAssessmentGrade> grades})>;
      final studentById = {for (final s in allStudents) s.studentId: s};

      // subject → studentId → list of grades, and subject → assessments
      final bySubject = <String, Map<String, List<int>>>{};
      final bySubjectAssessments = <String, List<TeacherAssessment>>{};
      for (final r in full) {
        final subject = r.assessment.subject.isNotEmpty ? r.assessment.subject : r.assessment.title;
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
    // Full-screen (root navigator): the subject detail is immersive with no app
    // top bar, so it must cover the shell entirely — otherwise the shell's FAB
    // shows through and stacks on top of this screen's Add button.
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
                      tooltip: l.a11yClear,
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
  int _avgSem = 1;
  // Local publish overrides so a publish/unpublish reflects instantly without
  // reloading the whole hub (the group is an immutable snapshot).
  final Map<String, bool> _publishOverride = {};

  bool _pub(TeacherAssessment a) => _publishOverride[a.id] ?? a.published;

  /// Per-student publish flow for an assessment: shows the liquid-glass list of
  /// every student who has a grade on it, with the currently-published ones
  /// pre-selected (select-all/unselect, individual toggles). Confirming
  /// publishes exactly the selected students and unpublishes the rest — each
  /// student only sees their own grade once it's published.
  Future<void> _openPublishSheet(TeacherAssessment a) async {
    final l = AppLocalizations.of(context)!;
    final repo = ref.read(teacherMobileRepositoryProvider);

    // Who did this grade — resolve names from the subject roster snapshot.
    final nameById = {for (final gs in widget.group.students) gs.student.studentId: gs.student.name};
    List<TeacherAssessmentGrade> rows;
    try {
      rows = await repo.fetchAssessmentGrades(a.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l.teacherCohortsScreenFailed}: $e')));
      return;
    }
    final graded = rows.where((r) => r.grade != null).toList();
    final items = <MultiSelectItem>[
      for (final r in graded)
        MultiSelectItem(id: r.studentId, name: nameById[r.studentId] ?? r.studentId, subtitle: '${r.grade} / ${a.maxGrade}'),
    ];
    if (!mounted) return;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.gradesSubjectNoGrades)));
      return;
    }
    // Pre-select the students whose grade is currently published.
    final initial = {for (final r in graded) if (r.published) r.studentId};

    final confirmed = await showStudentMultiSelectSheet(
      context: context,
      title: l.gradesPublishTitle(a.title),
      items: items,
      initiallySelected: initial,
      confirmLabel: l.gradesPublishAction,
    );
    if (confirmed == null) return; // dismissed → no change

    try {
      final nowPublished = await repo.publishAssessmentForStudents(a.id, confirmed.toList());
      if (!mounted) return;
      setState(() => _publishOverride[a.id] = nowPublished);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(confirmed.isNotEmpty ? l.gradesPublishedToast : l.gradesUnpublishedToast),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l.teacherCohortsScreenFailed}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final g = widget.group;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: cs.surface,
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
        // Full-screen & immersive: no app top bar — a slim inline header (back +
        // subject) and the tab strip live inside the body instead.
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l.a11yBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(g.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    // Manage first-class subject averages (weighted formulas),
                    // pre-filled to this subject.
                    IconButton(
                      tooltip: l.averagesManageTooltip,
                      icon: const Icon(Icons.functions_rounded),
                      onPressed: () => Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TeacherAveragesScreen(initialSubject: g.subject),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: l.gradesSubjectStudentsTab),
                  Tab(text: l.gradesSubjectGradesTab),
                  Tab(text: l.gradesSubjectAveragesTab),
                ],
              ),
              Expanded(
                child: TabBarView(
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
                            builder: (_) => TeacherStudentGradeDetailScreen(
                              student: gs.student,
                              subject: g.subject,
                            ),
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
                              _PublishPill(
                                published: _pub(a),
                                onTap: () => _openPublishSheet(a),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.tune_rounded, size: 18, color: cs.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
            // ── Averages by semester ──────────────────────────────────────
            _buildAveragesTab(context, l, cs, theme, g),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAveragesTab(BuildContext context, AppLocalizations l, ColorScheme cs, ThemeData theme, _SubjectGroup g) {
    final rawSem = ref.read(authSessionProvider).schoolSemesters;
    final count = schoolSemesterCount(rawSem);
    final sems = parseSchoolSemesters(rawSem);
    int? semOf(TeacherAssessment a) =>
        a.semester ?? semesterOfDate(sems, DateTime.tryParse(a.date) ?? DateTime.now());

    final weighted = g.assessments
        .where((a) => a.weightPercents.isNotEmpty || a.weightPercent != null)
        .where((a) => semOf(a) == _avgSem)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Weighting summary for the selected semester.
    final formatCount = weighted.fold<int>(0, (m, a) {
      final w = a.weightPercents.isNotEmpty ? a.weightPercents.length : (a.weightPercent != null ? 1 : 0);
      return w > m ? w : m;
    });
    final totals = <int>[
      for (int f = 0; f < (formatCount == 0 ? 1 : formatCount); f++)
        weighted.fold<int>(0, (s, a) {
          final ws = a.weightPercents.isNotEmpty ? a.weightPercents : (a.weightPercent != null ? [a.weightPercent!] : <int>[]);
          if (ws.isEmpty) return s;
          return s + (f < ws.length ? ws[f] : ws.last);
        }),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        // Semester selector
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 1; i <= count; i++)
              ChoiceChip(
                label: Text(l.adminSchoolSemesterN('$i')),
                selected: _avgSem == i,
                onSelected: (_) => setState(() => _avgSem = i),
              ),
          ],
        ),
        const SizedBox(height: 14),
        // Summary of the weighting for this semester.
        LiquidGlassCard(
          borderRadius: BorderRadius.circular(16),
          color: cs.primaryContainer,
          border: Border.all(color: cs.outlineVariant),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.gradesAveragesSummaryTitle,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onPrimaryContainer)),
              const SizedBox(height: 6),
              Text(l.gradesAveragesSummaryCount(weighted.length),
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
              const SizedBox(height: 4),
              for (int f = 0; f < totals.length; f++)
                Text(
                  totals.length > 1
                      ? '${l.gradeFormatN('${f + 1}')}: ${totals[f]}%'
                      : '${l.gradesAveragesTotalWeight}: ${totals[f]}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: totals[f] == 100 ? cs.onPrimaryContainer : cs.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => _addToAverage(g),
          icon: const Icon(Icons.add),
          label: Text(l.adminScheduleAddGrade),
        ),
        const SizedBox(height: 8),
        if (weighted.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(child: Text(l.gradesAveragesNoWeighted, style: TextStyle(color: cs.onSurfaceVariant))),
          )
        else
          for (final a in weighted)
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
                            Text(_assessmentSubtitle(l, a),
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
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

  /// Averages flow: instead of creating a grade on the spot, pick an existing
  /// published grade in this subject (filterable by student / grade / cohort),
  /// then set its weight %, semester and multi-format on the edit sheet — which
  /// is what makes it count toward (and be stored in) the average.
  Future<void> _addToAverage(_SubjectGroup g) async {
    final picked = await showModalBottomSheet<TeacherAssessment>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _AddToAverageSheet(group: g),
    );
    if (picked == null || !mounted) return;
    await _editAssessment(picked);
  }
}

// ── Pick an existing grade to add to the average ──────────────────────────────

class _AddToAverageSheet extends ConsumerStatefulWidget {
  const _AddToAverageSheet({required this.group});
  final _SubjectGroup group;

  @override
  ConsumerState<_AddToAverageSheet> createState() => _AddToAverageSheetState();
}

class _AddToAverageSheetState extends ConsumerState<_AddToAverageSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _weighted(TeacherAssessment a) =>
      a.weightPercents.isNotEmpty || a.weightPercent != null;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final g = widget.group;

    final query = _searchCtrl.text.trim().toLowerCase();
    final results = g.assessments
        .where((a) => query.isEmpty || a.title.toLowerCase().contains(query))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(22)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.gradesAvgPickTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(l.gradesAvgPickSubtitle(g.subject),
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: l.gradesAvgSearchHint,
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l.a11yClear,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => _searchCtrl.clear(),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: results.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(l.gradesAvgNoResults,
                            style: TextStyle(color: cs.onSurfaceVariant)),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final a = results[i];
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(a),
                          borderRadius: BorderRadius.circular(14),
                          child: LiquidGlassCard(
                            borderRadius: BorderRadius.circular(14),
                            color: cs.surfaceContainerLow,
                            border: Border.all(color: cs.outlineVariant),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(FriendlyDate.date(a.date),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: cs.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              if (_weighted(a))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(l.gradesAvgInAverage,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                          color: cs.onPrimaryContainer,
                                          fontWeight: FontWeight.w700)),
                                )
                              else
                                Icon(Icons.add_circle_outline_rounded,
                                    size: 20, color: cs.primary),
                            ]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
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
                    tooltip: l.a11yDelete,
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
              SemesterSelectField(
                count: schoolSemesterCount(ref.read(authSessionProvider).schoolSemesters),
                value: _semester,
                onChanged: (v) => setState(() => _semester = v),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const CmLoading(size: 18)
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

/// An action pill that names the command it will perform. When the assessment
/// is a draft it reads "Publish" (filled primary CTA); once published it reads
/// "Unpublish" (outlined). The label is the ACTION, not the state, so the
/// teacher always sees what tapping will do.
class _PublishPill extends StatelessWidget {
  const _PublishPill({required this.published, required this.onTap});
  final bool published;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          // Draft → prominent "Publish" CTA; Published → subdued "Unpublish".
          color: published ? Colors.transparent : cs.primary,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: published ? cs.outlineVariant : cs.primary),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(published ? Icons.visibility_off_rounded : Icons.publish_rounded,
              size: 14, color: published ? cs.onSurfaceVariant : cs.onPrimary),
          const SizedBox(width: 4),
          Text(published ? l.gradesUnpublishAction : l.gradesPublishAction,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: published ? cs.onSurfaceVariant : cs.onPrimary)),
        ]),
      ),
    );
  }
}
