import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lightweight sample models mirroring the native ClassNotes app's `Notebook`
/// and `Shelf`. These are placeholder/sample data so the ClassNotes tab looks
/// exactly like the real library; once ClassNotes syncs its library to the
/// backend, this is the layer that gets swapped for real records.

@immutable
class CnNotebook {
  const CnNotebook({
    required this.id,
    required this.title,
    required this.coverColor,
    required this.updatedAt,
    this.shelfId,
    this.pageCount = 1,
  });

  final String id;
  final String title;
  final Color coverColor;
  final DateTime updatedAt;
  final String? shelfId;
  final int pageCount;
}

@immutable
class CnShelf {
  const CnShelf({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final Color color;
  final IconData icon;
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

/// Sample shelves + notebooks so the tab renders a full, believable library.
abstract final class CnSampleData {
  static final List<CnShelf> shelves = <CnShelf>[
    const CnShelf(id: 's-bio', name: 'Biology', color: Color(0xFF416835), icon: Icons.science_outlined),
    const CnShelf(id: 's-math', name: 'Math', color: Color(0xFF38608F), icon: Icons.architecture_rounded),
    const CnShelf(id: 's-journal', name: 'Journal', color: Color(0xFF8D4A5D), icon: Icons.menu_book_rounded),
    const CnShelf(id: 's-art', name: 'Art', color: Color(0xFF66558E), icon: Icons.palette_outlined),
  ];

  static List<CnNotebook> notebooks() {
    final now = DateTime.now();
    DateTime ago(int days) => now.subtract(Duration(days: days));
    return <CnNotebook>[
      CnNotebook(id: 'n1', title: 'Cell Biology', coverColor: const Color(0xFF416835), updatedAt: ago(0), shelfId: 's-bio', pageCount: 14),
      CnNotebook(id: 'n2', title: 'Genetics Lab', coverColor: const Color(0xFF096B5A), updatedAt: ago(1), shelfId: 's-bio', pageCount: 8),
      CnNotebook(id: 'n3', title: 'Calculus II', coverColor: const Color(0xFF38608F), updatedAt: ago(2), shelfId: 's-math', pageCount: 22),
      CnNotebook(id: 'n4', title: 'Linear Algebra', coverColor: const Color(0xFF256489), updatedAt: ago(3), shelfId: 's-math', pageCount: 11),
      CnNotebook(id: 'n5', title: 'Daily Journal', coverColor: const Color(0xFF8D4A5D), updatedAt: ago(1), shelfId: 's-journal', pageCount: 40),
      CnNotebook(id: 'n6', title: 'Sketchbook', coverColor: const Color(0xFF66558E), updatedAt: ago(4), shelfId: 's-art', pageCount: 17),
      CnNotebook(id: 'n7', title: 'Physics Notes', coverColor: const Color(0xFF904B3F), updatedAt: ago(5), pageCount: 9),
      CnNotebook(id: 'n8', title: 'History Essays', coverColor: const Color(0xFF88511E), updatedAt: ago(6), pageCount: 6),
      CnNotebook(id: 'n9', title: 'Ideas & Drafts', coverColor: const Color(0xFF8C4F26), updatedAt: ago(9), pageCount: 3),
    ];
  }
}
