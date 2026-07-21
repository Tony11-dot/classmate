// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../../../ui/widgets/semester_select_field.dart';
import '../data/subject_average.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

/// Teacher screen to manage first-class "subject averages" — weighted grade
/// formulas per (cohort, subject). Each average has one or more formats, and
/// each format is a set of {assessment, weight%} components summing to 100.
/// Reached from the grades subject view (pushed via rootNavigator), so it
/// carries its own AppBar with a back button.
class TeacherAveragesScreen extends ConsumerStatefulWidget {
  const TeacherAveragesScreen({super.key, this.initialCohortId, this.initialSubject});

  final String? initialCohortId;
  final String? initialSubject;

  @override
  ConsumerState<TeacherAveragesScreen> createState() => _TeacherAveragesScreenState();
}

class _TeacherAveragesScreenState extends ConsumerState<TeacherAveragesScreen> {
  bool _loading = true;
  String? _error;

  List<SubjectAverage> _averages = [];
  List<TeacherAssessment> _assessments = [];
  List<Map<String, dynamic>> _cohorts = [];
  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait([
        repo.fetchAssessments(),
        repo.fetchCohortsForPicker(),
        repo.fetchSubjects(),
        repo.listAverages(subject: widget.initialSubject),
      ]);
      if (!mounted) return;
      final bundle = results[0] as TeacherAssessmentBundle;
      setState(() {
        _assessments = bundle.assessments;
        _cohorts = results[1] as List<Map<String, dynamic>>;
        _subjects = results[2] as List<String>;
        _averages = results[3] as List<SubjectAverage>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _reloadAverages() async {
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final list = await repo.listAverages(subject: widget.initialSubject);
      if (!mounted) return;
      setState(() => _averages = list);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  String _cohortName(String cohortId) {
    for (final c in _cohorts) {
      if ('${c['id']}' == cohortId) return '${c['name'] ?? ''}';
    }
    return '';
  }

  Future<void> _openEditor({SubjectAverage? existing}) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _AverageEditorSheet(
        existing: existing,
        assessments: _assessments,
        cohorts: _cohorts,
        subjects: _subjects,
        initialCohortId: widget.initialCohortId,
        initialSubject: widget.initialSubject,
      ),
    );
    if (changed == true) _reloadAverages();
  }

  Future<void> _delete(SubjectAverage a) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(l.averagesDeleteTitle),
        content: Text(l.averagesDeleteConfirm(a.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(l.averagesCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(dCtx).colorScheme.error),
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text(l.averagesDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).deleteAverage(a.id);
      _reloadAverages();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _openPreview(SubjectAverage a) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComputePreviewSheet(averageId: a.id, title: a.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.a11yBack,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l.averagesTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.averagesAdd),
      ),
      body: _loading
          ? const Center(child: CmLoading())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
              : CmRefreshIndicator(
                  onRefresh: _reloadAverages,
                  child: _averages.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 80),
                          Icon(Icons.functions_rounded, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(l.averagesEmptyTitle,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              l.averagesEmptyBody,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          itemCount: _averages.length,
                          itemBuilder: (_, i) => _averageCard(_averages[i]),
                        ),
                ),
    );
  }

  Widget _averageCard(SubjectAverage a) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final cohortName = _cohortName(a.cohortId);
    final semLabel = a.semester == null ? l.averagesFullYear : l.averagesSemesterN(a.semester!);
    final subtitle = [a.subject, if (cohortName.isNotEmpty) cohortName, semLabel].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openPreview(a),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(a.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    tooltip: l.a11yEdit,
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    onPressed: () => _openEditor(existing: a),
                  ),
                  IconButton(
                    tooltip: l.a11yDelete,
                    icon: Icon(Icons.delete_outline_rounded, size: 20, color: cs.error),
                    onPressed: () => _delete(a),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (int i = 0; i < a.variants.length; i++)
                    _formatChip(i + 1, a.variants[i].total),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formatChip(int index, int total) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final ok = total == 100;
    final color = ok ? Colors.green : cs.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        AppLocalizations.of(context)!.averagesFormatChip(index, total),
        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

/// Bottom-sheet listing each student's computed average for one formula.
class _ComputePreviewSheet extends ConsumerStatefulWidget {
  const _ComputePreviewSheet({required this.averageId, required this.title});
  final String averageId;
  final String title;

  @override
  ConsumerState<_ComputePreviewSheet> createState() => _ComputePreviewSheetState();
}

class _ComputePreviewSheetState extends ConsumerState<_ComputePreviewSheet> {
  bool _loading = true;
  String? _error;
  List<ComputedStudentAverage> _rows = [];

  @override
  void initState() {
    super.initState();
    _compute();
  }

  Future<void> _compute() async {
    try {
      final rows = await ref.read(teacherMobileRepositoryProvider).computeAverage(widget.averageId);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Flexible(
            child: _loading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CmLoading()))
                : _error != null
                    ? Padding(padding: const EdgeInsets.all(24), child: Text(_error!))
                    : _rows.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(l.averagesNoStudents,
                                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                            itemCount: _rows.length,
                            separatorBuilder: (_, _) => Divider(height: 1, color: cs.outlineVariant),
                            itemBuilder: (_, i) {
                              final r = _rows[i];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(r.name),
                                subtitle: r.formatUsed != null
                                    ? Text(l.averagesFormatN(r.formatUsed! + 1),
                                        style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant))
                                    : null,
                                trailing: Text(
                                  r.value == null ? '—' : r.value!.toStringAsFixed(1),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: r.value == null ? cs.onSurfaceVariant : cs.onSurface,
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Editor ─────────────────────────────────────────────────────────────────

class _ComponentDraft {
  _ComponentDraft({this.assessmentId, String weight = ''})
      : weightCtrl = TextEditingController(text: weight);
  String? assessmentId;
  final TextEditingController weightCtrl;
  void dispose() => weightCtrl.dispose();
}

class _FormatDraft {
  _FormatDraft({String label = '', List<_ComponentDraft>? components})
      : labelCtrl = TextEditingController(text: label),
        components = components ?? [_ComponentDraft()];
  final TextEditingController labelCtrl;
  final List<_ComponentDraft> components;
  void dispose() {
    labelCtrl.dispose();
    for (final c in components) {
      c.dispose();
    }
  }
}

class _AverageEditorSheet extends ConsumerStatefulWidget {
  const _AverageEditorSheet({
    this.existing,
    required this.assessments,
    required this.cohorts,
    required this.subjects,
    this.initialCohortId,
    this.initialSubject,
  });

  final SubjectAverage? existing;
  final List<TeacherAssessment> assessments;
  final List<Map<String, dynamic>> cohorts;
  final List<String> subjects;
  final String? initialCohortId;
  final String? initialSubject;

  @override
  ConsumerState<_AverageEditorSheet> createState() => _AverageEditorSheetState();
}

class _AverageEditorSheetState extends ConsumerState<_AverageEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _unitsCtrl;
  String? _subject;
  String? _cohortId;
  int? _semester;
  final List<_FormatDraft> _formats = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _unitsCtrl = TextEditingController(text: (e != null && e.units > 0) ? '${e.units}' : '');
    _subject = e?.subject ?? widget.initialSubject;
    _cohortId = e?.cohortId ?? widget.initialCohortId;
    _semester = e?.semester;
    if (e != null) {
      for (final v in e.variants) {
        _formats.add(_FormatDraft(
          label: v.label ?? '',
          components: v.components
              .map((c) => _ComponentDraft(assessmentId: c.assessmentId, weight: '${c.weight}'))
              .toList(),
        ));
      }
    }
    if (_formats.isEmpty) _formats.add(_FormatDraft());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _unitsCtrl.dispose();
    for (final f in _formats) {
      f.dispose();
    }
    super.dispose();
  }

  List<TeacherAssessment> get _pickableAssessments {
    final subject = _subject;
    final cohortId = _cohortId;
    if (subject == null || cohortId == null) return const [];
    return widget.assessments
        .where((a) => a.subject == subject && a.cohortId == cohortId)
        .toList(growable: false);
  }

  int _formatTotal(_FormatDraft f) =>
      f.components.fold(0, (s, c) => s + (int.tryParse(c.weightCtrl.text.trim()) ?? 0));

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    final subject = _subject;
    final cohortId = _cohortId;

    if (title.isEmpty) {
      _snack(l.averagesErrTitle);
      return;
    }
    if (subject == null || subject.isEmpty) {
      _snack(l.averagesErrSubject);
      return;
    }
    if (cohortId == null || cohortId.isEmpty) {
      _snack(l.averagesErrCohort);
      return;
    }
    if (_formats.isEmpty) {
      _snack(l.averagesErrNoFormat);
      return;
    }

    final variants = <AverageFormat>[];
    for (int i = 0; i < _formats.length; i++) {
      final f = _formats[i];
      final components = <AverageComponent>[];
      for (final c in f.components) {
        final aid = c.assessmentId;
        if (aid == null || aid.isEmpty) continue;
        final weight = int.tryParse(c.weightCtrl.text.trim()) ?? 0;
        components.add(AverageComponent(assessmentId: aid, weight: weight));
      }
      if (components.isEmpty) {
        _snack(l.averagesErrFormatNoGrade(i + 1));
        return;
      }
      final total = components.fold(0, (s, c) => s + c.weight);
      if (total != 100) {
        _snack(l.averagesErrFormatSum(i + 1, total));
        return;
      }
      final label = f.labelCtrl.text.trim();
      variants.add(AverageFormat(
        label: label.isEmpty ? null : label,
        sortOrder: i,
        components: components,
      ));
    }

    final units = int.tryParse(_unitsCtrl.text.trim());

    setState(() => _saving = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      if (widget.existing == null) {
        await repo.createAverage(
          cohortId: cohortId,
          subject: subject,
          title: title,
          units: units,
          semester: _semester,
          variants: variants,
        );
      } else {
        await repo.updateAverage(
          widget.existing!.id,
          title: title,
          subject: subject,
          units: units,
          semester: _semester,
          variants: variants,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('$e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final semCount = schoolSemesterCount(ref.read(authSessionProvider).schoolSemesters);
    final pickable = _pickableAssessments;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.existing == null ? l.averagesNew : l.averagesEdit,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: l.averagesFieldTitle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LiquidGlassSelectField<String>(
                    label: l.averagesLabelSubject,
                    hint: l.averagesHintSubject,
                    value: _subject,
                    items: [
                      for (final s in widget.subjects) LiquidGlassDropdownItem(value: s, label: s),
                    ],
                    onChanged: (v) => setState(() {
                      _subject = v;
                      // Chosen assessments may no longer match — clear stale picks.
                      _clearInvalidComponents();
                    }),
                  ),
                  const SizedBox(height: 12),
                  LiquidGlassSelectField<String>(
                    label: l.averagesLabelCohort,
                    hint: l.averagesHintCohort,
                    value: _cohortId,
                    items: [
                      for (final c in widget.cohorts)
                        LiquidGlassDropdownItem(value: '${c['id']}', label: '${c['name'] ?? ''}'),
                    ],
                    onChanged: (v) => setState(() {
                      _cohortId = v;
                      _clearInvalidComponents();
                    }),
                  ),
                  const SizedBox(height: 12),
                  SemesterSelectField(
                    count: semCount,
                    value: _semester,
                    onChanged: (v) => setState(() => _semester = v),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      controller: _unitsCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l.averagesLabelUnits,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(l.averagesFormats,
                      style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    l.averagesFormatsHelp,
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _formats.length; i++) _formatEditor(i, pickable),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _formats.add(_FormatDraft())),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l.averagesAddFormat),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const CmLoading(size: 20)
                        : Text(l.averagesSave),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Drop any component whose chosen assessment is no longer valid for the
  /// current subject + cohort (e.g. after switching either).
  void _clearInvalidComponents() {
    final valid = _pickableAssessments.map((a) => a.id).toSet();
    for (final f in _formats) {
      for (final c in f.components) {
        if (c.assessmentId != null && !valid.contains(c.assessmentId)) {
          c.assessmentId = null;
        }
      }
    }
  }

  Widget _formatEditor(int index, List<TeacherAssessment> pickable) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final f = _formats[index];
    final total = _formatTotal(f);
    final ok = total == 100;
    final totalColor = ok ? Colors.green : cs.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l.averagesFormatN(index + 1),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                ),
                if (_formats.length > 1)
                  IconButton(
                    tooltip: l.a11yRemove,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close_rounded, size: 20, color: cs.error),
                    onPressed: () => setState(() => _formats.removeAt(index).dispose()),
                  ),
              ],
            ),
            TextField(
              controller: f.labelCtrl,
              decoration: InputDecoration(
                labelText: l.averagesLabelFormatLabel,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            for (int j = 0; j < f.components.length; j++) _componentRow(f, j, pickable),
            const SizedBox(height: 4),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => f.components.add(_ComponentDraft())),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l.averagesAddGrade),
                ),
                const Spacer(),
                Text(
                  l.averagesTotal(total),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: totalColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _componentRow(_FormatDraft f, int j, List<TeacherAssessment> pickable) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final c = f.components[j];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: LiquidGlassSelectField<String>(
              label: l.averagesLabelGrade,
              hint: pickable.isEmpty ? l.averagesHintPickFirst : l.averagesHintGrade,
              value: c.assessmentId,
              items: [
                for (final a in pickable) LiquidGlassDropdownItem(value: a.id, label: a.title),
              ],
              onChanged: (v) => setState(() => c.assessmentId = v),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 78,
            child: TextField(
              controller: c.weightCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                isDense: true,
                suffixText: '%',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          IconButton(
            tooltip: l.a11yRemove,
            icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error),
            onPressed: f.components.length <= 1
                ? null
                : () => setState(() => f.components.removeAt(j).dispose()),
          ),
        ],
      ),
    );
  }
}
