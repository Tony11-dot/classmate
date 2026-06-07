// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data/teacher_mobile_repository.dart';

/// Teacher-facing cohort management — create cohorts, expand to see the
/// roster (flipping arrow), and add/remove students. Scoped server-side to
/// the teacher's own school.
final _cohortsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(teacherMobileRepositoryProvider).fetchManagedCohorts();
});

class TeacherCohortsScreen extends ConsumerWidget {
  const TeacherCohortsScreen({super.key});

  TeacherMobileRepository _repo(WidgetRef ref) => ref.read(teacherMobileRepositoryProvider);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(_cohortsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.teacherCohortsScreenTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.teacherCohortsScreenNewCohort),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('${l.teacherCohortsScreenLoadError}\n$e', textAlign: TextAlign.center, style: TextStyle(color: cs.error)),
        )),
        data: (cohorts) {
          if (cohorts.isEmpty) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.teacherCohortsScreenEmpty,
                  textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
            ));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
            children: [for (final c in cohorts) _CohortTile(cohort: c)],
          );
        },
      ),
    );
  }

  static String gradeLabel(Map<String, dynamic> c) {
    final raw = c['grades'];
    final grades = raw is List ? raw.map((e) => (e as num).toInt()).toList() : <int>[];
    if (grades.isEmpty) {
      final g = (c['grade'] as num?)?.toInt();
      return g == null ? '' : 'Grade $g';
    }
    grades.sort();
    if (grades.length == 1) return 'Grade ${grades.first}';
    final isRange = grades.last - grades.first == grades.length - 1;
    return isRange ? 'Grade ${grades.first}-${grades.last}' : 'Grades ${grades.join(', ')}';
  }

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.teacherCohortsScreenNewCohort),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, autofocus: true,
              decoration: InputDecoration(labelText: l.teacherCohortsScreenCohortNameLabel, hintText: l.teacherCohortsScreenCohortNameHint)),
          const SizedBox(height: 8),
          TextField(controller: gradeCtrl, keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.teacherCohortsScreenGradesLabel, hintText: l.teacherCohortsScreenGradesHint)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.teacherCohortsScreenCancel)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l.teacherCohortsScreenCreate)),
        ],
      ),
    );
    if (ok != true) return;
    final grades = _parseGrades(gradeCtrl.text);
    if (nameCtrl.text.trim().isEmpty || grades.isEmpty) {
      _toast(context, l.teacherCohortsScreenEnterNameAndGrade);
      return;
    }
    try {
      await _repo(ref).createManagedCohort(name: nameCtrl.text.trim(), grades: grades);
      ref.invalidate(_cohortsProvider);
      _toast(context, l.teacherCohortsScreenCohortCreated);
    } catch (e) {
      _toast(context, '${l.teacherCohortsScreenFailed}: $e');
    }
  }

  static List<int> _parseGrades(String raw) {
    return raw
        .split(RegExp(r'[,;\s]+'))
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .where((g) => g >= 1 && g <= 20)
        .toSet()
        .toList()
      ..sort();
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _CohortTile extends ConsumerWidget {
  const _CohortTile({required this.cohort});
  final Map<String, dynamic> cohort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final id = '${cohort['id']}';
    final name = '${cohort['name'] ?? ''}';
    final count = (cohort['studentCount'] as num?)?.toInt() ?? 0;
    final repo = ref.read(teacherMobileRepositoryProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${TeacherCohortsScreen.gradeLabel(cohort)} · ${l.teacherCohortsScreenStudentsCount(count)}',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'rename') await _renameDialog(context, ref, id, name, cohort);
              if (v == 'delete') await _deleteDialog(context, ref, id, name);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'rename', child: Text(l.teacherCohortsScreenRenameGrades)),
              PopupMenuItem(value: 'delete', child: Text(l.teacherCohortsScreenDeleteCohort)),
            ],
          ),
          const Icon(Icons.expand_more_rounded),
        ]),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          _Roster(cohortId: id),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _addStudents(context, ref, id, repo),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(l.teacherCohortsScreenAddStudents),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _renameDialog(BuildContext context, WidgetRef ref, String id, String name, Map<String, dynamic> c) async {
    final l = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: name);
    final gradeCtrl = TextEditingController(
        text: (c['grades'] is List ? (c['grades'] as List).join(',') : '${c['grade'] ?? ''}'));
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.teacherCohortsScreenEditCohort),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l.teacherCohortsScreenCohortNameLabel)),
          const SizedBox(height: 8),
          TextField(controller: gradeCtrl, keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.teacherCohortsScreenGradesLabel)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.teacherCohortsScreenCancel)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l.teacherCohortsScreenSave)),
        ],
      ),
    );
    if (ok != true) return;
    final grades = TeacherCohortsScreen._parseGrades(gradeCtrl.text);
    try {
      await ref.read(teacherMobileRepositoryProvider).updateManagedCohort(
            id, name: nameCtrl.text.trim(), grades: grades.isEmpty ? null : grades);
      ref.invalidate(_cohortsProvider);
      TeacherCohortsScreen._toast(context, l.teacherCohortsScreenSaved);
    } catch (e) {
      TeacherCohortsScreen._toast(context, '${l.teacherCohortsScreenFailed}: $e');
    }
  }

  Future<void> _deleteDialog(BuildContext context, WidgetRef ref, String id, String name) async {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.teacherCohortsScreenDeleteConfirmTitle(name)),
        content: Text(l.teacherCohortsScreenDeleteConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.teacherCohortsScreenCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.pop(d, true), child: Text(l.teacherCohortsScreenDelete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).deleteManagedCohort(id);
      ref.invalidate(_cohortsProvider);
      TeacherCohortsScreen._toast(context, l.teacherCohortsScreenDeleted);
    } catch (e) {
      TeacherCohortsScreen._toast(context, '${l.teacherCohortsScreenFailed}: $e');
    }
  }

  Future<void> _addStudents(BuildContext context, WidgetRef ref, String id, TeacherMobileRepository repo) async {
    final l = AppLocalizations.of(context)!;
    List<Map<String, dynamic>> students;
    try {
      students = await repo.fetchSchoolStudents();
    } catch (e) {
      TeacherCohortsScreen._toast(context, '${l.teacherCohortsScreenLoadStudentsError}: $e');
      return;
    }
    final selected = <String>{};
    final picked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        return DraggableScrollableSheet(
          expand: false, initialChildSize: 0.7, maxChildSize: 0.95,
          builder: (ctx, scroll) => Column(children: [
            Padding(padding: const EdgeInsets.all(16),
                child: Text(l.teacherCohortsScreenAddStudents, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            Expanded(child: ListView(controller: scroll, children: [
              for (final s in students)
                CheckboxListTile(
                  value: selected.contains('${s['id']}'),
                  title: Text('${s['name'] ?? s['nameEn'] ?? '—'}'),
                  onChanged: (v) => setSheet(() {
                    final sid = '${s['id']}';
                    if (v == true) { selected.add(sid); } else { selected.remove(sid); }
                  }),
                ),
            ])),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(width: double.infinity, child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.teacherCohortsScreenAddNStudents(selected.length)),
              )),
            ),
          ]),
        );
      }),
    );
    if (picked != true || selected.isEmpty) return;
    try {
      await repo.addStudentsToManagedCohort(id, selected.toList());
      ref.invalidate(_cohortsProvider);
      TeacherCohortsScreen._toast(context, l.teacherCohortsScreenAddedNStudents(selected.length));
    } catch (e) {
      TeacherCohortsScreen._toast(context, '${l.teacherCohortsScreenFailed}: $e');
    }
  }
}

/// Roster for one cohort — loaded lazily when the tile expands.
class _Roster extends ConsumerStatefulWidget {
  const _Roster({required this.cohortId});
  final String cohortId;
  @override
  ConsumerState<_Roster> createState() => _RosterState();
}

class _RosterState extends ConsumerState<_Roster> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(teacherMobileRepositoryProvider).fetchManagedCohortRoster(widget.cohortId);
  }

  void _reload() {
    setState(() {
      _future = ref.read(teacherMobileRepositoryProvider).fetchManagedCohortRoster(widget.cohortId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
        }
        final students = snap.data ?? const [];
        if (students.isEmpty) {
          return Padding(padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l.teacherCohortsScreenNoStudentsYet, style: TextStyle(color: cs.onSurfaceVariant)));
        }
        return Column(children: [
          for (final s in students)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${s['name'] ?? '—'}'),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error),
                onPressed: () async {
                  try {
                    await ref.read(teacherMobileRepositoryProvider)
                        .removeStudentFromManagedCohort(widget.cohortId, '${s['id']}');
                    _reload();
                    ref.invalidate(_cohortsProvider);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l.teacherCohortsScreenFailed}: $e')));
                    }
                  }
                },
              ),
            ),
        ]);
      },
    );
  }
}
