// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';

class TeacherExamGradesScreen extends ConsumerStatefulWidget {
  const TeacherExamGradesScreen({super.key, required this.exam});
  final Map<String, dynamic> exam;

  @override
  ConsumerState<TeacherExamGradesScreen> createState() => _TeacherExamGradesScreenState();
}

class _TeacherExamGradesScreenState extends ConsumerState<TeacherExamGradesScreen> {
  List<TeacherStudentWithLevel> _students = [];
  final Map<String, TextEditingController> _ctrls = {};
  Map<String, int?> _savedGrades = {};
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
    for (final c in _ctrls.values) {
      c.dispose();
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
      final exam = widget.exam;
      final targetType = exam['targetType'] as String? ?? 'EVERYONE';
      final cohortIds = (exam['targetCohortIds'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final studentIds = (exam['targetStudentIds'] as List?)?.map((e) => e.toString()).toList() ?? [];

      final results = await Future.wait<dynamic>([
        repo.fetchAllStudents(),
        repo.fetchExamGrades(exam['id'] as String? ?? ''),
      ]);

      final allStudents = results[0] as List<TeacherStudentWithLevel>;
      final gradeData = results[1] as Map<String, dynamic>;

      // Resolve targeted students
      List<TeacherStudentWithLevel> targeted;
      if (targetType == 'STUDENTS' && studentIds.isNotEmpty) {
        targeted = allStudents.where((s) => studentIds.contains(s.studentId)).toList();
      } else if (targetType == 'COHORT' && cohortIds.isNotEmpty) {
        targeted = allStudents.where((s) => cohortIds.contains(s.cohortId)).toList();
      } else {
        targeted = allStudents;
      }

      // Build grade map from existing grades
      final gradeList = gradeData['grades'] as List? ?? [];
      final saved = <String, int?>{};
      for (final g in gradeList) {
        if (g is Map) {
          final sid = (g['studentId'] ?? '').toString();
          final val = g['grade'];
          if (sid.isNotEmpty) saved[sid] = val is int ? val : int.tryParse(val.toString());
        }
      }

      // Dispose old controllers
      for (final c in _ctrls.values) {
        c.dispose();
      }
      _ctrls.clear();

      for (final s in targeted) {
        _ctrls[s.studentId] = TextEditingController(
          text: saved[s.studentId]?.toString() ?? '',
        );
      }

      if (!mounted) return;
      setState(() {
        _students = targeted;
        _savedGrades = Map.from(saved);
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
    final l = AppLocalizations.of(context)!;
    final dirtyGrades = <TeacherGradeDraftRecord>[];
    for (final s in _students) {
      final text = _ctrls[s.studentId]?.text.trim() ?? '';
      final val = int.tryParse(text);
      if (val != null && val != _savedGrades[s.studentId]) {
        dirtyGrades.add(TeacherGradeDraftRecord(studentId: s.studentId, grade: val));
      }
    }
    if (dirtyGrades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherGradesNothingToSave)));
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(teacherMobileRepositoryProvider).saveExamGrades(
            examId: widget.exam['id'] as String? ?? '',
            grades: dirtyGrades,
          );
      if (!mounted) return;
      // Update saved state
      for (final g in dirtyGrades) {
        _savedGrades[g.studentId] = g.grade;
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherGradesSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _hasDirty {
    for (final s in _students) {
      final text = _ctrls[s.studentId]?.text.trim() ?? '';
      final val = int.tryParse(text);
      if (val != null && val != _savedGrades[s.studentId]) return true;
    }
    return false;
  }

  List<Widget> _buildAttachmentPills(Map<String, dynamic> exam) {
    final raw = exam['attachments'];
    if (raw is! List || raw.isEmpty) return const [];
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final pills = raw.whereType<Map>().map((a) {
      final title = (a['title'] ?? a['name'] ?? 'File').toString();
      final url = (a['url'] ?? '').toString();
      return GestureDetector(
        onTap: url.isNotEmpty
            ? () async {
                final uri = Uri.tryParse(url);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file_rounded, size: 14, color: cs.onPrimaryContainer),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(growable: false);

    if (pills.isEmpty) return const [];
    return [
      Wrap(spacing: 8, runSpacing: 6, children: pills),
      const SizedBox(height: 14),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    final exam = widget.exam;
    final title = exam['title'] as String? ?? 'Exam';
    final subject = exam['subject'] as String? ?? '';
    final maxGrade = exam['maxGrade'] as int?;
    final dateRaw = exam['date'] as String? ?? '';
    final date = dateRaw.isNotEmpty ? DateTime.tryParse(dateRaw) : null;
    final gradedCount = _savedGrades.values.where((g) => g != null).length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            if (subject.isNotEmpty || date != null)
              Text(
                [subject, if (date != null) DateFormat.yMMMd(locale).format(date)]
                    .where((s) => s.isNotEmpty)
                    .join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: (_saving || _loading) ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(l.teacherGradesSaveAction),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: const CmLoading())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _load, child: Text(l.teacherRetry)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      // Summary banner
                      LiquidGlassCard(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: cs.outlineVariant),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_students.length} ${l.teacherExamGradesStudents}',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$gradedCount ${l.teacherExamGradesGraded}${maxGrade != null ? ' · Max $maxGrade' : ''}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.quiz_rounded, size: 24, color: cs.onPrimary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Attachments
                      ..._buildAttachmentPills(exam),

                      if (_students.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.people_outline_rounded, size: 48, color: cs.onSurfaceVariant),
                                const SizedBox(height: 16),
                                Text(
                                  l.teacherExamGradesNoStudents,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          l.teacherExamGradesEnterGrades,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._students.map((s) {
                          final ctrl = _ctrls[s.studentId]!;
                          final saved = _savedGrades[s.studentId];
                          final currentText = ctrl.text.trim();
                          final currentVal = int.tryParse(currentText);
                          final isDirty = currentVal != null && currentVal != saved;
                          final isGraded = saved != null;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: LiquidGlassCard(
                              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                              borderRadius: BorderRadius.circular(18),
                              color: isDirty
                                  ? cs.primaryContainer
                                  : cs.surface,
                              border: Border.all(
                                color: isDirty
                                    ? cs.primary
                                    : cs.outlineVariant,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isGraded
                                        ? cs.primaryContainer
                                        : cs.surfaceContainerHigh,
                                    child: Text(
                                      s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: isGraded ? cs.onPrimaryContainer : cs.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.name,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        if (s.cohortName.isNotEmpty)
                                          Text(
                                            s.cohortName,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: maxGrade != null ? 96 : 80,
                                    child: TextField(
                                      controller: ctrl,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onChanged: (_) => setState(() {}),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: maxGrade != null ? '/ $maxGrade' : '—',
                                        hintStyle: TextStyle(
                                          color: cs.onSurfaceVariant,
                                          fontSize: 14,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 12,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: (_saving || !_hasDirty) ? null : _save,
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(_saving ? l.teacherGradesSaving : l.teacherGradesSaveAction),
                          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
