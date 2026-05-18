import 'package:flutter/material.dart';

/// Curated subject palette — friendly, distinguishable, used for the color
/// picker in the subject editor and as the deterministic fallback when a
/// subject has no color set.
const List<Color> kSubjectPalette = [
  Color(0xFF1976D2), // Blue
  Color(0xFF388E3C), // Green
  Color(0xFFD32F2F), // Red
  Color(0xFFF57C00), // Orange
  Color(0xFF7B1FA2), // Purple
  Color(0xFF00838F), // Teal
  Color(0xFF5D4037), // Brown
  Color(0xFFC2185B), // Pink
  Color(0xFF455A64), // Slate
  Color(0xFFFBC02D), // Amber
  Color(0xFF512DA8), // Deep Purple
  Color(0xFF00897B), // Dark Teal
];

/// Parses `#RRGGBB`, `RRGGBB`, `#AARRGGBB`, or `0xAARRGGBB` into a [Color].
Color? parseSubjectColor(String? hex) {
  if (hex == null) return null;
  var h = hex.trim();
  if (h.isEmpty) return null;
  if (h.startsWith('#')) h = h.substring(1);
  if (h.startsWith('0x') || h.startsWith('0X')) h = h.substring(2);
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final v = int.tryParse(h, radix: 16);
  return v == null ? null : Color(v);
}

/// Serializes a [Color] as `#RRGGBB` (no alpha).
String colorToHex(Color c) {
  final v = c.toARGB32() & 0xFFFFFF;
  return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// Compares two colors by their RGB channels (alpha ignored).
bool sameRgb(Color a, Color b) =>
    (a.toARGB32() & 0xFFFFFF) == (b.toARGB32() & 0xFFFFFF);

/// Returns the subject's color, or a deterministic palette fallback derived
/// from [seed].  Use the subject's English name as [seed] so the same subject
/// always lands on the same color across the app even before the admin
/// explicitly sets one.
Color subjectColorOrFallback(String? hex, String seed) {
  final parsed = parseSubjectColor(hex);
  if (parsed != null) return parsed;
  if (seed.isEmpty) return kSubjectPalette.first;
  var h = 0;
  for (final c in seed.codeUnits) {
    h = (h * 31 + c) & 0x7FFFFFFF;
  }
  return kSubjectPalette[h % kSubjectPalette.length];
}
