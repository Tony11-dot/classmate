// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';

import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/teacher_mobile_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────────────────────────────────────

class _GradeEntry {
  _GradeEntry({
    required this.assessment,
    required this.subject,
    this.grade,
  }) : controller = TextEditingController(
          text: grade?.toString() ?? '',
        ),
       initialGrade = grade;

  final TeacherAssessment assessment;
  final String subject;
  final TextEditingController controller;
  int? grade;
  int? initialGrade;

  bool get isDirty => int.tryParse(controller.text.trim()) != initialGrade;

  void dispose() => controller.dispose();
}

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────

class TeacherStudentGradeDetailScreen extends ConsumerStatefulWidget {
  const TeacherStudentGradeDetailScreen({
    super.key,
    required this.student,
  });

  final TeacherStudentWithLevel student;

  @override
  ConsumerState<TeacherStudentGradeDetailScreen> createState() =>
      _TeacherStudentGradeDetailScreenState();
}

class _TeacherStudentGradeDetailScreenState
    extends ConsumerState<TeacherStudentGradeDetailScreen> {
  List<_GradeEntry> _entries = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final bundle = await repo.fetchAssessments();

      final courseById = <String, TeacherCourse>{
        for (final c in bundle.courses) c.id: c,
      };

      // Fetch grades for all published assessments in parallel.
      final results = await Future.wait(
        bundle.assessments
            .where((a) => a.published)
            .map((a) async {
              try {
                final grades = await repo.fetchAssessmentGrades(a.id);
                final match = grades
                    .where((g) => g.studentId == widget.student.studentId)
                    .firstOrNull;
                return (assessment: a, grade: match?.grade);
              } catch (_) {
                return null;
              }
            }),
      );

      final entries = <_GradeEntry>[];
      for (final r in results) {
        if (r == null) continue;
        final course = courseById[r.assessment.courseId];
        final subject = course?.subject ?? r.assessment.title;
        // Only show assessments for subjects this student is enrolled in.
        if (widget.student.subjects.isNotEmpty &&
            !widget.student.subjects.contains(subject)) {
          continue;
        }
        entries.add(
          _GradeEntry(
            assessment: r.assessment,
            subject: subject,
            grade: r.grade,
          ),
        );
      }

      // Group by subject → sort by subject name, then assessment date.
      entries.sort((a, b) {
        final bySub = a.subject.compareTo(b.subject);
        if (bySub != 0) return bySub;
        return a.assessment.date.compareTo(b.assessment.date);
      });

      if (!mounted) return;
      setState(() {
        _entries = entries;
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

  Future<void> _save() async {
    final dirty = _entries.where((e) => e.isDirty).toList();
    if (dirty.isEmpty) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      for (final entry in dirty) {
        final val = int.tryParse(entry.controller.text.trim());
        if (val == null) continue;
        await repo.saveBulkGrades(
          assessmentId: entry.assessment.id,
          grades: [
            TeacherGradeDraftRecord(
              studentId: widget.student.studentId,
              grade: val,
            ),
          ],
        );
        entry.initialGrade = val;
        entry.grade = val;
      }
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherStudentGradesSaved)),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.commonErrorWith(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final s = widget.student;

    // Group entries by subject.
    final bySubject = <String, List<_GradeEntry>>{};
    for (final e in _entries) {
      bySubject.putIfAbsent(e.subject, () => []).add(e);
    }

    final hasDirty = _entries.any((e) => e.isDirty);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.name,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (s.cohortName.isNotEmpty)
              Text(
                s.cohortName,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          if (hasDirty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(l.commonSave),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CmLoading())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _error!,
                        style: TextStyle(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.grade_outlined,
                                size: 48, color: cs.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'No grades yet for ${s.name}',
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 120),
                        children: [
                          // ── Student hero ─────────────────────────────────
                          LiquidGlassCard(
                            borderRadius: BorderRadius.circular(20),
                            color: cs.primaryContainer,
                            border: Border.all(
                                color: cs.outlineVariant),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    s.name.isNotEmpty
                                        ? s.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: cs.onPrimary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: cs.onPrimaryContainer,
                                        ),
                                      ),
                                      Text(
                                        [
                                          if (s.cohortName.isNotEmpty)
                                            s.cohortName,
                                          if (s.gradeLevel != null)
                                            'Grade ${s.gradeLevel}',
                                          '${_entries.where((e) => e.grade != null).length} grades',
                                        ].join(' · '),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color:
                                                    cs.onPrimaryContainer),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ── Grades by subject ────────────────────────────
                          ...bySubject.entries.map((entry) {
                            final subject = entry.key;
                            final rows = entry.value;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 14),
                              child: LiquidGlassCard(
                                borderRadius: BorderRadius.circular(18),
                                color: cs.surfaceContainerLow,
                                border: Border.all(
                                    color: cs.outlineVariant),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Subject header
                                    Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: cs.secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    10),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.menu_book_rounded,
                                            size: 16,
                                            color:
                                                cs.onSecondaryContainer,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          subject,
                                          style: theme
                                              .textTheme.titleSmall
                                              ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w800),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    // ── Ungraded assessments first ───────────
                                    Builder(builder: (ctx) {
                                      final ungraded = rows.where((e) => e.grade == null).toList();
                                      final graded = rows.where((e) => e.grade != null).toList();

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (ungraded.isNotEmpty) ...[
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 6),
                                              child: Row(children: [
                                                Icon(Icons.pending_rounded, size: 13, color: cs.onSurfaceVariant),
                                                const SizedBox(width: 5),
                                                Text(l.teacherStudentToGrade, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                                              ]),
                                            ),
                                            ...ungraded.map((e) => Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: _GradeRow(entry: e, onChanged: () => setState(() {})),
                                            )),
                                          ],
                                          if (graded.isNotEmpty && ungraded.isNotEmpty) ...[
                                            const Divider(height: 16),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 6),
                                              child: Row(children: [
                                                Icon(Icons.check_circle_outline_rounded, size: 13, color: cs.primary),
                                                const SizedBox(width: 5),
                                                Text(l.teacherStudentGraded, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary)),
                                              ]),
                                            ),
                                          ],
                                          ...graded.asMap().entries.map((re) => Padding(
                                            padding: EdgeInsets.only(bottom: re.key < graded.length - 1 ? 10 : 0),
                                            child: _GradeRow(entry: re.value, onChanged: () => setState(() {})),
                                          )),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single editable grade row
// ─────────────────────────────────────────────────────────────────────────────

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.entry, required this.onChanged});

  final _GradeEntry entry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDirty = entry.isDirty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDirty
            ? cs.primaryContainer.withValues(alpha: 0.35)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isDirty
            ? Border.all(
                color: cs.primary.withValues(alpha: 0.30))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.assessment.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (entry.assessment.date.isNotEmpty)
                  Text(
                    entry.assessment.date,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: TextField(
              controller: entry.controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (_) => onChanged(),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: entry.grade != null
                    ? '/ ${entry.assessment.maxGrade ?? 100}'
                    : '—',
                hintStyle: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDirty ? cs.primary : cs.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
