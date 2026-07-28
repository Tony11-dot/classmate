import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Flutter mirror of the native ClassNotes data model (`Notebook`, `Shelf`,
/// `PageTemplate`). These are sample records for now — the ClassNotes library
/// lives locally on the iPad with no backend yet — but the SHAPE matches the
/// real model field-for-field, so this is the single layer that gets swapped
/// for real records once a notebooks backend / sync exists. Ordering rules also
/// match ClassNotes: notebooks are always most-recently-updated first, shelves
/// by their `sortIndex`.

/// Page paper style — mirrors ClassNotes' `PageTemplate` (blank/ruled/grid/
/// dotGrid). Geometry constants are in the fixed 768-wide logical page space,
/// exactly as the native `PageTemplateView` uses them.
enum CnTemplate {
  blank('Blank', Icons.crop_portrait_rounded),
  ruled('Ruled', Icons.notes_rounded),
  grid('Grid', Icons.grid_4x4_rounded),
  dotGrid('Dot grid', Icons.blur_on_rounded);

  const CnTemplate(this.label, this.icon);
  final String label;
  final IconData icon;
}

@immutable
class CnNotebook {
  const CnNotebook({
    required this.id,
    required this.title,
    required this.coverColor,
    required this.template,
    required this.createdAt,
    required this.updatedAt,
    this.shelfId,
    this.pageCount = 1,
    this.coverImage,
  });

  final String id;
  final String title;
  final Color coverColor;

  /// The cover exactly as the iPad draws it — artwork plus anything written on
  /// the cover page — as a `data:image/png;base64,...` URL. Null for notebooks
  /// last synced by a build without cover pages, and the tab then falls back to
  /// drawing the cover from [coverColor].
  final String? coverImage;

  /// The decoded cover render, or null when there isn't a usable one.
  Uint8List? get coverImageBytes => decodeDataUrl(coverImage);

  /// Paper style of the notebook's pages (the notebook's default template).
  final CnTemplate template;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// `null` = unfiled (shows under "All", never under a shelf) — matching
  /// ClassNotes' nullable `Notebook.shelfID`.
  final String? shelfId;

  /// ClassNotes derives this from the manifest; here it drives how many
  /// representative pages the read-only viewer renders.
  final int pageCount;
}

/// What kind of extra a page carries: a voice note to play, a file to open, or
/// a link to follow.
enum CnAttachmentKind { audio, file, link }

/// One playable / openable thing on a page, synced up from ClassNotes alongside
/// the page render. Audio and files arrive as `data:` URLs (written to a temp
/// file before opening); links carry their address.
@immutable
class CnAttachment {
  const CnAttachment({
    required this.kind,
    required this.name,
    this.durationSeconds,
    this.dataUrl,
    this.url,
  });

  final CnAttachmentKind kind;
  final String name;

  /// Voice-note length in seconds, when known.
  final double? durationSeconds;

  /// `data:<mime>;base64,...` for audio and files.
  final String? dataUrl;

  /// The destination, for links.
  final String? url;

  /// True when there is actually something to play / open.
  bool get isPlayable =>
      kind == CnAttachmentKind.audio && (dataUrl?.isNotEmpty ?? false);

  bool get isOpenable => switch (kind) {
        CnAttachmentKind.link => (url?.isNotEmpty ?? false),
        _ => (dataUrl?.isNotEmpty ?? false),
      };

  /// The file extension implied by a data URL's MIME type, for the temp file the
  /// system viewer opens.
  String get fileExtension {
    final mime = mimeType;
    return switch (mime) {
      'application/pdf' => 'pdf',
      'image/png' => 'png',
      'image/jpeg' => 'jpg',
      'image/heic' => 'heic',
      'image/gif' => 'gif',
      'text/plain' => 'txt',
      'text/csv' => 'csv',
      'application/json' => 'json',
      'audio/m4a' => 'm4a',
      'audio/mpeg' => 'mp3',
      'audio/wav' => 'wav',
      'video/mp4' => 'mp4',
      'application/zip' => 'zip',
      _ => 'dat',
    };
  }

  /// The MIME type declared in the data URL, or the octet-stream fallback.
  String get mimeType {
    final value = dataUrl;
    if (value == null || !value.startsWith('data:')) {
      return 'application/octet-stream';
    }
    final semicolon = value.indexOf(';');
    if (semicolon <= 5) return 'application/octet-stream';
    return value.substring(5, semicolon);
  }

  /// The decoded payload, or null when there isn't one (a link) or it's corrupt.
  Uint8List? get bytes => decodeDataUrl(dataUrl);
}

/// Decodes the base64 payload of a `data:...,<base64>` URL. Null on anything
/// missing or unparseable, so a corrupt payload degrades instead of throwing.
Uint8List? decodeDataUrl(String? dataUrl) {
  if (dataUrl == null || dataUrl.isEmpty) return null;
  final comma = dataUrl.indexOf(',');
  final b64 = comma >= 0 ? dataUrl.substring(comma + 1) : dataUrl;
  if (b64.isEmpty) return null;
  try {
    return base64Decode(b64);
  } catch (_) {
    return null;
  }
}

/// One rendered page of a notebook, synced up from the native ClassNotes app.
/// `dataUrl` is a `data:image/png;base64,...` string; the viewer decodes the
/// base64 payload and paints it over the paper template. `attachments` are the
/// page's voice notes, files and links, which stay usable here.
@immutable
class CnPage {
  const CnPage({
    required this.pageIndex,
    required this.dataUrl,
    this.attachments = const <CnAttachment>[],
  });

  final int pageIndex;
  final String dataUrl;
  final List<CnAttachment> attachments;
}

@immutable
class CnShelf {
  const CnShelf({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.sortIndex,
    this.symbolName = 'bag',
    this.createdAt,
  });

  final String id;
  final String name;
  final Color color;
  final IconData icon;

  /// Append/creation order — shelves are shown sorted by this, matching
  /// ClassNotes' `Shelf.sortIndex`.
  final int sortIndex;

  /// The native SF Symbol name this shelf was created with. Kept verbatim so
  /// editing a shelf from here round-trips through the shared upsert endpoint
  /// without changing its icon on the iPad.
  final String symbolName;

  /// The shelf's original creation date, for the same reason.
  final DateTime? createdAt;

  CnShelf copyWith({String? name, Color? color}) => CnShelf(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
        icon: icon,
        sortIndex: sortIndex,
        symbolName: symbolName,
        createdAt: createdAt,
      );
}

/// A [Color] as the `#RRGGBB` the ClassNotes API speaks.
String cnHex(Color color) {
  int channel(double v) => (v * 255).round().clamp(0, 255);
  final r = channel(color.r).toRadixString(16).padLeft(2, '0');
  final g = channel(color.g).toRadixString(16).padLeft(2, '0');
  final b = channel(color.b).toRadixString(16).padLeft(2, '0');
  return '#$r$g$b'.toUpperCase();
}

/// The whole library, pre-ordered the ClassNotes way. Built by the data layer
/// (see `classNotesLibraryProvider`) so widgets never re-sort ad hoc.
@immutable
class CnLibrary {
  const CnLibrary({required this.shelves, required this.notebooks});

  /// Shelves sorted by `sortIndex`.
  final List<CnShelf> shelves;

  /// All notebooks, sorted most-recently-updated first.
  final List<CnNotebook> notebooks;

  bool get isEmpty => notebooks.isEmpty;

  /// Notebooks for a shelf (or all when [shelfId] is null), preserving the
  /// most-recent-first order.
  List<CnNotebook> inShelf(String? shelfId) => shelfId == null
      ? notebooks
      : notebooks.where((n) => n.shelfId == shelfId).toList(growable: false);
}

/// The ClassNotes cover palette — the 19 preset accent colors from
/// `ClassMateTheme`'s `ThemePreset`, used verbatim so covers read identically
/// to the native app regardless of the ClassMate theme in effect.
abstract final class CnPalette {
  static const List<Color> covers = <Color>[
    Color(0xFF256489), // light
    Color(0xFF88511E), // coffee
    Color(0xFF416835), // matcha
    Color(0xFF8D4A5D), // rose
    Color(0xFF8C4F26), // sand
    Color(0xFF38608F), // sky
    Color(0xFF66558E), // lavender
    Color(0xFF904B3F), // peach
    Color(0xFF096B5A), // mint
    Color(0xFF94CDF7), // dark
    Color(0xFF8FA6FF), // midnight
    Color(0xFF88C0D0), // nord
    Color(0xFFA7C080), // forest
    Color(0xFFBD93F9), // dracula
    Color(0xFF57D6E0), // obsidian
    Color(0xFFEC9AAE), // wine
    Color(0xFFC99A2E), // solarized
    Color(0xFFC9A2ED), // plum
    Color(0xFF56C7D4), // ocean
  ];
}

/// WCAG-style contrast pick — white vs near-black ink — matching ClassNotes'
/// `contrastingInk(on:)`. Used for cover titles and selected shelf chips.
Color cnContrastingInk(Color background) {
  double linearize(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  double luminance(Color c) =>
      0.2126 * linearize(c.r) +
      0.7152 * linearize(c.g) +
      0.0722 * linearize(c.b);

  final bg = luminance(background);
  const nearBlack = Color(0xFF14171A);

  double ratio(Color fg) {
    final f = luminance(fg);
    final hi = math.max(f, bg);
    final lo = math.min(f, bg);
    return (hi + 0.05) / (lo + 0.05);
  }

  return ratio(Colors.white) >= ratio(nearBlack) ? Colors.white : nearBlack;
}

/// Sample shelves + notebooks so the tab renders a full, believable library
/// with the exact ClassNotes ordering. Returns a [CnLibrary] with everything
/// pre-sorted; the provider layer hands this to the UI.
abstract final class CnSampleData {
  static List<CnShelf> _shelves() => const <CnShelf>[
        CnShelf(id: 's-bio', name: 'Biology', color: Color(0xFF416835), icon: Icons.science_outlined, sortIndex: 0),
        CnShelf(id: 's-math', name: 'Math', color: Color(0xFF38608F), icon: Icons.architecture_rounded, sortIndex: 1),
        CnShelf(id: 's-journal', name: 'Journal', color: Color(0xFF8D4A5D), icon: Icons.menu_book_rounded, sortIndex: 2),
        CnShelf(id: 's-art', name: 'Art', color: Color(0xFF66558E), icon: Icons.palette_outlined, sortIndex: 3),
      ];

  static List<CnNotebook> _notebooks() {
    // Fixed reference instant keeps the sample dates stable across rebuilds
    // (no Date.now() churn); still reads as "this week / last month".
    final now = DateTime(2026, 7, 25, 21);
    DateTime ago(int days, [int hours = 0]) =>
        now.subtract(Duration(days: days, hours: hours));
    return <CnNotebook>[
      CnNotebook(id: 'n1', title: 'Cell Biology', coverColor: const Color(0xFF416835), template: CnTemplate.ruled, createdAt: ago(40), updatedAt: ago(0), shelfId: 's-bio', pageCount: 14),
      CnNotebook(id: 'n2', title: 'Genetics Lab', coverColor: const Color(0xFF096B5A), template: CnTemplate.grid, createdAt: ago(30), updatedAt: ago(1), shelfId: 's-bio', pageCount: 8),
      CnNotebook(id: 'n3', title: 'Calculus II', coverColor: const Color(0xFF38608F), template: CnTemplate.grid, createdAt: ago(60), updatedAt: ago(1, 6), shelfId: 's-math', pageCount: 22),
      CnNotebook(id: 'n4', title: 'Linear Algebra', coverColor: const Color(0xFF256489), template: CnTemplate.ruled, createdAt: ago(55), updatedAt: ago(3), shelfId: 's-math', pageCount: 11),
      CnNotebook(id: 'n5', title: 'Daily Journal', coverColor: const Color(0xFF8D4A5D), template: CnTemplate.ruled, createdAt: ago(120), updatedAt: ago(2), shelfId: 's-journal', pageCount: 40),
      CnNotebook(id: 'n6', title: 'Sketchbook', coverColor: const Color(0xFF66558E), template: CnTemplate.blank, createdAt: ago(80), updatedAt: ago(4), shelfId: 's-art', pageCount: 17),
      CnNotebook(id: 'n7', title: 'Physics Notes', coverColor: const Color(0xFF904B3F), template: CnTemplate.dotGrid, createdAt: ago(48), updatedAt: ago(5), pageCount: 9),
      CnNotebook(id: 'n8', title: 'History Essays', coverColor: const Color(0xFF88511E), template: CnTemplate.ruled, createdAt: ago(70), updatedAt: ago(6), pageCount: 6),
      CnNotebook(id: 'n9', title: 'Chemistry', coverColor: const Color(0xFFC99A2E), template: CnTemplate.grid, createdAt: ago(52), updatedAt: ago(8), shelfId: 's-bio', pageCount: 12),
      CnNotebook(id: 'n10', title: 'Ideas & Drafts', coverColor: const Color(0xFF8C4F26), template: CnTemplate.dotGrid, createdAt: ago(20), updatedAt: ago(11), pageCount: 3),
      CnNotebook(id: 'n11', title: 'Watercolors', coverColor: const Color(0xFFC9A2ED), template: CnTemplate.blank, createdAt: ago(95), updatedAt: ago(14), shelfId: 's-art', pageCount: 21),
    ];
  }

  /// A fully-ordered library: shelves by `sortIndex`, notebooks by `updatedAt`
  /// descending — exactly how ClassNotes presents them.
  static CnLibrary library() {
    final shelves = _shelves()..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    final notebooks = _notebooks()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return CnLibrary(shelves: shelves, notebooks: notebooks);
  }
}
