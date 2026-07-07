// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/grade_multi_select_field.dart';
import '../../../ui/widgets/student_multi_select_sheet.dart';
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
      backgroundColor: cs.surface,
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
            padding: EdgeInsets.fromLTRB(12, 8 + MediaQuery.paddingOf(context).top, 12, 100),
            children: [for (final c in cohorts) _CohortTile(cohort: c)],
          );
        },
      ),
    );
  }

  static String gradeLabel(AppLocalizations l, Map<String, dynamic> c) {
    final raw = c['grades'];
    final grades = raw is List ? raw.map((e) => (e as num).toInt()).toList() : <int>[];
    if (grades.isEmpty) {
      final g = (c['grade'] as num?)?.toInt();
      return g == null ? '' : l.teacherCohortsScreenSingleGrade(g);
    }
    grades.sort();
    if (grades.length == 1) return l.teacherCohortsScreenSingleGrade(grades.first);
    final isRange = grades.last - grades.first == grades.length - 1;
    return isRange
        ? l.teacherCohortsScreenGradeRange(grades.first, grades.last)
        : l.teacherCohortsScreenMultiGrade(grades.join(', '));
  }

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final grades = <int>{};
    final available = ref.read(authSessionProvider).schoolGrades;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setSheet) => AlertDialog(
          title: Text(l.teacherCohortsScreenNewCohort),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, autofocus: true,
                decoration: InputDecoration(labelText: l.teacherCohortsScreenCohortNameLabel, hintText: l.teacherCohortsScreenCohortNameHint)),
            const SizedBox(height: 12),
            GradeMultiSelectField(
              label: l.teacherCohortsScreenGradesLabel,
              hint: l.pickerSelectGrades,
              availableGrades: available,
              selected: grades,
              onChanged: (next) => setSheet(() => grades..clear()..addAll(next)),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.teacherCohortsScreenCancel)),
            FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l.teacherCohortsScreenCreate)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final gradeList = grades.toList()..sort();
    if (nameCtrl.text.trim().isEmpty || gradeList.isEmpty) {
      _toast(context, l.teacherCohortsScreenEnterNameAndGrade);
      return;
    }
    try {
      await _repo(ref).createManagedCohort(name: nameCtrl.text.trim(), grades: gradeList);
      ref.invalidate(_cohortsProvider);
      _toast(context, l.teacherCohortsScreenCohortCreated);
    } catch (e) {
      _toast(context, '${l.teacherCohortsScreenFailed}: $e');
    }
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
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        // Drop the default top/bottom divider lines that make the expanded
        // block look boxed-in — keep it clean.
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${TeacherCohortsScreen.gradeLabel(l, cohort)} · ${l.teacherCohortsScreenStudentsCount(count)}',
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
    final grades = <int>{};
    final raw = c['grades'];
    if (raw is List) {
      grades.addAll(raw.map((e) => (e as num).toInt()));
    } else if (c['grade'] != null) {
      grades.add((c['grade'] as num).toInt());
    }
    final available = ref.read(authSessionProvider).schoolGrades;
    String? homeroomTeacherId = (c['homeroomTeacherId'] ?? '').toString().isEmpty ? null : c['homeroomTeacherId'].toString();
    List<Map<String, dynamic>> teachers = const [];
    try {
      teachers = await ref.read(teacherMobileRepositoryProvider).schoolTeachers();
    } catch (_) {}
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setSheet) => AlertDialog(
          title: Text(l.teacherCohortsScreenEditCohort),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l.teacherCohortsScreenCohortNameLabel)),
              const SizedBox(height: 12),
              GradeMultiSelectField(
                label: l.teacherCohortsScreenGradesLabel,
                hint: l.pickerSelectGrades,
                availableGrades: available,
                selected: grades,
                onChanged: (next) => setSheet(() => grades..clear()..addAll(next)),
              ),
              const SizedBox(height: 12),
              // Homeroom teacher (مربّي/ة الصف) — drives the certificates access.
              DropdownButtonFormField<String>(
                initialValue: homeroomTeacherId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.cohortHomeroomTeacher, border: const OutlineInputBorder()),
                items: teachers
                    .map((t) => DropdownMenuItem(value: '${t['id']}', child: Text('${t['name'] ?? ''}', overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setSheet(() => homeroomTeacherId = v),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.teacherCohortsScreenCancel)),
            FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l.teacherCohortsScreenSave)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final gradeList = grades.toList()..sort();
    try {
      await ref.read(teacherMobileRepositoryProvider).updateManagedCohort(
            id, name: nameCtrl.text.trim(), grades: gradeList.isEmpty ? null : gradeList, homeroomTeacherId: homeroomTeacherId);
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
    List<MultiSelectItem> items;
    try {
      final all = await repo.fetchSchoolStudents();
      // Exclude students already in this cohort — only offer ones not yet added.
      final existing = await repo.fetchCohortStudents(id);
      final existingIds = existing.map((s) => s.studentId).toSet();
      // The school-students endpoint keys each row as `studentId` (not `id`);
      // using `id` made every row share the same empty key → tapping one
      // selected all, and the Add call sent null ids → server rejected it.
      String sid(Map<String, dynamic> s) => '${s['studentId'] ?? s['id'] ?? ''}';
      items = [
        for (final s in all)
          if (sid(s).isNotEmpty && !existingIds.contains(sid(s)))
            MultiSelectItem(id: sid(s), name: '${s['name'] ?? s['nameEn'] ?? '—'}'),
      ];
    } catch (e) {
      TeacherCohortsScreen._toast(context, '${l.teacherCohortsScreenLoadStudentsError}: $e');
      return;
    }
    if (items.isEmpty) {
      TeacherCohortsScreen._toast(context, l.teacherCohortsScreenNoStudentsToAdd);
      return;
    }
    if (!context.mounted) return;
    final selected = await showStudentMultiSelectSheet(
      context: context,
      title: l.teacherCohortsScreenAddStudents,
      items: items,
    );
    if (selected == null || selected.isEmpty) return;
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
                tooltip: l.a11yRemove,
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
