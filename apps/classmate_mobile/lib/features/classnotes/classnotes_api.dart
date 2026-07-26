import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';
import 'classnotes_models.dart';

/// Authenticated ClassNotes API — same backend + account as the native
/// ClassNotes app, which uploads the user's notebooks/shelves. This is the read
/// side for the ClassMate "ClassNotes" tab.
final classNotesApiProvider = Provider<ClassNotesApi>((ref) {
  final session = ref.watch(authSessionProvider);
  return ClassNotesApi(token: (session.token ?? '').trim());
});

class ClassNotesApi {
  ClassNotesApi({required this.token});

  final String token;

  CMApi get _api => CMApi(token: token);

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
      _ => Icons.shopping_bag_outlined, // bag (default)
    };
