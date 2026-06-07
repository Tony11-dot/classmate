// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data/class_materials_repository.dart';
import 'class_material_pill.dart';

/// Collaborative "class materials" block embedded in a period detail sheet.
/// Every participant (students AND teachers) can see what classmates shared
/// for this period and add their own photos/files with an optional caption.
class ClassMaterialsSection extends ConsumerStatefulWidget {
  const ClassMaterialsSection({
    super.key,
    required this.slotId,
    this.date = '',
  });

  final String slotId;
  final String date;

  @override
  ConsumerState<ClassMaterialsSection> createState() => _ClassMaterialsSectionState();
}

class _ClassMaterialsSectionState extends ConsumerState<ClassMaterialsSection> {
  late Future<List<ClassMaterial>> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ClassMaterial>> _load() {
    return ref.read(classMaterialsRepositoryProvider).listForSlot(widget.slotId);
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  String? _guessMime(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    const map = {
      'pdf': 'application/pdf',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'webp': 'image/webp',
      'gif': 'image/gif',
      'heic': 'image/heic',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
      'zip': 'application/zip',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
    };
    return map[ext];
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context)!;
    PlatformFile file;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withReadStream: false,
      );
      if (result == null || result.files.isEmpty) return;
      file = result.files.first;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherFilePickError(e.toString()))),
      );
      return;
    }

    final path = file.path;
    if (path == null || path.isEmpty) return;

    if (!mounted) return;
    final caption = await _askCaption(file.name);
    if (caption == null) return; // cancelled

    setState(() => _busy = true);
    try {
      await ref.read(classMaterialsRepositoryProvider).add(
            slotId: widget.slotId,
            filePath: path,
            mimeType: _guessMime(file.name),
            caption: caption,
            date: widget.date,
          );
      if (!mounted) return;
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Returns the caption (possibly empty) on confirm, or null on cancel.
  Future<String?> _askCaption(String fileName) {
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(l.classMaterialsCaption),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l.classMaterialsCaptionHint,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: Text(l.classMaterialsShare),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete(ClassMaterial m) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.classMaterialsRemoveTitle),
        content: Text(l.classMaterialsRemoveBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(classMaterialsRepositoryProvider).remove(m.id);
      if (mounted) _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.collections_bookmark_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              l.classMaterialsTitle,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            const Spacer(),
            if (_busy)
              const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l.commonAdd),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<ClassMaterial>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            if (snap.hasError) {
              return Text(
                l.classMaterialsLoadError,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
              );
            }
            final items = snap.data ?? const <ClassMaterial>[];
            if (items.isEmpty) {
              return Text(
                l.classMaterialsEmpty,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map((m) => ClassMaterialPill(
                        material: m,
                        onDelete: m.canDelete ? () => _delete(m) : null,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
