import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/cm_loading.dart';
import '../../bagrut/data/bagrut_api.dart';
import '../../bagrut/domain/bagrut_models.dart';
import '../../bagrut/domain/bagrut_subjects.dart';

/// One file slot (per kind) — either an already-uploaded file or a freshly
/// picked one waiting to be uploaded on save.
class _FileSlot {
  String? existingUrl; // absolute (from the loaded exam)
  String? existingMime;
  String? existingName;
  int? existingSize;

  List<int>? pickedBytes;
  String? pickedName;

  bool get hasFile => pickedBytes != null || (existingUrl != null && existingUrl!.isNotEmpty);
  String? get displayName => pickedName ?? existingName;
}

class ManagerExamFormScreen extends ConsumerStatefulWidget {
  const ManagerExamFormScreen({super.key, required this.subjectKey, this.existing});

  final String subjectKey;
  final BagrutExam? existing;

  @override
  ConsumerState<ManagerExamFormScreen> createState() => _ManagerExamFormScreenState();
}

class _ManagerExamFormScreenState extends ConsumerState<ManagerExamFormScreen> {
  final _title = TextEditingController();
  final _year = TextEditingController();
  final _term = TextEditingController();
  final Map<String, _FileSlot> _slots = {
    for (final k in BagrutFileKind.all) k: _FileSlot(),
  };
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      _year.text = e.year.toString();
      _term.text = e.term;
      for (final f in e.files) {
        final slot = _slots[f.kind];
        if (slot != null) {
          slot.existingUrl = f.url;
          slot.existingMime = f.mimeType;
          slot.existingName = f.fileName;
          slot.existingSize = f.fileSize;
        }
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _year.dispose();
    _term.dispose();
    super.dispose();
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  String _kindLabel(String k) {
    switch (k) {
      case BagrutFileKind.questions:
        return 'Questions';
      case BagrutFileKind.answers:
        return 'Answers';
      case BagrutFileKind.solution:
        return 'Solution';
      case BagrutFileKind.advanced:
        return 'Full solution (פתרון מלא)';
      default:
        return k;
    }
  }

  Future<void> _pick(String kind) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    final f = (res != null && res.files.isNotEmpty) ? res.files.first : null;
    if (f == null || f.bytes == null) return;
    setState(() {
      final slot = _slots[kind]!;
      slot.pickedBytes = f.bytes;
      slot.pickedName = f.name;
    });
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    final year = int.tryParse(_year.text.trim());
    if (title.isEmpty) return _snack('Title is required.');
    if (year == null) return _snack('A valid year is required.');
    final hasAny = _slots.values.any((s) => s.hasFile);
    if (!hasAny) return _snack('Attach at least one file.');

    setState(() => _submitting = true);
    try {
      final api = ref.read(bagrutApiProvider);
      final files = <Map<String, dynamic>>[];
      for (final kind in BagrutFileKind.all) {
        final slot = _slots[kind]!;
        if (slot.pickedBytes != null) {
          final up = await api.uploadFileBytes(slot.pickedBytes!, slot.pickedName ?? 'file');
          files.add({
            'kind': kind,
            'url': up['url'],
            'mimeType': up['mimeType'],
            'fileName': up['fileName'],
            'fileSize': up['fileSize'],
          });
        } else if (slot.existingUrl != null && slot.existingUrl!.isNotEmpty) {
          files.add({
            'kind': kind,
            'url': slot.existingUrl,
            'mimeType': slot.existingMime,
            'fileName': slot.existingName,
            'fileSize': slot.existingSize,
          });
        }
      }

      if (widget.existing != null) {
        await api.updateExam(
          id: widget.existing!.id,
          subject: widget.subjectKey,
          year: year,
          term: _term.text.trim(),
          title: title,
          files: files,
        );
      } else {
        await api.createExam(
          subject: widget.subjectKey,
          year: year,
          term: _term.text.trim(),
          title: title,
          files: files,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final subjectTitle = bagrutSubjectTitle(widget.subjectKey, locale);
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'New exam · $subjectTitle' : 'Edit exam')),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title *', helperText: 'e.g. 2019 Summer · Moed A'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Year *'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _term,
                    decoration: const InputDecoration(labelText: 'Term', helperText: 'summer_a, winter…'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Files', style: TextStyle(fontWeight: FontWeight.w800)),
            const Text('Questions is the main file; the rest are optional.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            for (final kind in BagrutFileKind.all) _fileRow(kind),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CmLoading(size: 20, color: Colors.white))
                  : Text(widget.existing == null ? 'Create exam' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileRow(String kind) {
    final slot = _slots[kind]!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(slot.hasFile ? Icons.check_circle_rounded : Icons.upload_file_rounded,
            color: slot.hasFile ? Colors.green : null),
        title: Text(_kindLabel(kind)),
        subtitle: slot.hasFile ? Text(slot.displayName ?? 'Attached', maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (slot.hasFile)
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () => setState(() {
                  slot.pickedBytes = null;
                  slot.pickedName = null;
                  slot.existingUrl = null;
                }),
              ),
            TextButton(onPressed: () => _pick(kind), child: Text(slot.hasFile ? 'Replace' : 'Pick')),
          ],
        ),
      ),
    );
  }
}
