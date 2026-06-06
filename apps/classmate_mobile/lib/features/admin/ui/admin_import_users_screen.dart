// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_repository.dart';

/// Bulk user import from a CSV whose headers may be in any of our five
/// languages. Flow: pick file → server preview (auto-detected columns) →
/// confirm → create. Generated credentials are shown for handoff.
class AdminImportUsersScreen extends ConsumerStatefulWidget {
  const AdminImportUsersScreen({super.key});

  @override
  ConsumerState<AdminImportUsersScreen> createState() => _AdminImportUsersScreenState();
}

class _AdminImportUsersScreenState extends ConsumerState<AdminImportUsersScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Import users')),
      body: ListView(
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
          if (_loading) ...[
            const SizedBox(height: 28),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(12)),
              child: Text(_error!, style: TextStyle(color: cs.onErrorContainer)),
            ),
          ],
          if (_preview != null && _result == null) _previewBlock(cs),
          if (_result != null) _resultBlock(cs),
        ],
      ),
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
          child: Text('No known columns detected — check your header row.',
              style: TextStyle(color: cs.error)),
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

  Widget _resultBlock(ColorScheme cs) {
    final r = _result!;
    final created = (r['created'] as List?) ?? const [];
    final createdCount = r['createdCount'] ?? created.length;
    final failed = r['failedCount'] ?? 0;
    final links = r['linksCreated'] ?? 0;
    final errors = (r['errors'] as List?) ?? const [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 22),
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
}
