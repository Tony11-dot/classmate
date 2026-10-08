// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_press.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

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
  bool _published = false; // are this exam's grades visible to students?
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

      // The backend already resolves EVERY targeted student for this exam (under
      // `students`); use that so a student not in the teacher's own list is still
      // shown and gradeable. Fall back to the local target filter only if empty.
      final gradeList =
          (gradeData['students'] as List?) ?? (gradeData['grades'] as List?) ?? [];
      final byId = {for (final s in allStudents) s.studentId: s};
      final saved = <String, int?>{};
      List<TeacherStudentWithLevel> targeted = [];
      for (final g in gradeList) {
        if (g is! Map) continue;
        final sid = (g['studentId'] ?? '').toString();
        if (sid.isEmpty) continue;
        final val = g['grade'];
        saved[sid] = val is int ? val : int.tryParse('${val ?? ''}');
        targeted.add(byId[sid] ??
            TeacherStudentWithLevel(
              studentId: sid,
              name: (g['name'] ?? '').toString(),
              email: '',
              gradeLevel: null,
              cohortId: '',
              cohortName: '',
              subjects: const [],
              coursesBySubject: const {},
            ));
      }
      if (targeted.isEmpty) {
        if (targetType == 'STUDENTS' && studentIds.isNotEmpty) {
          targeted = allStudents.where((s) => studentIds.contains(s.studentId)).toList();
        } else if (targetType == 'COHORT' && cohortIds.isNotEmpty) {
          targeted = allStudents.where((s) => cohortIds.contains(s.cohortId)).toList();
        } else {
          targeted = allStudents;
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
        _published = gradeData['published'] == true;
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

  /// [publish] null = save grades as a draft (no publish-state change; a new
  /// exam's grades stay hidden from students). true = save + publish (make the
  /// grades visible to students).
  Future<void> _save({bool? publish}) async {
    final l = AppLocalizations.of(context)!;
    final dirtyGrades = <TeacherGradeDraftRecord>[];
    for (final s in _students) {
      final text = _ctrls[s.studentId]?.text.trim() ?? '';
      final val = int.tryParse(text);
      if (val != null && val != _savedGrades[s.studentId]) {
        dirtyGrades.add(TeacherGradeDraftRecord(studentId: s.studentId, grade: val));
      }
    }
    // Nothing to do only when there are no edits AND we're not publishing.
    if (dirtyGrades.isEmpty && publish != true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherGradesNothingToSave)));
      return;
    }

    setState(() => _saving = true);
    try {
      final res = await ref.read(teacherMobileRepositoryProvider).saveExamGrades(
            examId: widget.exam['id'] as String? ?? '',
            grades: dirtyGrades,
            published: publish,
          );
      if (!mounted) return;
      final saved = (res['saved'] is num) ? (res['saved'] as num).toInt() : dirtyGrades.length;
      final dropped = (res['dropped'] is List) ? (res['dropped'] as List).length : 0;
      // Re-fetch from server so the UI reflects what was actually persisted,
      // not what we hoped would persist.
      await _load();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (dropped > 0 || saved < dirtyGrades.length) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.teacherGradesSavedOf(saved, dirtyGrades.length) +
                (dropped > 0 ? ' ${AppLocalizations.of(context)!.teacherGradesSkippedSuffix(dropped)}' : '')),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      } else {
        messenger.showSnackBar(SnackBar(content: Text(publish == true ? l.examGradesPublished : l.teacherGradesSaved)));
      }
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

  /// Mean of the grades currently entered for this exam (null if none).
  double? get _classAverage {
    final vals = <int>[];
    for (final s in _students) {
      final v = int.tryParse(_ctrls[s.studentId]?.text.trim() ?? '');
      if (v != null) vals.add(v);
    }
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  List<Widget> _buildAttachmentPills(Map<String, dynamic> exam) {
    final raw = exam['attachments'];
    if (raw is! List || raw.isEmpty) return const [];
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final pills = raw.whereType<Map>().map((a) {
      final title = (a['title'] ?? a['name'] ?? 'File').toString();
      final url = (a['url'] ?? '').toString();
      return CmPress(
        onTap: url.isNotEmpty
            ? () async {
                final uri = Uri.tryParse(url);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: cs.brightness == Brightness.dark ? 0.18 : 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file_rounded, size: 15, color: cs.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new_rounded, size: 13, color: cs.primary),
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
    final tk = CmTokens.of(context);

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
          tooltip: l.a11yBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            if (subject.isNotEmpty || date != null)
              Text(
                [subject, if (date != null) FriendlyDate.date(date)]
                    .where((s) => s.isNotEmpty)
                    .join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: OutlinedButton.icon(
              onPressed: (_saving || _loading) ? null : () => _save(),
              icon: _saving
                  ? const CmLoading(size: 16)
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(l.certSaveDraft),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CmLoading())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CmEmptyState(
                        icon: Icons.error_outline_rounded,
                        title: l.commonError,
                        message: _error,
                      ),
                      FilledButton(onPressed: _load, child: Text(l.teacherRetry)),
                    ],
                  ),
                )
              : CmRefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      // Summary banner
                      CmCard(
                        tint: cs.primary,
                        radius: CmTokens.radiusXl,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
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
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          CmPill(
                                            icon: Icons.done_all_rounded,
                                            label: '$gradedCount ${l.teacherExamGradesGraded}',
                                            color: cs.primary,
                                          ),
                                          if (maxGrade != null)
                                            CmPill(icon: Icons.grade_rounded, label: '/ $maxGrade'),
                                          if (_published)
                                            CmPill(
                                              icon: Icons.check_circle_rounded,
                                              label: l.examGradesPublishedShort,
                                              color: tk.good,
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
                            if (_students.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: gradedCount / _students.length,
                                  minHeight: 8,
                                  backgroundColor: cs.outlineVariant.withValues(alpha: 0.35),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    gradedCount >= _students.length ? tk.good : cs.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Attachments
                      ..._buildAttachmentPills(exam),

                      if (_students.isEmpty)
                        CmEmptyState(
                          icon: Icons.people_outline_rounded,
                          title: l.teacherExamGradesNoStudents,
                        )
                      else ...[
                        CmSectionHeader(
                          label: l.teacherExamGradesEnterGrades,
                          icon: Icons.edit_note_rounded,
                        ),
                        ..._students.map((s) {
                          final ctrl = _ctrls[s.studentId]!;
                          final saved = _savedGrades[s.studentId];
                          final currentText = ctrl.text.trim();
                          final currentVal = int.tryParse(currentText);
                          final isDirty = currentVal != null && currentVal != saved;
                          final isGraded = saved != null;
                          final dark = cs.brightness == Brightness.dark;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AnimatedContainer(
                              duration: CmTokens.fast,
                              curve: CmTokens.easeOut,
                              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                              decoration: BoxDecoration(
                                color: isDirty
                                    ? Color.alphaBlend(
                                        cs.primary.withValues(alpha: dark ? 0.16 : 0.07),
                                        cs.surfaceContainerLow,
                                      )
                                    : cs.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(CmTokens.radiusLg),
                                border: Border.all(
                                  color: isDirty
                                      ? cs.primary.withValues(alpha: 0.7)
                                      : cs.outlineVariant.withValues(alpha: 0.35),
                                  width: isDirty ? 1.4 : 0.8,
                                ),
                                boxShadow: tk.shadowSm,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isGraded
                                        ? tk.good.withValues(alpha: dark ? 0.24 : 0.14)
                                        : cs.surfaceContainerHigh,
                                    child: isGraded
                                        ? Icon(Icons.check_rounded, size: 20, color: tk.good)
                                        : Text(
                                            s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: cs.onSurfaceVariant,
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
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
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
                                        fontWeight: FontWeight.w900,
                                        fontFeatures: const [FontFeature.tabularFigures()],
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
                                          borderRadius: BorderRadius.circular(CmTokens.radiusSm),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        // Class average for this exam (mean of entered grades).
                        Builder(builder: (_) {
                          final avg = _classAverage;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 12),
                            child: CmCard(
                              tint: cs.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  CmIconTile(icon: Icons.bar_chart_rounded, size: 38, color: cs.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l.teacherExamClassAverage,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Text(
                                    avg == null ? '—' : (avg == avg.roundToDouble() ? avg.toInt().toString() : avg.toStringAsFixed(1)),
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: cs.primary,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: (_saving || !_hasDirty) ? null : () => _save(),
                                icon: const Icon(Icons.save_outlined, size: 18),
                                label: Text(l.certSaveDraft),
                                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _saving ? null : () => _save(publish: true),
                                icon: _saving
                                    ? const CmLoading(size: 18)
                                    : const Icon(Icons.publish_rounded),
                                label: Text(_published ? l.examRepublish : l.certSaveAndPublish),
                                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
