// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/contracts/grade_scale.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/admin_repository.dart';

/// Admin-managed custom grade scales (e.g. letter grades A / A+ / B). A scale
/// applies to a set of grade levels; teachers grading a student in one of those
/// levels pick a label instead of typing a 0–100 number. Body-only: the shell
/// supplies the top bar.
class AdminGradeScalesScreen extends ConsumerStatefulWidget {
  const AdminGradeScalesScreen({super.key});

  @override
  ConsumerState<AdminGradeScalesScreen> createState() => _AdminGradeScalesScreenState();
}

class _AdminGradeScalesScreenState extends ConsumerState<AdminGradeScalesScreen> {
  List<CustomGradeScale> _scales = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final scales = await ref.read(adminRepositoryProvider).listGradeScales();
      if (!mounted) return;
      setState(() { _scales = scales; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  Future<void> _openEditor({CustomGradeScale? existing}) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GradeScaleEditorSheet(existing: existing),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(CustomGradeScale s) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(l.gradeScaleDeleteTitle),
        content: Text(l.gradeScaleDeleteConfirm(s.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(l.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(dCtx).colorScheme.error),
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).deleteGradeScale(s.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.gradeScaleAdd),
      ),
      body: _loading
          ? const Center(child: CmLoading())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _scales.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 80),
                          Icon(Icons.abc_rounded, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Center(child: Text(l.gradeScaleEmptyTitle,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(l.gradeScaleEmptyHint,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          itemCount: _scales.length,
                          itemBuilder: (_, i) {
                            final s = _scales[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: LiquidGlassCard(
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(s.name,
                                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_rounded, size: 20),
                                            tooltip: l.a11yEdit,
                                            onPressed: () => _openEditor(existing: s),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline_rounded, size: 20, color: cs.error),
                                            tooltip: l.a11yDelete,
                                            onPressed: () => _delete(s),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        s.gradeLevels.isEmpty
                                            ? l.gradeScaleAllGrades
                                            : l.gradeScaleAppliesTo(s.gradeLevels.map((g) => '$g').join(', ')),
                                        style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          for (final lab in s.labels)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: cs.primaryContainer.withValues(alpha: 0.4),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                lab.value != null ? '${lab.label} · ${lab.value}' : lab.label,
                                                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}

/// Bottom-sheet editor to create/edit one scale: name, applicable grade levels,
/// and an ordered list of labels (each an optional numeric equivalent).
class _GradeScaleEditorSheet extends ConsumerStatefulWidget {
  const _GradeScaleEditorSheet({this.existing});
  final CustomGradeScale? existing;

  @override
  ConsumerState<_GradeScaleEditorSheet> createState() => _GradeScaleEditorSheetState();
}

class _LabelDraft {
  _LabelDraft({String label = '', String value = ''})
      : labelCtrl = TextEditingController(text: label),
        valueCtrl = TextEditingController(text: value);
  final TextEditingController labelCtrl;
  final TextEditingController valueCtrl;
  void dispose() { labelCtrl.dispose(); valueCtrl.dispose(); }
}

class _GradeScaleEditorSheetState extends ConsumerState<_GradeScaleEditorSheet> {
  late final TextEditingController _nameCtrl;
  final Set<int> _gradeLevels = {};
  final List<_LabelDraft> _labels = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    if (e != null) {
      _gradeLevels.addAll(e.gradeLevels);
      for (final lab in e.labels) {
        _labels.add(_LabelDraft(label: lab.label, value: lab.value?.toString() ?? ''));
      }
    }
    if (_labels.isEmpty) {
      _labels.add(_LabelDraft(label: '', value: ''));
      _labels.add(_LabelDraft(label: '', value: ''));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final d in _labels) { d.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.gradeScaleNameRequired)));
      return;
    }
    final labels = <GradeScaleLabel>[];
    for (final d in _labels) {
      final txt = d.labelCtrl.text.trim();
      if (txt.isEmpty) continue;
      final v = d.valueCtrl.text.trim();
      labels.add(GradeScaleLabel(label: txt, value: v.isEmpty ? null : int.tryParse(v)));
    }
    if (labels.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.gradeScaleNeedTwoLabels)));
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final levels = _gradeLevels.toList()..sort();
      if (widget.existing == null) {
        await repo.createGradeScale(name: name, gradeLevels: levels, labels: labels);
      } else {
        await repo.updateGradeScale(widget.existing!.id, name: name, gradeLevels: levels, labels: labels);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final grades = ref.watch(authSessionProvider).schoolGrades;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(children: [
                Expanded(child: Text(
                  widget.existing == null ? l.gradeScaleAdd : l.gradeScaleEdit,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
              ]),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: l.gradeScaleNameLabel,
                      hintText: l.gradeScaleNameHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(l.gradeScaleGradeLevels, style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(l.gradeScaleGradeLevelsHint, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final g in grades)
                        FilterChip(
                          label: Text(l.adminCohortGradeFormat('$g')),
                          selected: _gradeLevels.contains(g),
                          onSelected: (sel) => setState(() {
                            if (sel) { _gradeLevels.add(g); } else { _gradeLevels.remove(g); }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(l.gradeScaleLabels, style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(l.gradeScaleLabelsHint, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < _labels.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _labels[i].labelCtrl,
                            decoration: InputDecoration(
                              labelText: l.gradeScaleLabelText,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _labels[i].valueCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l.gradeScaleLabelValue,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error),
                          tooltip: l.a11yRemove,
                          onPressed: _labels.length <= 1 ? null : () => setState(() {
                            _labels.removeAt(i).dispose();
                          }),
                        ),
                      ]),
                    ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _labels.add(_LabelDraft())),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l.gradeScaleAddLabel),
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
                        : Text(l.commonSave),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
