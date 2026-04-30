import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

class TeacherGradesScreen extends ConsumerStatefulWidget {
  const TeacherGradesScreen({super.key});

  @override
  ConsumerState<TeacherGradesScreen> createState() => _TeacherGradesScreenState();
}

class _TeacherGradesScreenState extends ConsumerState<TeacherGradesScreen> {
  TeacherAssessmentBundle? _bundle;
  TeacherAssessment? _selectedAssessment;
  List<TeacherStudent> _students = const <TeacherStudent>[];
  Map<String, int?> _grades = <String, int?>{};
  Map<String, int?> _initialGrades = <String, int?>{};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _maxGradeCtrl = TextEditingController();
  String? _selectedCourseId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _maxGradeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bundle = await ref.read(teacherMobileRepositoryProvider).fetchAssessments();
      if (!mounted) return;
      setState(() {
        _bundle = bundle;
        _selectedCourseId ??= bundle.courses.isNotEmpty ? bundle.courses.first.id : null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createAssessment() async {
    final l = AppLocalizations.of(context)!;
    final courseId = _selectedCourseId;
    if (courseId == null || _titleCtrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final maxGrade = int.tryParse(_maxGradeCtrl.text.trim());
      final dateStr = _selectedDate != null
          ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
          : '';
      await ref.read(teacherMobileRepositoryProvider).createAssessment(
            courseId: courseId,
            title: _titleCtrl.text,
            date: dateStr,
            maxGrade: maxGrade,
          );
      _titleCtrl.clear();
      _maxGradeCtrl.clear();
      setState(() => _selectedDate = null);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherGradesAssessmentCreated)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _editAssessment(TeacherAssessment assessment) async {
    final l = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController(text: assessment.title);
    final dateCtrl = TextEditingController(text: assessment.date.split('T').first);
    final maxGradeCtrl = TextEditingController(text: assessment.maxGrade?.toString() ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.teacherGradesEditAssessmentTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: l.teacherGradesFieldTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateCtrl,
              decoration: InputDecoration(labelText: l.teacherGradesFieldDate),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxGradeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.teacherGradesFieldMaxGrade),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomsForwardCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.profileSave),
          ),
        ],
      ),
    );
    final updatedTitle = titleCtrl.text;
    final updatedDate = dateCtrl.text;
    final updatedMaxGrade = maxGradeCtrl.text;
    titleCtrl.dispose();
    dateCtrl.dispose();
    maxGradeCtrl.dispose();
    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(teacherMobileRepositoryProvider).updateAssessment(
            assessmentId: assessment.id,
        title: updatedTitle,
        date: updatedDate,
        maxGrade: int.tryParse(updatedMaxGrade.trim()),
          );
      await _load();
      if (!mounted) return;
      if (_selectedAssessment?.id == assessment.id) {
        final refreshed = _bundle?.assessments.where((item) => item.id == assessment.id).firstOrNull;
        if (refreshed != null) {
          await _openAssessment(refreshed);
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherGradesAssessmentUpdated)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteAssessment(TeacherAssessment assessment) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.teacherGradesDeleteAssessmentTitle),
        content: Text(
          l.teacherGradesDeleteAssessmentBody(assessment.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomsForwardCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.teacherGradesDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(teacherMobileRepositoryProvider).deleteAssessment(assessment.id);
      if (_selectedAssessment?.id == assessment.id) {
        _selectedAssessment = null;
        _students = const <TeacherStudent>[];
        _grades = <String, int?>{};
        _initialGrades = <String, int?>{};
      }
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherGradesAssessmentDeleted)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openAssessment(TeacherAssessment assessment) async {
    final l = AppLocalizations.of(context)!;
    final bundle = _bundle;
    if (bundle == null) return;
    final course = bundle.courses.where((item) => item.id == assessment.courseId).firstOrNull;
    if (course == null || course.cohortId.isEmpty) {
      setState(() => _error = l.teacherGradesRosterLinkError);
      return;
    }
    setState(() {
      _selectedAssessment = assessment;
      _students = const <TeacherStudent>[];
      _grades = <String, int?>{};
      _initialGrades = <String, int?>{};
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final values = await Future.wait<dynamic>([
        repo.fetchCohortStudents(course.cohortId),
        repo.fetchAssessmentGrades(assessment.id),
      ]);
      final students = values[0] as List<TeacherStudent>;
      final grades = values[1] as List<TeacherAssessmentGrade>;
      final gradeMap = <String, int?>{for (final grade in grades) grade.studentId: grade.grade};
      if (!mounted) return;
      setState(() {
        _students = students;
        _grades = <String, int?>{for (final student in students) student.studentId: gradeMap[student.studentId]};
        _initialGrades = Map<String, int?>.from(_grades);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _saveGrades() async {
    final l = AppLocalizations.of(context)!;
    final assessment = _selectedAssessment;
    if (assessment == null) return;
    final dirty = _grades.entries
        .where((entry) => entry.value != null && entry.value != _initialGrades[entry.key])
        .map((entry) => TeacherGradeDraftRecord(studentId: entry.key, grade: entry.value!))
        .toList(growable: false);
    if (dirty.isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(teacherMobileRepositoryProvider).saveBulkGrades(assessmentId: assessment.id, grades: dirty);
      if (!mounted) return;
      setState(() => _initialGrades = Map<String, int?>.from(_grades));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherGradesSaved)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bundle = _bundle;
    final dirtyCount = _grades.entries.where((entry) => entry.value != null && entry.value != _initialGrades[entry.key]).length;

    final totalCourses = bundle?.courses.length ?? 0;
    final totalStudents = bundle?.courses.map((c) => c.cohortId).where((id) => id.isNotEmpty).toSet().length ?? 0;
    final totalAssessments = bundle?.assessments.length ?? 0;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // ── Hero Banner ──────────────────────────────────────────────────
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            blurSigma: 20,
            gradient: LinearGradient(
              colors: [
                cs.secondaryContainer.withValues(alpha: 0.92),
                cs.primaryContainer.withValues(alpha: 0.68),
                cs.surfaceContainerHigh.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.secondary.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: cs.secondary.withValues(alpha: 0.12), blurRadius: 22, offset: const Offset(0, 8), spreadRadius: -4)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.navTeacherAssessments, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                          const SizedBox(height: 4),
                          Text(l.teacherGradesSubtitle, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: cs.secondary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                      child: Icon(Icons.grade_rounded, size: 24, color: cs.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _GradeStatPill(value: '$totalCourses', label: 'Classes', color: cs.primary),
                    const SizedBox(width: 8),
                    _GradeStatPill(value: '$totalAssessments', label: 'Tests', color: cs.secondary),
                    const SizedBox(width: 8),
                    _GradeStatPill(value: '$totalStudents', label: 'Groups', color: cs.tertiary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_error != null)
            LiquidGlassCard(color: cs.errorContainer.withValues(alpha: 0.72), child: Text(_error!)),
          const SizedBox(height: 4),
          LiquidGlassCard(
            color: cs.surface.withValues(alpha: 0.76),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surface.withValues(alpha: 0.84),
                cs.surfaceContainerHigh.withValues(alpha: 0.66),
              ],
            ),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.teacherGradesCreateAssessmentTitle,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCourseId,
                  decoration: InputDecoration(labelText: l.teacherGradesFieldCourse),
                  items: (bundle?.courses ?? const <TeacherCourse>[])
                      .map((course) => DropdownMenuItem<String>(value: course.id, child: Text(course.name)))
                      .toList(growable: false),
                  onChanged: (value) => setState(() => _selectedCourseId = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(labelText: l.teacherGradesFieldTitle),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? l.teacherGradesFieldDate
                                : MaterialLocalizations.of(context).formatMediumDate(_selectedDate!),
                            style: TextStyle(
                              color: _selectedDate == null ? cs.onSurfaceVariant : cs.onSurface,
                            ),
                          ),
                        ),
                        if (_selectedDate != null)
                          InkWell(
                            onTap: () => setState(() => _selectedDate = null),
                            child: Icon(Icons.close_rounded, size: 16, color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _maxGradeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l.teacherGradesFieldMaxGrade),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : _createAssessment,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l.teacherGradesCreateAction),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loading && bundle == null)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else ...[
            ...(bundle?.courses ?? const <TeacherCourse>[]).map((course) {
              final assessments = (bundle?.assessments ?? const <TeacherAssessment>[]).where((assessment) => assessment.courseId == course.id).toList(growable: false);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LiquidGlassCard(
                  color: cs.surface.withValues(alpha: 0.76),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.surface.withValues(alpha: 0.84),
                      cs.surfaceContainerHigh.withValues(alpha: 0.64),
                    ],
                  ),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      if (course.subject.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(course.subject, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        ),
                      const SizedBox(height: 12),
                      if (assessments.isEmpty)
                        Text(l.teacherNoAssessmentsYet)
                      else
                        ...assessments.map(
                          (assessment) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: LiquidGlassCard(
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(18),
                              blurSigma: 10,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  cs.surface.withValues(alpha: 0.80),
                                  cs.surfaceContainerHighest.withValues(alpha: 0.56),
                                ],
                              ),
                              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.16)),
                              child: ListTile(
                                title: Text(assessment.title),
                                subtitle: Text(assessment.date.split('T').first),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: l.teacherGradesEditAssessmentTitle,
                                      onPressed: _loading ? null : () => _editAssessment(assessment),
                                      icon: const Icon(Icons.edit_rounded),
                                    ),
                                    IconButton(
                                      tooltip: l.teacherGradesDeleteAssessmentTitle,
                                      onPressed: _loading ? null : () => _deleteAssessment(assessment),
                                      icon: const Icon(Icons.delete_outline_rounded),
                                    ),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                                onTap: () => _openAssessment(assessment),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedAssessment != null) ...[
              const SizedBox(height: 8),
              Text(_selectedAssessment!.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (_students.isEmpty)
                LiquidGlassCard(
                  color: cs.surface.withValues(alpha: 0.76),
                  child: Text(l.teacherGradesNoStudentsLoaded),
                )
              else ...[
                ..._students.map(
                  (student) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LiquidGlassCard(
                      color: (_grades[student.studentId] != _initialGrades[student.studentId])
                          ? cs.primaryContainer.withValues(alpha: 0.38)
                          : cs.surface.withValues(alpha: 0.76),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: (_grades[student.studentId] != _initialGrades[student.studentId])
                            ? [
                                cs.primaryContainer.withValues(alpha: 0.64),
                                cs.surface.withValues(alpha: 0.68),
                              ]
                            : [
                                cs.surface.withValues(alpha: 0.84),
                                cs.surfaceContainerHigh.withValues(alpha: 0.62),
                              ],
                      ),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          if (student.email.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(student.email, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                            ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: _grades[student.studentId]?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l.teacherGradesFieldGrade,
                              hintText: _selectedAssessment?.maxGrade == null
                                  ? null
                                  : l.teacherGradesMaxHint(_selectedAssessment!.maxGrade!),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _grades[student.studentId] = int.tryParse(value.trim());
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _saving || dirtyCount == 0 ? null : _saveGrades,
                  icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded),
                  label: Text(
                    _saving
                        ? l.teacherGradesSaving
                        : l.teacherGradesSaveCount(dirtyCount),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _GradeStatPill extends StatelessWidget {
  const _GradeStatPill({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color, height: 1.1)),
            Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}