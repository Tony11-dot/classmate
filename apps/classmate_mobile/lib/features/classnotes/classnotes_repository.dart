import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'classnotes_api.dart';
import 'classnotes_models.dart';

/// The ClassNotes library for the "ClassNotes" tab — the user's REAL notebooks,
/// fetched from the ClassMate backend (`GET /classnotes/library`). The native
/// ClassNotes app syncs them up on every edit; both apps use the same account,
/// so this returns exactly what the user has. Auto-disposes so it re-fetches
/// each time the tab is opened, and can be `ref.invalidate`d for pull-to-refresh.
final classNotesLibraryProvider =
    FutureProvider.autoDispose<CnLibrary>((ref) async {
  return ref.watch(classNotesApiProvider).fetchLibrary();
});

/// The rendered page images for one notebook (`GET /classnotes/notebooks/:id/
/// pages`), keyed by notebook id. Auto-disposes so it re-fetches each time a
/// notebook is opened. Returns an empty list for older notebooks with no synced
/// content, in which case the viewer falls back to blank template paper.
final classNotesPagesProvider =
    FutureProvider.autoDispose.family<List<CnPage>, String>((ref, id) async {
  return ref.watch(classNotesApiProvider).fetchNotebookPages(id);
});
