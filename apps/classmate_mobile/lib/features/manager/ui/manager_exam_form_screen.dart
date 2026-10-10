import 'package:classmate_mobile/core/theme/cm_tokens.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/cm_loading.dart';
import '../../../l10n/app_localizations.dart';
import '../../bagrut/data/bagrut_api.dart';
import '../../bagrut/domain/bagrut_models.dart';
import '../../bagrut/domain/bagrut_subjects.dart';

import '../../../ui/widgets/cm_sub_bar.dart';
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

  String _kindLabel(AppLocalizations l, String k) {
    switch (k) {
      case BagrutFileKind.questions:
        return l.bagrutFileQuestions;
      case BagrutFileKind.answers:
        return l.bagrutFileAnswers;
      case BagrutFileKind.solution:
        return l.bagrutFileSolution;
      case BagrutFileKind.advanced:
        return l.bagrutFileAdvanced;
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
    final l = AppLocalizations.of(context)!;
    final title = _title.text.trim();
    final year = int.tryParse(_year.text.trim());
    if (title.isEmpty) return _snack(l.commonTitleRequired);
    if (year == null) return _snack(l.managerYearRequired);
    final hasAny = _slots.values.any((s) => s.hasFile);
    if (!hasAny) return _snack(l.managerAttachOneFile);

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
            // Persist the relative /uploads path, not the resolved absolute URL.
            'url': api.relativizeUrl(slot.existingUrl!),
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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CmSubBar(
        title: widget.existing == null ? '${l.managerNewExam} · $subjectTitle' : l.managerEditExam,
      ),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: '${l.commonTitle} *', helperText: l.managerExamTitleHelper),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '${l.managerYear} *'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _term,
                    decoration: InputDecoration(labelText: l.managerTerm, helperText: l.managerTermHelper),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l.commonFiles, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(l.managerFilesHelper,
                style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            for (final kind in BagrutFileKind.all) _fileRow(kind),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CmLoading(size: 20, color: Colors.white))
                  : Text(widget.existing == null ? l.managerCreateExam : l.permissionsSave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileRow(String kind) {
    final slot = _slots[kind]!;
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final good = CmTokens.of(context).good;
    final dark = cs.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(CmTokens.radiusMd),
        border: Border.all(
          color: slot.hasFile ? good.withValues(alpha: 0.45) : cs.outlineVariant.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: slot.hasFile
                ? good.withValues(alpha: dark ? 0.20 : 0.12)
                : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(CmTokens.radiusSm),
          ),
          child: Icon(
            slot.hasFile ? Icons.check_circle_rounded : Icons.upload_file_rounded,
            size: 20,
            color: slot.hasFile ? good : cs.onSurfaceVariant,
          ),
        ),
        title: Text(_kindLabel(l, kind)),
        subtitle: slot.hasFile ? Text(slot.displayName ?? l.managerAttached, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (slot.hasFile)
              IconButton(
                tooltip: l.commonRemove,
                icon: const Icon(Icons.clear_rounded),
                onPressed: () => setState(() {
                  slot.pickedBytes = null;
                  slot.pickedName = null;
                  slot.existingUrl = null;
                }),
              ),
            TextButton(onPressed: () => _pick(kind), child: Text(slot.hasFile ? l.commonReplaceFile : l.commonAttachFile)),
          ],
        ),
      ),
    );
  }
}
