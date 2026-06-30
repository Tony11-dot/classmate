// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/semester/school_semester.dart';
import '../../l10n/app_localizations.dart';
import 'data/averages_repository.dart';

class AveragesEditScreen extends ConsumerStatefulWidget {
  const AveragesEditScreen({
    super.key,
    required this.cohort,
    required this.subject,
    this.existing,
  });

  final AvgCohort cohort;
  final AvgSubject subject;
  final AvgFormula? existing;

  @override
  ConsumerState<AveragesEditScreen> createState() => _AveragesEditScreenState();
}

class _AveragesEditScreenState extends ConsumerState<AveragesEditScreen> {
  final _titleCtrl = TextEditingController();
  final _unitsCtrl = TextEditingController(text: '0');

  List<AvgVariant> _variants = [AvgVariant(components: [AvgComponent(assessmentId: '', weight: 0)])];
  List<AvgAssessment> _assessments = [];
  int _semester = 1;
  int _semesterCount = 1;

  bool _loadingGrades = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final sems = parseSchoolSemesters(ref.read(authSessionProvider).schoolSemesters);
    _semesterCount = sems.isEmpty ? 1 : sems.length;
    _semester = currentSemesterWindow(sems, DateTime.now())?.number ?? 1;

    final ex = widget.existing;
    if (ex != null) {
      _titleCtrl.text = ex.title;
      _unitsCtrl.text = '${ex.units}';
      _variants = ex.variants
          .map((v) => AvgVariant(
                label: v.label,
                components: v.components.map((c) => AvgComponent(assessmentId: c.assessmentId, weight: c.weight)).toList(),
              ))
          .toList();
      if (_variants.isEmpty) {
        _variants = [AvgVariant(components: [AvgComponent(assessmentId: '', weight: 0)])];
      }
    }
    Future<void>.microtask(_loadGrades);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _unitsCtrl.dispose();
    super.dispose();
  }

  AveragesRepository get _repo => ref.read(averagesRepositoryProvider);

  Future<void> _loadGrades() async {
    setState(() => _loadingGrades = true);
    try {
      final g = await _repo.grades(
        widget.cohort.id,
        widget.subject.value,
        semester: _semesterCount > 1 ? _semester : null,
      );
      setState(() {
        _assessments = g;
        _loadingGrades = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loadingGrades = false;
      });
    }
  }

  int _sumOf(AvgVariant v) => v.components.fold(0, (a, c) => a + c.weight);

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = l.averagesTitleRequired);
      return;
    }
    for (final v in _variants) {
      if (v.components.isEmpty || v.components.any((c) => c.assessmentId.isEmpty)) {
        setState(() => _error = l.averagesPickGradeForEachRow);
        return;
      }
      if (_sumOf(v) != 100) {
        setState(() => _error = l.averagesWeightMustBe100);
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final units = int.tryParse(_unitsCtrl.text.trim()) ?? 0;
      if (widget.existing == null) {
        await _repo.create(
          title: title,
          cohortId: widget.cohort.id,
          subject: widget.subject.value,
          units: units,
          variants: _variants,
        );
      } else {
        await _repo.update(widget.existing!.id, title: title, units: units, variants: _variants);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = '$e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isNew = widget.existing == null;

    return Scaffold(
      appBar: AppBar(title: Text(isNew ? l.averagesAddTitle : l.averagesEditTitle)),
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: TextStyle(color: cs.error)),
              ),
            // Context (class + subject — fixed for this formula)
            Card(
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.groups_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${widget.cohort.name} · ${widget.subject.display}')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l.averagesFieldTitle,
                hintText: l.averagesFieldTitleHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            // Semester selector — scopes which grades are offered.
            if (_semesterCount > 1)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _semester,
                      decoration: InputDecoration(
                        labelText: l.averagesSemester,
                        border: const OutlineInputBorder(),
                      ),
                      items: List.generate(_semesterCount, (i) => i + 1)
                          .map((n) => DropdownMenuItem(value: n, child: Text(l.adminSchoolSemesterN('$n'))))
                          .toList(),
                      onChanged: (n) {
                        if (n == null) return;
                        setState(() => _semester = n);
                        _loadGrades();
                      },
                    ),
                  ),
                ],
              ),
            if (_semesterCount > 1) const SizedBox(height: 14),
            // Units
            TextField(
              controller: _unitsCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l.averagesUnits,
                helperText: l.averagesUnitsHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Best-format helper note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.averagesBestFormatNote, style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_loadingGrades)
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator())
            else if (_assessments.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(l.averagesNoGrades, style: TextStyle(color: cs.error)),
              ),
            // Variants (formats)
            for (int i = 0; i < _variants.length; i++) _buildVariant(l, cs, i),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _variants.add(
                    AvgVariant(components: [AvgComponent(assessmentId: '', weight: 0)]),
                  )),
              icon: const Icon(Icons.add),
              label: Text(l.averagesAddFormat),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.averagesSave),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildVariant(AppLocalizations l, ColorScheme cs, int vi) {
    final v = _variants[vi];
    final sum = _sumOf(v);
    final ok = sum == 100;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${l.averagesFormat} ${vi + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_variants.length > 1)
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: cs.error),
                    onPressed: () => setState(() => _variants.removeAt(vi)),
                  ),
              ],
            ),
            for (int ci = 0; ci < v.components.length; ci++) _buildComponentRow(l, cs, vi, ci),
            const SizedBox(height: 4),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => v.components.add(AvgComponent(assessmentId: '', weight: 0))),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l.averagesAddGrade),
                ),
                const Spacer(),
                Text(
                  l.averagesWeightSum('$sum'),
                  style: TextStyle(
                    color: ok ? Colors.green : cs.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentRow(AppLocalizations l, ColorScheme cs, int vi, int ci) {
    final c = _variants[vi].components[ci];
    // Guard: the saved assessmentId might not be in the current (semester-filtered) list.
    final hasValue = _assessments.any((a) => a.id == c.assessmentId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: DropdownButtonFormField<String>(
              initialValue: hasValue ? c.assessmentId : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.averagesGrade,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: _assessments
                  .map((a) => DropdownMenuItem(value: a.id, child: Text(a.title, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (id) => setState(() => c.assessmentId = id ?? ''),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 78,
            child: TextFormField(
              initialValue: c.weight == 0 ? '' : '${c.weight}',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                suffixText: '%',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              onChanged: (t) {
                final w = int.tryParse(t) ?? 0;
                setState(() => c.weight = w.clamp(0, 100));
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, size: 20, color: cs.error),
            onPressed: _variants[vi].components.length > 1
                ? () => setState(() => _variants[vi].components.removeAt(ci))
                : null,
          ),
        ],
      ),
    );
  }
}
