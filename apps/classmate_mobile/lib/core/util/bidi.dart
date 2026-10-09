import 'package:flutter/widgets.dart';

/// Wraps [s] in a left-to-right isolate (LRI … PDI) so a time range such as
/// "08:00–08:45" keeps its order inside Hebrew/Arabic text — without it the
/// bidi algorithm shows "08:45–08:00".
String ltrIsolate(String s) => '\u{2066}$s\u{2069}';

/// Wraps one-line user text (a list preview, a name) in a first-strong
/// isolate: the row keeps the app's alignment while the text inside reads in
/// its own direction.
String firstStrongIsolate(String s) => '\u{2068}$s\u{2069}';

/// Direction of user-written text, taken from its first letter (WhatsApp does
/// the same): an English message in the Hebrew app — or a Hebrew one in the
/// English app — reads in its own direction, so its punctuation stays at the
/// end instead of jumping to the front (".derivatives"). Text with no letters
/// (numbers, emoji) keeps [fallback].
TextDirection firstStrongDirection(String text, TextDirection fallback) {
  for (final r in text.runes) {
    final rtl = (r >= 0x0590 && r <= 0x08FF) || // Hebrew, Arabic, Syriac, Thaana
        (r >= 0xFB1D && r <= 0xFDFF) || // Hebrew/Arabic presentation forms
        (r >= 0xFE70 && r <= 0xFEFF);
    if (rtl) return TextDirection.rtl;
    final ltr = (r >= 0x41 && r <= 0x5A) ||
        (r >= 0x61 && r <= 0x7A) ||
        (r >= 0xC0 && r <= 0x024F) || // Latin with accents (French)
        (r >= 0x0370 && r <= 0x052F); // Greek, Cyrillic (Russian)
    if (ltr) return TextDirection.ltr;
  }
  return fallback;
}
