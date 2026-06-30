// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/semester/school_semester.dart';
import '../../l10n/app_localizations.dart';
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
    final changed = await Navigator.of(context).push<bool>(
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

    return Scaffold(
      appBar: AppBar(title: Text(l.averagesTitle)),
      floatingActionButton: (_cohort != null && _subject != null)
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: Text(l.averagesAddTitle),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadCohorts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: TextStyle(color: cs.error)),
              ),
            // Class picker
            DropdownButtonFormField<AvgCohort>(
              initialValue: _cohort,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.averagesSelectCohort,
                border: const OutlineInputBorder(),
              ),
              items: _cohorts
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: _loadingCohorts ? null : _onCohortChanged,
            ),
            const SizedBox(height: 14),
            // Subject picker
            DropdownButtonFormField<AvgSubject>(
              initialValue: _subject,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.averagesSelectSubject,
                border: const OutlineInputBorder(),
              ),
              items: _subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.display)))
                  .toList(),
              onChanged: (_cohort == null || _loadingSubjects) ? null : _onSubjectChanged,
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
            if (_subject != null) ...[
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
      ),
    );
  }
}

/// The current default semester number from the school's config (1 if none).
int defaultSemesterNumber(WidgetRef ref) {
  final raw = ref.read(authSessionProvider).schoolSemesters;
  final sems = parseSchoolSemesters(raw);
  final cur = currentSemesterWindow(sems, DateTime.now());
  return cur?.number ?? 1;
}
