// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/admin_repository.dart';

/// Bulk user import — two ways:
///  • Grid: fill rows in-app (all 5 roles, link students to a parent username).
///  • CSV: upload a file whose headers may be in any of our five languages.
class AdminImportUsersScreen extends StatelessWidget {
  const AdminImportUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Import users'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.grid_on_rounded), text: 'Grid'),
            Tab(icon: Icon(Icons.upload_file_rounded), text: 'CSV'),
          ]),
        ),
        body: const TabBarView(children: [_GridTab(), _CsvTab()]),
      ),
    );
  }
}

const _roleItems = <LiquidGlassDropdownItem<String>>[
  LiquidGlassDropdownItem(value: 'STUDENT', label: 'Student'),
  LiquidGlassDropdownItem(value: 'TEACHER', label: 'Teacher'),
  LiquidGlassDropdownItem(value: 'PARENT', label: 'Parent'),
  LiquidGlassDropdownItem(value: 'SECRETARY', label: 'Secretary'),
  LiquidGlassDropdownItem(value: 'ADMIN', label: 'Admin'),
];

// ── Grid tab ─────────────────────────────────────────────────────────────────

class _GridRow {
  String role = 'STUDENT';
  final name = TextEditingController();
  final username = TextEditingController();
  final grade = TextEditingController();
  final parent = TextEditingController();

  void dispose() { name.dispose(); username.dispose(); grade.dispose(); parent.dispose(); }

  Map<String, dynamic>? toDto() {
    final n = name.text.trim();
    if (n.isEmpty) return null; // blank row → skip
    final dto = <String, dynamic>{'role': role, 'name': n};
    final u = username.text.trim();
    if (u.isNotEmpty) dto['username'] = u;
    if (role == 'STUDENT') {
      final g = int.tryParse(grade.text.trim());
      if (g != null) dto['grade'] = g;
      final p = parent.text.trim();
      if (p.isNotEmpty) dto['parentUsername'] = p;
    }
    return dto;
  }
}

class _GridTab extends ConsumerStatefulWidget {
  const _GridTab();
  @override
  ConsumerState<_GridTab> createState() => _GridTabState();
}

class _GridTabState extends ConsumerState<_GridTab> {
  final List<_GridRow> _rows = [for (var i = 0; i < 4; i++) _GridRow()];
  bool _saving = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    for (final r in _rows) { r.dispose(); }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_GridRow()));
  void _removeRow(int i) => setState(() => _rows.removeAt(i).dispose());

  Future<void> _submit() async {
    final dtos = _rows.map((r) => r.toDto()).whereType<Map<String, dynamic>>().toList();
    if (dtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill at least one name')));
      return;
    }
    setState(() { _saving = true; _result = null; });
    try {
      final r = await ref.read(adminRepositoryProvider).bulkCreateUsers(dtos);
      setState(() => _result = r);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_result != null) {
      return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), children: [
        _resultView(context, _result!),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: () => setState(() => _result = null), child: const Text('Back to grid')),
      ]);
    }
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Text(
          'Fill a row per person. Username is optional — we generate one if left blank. '
          'For a student, set the grade and (optionally) a parent\'s username to link them.',
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
                label: const Text('Add row'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_rounded),
                label: const Text('Create users'),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _rowCard(int i, ColorScheme cs) {
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
                label: 'Role',
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
            decoration: const InputDecoration(labelText: 'Full name *', isDense: true, border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: row.username,
            decoration: const InputDecoration(
                labelText: 'Username', hintText: '(auto if blank)', isDense: true, border: OutlineInputBorder()),
          ),
          if (isStudent) ...[
            const SizedBox(height: 8),
            Row(children: [
              SizedBox(
                width: 90,
                child: TextField(
                  controller: row.grade,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Grade', isDense: true, border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.parent,
                  decoration: const InputDecoration(
                      labelText: 'Parent username', hintText: 'link (optional)', isDense: true, border: OutlineInputBorder()),
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
  const _CsvTab();
  @override
  ConsumerState<_CsvTab> createState() => _CsvTabState();
}

class _CsvTabState extends ConsumerState<_CsvTab> {
  String? _fileName;
  String? _filePath;
  bool _loading = false;
  Map<String, dynamic>? _preview;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['csv'], allowMultiple: false,
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    if (f.path == null) { setState(() => _error = 'Could not read that file.'); return; }
    setState(() { _fileName = f.name; _filePath = f.path; _preview = null; _result = null; _error = null; });
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

  Future<void> _commit() async {
    if (_filePath == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ref.read(adminRepositoryProvider).importCsv(_filePath!, dryRun: false);
      setState(() => _result = r);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Text(
          'Upload a CSV of your users. Column headers can be in any language — '
          'ClassMate detects what each column means automatically.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        _hintCard(cs),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _pick,
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(_fileName == null ? 'Choose CSV file' : 'Choose a different file'),
        ),
        if (_fileName != null) ...[
          const SizedBox(height: 8),
          Text('Selected: $_fileName', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
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
        if (_preview != null && _result == null) _previewBlock(cs),
        if (_result != null) _resultView(context, _result!),
      ],
    );
  }

  Widget _hintCard(ColorScheme cs) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Recognised columns', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(
        'name · username · password · email · phone · role · grade · '
        'parent (a username) · children (usernames)\n\n'
        'Role words like "student / طالب / תלמיד / élève / ученик" all map correctly. '
        'Grade reads the number from "Grade 10", "الصف 10", "כיתה 10". '
        'Missing usernames or passwords are generated automatically.',
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, height: 1.45),
      ),
    ]),
  );

  Widget _previewBlock(ColorScheme cs) {
    final p = _preview!;
    final fields = (p['detectedFields'] as List?)?.map((e) => '$e').toList() ?? const [];
    final rows = (p['preview'] as List?) ?? const [];
    final count = p['rowCount'] ?? rows.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 22),
      Text('Preview — $count rows', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final f in fields) Chip(label: Text(f), visualDensity: VisualDensity.compact),
      ]),
      if (fields.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('No known columns detected — check your header row.', style: TextStyle(color: cs.error)),
        ),
      const SizedBox(height: 12),
      ...rows.take(15).map((r) {
        final m = Map<String, dynamic>.from(r as Map);
        final name = m['name'] ?? m['nameEn'] ?? '—';
        final role = m['role'] ?? '?';
        final uname = m['username'] ?? '(auto)';
        final grade = m['grade'];
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Expanded(child: Text('$name', style: const TextStyle(fontWeight: FontWeight.w600))),
            Text('$role${grade != null ? ' · G$grade' : ''} · $uname',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ]),
        );
      }),
      if (rows.length > 15)
        Text('…and ${rows.length - 15} more', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: (_loading || fields.isEmpty) ? null : _commit,
          icon: const Icon(Icons.check_rounded),
          label: Text('Import $count users'),
        ),
      ),
    ]);
  }
}

// ── Shared result view ───────────────────────────────────────────────────────

Widget _resultView(BuildContext context, Map<String, dynamic> r) {
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
        '✓ Created $createdCount users · $links links${failed != 0 ? ' · $failed failed' : ''}',
        style: TextStyle(fontWeight: FontWeight.w700, color: cs.onPrimaryContainer),
      ),
    ),
    if (errors.isNotEmpty) ...[
      const SizedBox(height: 12),
      Text('Failed rows', style: TextStyle(fontWeight: FontWeight.w700, color: cs.error)),
      const SizedBox(height: 4),
      ...errors.take(25).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return Text('Row ${m['row']}: ${m['reason']}', style: TextStyle(color: cs.error, fontSize: 12));
      }),
    ],
    if (created.isNotEmpty) ...[
      const SizedBox(height: 16),
      const Text('Credentials (hand these to your users)', style: TextStyle(fontWeight: FontWeight.w800)),
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
