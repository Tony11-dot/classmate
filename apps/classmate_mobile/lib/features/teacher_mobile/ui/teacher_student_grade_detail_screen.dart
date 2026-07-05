// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/util/friendly_date.dart';
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
    this.gradeTime,
  }) : controller = TextEditingController(
          text: grade?.toString() ?? '',
        ),
       initialGrade = grade;

  final TeacherAssessment assessment;
  final String subject;
  final TextEditingController controller;
  int? grade;
  int? initialGrade;
  /// Real moment the grade was recorded (with time), when graded.
  final String? gradeTime;

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
    this.subject,
  });

  final TeacherStudentWithLevel student;

  /// When set, only this subject's grades are shown (opened from a subject).
  /// Null = every subject the student is enrolled in.
  final String? subject;

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
      // ONE atomic call (all assessments + their grades) — no per-assessment
      // fetch loop, so a transient failure can't silently drop entries.
      final full = await repo.fetchGradesFull();

      final entries = <_GradeEntry>[];
      for (final r in full) {
        final match = r.grades.where((g) => g.studentId == widget.student.studentId).firstOrNull;
        final subject = r.assessment.subject.isNotEmpty ? r.assessment.subject : r.assessment.title;
        // When opened from a subject, show ONLY that subject's grades.
        if (widget.subject != null && widget.subject!.isNotEmpty && subject != widget.subject) {
          continue;
        }
        // Otherwise only show assessments for subjects this student is enrolled in.
        if (widget.student.subjects.isNotEmpty && !widget.student.subjects.contains(subject)) {
          continue;
        }
        entries.add(
          _GradeEntry(
            assessment: r.assessment,
            subject: subject,
            grade: match?.grade,
            gradeTime: match?.updatedAt,
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

  Future<void> _deleteGrade(_GradeEntry entry) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.gradeDeleteTitle),
        content: Text(l.gradeDeleteConfirm(entry.assessment.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.averagesDelete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).deleteGrade(
            assessmentId: entry.assessment.id,
            studentId: widget.student.studentId,
          );
      if (mounted) await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
              padding: const EdgeInsetsDirectional.only(end: 12),
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
                                            child: _GradeRow(
                                              entry: re.value,
                                              onChanged: () => setState(() {}),
                                              onDelete: () => _deleteGrade(re.value),
                                            ),
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
  const _GradeRow({required this.entry, required this.onChanged, this.onDelete});

  final _GradeEntry entry;
  final VoidCallback onChanged;
  final VoidCallback? onDelete;

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
                // Graded → the real moment the grade was recorded (with time);
                // ungraded → the assessment's date (date-only, no real time).
                if (entry.gradeTime != null || entry.assessment.date.isNotEmpty)
                  Text(
                    entry.gradeTime != null
                        ? FriendlyDate.dateTime(entry.gradeTime)
                        : FriendlyDate.date(entry.assessment.date),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 108,
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
                // In-field X clears just the number (does NOT delete the grade).
                suffixIcon: entry.controller.text.trim().isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 16, color: cs.onSurfaceVariant),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints:
                            const BoxConstraints(minWidth: 26, minHeight: 26),
                        tooltip: MaterialLocalizations.of(context)
                            .deleteButtonTooltip,
                        onPressed: () {
                          entry.controller.clear();
                          onChanged();
                        },
                      ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 26, minHeight: 26),
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
          if (onDelete != null && entry.grade != null)
            IconButton(
              tooltip: AppLocalizations.of(context)!.gradeDeleteTooltip,
              icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 20),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
