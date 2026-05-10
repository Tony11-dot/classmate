// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'teacher_student_grade_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data helpers
// ─────────────────────────────────────────────────────────────────────────────

class _StudentGradeRow {
  const _StudentGradeRow({
    required this.student,
    required this.gradeBySubject,
  });

  final TeacherStudentWithLevel student;
  // subject → latest grade (null = not graded yet)
  final Map<String, int?> gradeBySubject;

  bool matchesQuery(String q) {
    if (q.isEmpty) return true;
    final lower = q.toLowerCase();
    final name = student.name.toLowerCase();
    final email = student.email.toLowerCase();
    // Tokenise on whitespace so Arabic/Hebrew words can be searched individually.
    if (name.contains(lower) || email.contains(lower)) return true;
    for (final word in name.split(RegExp(r'\s+'))) {
      if (word.startsWith(lower)) return true;
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────

class TeacherGradesScreen extends ConsumerStatefulWidget {
  const TeacherGradesScreen({super.key});

  @override
  ConsumerState<TeacherGradesScreen> createState() =>
      _TeacherGradesScreenState();
}

class _TeacherGradesScreenState extends ConsumerState<TeacherGradesScreen> {
  List<_StudentGradeRow> _rows = [];
  List<String> _allSubjects = [];
  int _totalCourses = 0;
  bool _loading = true;
  String? _error;

  final TextEditingController _searchCtrl = TextEditingController();

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

      // Fetch students and assessment bundle in parallel.
      final results = await Future.wait<dynamic>([
        repo.fetchAllStudents(),
        repo.fetchAssessments(),
      ]);

      final allStudents = results[0] as List<TeacherStudentWithLevel>;
      final bundle = results[1] as TeacherAssessmentBundle;

      final publishedAssessments =
          bundle.assessments.where((a) => a.published).toList();

      // Build subject → courseId map from courses.
      final courseById = <String, TeacherCourse>{
        for (final c in bundle.courses) c.id: c,
      };

      // Fetch grades for all published assessments in parallel.
      final gradeResults = await Future.wait(
        publishedAssessments.map((a) async {
          try {
            final grades = await repo.fetchAssessmentGrades(a.id);
            return (assessment: a, grades: grades);
          } catch (_) {
            return null;
          }
        }),
      );

      // Build studentId → {subject → grade} matrix.
      // If a student has multiple grades per subject, keep the latest non-null.
      final matrix = <String, Map<String, int?>>{};
      for (final r in gradeResults) {
        if (r == null) continue;
        final course = courseById[r.assessment.courseId];
        final subject = course?.subject ?? r.assessment.title;
        for (final g in r.grades) {
          if (g.grade == null) continue;
          matrix.putIfAbsent(g.studentId, () => {})[subject] = g.grade;
        }
      }

      final allSubjects = bundle.courses
          .map((c) => c.subject)
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      // Only show students who have at least one recorded grade
      final rows = allStudents
          .where((s) => matrix.containsKey(s.studentId))
          .map((s) => _StudentGradeRow(
                student: s,
                gradeBySubject: matrix[s.studentId] ?? {},
              ))
          .toList()
        ..sort((a, b) => a.student.name.compareTo(b.student.name));

      if (!mounted) return;
      setState(() {
        _rows = rows;
        _allSubjects = allSubjects;
        _totalCourses = bundle.courses.length;
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

  List<_StudentGradeRow> get _filtered {
    final q = _searchCtrl.text.trim();
    return _rows.where((r) => r.matchesQuery(q)).toList();
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
          // ── Hero ────────────────────────────────────────────────────────
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            color: cs.primaryContainer,
            border: Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            '${_rows.length} students · ${_allSubjects.length} subjects',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: cs.onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.grade_rounded,
                          size: 24, color: cs.onSecondaryContainer),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _GradeStatPill(
                      value: '$_totalCourses',
                      label: l.titleClasses,
                      // Distinct green — not primaryContainer so it's visible
                      // against the card background.
                      accentColor: const Color(0xFF22C55E),
                    ),
                    const SizedBox(width: 8),
                    _GradeStatPill(
                      value: '${_allSubjects.length}',
                      label: 'Subjects',
                      accentColor: cs.secondary,
                    ),
                    const SizedBox(width: 8),
                    _GradeStatPill(
                      value: '${_rows.length}',
                      label: l.teacherGroupsLabel,
                      accentColor: cs.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Search ──────────────────────────────────────────────────────
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search students…',
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Error ────────────────────────────────────────────────────────
          if (_error != null) ...[
            LiquidGlassCard(
              color: cs.errorContainer,
              child: Text(_error!,
                  style: TextStyle(color: cs.onErrorContainer)),
            ),
            const SizedBox(height: 12),
          ],

          // ── Content ──────────────────────────────────────────────────────
          if (_loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(40), child: CmLoading()))
          else if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  _rows.isEmpty
                      ? l.teacherGradesNoStudentsLoaded
                      : 'No students match "${_searchCtrl.text}"',
                  style:
                      theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...filtered.map((row) => _StudentGradeCard(
                  row: row,
                  allSubjects: _allSubjects,
                  onTap: () async {
                    await Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TeacherStudentGradeDetailScreen(
                          student: row.student,
                        ),
                      ),
                    );
                    if (mounted) _load();
                  },
                  onAddGrade: () async {
                    await context.push(
                      '/teacher/grades/add',
                      extra: <String, dynamic>{
                        'studentIds': [row.student.studentId],
                        'subject': row.student.subjects.isNotEmpty
                            ? row.student.subjects.first
                            : null,
                      },
                    );
                    if (mounted) _load();
                  },
                )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Student grade card
// ─────────────────────────────────────────────────────────────────────────────

class _StudentGradeCard extends StatelessWidget {
  const _StudentGradeCard({
    required this.row,
    required this.allSubjects,
    required this.onTap,
    required this.onAddGrade,
  });

  final _StudentGradeRow row;
  final List<String> allSubjects;
  final VoidCallback onTap;
  final VoidCallback onAddGrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final graded = row.gradeBySubject;
    // Show subjects this student is enrolled in, falling back to all subjects.
    final subjects = row.student.subjects.isNotEmpty
        ? row.student.subjects
        : allSubjects;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(18),
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Student name + cohort ────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    row.student.name.isNotEmpty
                        ? row.student.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.student.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (row.student.cohortName.isNotEmpty)
                        Text(
                          row.student.cohortName,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  tooltip: 'Add grade',
                  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                  onPressed: onAddGrade,
                ),
              ],
            ),
            // ── Grade pills ───────────────────────────────────────────────
            if (subjects.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: subjects.map((subject) {
                  final grade = graded[subject];
                  final hasGrade = grade != null;
                  // Color-code by score: ≥80 green, 60-79 amber, <60 red
                  Color pillColor;
                  Color textColor;
                  String pillLabel;
                  if (!hasGrade) {
                    pillColor = cs.surfaceContainerHighest;
                    textColor = cs.onSurfaceVariant;
                    pillLabel = subject; // just subject name if no grade
                  } else if (grade >= 80) {
                    pillColor = cs.secondaryContainer;
                    textColor = cs.onSecondaryContainer;
                    pillLabel = '$subject · $grade';
                  } else if (grade >= 60) {
                    pillColor = const Color(0xFFFFF3CD);
                    textColor = const Color(0xFF7B5E00);
                    pillLabel = '$subject · $grade';
                  } else {
                    pillColor = cs.errorContainer;
                    textColor = cs.onErrorContainer;
                    pillLabel = '$subject · $grade';
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: textColor.withValues(alpha: 0.20)),
                    ),
                    child: Text(
                      pillLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hero stat pill — surface bg so it's always visible against the card bg
// ─────────────────────────────────────────────────────────────────────────────

class _GradeStatPill extends StatelessWidget {
  const _GradeStatPill({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: accentColor,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
