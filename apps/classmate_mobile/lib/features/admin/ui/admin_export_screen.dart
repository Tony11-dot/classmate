// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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

class _AdminExportScreenState extends ConsumerState<AdminExportScreen> {
  // Mode
  bool _byCohort = false;

  // Selection
  final Set<String> _selectedStudentIds = {};
  final Set<String> _selectedCohortIds  = {};
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
      if (mounted) setState(() {
        _students = students;
        _cohorts  = cohorts;
        _loading  = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Returns the effective list of selected student IDs (combining direct + cohort selections)
  List<String> get _effectiveStudentIds {
    final ids = <String>{..._selectedStudentIds};
    if (_byCohort) {
      for (final cid in _selectedCohortIds) {
        for (final s in _students) {
          // match by cohortId or cohortName
          final cohort = _cohorts.firstWhere((c) => c['id']?.toString() == cid, orElse: () => const {});
          final cohortName = cohort['name']?.toString() ?? '';
          if ((s['cohortName']?.toString() ?? '') == cohortName) {
            ids.add(s['id']?.toString() ?? '');
          }
        }
      }
    }
    return ids.where((id) => id.isNotEmpty).toList();
  }

  int get _selectedCount => _byCohort ? _effectiveStudentIds.length : _selectedStudentIds.length;

  void _toggleStudent(String id) => setState(() =>
    _selectedStudentIds.contains(id) ? _selectedStudentIds.remove(id) : _selectedStudentIds.add(id));

  void _toggleCohort(String id) => setState(() =>
    _selectedCohortIds.contains(id) ? _selectedCohortIds.remove(id) : _selectedCohortIds.add(id));

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
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Select Students'), icon: Icon(Icons.person_rounded, size: 16)),
                  ButtonSegment(value: true,  label: Text('Select Cohorts'),  icon: Icon(Icons.groups_rounded,  size: 16)),
                ],
                selected: {_byCohort},
                onSelectionChanged: (s) => setState(() { _byCohort = s.first; _selectedStudentIds.clear(); _selectedCohortIds.clear(); }),
              ),
            ),

            // Search
            if (!_byCohort)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search students…',
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
                  : _byCohort
                      ? _CohortPickerList(
                          cohorts: _cohorts,
                          students: _students,
                          selectedCohortIds: _selectedCohortIds,
                          expandedCohortIds: _expandedCohortIds,
                          onToggleCohort: _toggleCohort,
                          onToggleExpand: _toggleExpandCohort,
                        )
                      : _StudentPickerList(
                          students: _students.where((s) {
                            if (q.isEmpty) return true;
                            return (s['name']?.toString() ?? '').toLowerCase().contains(q);
                          }).toList(),
                          selectedIds: _selectedStudentIds,
                          onToggle: _toggleStudent,
                        ),
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

        // Students of this cohort
        final cohortStudents = students.where((s) => (s['cohortName']?.toString() ?? '') == name).toList();

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

  Future<bool> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Reset passwords?'),
        content: Text(
          'This will generate new temporary passwords for all ${widget.studentCount} selected students '
          'and include them in the export. Their existing passwords will be reset immediately.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(d, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(d).colorScheme.error),
            child: const Text('Reset & Export'),
          ),
        ],
      ),
    );
    return confirm == true;
  }

  Future<List<Map<String, dynamic>>> _fetch() =>
      widget.repo.exportStudents(studentIds: widget.selectedStudentIds, generatePasswords: _includePasswords);

  // ── CSV ────────────────────────────────────────────────────────────────────

  Future<void> _exportCsv() async {
    if (_includePasswords && !await _confirmReset()) return;
    setState(() => _exporting = true);
    try {
      final students = await _fetch();
      if (!mounted) return;

      final headers = ['Name (EN)', 'Name (AR)', 'Name (HE)', 'Name (FR)', 'Name (RU)', 'Email', 'Username', 'Grade', 'Cohort'];
      if (_includePasswords) headers.add('Password');
      final buf = StringBuffer()..writeln(headers.join(','));
      for (final s in students) {
        final row = [
          _esc(s['nameEn']?.toString() ?? ''),
          _esc(s['nameAr']?.toString() ?? ''),
          _esc(s['nameHe']?.toString() ?? ''),
          _esc(s['nameFr']?.toString() ?? ''),
          _esc(s['nameRu']?.toString() ?? ''),
          _esc(s['email']?.toString() ?? ''),
          _esc(s['username']?.toString() ?? ''),
          s['grade']?.toString() ?? '',
          _esc(s['cohortName']?.toString() ?? ''),
          if (_includePasswords) _esc(s['tempPassword']?.toString() ?? ''),
        ];
        buf.writeln(row.join(','));
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/students_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buf.toString());
      if (!mounted) return;
      Navigator.pop(context);
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')], subject: 'ClassMate Students');
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
      Navigator.pop(context);
      await Printing.sharePdf(bytes: bytes, filename: 'classmate_students.pdf');
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
    final doc = pw.Document();
    final now = DateTime.now();
    final dateStr = '${_months[now.month]} ${now.day}, ${now.year}';

    const brandBlue    = PdfColor.fromInt(0xFF2563EB);
    const brandLight   = PdfColor.fromInt(0xFFEFF6FF);
    const headerBg     = PdfColor.fromInt(0xFF1E3A5F);
    const rowAlt       = PdfColor.fromInt(0xFFF8FAFD);
    const pwColor      = PdfColor.fromInt(0xFF7C3AED);

    final cols = withPasswords
        ? [_Col('#', 0.04), _Col('Name EN', 0.17), _Col('Email', 0.18), _Col('Username', 0.13), _Col('Grade', 0.06), _Col('Cohort', 0.13), _Col('Password', 0.14), _Col('AR', 0.08), _Col('HE', 0.07)]
        : [_Col('#', 0.04), _Col('Name EN', 0.22), _Col('Email', 0.22), _Col('Username', 0.14), _Col('Grade', 0.07), _Col('Cohort', 0.15), _Col('AR', 0.08), _Col('HE', 0.08)];

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
                decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(10)),
                alignment: pw.Alignment.center,
                child: pw.Text('C', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: brandBlue)),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('ClassMate', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                if (schoolName.isNotEmpty) pw.Text(schoolName, style: const pw.TextStyle(fontSize: 11, color: const PdfColor(1, 1, 1, 0.7))),
              ])),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('Student Directory', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10, color: const PdfColor(1, 1, 1, 0.7))),
                pw.Text('By: $exportedBy', style: const pw.TextStyle(fontSize: 10, color: const PdfColor(1, 1, 1, 0.7))),
                pw.Text('${students.length} students', style: const pw.TextStyle(fontSize: 10, color: const PdfColor(1, 1, 1, 0.7))),
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
              final cells = withPasswords
                  ? ['${i+1}', s['nameEn']??'', s['email']??'', s['username']??'', '${s['grade']??''}', s['cohortName']??'', s['tempPassword']??'', s['nameAr']??'', s['nameHe']??'']
                  : ['${i+1}', s['nameEn']??'', s['email']??'', s['username']??'', '${s['grade']??''}', s['cohortName']??'', s['nameAr']??'', s['nameHe']??''];
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: i.isOdd ? rowAlt : PdfColors.white),
                children: cells.asMap().entries.map((ce) {
                  final isPw = withPasswords && ce.key == 6;
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

          // Password toggle
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
                    ? 'New passwords generated — all selected students\' passwords will be reset.'
                    : 'Generates new temp passwords and resets them.',
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
