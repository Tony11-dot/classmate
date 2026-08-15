import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'classnotes_api.dart';
import 'classnotes_export.dart';
import 'classnotes_models.dart';
import 'classnotes_repository.dart';

/// Managing the ClassNotes library from inside ClassMate: rename a notebook, move
/// it to a shelf, download it as a PDF or PNGs, delete it — plus renaming and
/// deleting the shelves themselves.
///
/// Everything here goes through the same account and endpoints the iPad uses, and
/// a change made here reaches the iPad on its next launch (the server marks it and
/// the app pulls it). Deleting is therefore a real delete, not a hide.
class CnManage {
  /// The action sheet behind a cover's ⋮ button (and a long-press).
  static Future<void> showNotebookActions(
    BuildContext context,
    WidgetRef ref, {
    required CnNotebook notebook,
    required List<CnShelf> shelves,
    required VoidCallback onOpen,
  }) async {
    final origin = CnExport.originOf(context);
    final l = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final cs = Theme.of(sheetCtx).colorScheme;
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    notebook.title.isEmpty ? l.commonUntitled : notebook.title,
                    style: Theme.of(sheetCtx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded),
                  title: Text(l.examsOpenState),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    onOpen();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.drive_file_rename_outline_rounded),
                  title: Text(l.adminRenameCohort),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    await _rename(context, ref, notebook);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shelves),
                  title: Text(l.cnMoveToShelf),
                  subtitle: Text(
                    shelves
                            .where((s) => s.id == notebook.shelfId)
                            .map((s) => s.name)
                            .firstOrNull ??
                        l.cnNotOnShelf,
                  ),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    await _moveToShelf(context, ref, notebook, shelves);
                  },
                ),
                const Divider(height: 8),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: Text(l.cnDownloadAsPdf),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    await _export(context, ref, notebook, asPdf: true, origin: origin);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image_rounded),
                  // On web there's no file share sheet to rely on, so the pages
                  // open as images to save — say so rather than promising a file.
                  title: Text(kIsWeb ? l.cnOpenPagesPng : l.cnDownloadPagesPng),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    await _export(context, ref, notebook, asPdf: false, origin: origin);
                  },
                ),
                const Divider(height: 8),
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: cs.error),
                  title: Text(l.chatContextDelete, style: TextStyle(color: cs.error)),
                  subtitle: Text(l.cnDeleteNotebookSubtitle),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    await _delete(context, ref, notebook);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Notebook actions ──────────────────────────────────────────────────────

  static Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    CnNotebook notebook,
  ) async {
    final l = AppLocalizations.of(context)!;
    final next = await _promptForText(
      context,
      title: l.cnRenameNotebook,
      initial: notebook.title,
      hint: l.cnNotebookTitleHint,
    );
    if (next == null || next == notebook.title) return;
    if (!context.mounted) return;
    await _run(
      context,
      ref,
      () => ref.read(classNotesApiProvider).patchNotebook(notebook.id, title: next),
      success: l.cnRenamed,
    );
  }

  static Future<void> _moveToShelf(
    BuildContext context,
    WidgetRef ref,
    CnNotebook notebook,
    List<CnShelf> shelves,
  ) async {
    // A sentinel rather than null, so "chose Not on a shelf" is distinguishable
    // from "dismissed the sheet".
    const unfiled = '__unfiled__';
    final l = AppLocalizations.of(context)!;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.remove_circle_outline_rounded),
                title: Text(l.cnNotOnShelf),
                trailing: notebook.shelfId == null
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(sheetCtx).pop(unfiled),
              ),
              for (final shelf in shelves)
                ListTile(
                  leading: Icon(shelf.icon, color: shelf.color),
                  title: Text(shelf.name),
                  trailing: notebook.shelfId == shelf.id
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(sheetCtx).pop(shelf.id),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    final target = picked == unfiled ? null : picked;
    if (target == notebook.shelfId) return;
    if (!context.mounted) return;
    await _run(
      context,
      ref,
      () => ref.read(classNotesApiProvider).patchNotebook(
            notebook.id,
            shelfId: target,
            clearShelf: target == null,
          ),
      success: target == null ? l.cnTakenOffShelf : l.cnMoved,
    );
  }

  static Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    CnNotebook notebook, {
    required bool asPdf,
    Rect? origin,
  }) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(asPdf ? l.cnBuildingPdf : l.cnPreparingPages)),
    );
    try {
      final pages = await ref.read(classNotesApiProvider).fetchNotebookPages(notebook.id);
      if (pages.isEmpty) {
        messenger.showSnackBar(
          SnackBar(content: Text(l.cnNoSyncedPages)),
        );
        return;
      }
      if (asPdf) {
        await CnExport.sharePdf(pages: pages, title: notebook.title, origin: origin);
      } else {
        await CnExport.sharePng(pages: pages, title: notebook.title, origin: origin);
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.cnExportFailed('$e'))));
    }
  }

  static Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CnNotebook notebook,
  ) async {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.cnDeleteNotebookTitle),
        content: Text(
          l.cnDeleteNotebookBody(
            notebook.title.isEmpty ? l.commonUntitled : notebook.title,
            notebook.pageCount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l.tutorCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l.chatContextDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await _run(
      context,
      ref,
      () => ref.read(classNotesApiProvider).deleteNotebook(notebook.id),
      success: l.cnDeleted,
    );
  }

  // ── Shelves ───────────────────────────────────────────────────────────────

  /// Rename or delete one shelf. Deleting a shelf never deletes notebooks — they
  /// come back to "All".
  static Future<void> showShelfActions(
    BuildContext context,
    WidgetRef ref,
    CnShelf shelf,
  ) async {
    final l = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        final cs = Theme.of(sheetCtx).colorScheme;
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(shelf.icon, color: shelf.color),
                title: Text(
                  shelf.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const Divider(height: 8),
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline_rounded),
                title: Text(l.cnRenameShelf),
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  final next = await _promptForText(
                    context,
                    title: l.cnRenameShelf,
                    initial: shelf.name,
                    hint: l.cnShelfNameHint,
                  );
                  if (next == null || next == shelf.name) return;
                  if (!context.mounted) return;
                  await _run(
                    context,
                    ref,
                    () => ref
                        .read(classNotesApiProvider)
                        .putShelf(shelf.copyWith(name: next)),
                    success: l.cnRenamed,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: cs.error),
                title: Text(l.cnDeleteShelf, style: TextStyle(color: cs.error)),
                subtitle: Text(l.cnDeleteShelfSubtitle),
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  await _run(
                    context,
                    ref,
                    () => ref.read(classNotesApiProvider).deleteShelf(shelf.id),
                    success: l.cnShelfDeleted,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Plumbing ──────────────────────────────────────────────────────────────

  /// Persist the order the user dragged the covers into.
  static Future<void> saveOrder(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) async {
    try {
      await ref.read(classNotesApiProvider).reorderNotebooks(ids);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.cnReorderFailed('$e'))));
      ref.invalidate(classNotesLibraryProvider);
    }
  }

  static Future<String?> _promptForText(
    BuildContext context, {
    required String title,
    required String initial,
    required String hint,
  }) async {
    final controller = TextEditingController(text: initial);
    final l = AppLocalizations.of(context)!;
    final value = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (v) => Navigator.of(dialogCtx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l.tutorCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(controller.text),
            child: Text(l.profileSave),
          ),
        ],
      ),
    );
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  /// Runs a mutation, refreshes the library, and reports either way. The library
  /// is invalidated on failure too — the local list may already be optimistic.
  static Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action, {
    required String success,
  }) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      ref.invalidate(classNotesLibraryProvider);
      messenger.showSnackBar(SnackBar(content: Text(success)));
    } catch (e) {
      ref.invalidate(classNotesLibraryProvider);
      messenger.showSnackBar(SnackBar(content: Text(l.cnGenericError('$e'))));
    }
  }
}
