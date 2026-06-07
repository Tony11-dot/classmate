// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/attachment_pill.dart';
import '../data/class_materials_repository.dart';

/// Materials block embedded in a period detail sheet. Shows the period's
/// materials exactly as before (tappable pills) and lets the viewer ADD their
/// own — pick photos/files, give a title; the subject + audience are inherited
/// from the period. There is no separate page and no FAB; adding happens only
/// from here.
class ClassMaterialsSection extends ConsumerStatefulWidget {
  const ClassMaterialsSection({
    super.key,
    required this.slotId,
    this.date = '',
    this.initial = const <Map<String, dynamic>>[],
  });

  final String slotId;
  final String date;

  /// Attachments already resolved for the period (from the schedule payload),
  /// shown immediately so there's no flash before the live fetch lands.
  final List<Map<String, dynamic>> initial;

  @override
  ConsumerState<ClassMaterialsSection> createState() => _ClassMaterialsSectionState();
}

class _ClassMaterialsSectionState extends ConsumerState<ClassMaterialsSection> {
  List<SlotMaterial>? _materials;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ref
          .read(classMaterialsRepositoryProvider)
          .listForSlot(widget.slotId, date: widget.date);
      if (mounted) setState(() { _materials = list; _failed = false; });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  String? _guessMime(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    const map = {
      'pdf': 'application/pdf',
      'png': 'image/png', 'jpg': 'image/jpeg', 'jpeg': 'image/jpeg',
      'webp': 'image/webp', 'gif': 'image/gif', 'heic': 'image/heic',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain', 'zip': 'application/zip',
      'mp4': 'video/mp4', 'mp3': 'audio/mpeg',
    };
    return map[ext];
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context)!;
    List<PlatformFile> picked;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return;
      picked = result.files.where((f) => (f.path ?? '').isNotEmpty).toList();
      if (picked.isEmpty) return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherFilePickError(e.toString()))),
      );
      return;
    }

    if (!mounted) return;
    final title = await _askTitle(
      picked.length == 1 ? picked.first.name : l.classMaterialsFilesCount(picked.length),
    );
    if (title == null || title.trim().isEmpty) return; // cancelled / empty

    setState(() => _busy = true);
    try {
      await ref.read(classMaterialsRepositoryProvider).add(
            slotId: widget.slotId,
            title: title.trim(),
            date: widget.date,
            files: picked
                .map((f) => (path: f.path!, mime: _guessMime(f.name), name: f.name))
                .toList(),
          );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Title is required (the file count/name is shown as a hint).
  Future<String?> _askTitle(String fileHint) {
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(l.classMaterialsAddTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fileHint,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l.classMaterialsTitleLabel,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: Text(l.commonCancel)),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: Text(l.commonAdd),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;

    // Pills: prefer the live list once loaded, else the seed from the payload.
    final List<Map<String, dynamic>> pills = _materials != null
        ? _materials!
            .map((m) => <String, dynamic>{'url': m.url, 'name': m.title, 'type': m.pillType})
            .toList()
        : widget.initial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              l.navMaterials,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            const Spacer(),
            if (_busy)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            else
              TextButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l.commonAdd),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (pills.isNotEmpty)
          AttachmentPills(attachments: pills)
        else
          Text(
            _failed ? l.classMaterialsLoadError : l.classMaterialsEmpty,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
      ],
    );
  }
}
