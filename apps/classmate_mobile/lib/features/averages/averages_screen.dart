// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import 'data/averages_repository.dart';
import 'averages_edit_screen.dart';

/// Teacher "Averages" — build weighted grade formulas per (class, subject).
class AveragesScreen extends ConsumerStatefulWidget {
  const AveragesScreen({super.key});

  @override
  ConsumerState<AveragesScreen> createState() => _AveragesScreenState();
}

class _AveragesScreenState extends ConsumerState<AveragesScreen> {
  List<AvgCohort> _cohorts = [];
  List<AvgSubject> _subjects = [];
  List<AvgFormula> _formulas = [];

  AvgCohort? _cohort;
  AvgSubject? _subject;

  bool _loadingCohorts = true;
  bool _loadingSubjects = false;
  bool _loadingFormulas = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadCohorts);
  }

  AveragesRepository get _repo => ref.read(averagesRepositoryProvider);

  Future<void> _loadCohorts() async {
    setState(() {
      _loadingCohorts = true;
      _error = null;
    });
    try {
      final cohorts = await _repo.cohorts();
      setState(() {
        _cohorts = cohorts;
        _loadingCohorts = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loadingCohorts = false;
      });
    }
  }

  Future<void> _onCohortChanged(AvgCohort? c) async {
    setState(() {
      _cohort = c;
      _subject = null;
      _subjects = [];
      _formulas = [];
    });
    if (c == null) return;
    setState(() => _loadingSubjects = true);
    try {
      final subs = await _repo.options(c.id);
      setState(() {
        _subjects = subs;
        _loadingSubjects = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loadingSubjects = false;
      });
    }
  }

  Future<void> _onSubjectChanged(AvgSubject? s) async {
    setState(() => _subject = s);
    if (s == null || _cohort == null) return;
    await _loadFormulas();
  }

  Future<void> _loadFormulas() async {
    if (_cohort == null || _subject == null) return;
    setState(() => _loadingFormulas = true);
    try {
      final fs = await _repo.list(_cohort!.id, _subject!.value);
      setState(() {
        _formulas = fs;
        _loadingFormulas = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loadingFormulas = false;
      });
    }
  }

  Future<void> _openEditor({AvgFormula? existing}) async {
    if (_cohort == null || _subject == null) return;
    // rootNavigator: push ABOVE the app shell so the editor is truly
    // full-screen (no shell top bar / burger), with iOS edge-swipe-to-leave.
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => AveragesEditScreen(
          cohort: _cohort!,
          subject: _subject!,
          existing: existing,
        ),
      ),
    );
    if (changed == true) await _loadFormulas();
  }

  Future<void> _delete(AvgFormula f) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.averagesDeleteTitle),
        content: Text(l.averagesDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.averagesDelete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.delete(f.id);
      await _loadFormulas();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    // Body-only: the app shell supplies the top bar / section pill, so this
    // screen has no header of its own.
    return RefreshIndicator(
      onRefresh: _loadCohorts,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: TextStyle(color: cs.error)),
            ),
          // Class picker (liquid glass)
          LiquidGlassSelectField<AvgCohort>(
            label: l.averagesSelectCohort,
            hint: l.averagesSelectCohort,
            value: _cohort,
            enabled: !_loadingCohorts,
            items: _cohorts
                .map((c) => LiquidGlassDropdownItem(value: c, label: c.name))
                .toList(),
            onChanged: _onCohortChanged,
          ),
          const SizedBox(height: 14),
          // Subject picker (liquid glass)
          LiquidGlassSelectField<AvgSubject>(
            label: l.averagesSelectSubject,
            hint: l.averagesSelectSubject,
            value: _subject,
            enabled: _cohort != null && !_loadingSubjects,
            items: _subjects
                .map((s) => LiquidGlassDropdownItem(value: s, label: s.display))
                .toList(),
            onChanged: _onSubjectChanged,
          ),
          if (_loadingSubjects)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
          if (_cohort != null && !_loadingSubjects && _subjects.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(l.averagesNoSubjects, style: TextStyle(color: cs.onSurfaceVariant)),
            ),
          const SizedBox(height: 20),
          if (_cohort != null && _subject != null) ...[
            FilledButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: Text(l.averagesAddTitle),
            ),
            const SizedBox(height: 16),
            if (_loadingFormulas)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_formulas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(l.averagesEmpty, style: TextStyle(color: cs.onSurfaceVariant)),
                ),
              )
            else
              ..._formulas.map((f) => Card(
                    child: ListTile(
                      title: Text(f.title),
                      subtitle: Text(l.averagesVariantCount(f.variants.length, f.units)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openEditor(existing: f),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: cs.error),
                            onPressed: () => _delete(f),
                          ),
                        ],
                      ),
                      onTap: () => _openEditor(existing: f),
                    ),
                  )),
          ],
        ],
      ),
    );
  }
}
