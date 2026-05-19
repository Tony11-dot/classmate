// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/auth/auth_controller.dart';
import '../data/admin_repository.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminExportScreen extends ConsumerStatefulWidget {
  const AdminExportScreen({super.key});

  @override
  ConsumerState<AdminExportScreen> createState() => _AdminExportScreenState();
}

enum _PickerMode { students, cohorts, grades }

class _AdminExportScreenState extends ConsumerState<AdminExportScreen> {
  // Mode
  _PickerMode _mode = _PickerMode.students;

  // Selection
  final Set<String> _selectedStudentIds = {};
  final Set<String> _selectedCohortIds  = {};
  final Set<int>    _selectedGrades     = {};
  final Set<String> _expandedCohortIds  = {};

  // Data
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _cohorts  = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final [students, cohorts] = await Future.wait([
        ref.read(adminRepositoryProvider).getDdlStudents(),
        ref.read(adminRepositoryProvider).getDdlCohorts(),
      ]);
      if (mounted) {
        setState(() {
        _students = students;
        _cohorts  = cohorts;
        _loading  = false;
      });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// All grades visible in this school — derived from the cohorts DDL so we
  /// don't need a separate school-grades fetch. Each cohort can span multiple
  /// grades via `grades[]`, otherwise falls back to its primary `grade`.
  List<int> get _allGrades {
    final set = <int>{};
    for (final c in _cohorts) {
      final gs = c['grades'];
      if (gs is List && gs.isNotEmpty) {
        for (final g in gs) {
          if (g is num) set.add(g.toInt());
        }
      } else {
        final g = c['grade'];
        if (g is num) set.add(g.toInt());
      }
    }
    return set.toList()..sort();
  }

  /// Resolves the list of selected student IDs across all three picker
  /// modes, deduplicated. Students mode = direct selection. Cohorts mode =
  /// roster lookup by selected cohort ids (matched against StudentCohort
  /// memberships, with a name fallback for legacy rows). Grades mode =
  /// any student whose own grade or whose cohorts cover one of the
  /// selected grades.
  List<String> get _effectiveStudentIds {
    final ids = <String>{};
    if (_mode == _PickerMode.students) {
      ids.addAll(_selectedStudentIds);
    } else if (_mode == _PickerMode.cohorts) {
      for (final cid in _selectedCohortIds) {
        final cohort = _cohorts.firstWhere(
          (c) => c['id']?.toString() == cid,
          orElse: () => const {},
        );
        // Prefer the new multi-cohort membership lookup (cohort.studentIds
        // from the DDL); fall back to legacy single-cohort name match.
        final memberIds = (cohort['studentIds'] as List?)
                ?.map((e) => e.toString())
                .where((s) => s.isNotEmpty)
                .toList() ??
            const <String>[];
        if (memberIds.isNotEmpty) {
          ids.addAll(memberIds);
        } else {
          final cohortName = cohort['name']?.toString() ?? '';
          for (final s in _students) {
            if ((s['cohortName']?.toString() ?? '') == cohortName) {
              ids.add(s['id']?.toString() ?? '');
            }
          }
        }
      }
    } else if (_mode == _PickerMode.grades) {
      for (final g in _selectedGrades) {
        for (final s in _students) {
          final sg = (s['grade'] as num?)?.toInt();
          if (sg == g) {
            ids.add(s['id']?.toString() ?? '');
          }
        }
      }
    }
    return ids.where((id) => id.isNotEmpty).toList();
  }

  int get _selectedCount {
    if (_mode == _PickerMode.students) return _selectedStudentIds.length;
    return _effectiveStudentIds.length;
  }

  void _toggleStudent(String id) => setState(() =>
    _selectedStudentIds.contains(id) ? _selectedStudentIds.remove(id) : _selectedStudentIds.add(id));

  void _toggleCohort(String id) => setState(() =>
    _selectedCohortIds.contains(id) ? _selectedCohortIds.remove(id) : _selectedCohortIds.add(id));

  void _toggleGrade(int g) => setState(() =>
    _selectedGrades.contains(g) ? _selectedGrades.remove(g) : _selectedGrades.add(g));

  void _toggleExpandCohort(String id) => setState(() =>
    _expandedCohortIds.contains(id) ? _expandedCohortIds.remove(id) : _expandedCohortIds.add(id));

  // ── Export sheet ───────────────────────────────────────────────────────────

  void _showExportSheet() {
    final count = _selectedCount;
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one student or cohort first')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _ExportOptionsSheet(
        studentCount: count,
        selectedStudentIds: _effectiveStudentIds,
        repo: ref.read(adminRepositoryProvider),
        session: ref.read(authSessionProvider),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final q     = _search.toLowerCase();

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: _selectedCount > 0
          ? FloatingActionButton.extended(
              heroTag: 'fab_export',
              onPressed: _showExportSheet,
              icon: const Icon(Icons.download_rounded),
              label: Text('Export $_selectedCount'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Mode toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: SegmentedButton<_PickerMode>(
                segments: const [
                  ButtonSegment(value: _PickerMode.students, label: Text('Students'), icon: Icon(Icons.person_rounded, size: 16)),
                  ButtonSegment(value: _PickerMode.cohorts,  label: Text('Cohorts'),  icon: Icon(Icons.groups_rounded,  size: 16)),
                  ButtonSegment(value: _PickerMode.grades,   label: Text('Grades'),   icon: Icon(Icons.school_rounded,  size: 16)),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() {
                  _mode = s.first;
                  _selectedStudentIds.clear();
                  _selectedCohortIds.clear();
                  _selectedGrades.clear();
                }),
              ),
            ),

            // Search — flips its hint with the active mode. Grades mode skips
            // it since the picker is a short chip list anyway.
            if (_mode != _PickerMode.grades)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: _mode == _PickerMode.cohorts ? 'Search cohorts…' : 'Search students…',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                  ),
                ),
              ),

            // Selection count
            if (_selectedCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        '$_selectedCount student${_selectedCount == 1 ? '' : 's'} selected',
                        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : switch (_mode) {
                      _PickerMode.cohorts => _CohortPickerList(
                          cohorts: _cohorts.where((c) {
                            if (q.isEmpty) return true;
                            final name = (c['name']?.toString() ?? '').toLowerCase();
                            return name.contains(q);
                          }).toList(),
                          students: _students,
                          selectedCohortIds: _selectedCohortIds,
                          expandedCohortIds: _expandedCohortIds,
                          onToggleCohort: _toggleCohort,
                          onToggleExpand: _toggleExpandCohort,
                        ),
                      _PickerMode.grades => _GradePickerList(
                          grades: _allGrades,
                          students: _students,
                          selectedGrades: _selectedGrades,
                          onToggle: _toggleGrade,
                        ),
                      _PickerMode.students => _StudentPickerList(
                          students: _students.where((s) {
                            if (q.isEmpty) return true;
                            return (s['name']?.toString() ?? '').toLowerCase().contains(q);
                          }).toList(),
                          selectedIds: _selectedStudentIds,
                          onToggle: _toggleStudent,
                        ),
                    },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student picker list ────────────────────────────────────────────────────────

class _StudentPickerList extends StatelessWidget {
  const _StudentPickerList({required this.students, required this.selectedIds, required this.onToggle});
  final List<Map<String, dynamic>> students;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (students.isEmpty) {
      return Center(child: Text('No students found', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 120),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (ctx, i) {
        final s        = students[i];
        final id       = s['id']?.toString() ?? '';
        final name     = s['name']?.toString() ?? '';
        final cohort   = s['cohortName']?.toString() ?? '';
        final grade    = (s['grade'] as num?)?.toInt();
        final selected = selectedIds.contains(id);

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onToggle(id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      if (cohort.isNotEmpty || grade != null)
                        Text(
                          [if (grade != null) 'Grade $grade', if (cohort.isNotEmpty) cohort].join(' · '),
                          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Grade picker list ─────────────────────────────────────────────────────────

class _GradePickerList extends StatelessWidget {
  const _GradePickerList({
    required this.grades,
    required this.students,
    required this.selectedGrades,
    required this.onToggle,
  });
  final List<int> grades;
  final List<Map<String, dynamic>> students;
  final Set<int> selectedGrades;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (grades.isEmpty) {
      return Center(
        child: Text(
          'No grades configured for this school',
          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 120),
      itemCount: grades.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (ctx, i) {
        final g = grades[i];
        final selected = selectedGrades.contains(g);
        // Live preview of how many students this grade covers — same source
        // the effective-selection getter uses, so the count and the export
        // result can't drift.
        final count = students.where((s) => (s['grade'] as num?)?.toInt() == g).length;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onToggle(g),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? cs.primary.withValues(alpha: 0.4)
                    : cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Grade $g',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '$count student${count == 1 ? '' : 's'}',
                  style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Cohort picker list ────────────────────────────────────────────────────────

class _CohortPickerList extends StatelessWidget {
  const _CohortPickerList({
    required this.cohorts,
    required this.students,
    required this.selectedCohortIds,
    required this.expandedCohortIds,
    required this.onToggleCohort,
    required this.onToggleExpand,
  });
  final List<Map<String, dynamic>> cohorts;
  final List<Map<String, dynamic>> students;
  final Set<String> selectedCohortIds;
  final Set<String> expandedCohortIds;
  final ValueChanged<String> onToggleCohort;
  final ValueChanged<String> onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 120),
      itemCount: cohorts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) {
        final c        = cohorts[i];
        final cid      = c['id']?.toString() ?? '';
        final name     = c['name']?.toString() ?? '';
        final grade    = (c['grade'] as num?)?.toInt();
        final selected = selectedCohortIds.contains(cid);
        final expanded = expandedCohortIds.contains(cid);

        // Students of this cohort — read the DDL's studentIds (server-side
        // union of StudentCohort + legacy studentProfile.cohortId) and
        // resolve to names from the students list. Falls back to a
        // cohort-name match for legacy rows where studentIds is empty,
        // and to cohortIds-on-the-student row when both fail. Previous
        // behavior matched only on cohortName which silently showed 0
        // for every cohort whose students were multi-cohort'd (the
        // student's primary cohortName resolved to a different cohort).
        final memberIdsFromCohort = (c['studentIds'] as List?)
                ?.map((e) => e.toString())
                .where((s) => s.isNotEmpty)
                .toSet() ??
            <String>{};
        List<Map<String, dynamic>> cohortStudents;
        if (memberIdsFromCohort.isNotEmpty) {
          cohortStudents = students
              .where((s) => memberIdsFromCohort.contains(s['id']?.toString() ?? ''))
              .toList();
        } else {
          cohortStudents = students.where((s) {
            final cohortIds = (s['cohortIds'] as List?)
                    ?.map((e) => e.toString())
                    .toSet() ??
                <String>{};
            if (cohortIds.contains(cid)) return true;
            if ((s['cohortId']?.toString() ?? '') == cid) return true;
            return (s['cohortName']?.toString() ?? '') == name;
          }).toList();
        }

        return Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onToggleCohort(cid),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            '${grade != null ? 'Grade $grade · ' : ''}${cohortStudents.length} students',
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    // Expand toggle
                    if (cohortStudents.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () => onToggleExpand(cid),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
            ),
            // Expanded student preview
            if (expanded)
              Container(
                margin: const EdgeInsets.only(left: 16, top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cohortStudents.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(s['name']?.toString() ?? '', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Export options bottom sheet ────────────────────────────────────────────────

class _ExportOptionsSheet extends StatefulWidget {
  const _ExportOptionsSheet({
    required this.studentCount,
    required this.selectedStudentIds,
    required this.repo,
    required this.session,
  });
  final int studentCount;
  final List<String> selectedStudentIds;
  final AdminRepository repo;
  final dynamic session;

  @override
  State<_ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<_ExportOptionsSheet> {
  bool _includePasswords = false;
  bool _exporting = false;

  /// Source rect for the iOS share popover. iPad + newer iPhone share sheets
  /// require a non-zero anchor or they throw
  /// `PlatformException(sharePositionOrigin: argument must be set...)`.
  Rect _shareOrigin(BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    // Fallback: anchor at top-center of the screen with a 1x1 rect.
    final size = MediaQuery.sizeOf(ctx);
    return Rect.fromLTWH(size.width / 2, 0, 1, 1);
  }

  /// Pre-export warning that the file contains passwords. Replaces the
  /// previous type-RESET ceremony: that dialog also wiped every selected
  /// student's password (regenerating fresh temp passwords for the
  /// export), which silently locked students out of the app. The new
  /// flow just confirms the admin understands the file is sensitive — no
  /// server-side password reset happens.
  Future<bool> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (d) {
        final cs = Theme.of(d).colorScheme;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: cs.error),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Export will include passwords'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The file will contain ${widget.studentCount} '
                'student${widget.studentCount == 1 ? '' : 's'}\' login info. '
                'Anyone with access can sign in as those students — share with '
                'care and delete the file when done.',
                style: const TextStyle(height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No password resets happen — students keep their existing logins.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(d, true),
              style: FilledButton.styleFrom(backgroundColor: cs.error),
              child: const Text('Export anyway'),
            ),
          ],
        );
      },
    );
    return confirm == true;
  }

  Future<List<Map<String, dynamic>>> _fetch() =>
      // generatePasswords used to fire when _includePasswords was toggled,
      // which silently reset every selected student's password. Now the
      // toggle is purely informational — the warning before export
      // explains the file is sensitive; nothing changes server-side.
      widget.repo.exportStudents(studentIds: widget.selectedStudentIds, generatePasswords: false);

  // ── CSV ────────────────────────────────────────────────────────────────────

  Future<void> _exportCsv() async {
    if (_includePasswords && !await _confirmReset()) return;
    setState(() => _exporting = true);
    try {
      final students = await _fetch();
      if (!mounted) return;

      final headers = ['Name (EN)', 'Name (AR)', 'Name (HE)', 'Name (FR)', 'Name (RU)', 'Email', 'Username', 'Phone', 'Grade', 'Cohorts', 'School'];
      if (_includePasswords) headers.add('Password');
      final buf = StringBuffer()..writeln(headers.join(','));
      for (final s in students) {
        // Cohorts list: prefer the new cohortNames[] field with every
        // cohort the student belongs to; fall back to legacy cohortName.
        final cohortNamesRaw = s['cohortNames'];
        final cohortsJoined = cohortNamesRaw is List
            ? cohortNamesRaw.whereType<String>().where((n) => n.isNotEmpty).join(' / ')
            : (s['cohortName']?.toString() ?? '');
        final row = [
          _esc(s['nameEn']?.toString() ?? ''),
          _esc(s['nameAr']?.toString() ?? ''),
          _esc(s['nameHe']?.toString() ?? ''),
          _esc(s['nameFr']?.toString() ?? ''),
          _esc(s['nameRu']?.toString() ?? ''),
          _esc(s['email']?.toString() ?? ''),
          _esc(s['username']?.toString() ?? ''),
          _esc(s['phone']?.toString() ?? ''),
          s['grade']?.toString() ?? '',
          _esc(cohortsJoined),
          _esc(s['schoolName']?.toString() ?? ''),
          if (_includePasswords) _esc(s['tempPassword']?.toString() ?? ''),
        ];
        buf.writeln(row.join(','));
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/students_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buf.toString());
      if (!mounted) return;
      // iOS share sheet REQUIRES a non-zero source rect on iPad / newer
      // iPhones. Grab the bottom-sheet's render box BEFORE we pop so we can
      // anchor the share popover correctly.
      final origin = _shareOrigin(context);
      Navigator.pop(context);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'ClassMate Students',
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── PDF ────────────────────────────────────────────────────────────────────

  Future<void> _exportPdf() async {
    if (_includePasswords && !await _confirmReset()) return;
    setState(() => _exporting = true);
    try {
      final students = await _fetch();
      if (!mounted) return;
      final schoolName = widget.session?.schoolName ?? '';
      final exportedBy = (widget.session?.displayName ?? widget.session?.email ?? 'Admin') as String;
      final bytes = await _buildPdf(students, withPasswords: _includePasswords, schoolName: schoolName, exportedBy: exportedBy);
      if (!mounted) return;
      final origin = _shareOrigin(context);
      Navigator.pop(context);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'classmate_students.pdf',
        // Same iOS source-rect requirement as the CSV share above.
        bounds: origin,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── PDF builder ────────────────────────────────────────────────────────────

  Future<Uint8List> _buildPdf(
    List<Map<String, dynamic>> students, {
    required bool withPasswords,
    required String schoolName,
    required String exportedBy,
  }) async {
    // Bundle Latin + Arabic + Hebrew fonts so multi-language student names
    // actually render. Helvetica (the pdf-package default) only ships Latin
    // glyphs — without these fallbacks Arabic / Hebrew names came out as
    // tofu boxes and we got the "Helvetica has no Unicode support" warning.
    final baseFont    = await PdfGoogleFonts.notoSansRegular();
    final baseBold    = await PdfGoogleFonts.notoSansBold();
    final arabicFont  = await PdfGoogleFonts.notoSansArabicRegular();
    final hebrewFont  = await PdfGoogleFonts.notoSansHebrewRegular();
    final cmLogo      = pw.MemoryImage(
      (await rootBundle.load('assets/images/icon_light.png')).buffer.asUint8List(),
    );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: baseBold,
        fontFallback: [arabicFont, hebrewFont],
      ),
    );
    final now = DateTime.now();
    final dateStr = '${_months[now.month]} ${now.day}, ${now.year}';

    const brandBlue    = PdfColor.fromInt(0xFF2563EB);
    const brandLight   = PdfColor.fromInt(0xFFEFF6FF);
    const headerBg     = PdfColor.fromInt(0xFF1E3A5F);
    const rowAlt       = PdfColor.fromInt(0xFFF8FAFD);
    const pwColor      = PdfColor.fromInt(0xFF7C3AED);

    // PDF columns: Phone + School + multi-Cohort added. Dropped the AR/HE
    // columns from the PDF entirely because the pdf package's table layout
    // can't reliably reverse-direction Hebrew/Arabic glyphs inside a Text
    // cell (without a Directionality wrapper, RTL scripts render in
    // visual order which reads right-to-left scrambled). Localized names
    // are still in the CSV export — admins who need them open Excel.
    final cols = withPasswords
        ? [_Col('#', 0.03), _Col('Name', 0.15), _Col('Email', 0.15), _Col('Username', 0.10), _Col('Phone', 0.11), _Col('Grade', 0.05), _Col('Cohorts', 0.14), _Col('School', 0.12), _Col('Password', 0.15)]
        : [_Col('#', 0.04), _Col('Name', 0.18), _Col('Email', 0.18), _Col('Username', 0.11), _Col('Phone', 0.12), _Col('Grade', 0.05), _Col('Cohorts', 0.18), _Col('School', 0.14)];

    final fmt  = PdfPageFormat.a4.landscape;
    final pageW = fmt.availableWidth;

    doc.addPage(pw.MultiPage(
      pageFormat: fmt,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => [
        // ── Header banner ──────────────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(color: brandBlue, borderRadius: pw.BorderRadius.circular(12)),
          child: pw.Row(
            children: [
              pw.Container(
                width: 44, height: 44,
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(10)),
                alignment: pw.Alignment.center,
                child: pw.Image(cmLogo, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('ClassMate', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                if (schoolName.isNotEmpty) pw.Text(schoolName, style: const pw.TextStyle(fontSize: 11, color: PdfColor(1, 1, 1, 0.7))),
              ])),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('Student Directory', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10, color: PdfColor(1, 1, 1, 0.7))),
                pw.Text('By: $exportedBy', style: const pw.TextStyle(fontSize: 10, color: PdfColor(1, 1, 1, 0.7))),
                pw.Text('${students.length} students', style: const pw.TextStyle(fontSize: 10, color: PdfColor(1, 1, 1, 0.7))),
              ]),
            ],
          ),
        ),
        pw.SizedBox(height: 14),

        // ── Table ──────────────────────────────────────────────────────────────
        pw.Table(
          columnWidths: { for (var i = 0; i < cols.length; i++) i: pw.FixedColumnWidth(cols[i].fraction * pageW) },
          children: [
            // Header row
            pw.TableRow(
              decoration: pw.BoxDecoration(color: headerBg, borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(8), topRight: pw.Radius.circular(8))),
              children: cols.map((c) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                child: pw.Text(c.label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              )).toList(),
            ),
            // Data rows
            ...students.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              // Multi-cohort: join the new cohortNames[] field; fall back
              // to the legacy singular cohortName for back-compat.
              final cohortNamesRaw = s['cohortNames'];
              final cohortsJoined = cohortNamesRaw is List
                  ? cohortNamesRaw.whereType<String>().where((n) => n.isNotEmpty).join(' / ')
                  : (s['cohortName']?.toString() ?? '');
              final cells = withPasswords
                  ? ['${i+1}', s['nameEn']??'', s['email']??'', s['username']??'', s['phone']??'', '${s['grade']??''}', cohortsJoined, s['schoolName']??'', s['tempPassword']??'']
                  : ['${i+1}', s['nameEn']??'', s['email']??'', s['username']??'', s['phone']??'', '${s['grade']??''}', cohortsJoined, s['schoolName']??''];
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: i.isOdd ? rowAlt : PdfColors.white),
                children: cells.asMap().entries.map((ce) {
                  // Password is always the LAST column now (index 8 with
                  // passwords) — keeps its monospace-ish purple styling.
                  final isPw = withPasswords && ce.key == cells.length - 1;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    child: pw.Text(ce.value.toString(),
                      style: pw.TextStyle(fontSize: 8, color: isPw ? pwColor : PdfColors.black, fontWeight: isPw ? pw.FontWeight.bold : pw.FontWeight.normal),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
        pw.SizedBox(height: 10),

        // ── Footer ────────────────────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(color: brandLight, borderRadius: pw.BorderRadius.circular(8), border: pw.Border.all(color: brandBlue, width: 0.5)),
          child: pw.Text(
            withPasswords
                ? '⚠  Passwords are temporary and were reset on export. Students should change them on first login.'
                : 'Generated by ClassMate — confidential school data.',
            style: pw.TextStyle(fontSize: 8, color: brandBlue, fontStyle: pw.FontStyle.italic),
          ),
        ),
      ],
    ));
    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export Options', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    Text('${widget.studentCount} student${widget.studentCount == 1 ? '' : 's'} selected',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Password toggle — no longer regenerates anything. When on, the
          // server still includes the password column in the export, but
          // it's the existing temporary password admins set at user-add
          // time (never overwritten silently). The previous design did a
          // hard reset on toggle-on and surfaced new passwords in the
          // file — too dangerous when an admin just wanted to share login
          // info with parents.
          Container(
            decoration: BoxDecoration(
              color: _includePasswords ? cs.errorContainer.withValues(alpha: 0.2) : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _includePasswords ? cs.error.withValues(alpha: 0.4) : cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: SwitchListTile.adaptive(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              title: Text('Include Passwords',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: _includePasswords ? cs.error : cs.onSurface)),
              subtitle: Text(
                _includePasswords
                    ? 'Passwords will be visible in the export — handle the file securely.'
                    : 'Export will not contain any passwords.',
                style: theme.textTheme.labelSmall?.copyWith(color: _includePasswords ? cs.error : cs.onSurfaceVariant, height: 1.3),
              ),
              value: _includePasswords,
              activeColor: cs.error,
              onChanged: (v) => setState(() => _includePasswords = v),
            ),
          ),
          const SizedBox(height: 16),

          // Export buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _exporting ? null : _exportCsv,
                  icon: _exporting ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.table_chart_rounded, size: 16),
                  label: const Text('Export CSV'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _exporting ? null : _exportPdf,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
                  icon: _exporting ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('Export PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Col {
  const _Col(this.label, this.fraction);
  final String label;
  final double fraction;
}

const _months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _esc(String v) {
  if (v.contains(',') || v.contains('"') || v.contains('\n')) return '"${v.replaceAll('"', '""')}"';
  return v;
}
