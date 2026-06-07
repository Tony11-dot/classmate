// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/admin_repository.dart';

/// Bulk user import — two ways that feed the SAME editable grid:
///  • Grid: fill rows in-app (all 5 roles, link students to a parent username).
///  • CSV: upload a file (headers in any language) → load the parsed rows INTO
///    the grid → review & fix any mis-reads → create.
class AdminImportUsersScreen extends ConsumerStatefulWidget {
  const AdminImportUsersScreen({super.key});

  @override
  ConsumerState<AdminImportUsersScreen> createState() => _AdminImportUsersScreenState();
}

const _validRoles = {'STUDENT', 'TEACHER', 'PARENT', 'SECRETARY', 'ADMIN'};
const _roleItems = <LiquidGlassDropdownItem<String>>[
  LiquidGlassDropdownItem(value: 'STUDENT', label: 'Student'),
  LiquidGlassDropdownItem(value: 'TEACHER', label: 'Teacher'),
  LiquidGlassDropdownItem(value: 'PARENT', label: 'Parent'),
  LiquidGlassDropdownItem(value: 'SECRETARY', label: 'Secretary'),
  LiquidGlassDropdownItem(value: 'ADMIN', label: 'Admin'),
];

class _GridRow {
  String role = 'STUDENT';
  final name = TextEditingController();
  final username = TextEditingController();
  final grade = TextEditingController();
  final parent = TextEditingController();
  List<String>? childUsernames; // carried through from CSV (parent rows)

  _GridRow();

  factory _GridRow.fromPreview(Map<String, dynamic> m) {
    final r = _GridRow();
    final role = '${m['role'] ?? 'STUDENT'}'.toUpperCase();
    r.role = _validRoles.contains(role) ? role : 'STUDENT';
    r.name.text = '${m['name'] ?? m['nameEn'] ?? ''}';
    r.username.text = '${m['username'] ?? ''}';
    final g = m['grade'];
    r.grade.text = g == null ? '' : '$g';
    r.parent.text = '${m['parentUsername'] ?? ''}';
    final cu = m['childUsernames'];
    if (cu is List && cu.isNotEmpty) r.childUsernames = cu.map((e) => '$e').toList();
    return r;
  }

  void dispose() { name.dispose(); username.dispose(); grade.dispose(); parent.dispose(); }

  Map<String, dynamic>? toDto() {
    final n = name.text.trim();
    if (n.isEmpty) return null;
    final dto = <String, dynamic>{'role': role, 'name': n};
    final u = username.text.trim();
    if (u.isNotEmpty) dto['username'] = u;
    if (role == 'STUDENT') {
      final g = int.tryParse(grade.text.trim());
      if (g != null) dto['grade'] = g;
      final p = parent.text.trim();
      if (p.isNotEmpty) dto['parentUsername'] = p;
    }
    if (childUsernames != null && childUsernames!.isNotEmpty) dto['childUsernames'] = childUsernames;
    return dto;
  }
}

class _AdminImportUsersScreenState extends ConsumerState<AdminImportUsersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final List<_GridRow> _rows = [for (var i = 0; i < 4; i++) _GridRow()];
  bool _saving = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _tabs.dispose();
    for (final r in _rows) { r.dispose(); }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_GridRow()));
  void _removeRow(int i) => setState(() => _rows.removeAt(i).dispose());

  /// Replace the grid with parsed CSV rows and jump to the Grid tab for review.
  void _loadFromPreview(List<dynamic> preview) {
    for (final r in _rows) { r.dispose(); }
    setState(() {
      _rows
        ..clear()
        ..addAll(preview.map((e) => _GridRow.fromPreview(Map<String, dynamic>.from(e as Map))));
      if (_rows.isEmpty) _rows.add(_GridRow());
      _result = null;
    });
    _tabs.animateTo(0);
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.adminImportUsersScreenLoadedRows(preview.length))),
    );
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    final dtos = _rows.map((r) => r.toDto()).whereType<Map<String, dynamic>>().toList();
    if (dtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminImportUsersScreenFillAtLeastOneName)));
      return;
    }
    setState(() { _saving = true; _result = null; });
    try {
      final r = await ref.read(adminRepositoryProvider).bulkCreateUsers(dtos);
      setState(() => _result = r);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminImportUsersScreenFailed('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminImportUsersScreenTitle),
        bottom: TabBar(controller: _tabs, tabs: [
          Tab(icon: const Icon(Icons.grid_on_rounded), text: l.adminImportUsersScreenTabGrid),
          Tab(icon: const Icon(Icons.upload_file_rounded), text: l.adminImportUsersScreenTabCsv),
        ]),
      ),
      body: TabBarView(controller: _tabs, children: [
        _grid(context),
        _CsvTab(onLoadToGrid: _loadFromPreview),
      ]),
    );
  }

  Widget _grid(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    if (_result != null) {
      return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), children: [
        _resultView(context, _result!),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: () => setState(() => _result = null), child: Text(l.adminImportUsersScreenBackToGrid)),
      ]);
    }
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Text(
          l.adminImportUsersScreenGridIntro,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          itemCount: _rows.length,
          itemBuilder: (context, i) => _rowCard(i, cs),
        ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saving ? null : _addRow,
                icon: const Icon(Icons.add_rounded),
                label: Text(l.adminImportUsersScreenAddRow),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_rounded),
                label: Text(l.adminImportUsersScreenCreateCount(_rows.where((r) => r.name.text.trim().isNotEmpty).length)),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _rowCard(int i, ColorScheme cs) {
    final l = AppLocalizations.of(context)!;
    final row = _rows[i];
    final isStudent = row.role == 'STUDENT';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: LiquidGlassDropdown<String>(
                label: l.adminImportUsersScreenRole,
                value: row.role,
                items: _roleItems,
                onChanged: (v) => setState(() => row.role = v),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
              onPressed: _rows.length <= 1 ? null : () => _removeRow(i),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: row.name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l.adminImportUsersScreenFullName, isDense: true, border: const OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: row.username,
            decoration: InputDecoration(
                labelText: l.adminImportUsersScreenUsername, hintText: l.adminImportUsersScreenUsernameHint, isDense: true, border: const OutlineInputBorder()),
          ),
          if (isStudent) ...[
            const SizedBox(height: 8),
            Row(children: [
              SizedBox(
                width: 90,
                child: TextField(
                  controller: row.grade,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l.adminImportUsersScreenGrade, isDense: true, border: const OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.parent,
                  decoration: InputDecoration(
                      labelText: l.adminImportUsersScreenParentUsername, hintText: l.adminImportUsersScreenParentUsernameHint, isDense: true, border: const OutlineInputBorder()),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}

// ── CSV tab ──────────────────────────────────────────────────────────────────

class _CsvTab extends ConsumerStatefulWidget {
  const _CsvTab({required this.onLoadToGrid});
  final void Function(List<dynamic> preview) onLoadToGrid;
  @override
  ConsumerState<_CsvTab> createState() => _CsvTabState();
}

class _CsvTabState extends ConsumerState<_CsvTab> {
  String? _fileName;
  String? _filePath;
  bool _loading = false;
  Map<String, dynamic>? _preview;
  String? _error;

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['csv'], allowMultiple: false,
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    if (f.path == null) { setState(() => _error = AppLocalizations.of(context)!.adminImportUsersScreenCouldNotReadFile); return; }
    setState(() { _fileName = f.name; _filePath = f.path; _preview = null; _error = null; });
    await _runPreview();
  }

  Future<void> _runPreview() async {
    if (_filePath == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ref.read(adminRepositoryProvider).importCsv(_filePath!, dryRun: true);
      setState(() => _preview = r);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Text(
          l.adminImportUsersScreenCsvIntro,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        _hintCard(cs),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _pick,
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(_fileName == null ? l.adminImportUsersScreenChooseCsv : l.adminImportUsersScreenChooseDifferentFile),
        ),
        if (_fileName != null) ...[
          const SizedBox(height: 8),
          Text(l.adminImportUsersScreenSelectedFile(_fileName!), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ],
        if (_loading) ...[const SizedBox(height: 28), const Center(child: CircularProgressIndicator())],
        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(12)),
            child: Text(_error!, style: TextStyle(color: cs.onErrorContainer)),
          ),
        ],
        if (_preview != null) _previewBlock(cs),
      ],
    );
  }

  Widget _hintCard(ColorScheme cs) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.adminImportUsersScreenRecognisedColumns, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          l.adminImportUsersScreenRecognisedColumnsBody,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, height: 1.45),
        ),
      ]),
    );
  }

  Widget _previewBlock(ColorScheme cs) {
    final l = AppLocalizations.of(context)!;
    final p = _preview!;
    final fields = (p['detectedFields'] as List?)?.map((e) => '$e').toList() ?? const [];
    final rows = (p['preview'] as List?) ?? const [];
    final count = p['rowCount'] ?? rows.length;
    final truncated = p['truncated'] == true;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 22),
      Text(l.adminImportUsersScreenDetectedRows(count is int ? count : int.tryParse('$count') ?? rows.length), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final f in fields) Chip(label: Text(f), visualDensity: VisualDensity.compact),
      ]),
      if (fields.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(l.adminImportUsersScreenNoColumnsDetected, style: TextStyle(color: cs.error)),
        ),
      if (truncated)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(l.adminImportUsersScreenTruncatedNotice, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: (rows.isEmpty || fields.isEmpty) ? null : () => widget.onLoadToGrid(rows),
          icon: const Icon(Icons.edit_note_rounded),
          label: Text(l.adminImportUsersScreenReviewEditInGrid),
        ),
      ),
      const SizedBox(height: 6),
      Text(l.adminImportUsersScreenReviewEditHint,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11.5)),
    ]);
  }
}

// ── Shared result view ───────────────────────────────────────────────────────

Widget _resultView(BuildContext context, Map<String, dynamic> r) {
  final l = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;
  final created = (r['created'] as List?) ?? const [];
  final createdCount = r['createdCount'] ?? created.length;
  final failed = r['failedCount'] ?? 0;
  final links = r['linksCreated'] ?? 0;
  final errors = (r['errors'] as List?) ?? const [];
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 12),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Text(
        l.adminImportUsersScreenResultSummary(
          createdCount is int ? createdCount : int.tryParse('$createdCount') ?? 0,
          links is int ? links : int.tryParse('$links') ?? 0,
        ) + (failed != 0 ? l.adminImportUsersScreenResultFailedSuffix(failed is int ? failed : int.tryParse('$failed') ?? 0) : ''),
        style: TextStyle(fontWeight: FontWeight.w700, color: cs.onPrimaryContainer),
      ),
    ),
    if (errors.isNotEmpty) ...[
      const SizedBox(height: 12),
      Text(l.adminImportUsersScreenFailedRows, style: TextStyle(fontWeight: FontWeight.w700, color: cs.error)),
      const SizedBox(height: 4),
      ...errors.take(25).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return Text(l.adminImportUsersScreenFailedRow('${m['row']}', '${m['reason']}'), style: TextStyle(color: cs.error, fontSize: 12));
      }),
    ],
    if (created.isNotEmpty) ...[
      const SizedBox(height: 16),
      Text(l.adminImportUsersScreenCredentialsTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      ...created.map((c) {
        final m = Map<String, dynamic>.from(c as Map);
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Expanded(child: Text('${m['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600))),
            SelectableText('${m['username']}  ·  ${m['tempPassword']}',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ]),
        );
      }),
    ],
  ]);
}
