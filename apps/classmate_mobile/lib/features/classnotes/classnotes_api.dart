import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';
import 'classnotes_models.dart';

/// Authenticated ClassNotes API — same backend + account as the native
/// ClassNotes app, which uploads the user's notebooks/shelves. This is the read
/// side for the ClassMate "ClassNotes" tab.
///
/// The token is read LAZILY at request time (not snapshotted at build), because
/// `authSessionProvider` is a plain Provider that doesn't rebuild when the token
/// hydrates asynchronously on launch — snapshotting it caused an empty-bearer
/// request (→ 401 / blank screen) on the first open.
final classNotesApiProvider = Provider<ClassNotesApi>((ref) {
  return ClassNotesApi(
    tokenGetter: () => (ref.read(authSessionProvider).token ?? '').trim(),
  );
});

class ClassNotesApi {
  ClassNotesApi({required this.tokenGetter});

  final String Function() tokenGetter;

  CMApi get _api => CMApi(token: tokenGetter());

  /// `GET /classnotes/library` → the user's shelves + notebooks, already ordered
  /// server-side (shelves by sortIndex, notebooks most-recently-updated first).
  Future<CnLibrary> fetchLibrary() async {
    final raw = await _api.getJson('/classnotes/library');
    final map = raw is Map ? raw : const <String, dynamic>{};
    final shelvesJson = (map['shelves'] as List?) ?? const [];
    final notebooksJson = (map['notebooks'] as List?) ?? const [];
    final shelves = shelvesJson
        .whereType<Map>()
        .map((e) => _shelf(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    final notebooks = notebooksJson
        .whereType<Map>()
        .map((e) => _notebook(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    return CnLibrary(shelves: shelves, notebooks: notebooks);
  }

  /// `GET /classnotes/notebooks/:id/pages` → the notebook's rendered page
  /// images, ordered by pageIndex. Empty for older notebooks that predate the
  /// page-content sync (the viewer falls back to blank template paper).
  Future<List<CnPage>> fetchNotebookPages(String id) async {
    final raw = await _api.getJson('/classnotes/notebooks/$id/pages');
    final map = raw is Map ? raw : const <String, dynamic>{};
    final pagesJson = (map['pages'] as List?) ?? const [];
    return pagesJson
        .whereType<Map>()
        .map((e) => _page(Map<String, dynamic>.from(e)))
        .where((p) => p.dataUrl.isNotEmpty)
        .toList(growable: false);
  }

  CnPage _page(Map<String, dynamic> j) => CnPage(
        pageIndex: (j['pageIndex'] as num?)?.toInt() ?? 0,
        dataUrl: '${j['dataUrl'] ?? ''}',
      );

  CnShelf _shelf(Map<String, dynamic> j) => CnShelf(
        id: '${j['id']}',
        name: '${j['name'] ?? ''}',
        color: _hexColor(j['colorHex']) ?? CnPalette.covers.first,
        icon: _shelfIcon('${j['symbolName'] ?? 'bag'}'),
        sortIndex: (j['sortIndex'] as num?)?.toInt() ?? 0,
      );

  CnNotebook _notebook(Map<String, dynamic> j) => CnNotebook(
        id: '${j['id']}',
        title: '${j['title'] ?? ''}',
        coverColor: _hexColor(j['coverColorHex']) ?? CnPalette.covers.first,
        template: _template('${j['template'] ?? 'ruled'}'),
        createdAt:
            DateTime.tryParse('${j['createdAt']}')?.toLocal() ?? DateTime(2020),
        updatedAt:
            DateTime.tryParse('${j['updatedAt']}')?.toLocal() ?? DateTime(2020),
        shelfId: j['shelfId'] as String?,
        pageCount: (j['pageCount'] as num?)?.toInt() ?? 1,
      );
}

/// `#RRGGBB` (or `RRGGBB`) → opaque [Color]; null on anything unparseable.
Color? _hexColor(dynamic value) {
  if (value is! String) return null;
  var s = value.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  if (s.length != 8) return null;
  final n = int.tryParse(s, radix: 16);
  return n == null ? null : Color(n);
}

/// PageTemplate.rawValue → [CnTemplate] (defaults to ruled).
CnTemplate _template(String raw) => switch (raw) {
      'blank' => CnTemplate.blank,
      'grid' => CnTemplate.grid,
      'dotGrid' => CnTemplate.dotGrid,
      _ => CnTemplate.ruled,
    };

/// The native `ShelfSymbol` SF Symbol names → the closest Material icon, so
/// shelves keep their identity across apps.
IconData _shelfIcon(String sfSymbol) => switch (sfSymbol) {
      'books.vertical' => Icons.auto_stories_outlined,
      'backpack' => Icons.backpack_outlined,
      'folder' => Icons.folder_outlined,
      'graduationcap' => Icons.school_outlined,
      'pencil.and.ruler' => Icons.architecture_rounded,
      'flask' => Icons.science_outlined,
      'paintpalette' => Icons.palette_outlined,
      'star' => Icons.star_outline_rounded,
      'heart' => Icons.favorite_outline_rounded,
      'bookmark' => Icons.bookmark_outline_rounded,
      'tray.full' => Icons.inbox_outlined,
      'calendar' => Icons.calendar_today_outlined,
      'function' => Icons.functions_rounded,
      'atom' => Icons.hub_outlined,
      'globe' => Icons.public_outlined,
      'leaf' => Icons.eco_outlined,
      'music.note' => Icons.music_note_outlined,
      'sparkles' => Icons.auto_awesome_outlined,
      'lightbulb' => Icons.lightbulb_outline_rounded,
      'briefcase' => Icons.work_outline_rounded,
      'camera' => Icons.photo_camera_outlined,
      'gamecontroller' => Icons.sports_esports_outlined,
      'sportscourt' => Icons.sports_basketball_outlined,
      _ => Icons.shopping_bag_outlined, // bag (default)
    };
