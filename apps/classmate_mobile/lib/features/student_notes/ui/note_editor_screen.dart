// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data/notes_api.dart';

/// Apple-Notes-style editor: a big borderless title field over a borderless
/// body field. Saves on back (autosave) and on the check button; renaming IS
/// editing the title. Read-only when the viewer can't edit someone else's
/// note (non-author teacher).
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.studentId, this.note});

  final String studentId;

  /// Null = new note (created on first save).
  final StudentNote? note;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleCtl;
  late final TextEditingController _bodyCtl;
  String? _noteId;
  bool _saving = false;

  bool get _canEdit => widget.note?.canEdit ?? true;

  @override
  void initState() {
    super.initState();
    _noteId = widget.note?.id;
    _titleCtl = TextEditingController(text: widget.note?.title ?? '');
    _bodyCtl = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _titleCtl.text != (widget.note?.title ?? '') ||
      _bodyCtl.text != (widget.note?.body ?? '');

  bool get _empty =>
      _titleCtl.text.trim().isEmpty && _bodyCtl.text.trim().isEmpty;

  Future<bool> _save() async {
    if (!_canEdit || _saving) return true;
    // Nothing typed on a brand-new note → don't create an empty note.
    if (_noteId == null && _empty) return true;
    if (_noteId != null && !_dirty) return true;
    setState(() => _saving = true);
    try {
      final api = ref.read(notesApiProvider);
      if (_noteId == null) {
        _noteId = await api.createNote(
          widget.studentId,
          title: _titleCtl.text,
          body: _bodyCtl.text,
        );
      } else {
        await api.updateNote(_noteId!,
            title: _titleCtl.text, body: _bodyCtl.text);
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteNote() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.notesDeleteTitle),
        content: Text(l.notesDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      if (_noteId != null) {
        await ref.read(notesApiProvider).deleteNote(_noteId!);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final saved = await _save();
        if (saved && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (_canEdit && _noteId != null)
              IconButton(
                tooltip: l.commonDelete,
                onPressed: _deleteNote,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            if (_canEdit)
              IconButton(
                tooltip: l.commonSave,
                onPressed: _saving
                    ? null
                    : () async {
                        final saved = await _save();
                        if (saved && mounted) Navigator.of(context).pop();
                      },
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: TextField(
                  controller: _titleCtl,
                  readOnly: !_canEdit,
                  textInputAction: TextInputAction.next,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    hintText: l.notesTitleHint,
                    border: InputBorder.none,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: TextField(
                    controller: _bodyCtl,
                    readOnly: !_canEdit,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: _canEdit ? l.notesBodyHint : null,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
