// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/notes_api.dart';
import 'note_editor_screen.dart';

/// One student's notes — Apple-Notes-style list: title, one-line preview,
/// last-edited date and author. Swipe a row (or use its menu) to delete.
class StudentNotesScreen extends ConsumerWidget {
  const StudentNotesScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  final String studentId;
  final String studentName;

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    StudentNote? note,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => NoteEditorScreen(studentId: studentId, note: note),
      ),
    );
    ref.invalidate(studentNotesProvider(studentId));
  }

  Future<bool> _confirmDelete(BuildContext context) async {
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
    return ok == true;
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, StudentNote note) async {
    try {
      await ref.read(notesApiProvider).deleteNote(note.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    ref.invalidate(studentNotesProvider(studentId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final page = ref.watch(studentNotesProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(studentName,
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.edit_note_rounded),
        label: Text(l.notesNewNote),
      ),
      body: SafeArea(
        child: page.when(
          loading: () => const Center(child: CmLoading()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(e.toString(), textAlign: TextAlign.center),
            ),
          ),
          data: (data) {
            if (data.notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sticky_note_2_outlined,
                        size: 56, color: cs.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(l.notesNoNotes,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        l.notesNoNotesHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(studentNotesProvider(studentId));
                await ref.read(studentNotesProvider(studentId).future);
              },
              child: ListView.builder(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
                itemCount: data.notes.length,
                itemBuilder: (ctx, i) {
                  final note = data.notes[i];
                  final row = _NoteRow(
                    note: note,
                    onTap: () => _openEditor(context, ref, note: note),
                  );
                  if (!note.canEdit) return row;
                  return Dismissible(
                    key: ValueKey(note.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(context),
                    onDismissed: (_) => _delete(context, ref, note),
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.delete_rounded,
                          color: cs.onErrorContainer),
                    ),
                    child: row,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note, required this.onTap});

  final StudentNote note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final title = note.title.trim().isEmpty ? l.notesUntitled : note.title;
    final preview = note.body.replaceAll('\n', ' ').trim();
    final date = DateFormat.MMMd().add_jm().format(note.updatedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  note.authorName.isEmpty
                      ? date
                      : '$date · ${l.notesEditedBy(note.authorName)}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
