import 'dart:convert';
import 'dart:io';

/// Generates `lib/l10n/app_ps.arb` from `lib/l10n/app_en.arb`.
///
/// The pseudo-locale wraps every translated value in `‹‹ ... ››` braces so
/// that any string still rendering in plain English when the app is run in
/// "ps" locale is a hardcoded leak. Quick visual smoke test for any screen
/// in any role — anything not braced is a bug.
///
/// Preserves ARB metadata keys (`@@locale`, `@key`, etc.) untouched so the
/// generated AppLocalizations interface matches every other locale.
///
/// Usage: dart run scripts/generate_pseudo_locale.dart
void main() {
  final root = Directory.current;
  final enFile = File('${root.path}/lib/l10n/app_en.arb');
  if (!enFile.existsSync()) {
    stderr.writeln('app_en.arb not found at ${enFile.path}');
    exitCode = 2;
    return;
  }
  final psFile = File('${root.path}/lib/l10n/app_ps.arb');

  final raw = enFile.readAsStringSync();
  final map = jsonDecode(raw) as Map<String, dynamic>;

  final out = <String, dynamic>{};
  for (final entry in map.entries) {
    final key = entry.key;
    final value = entry.value;
    if (key == '@@locale') {
      out[key] = 'ps';
      continue;
    }
    if (key.startsWith('@')) {
      // Metadata block (placeholders, descriptions). Copy verbatim so the
      // generated codegen knows the same arg shapes.
      out[key] = value;
      continue;
    }
    if (value is! String) {
      out[key] = value;
      continue;
    }
    out[key] = _wrap(value);
  }

  // Stable, human-readable output.
  final encoder = const JsonEncoder.withIndent('  ');
  psFile.writeAsStringSync('${encoder.convert(out)}\n');
  stdout.writeln('Wrote ${psFile.path}');
}

/// Wraps the value in ‹‹ ... ›› while preserving ICU placeholders and plural
/// markers untouched. ICU expressions live inside `{ ... }` and must not be
/// braced or the codegen breaks; we wrap each plain-text chunk separately.
String _wrap(String value) {
  if (value.isEmpty) return value;
  final buf = StringBuffer('‹‹');
  var i = 0;
  while (i < value.length) {
    final open = value.indexOf('{', i);
    if (open < 0) {
      buf.write(value.substring(i));
      break;
    }
    buf.write(value.substring(i, open));
    // Find matching close brace (allowing nested braces for ICU plurals).
    var depth = 1;
    var j = open + 1;
    while (j < value.length && depth > 0) {
      final c = value[j];
      if (c == '{') depth++;
      if (c == '}') depth--;
      j++;
    }
    buf.write(value.substring(open, j));
    i = j;
  }
  buf.write('››');
  return buf.toString();
}
