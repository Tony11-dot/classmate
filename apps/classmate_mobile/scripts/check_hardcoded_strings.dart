import 'dart:io';

/// Greps `lib/` for user-visible English strings that aren't routed through
/// AppLocalizations. Run before commit or in CI:
///
///   dart run scripts/check_hardcoded_strings.dart
///
/// Exits non-zero if any patterns match. Excludes generated localization
/// files, the bootstrap (no localizer yet), and known false-positive
/// patterns (short brand/system labels, code-like tokens).
///
/// This is intentionally simple — a real Dart `custom_lint` rule would be
/// more precise but adds 30s to every analyze. A regex scan catches the
/// vast majority of leaks for almost zero overhead.
void main(List<String> args) {
  final root = Directory('${Directory.current.path}/lib');
  if (!root.existsSync()) {
    stderr.writeln('lib/ not found — run from apps/classmate_mobile/');
    exitCode = 2;
    return;
  }

  // Patterns to flag. Each is `(label, regex)` — the regex must capture a
  // user-visible string. Keep these tight to avoid noise.
  final patterns = <(String, RegExp)>[
    (
      'Text(\'English…\')',
      RegExp(r'''Text\((?:const\s+)?[\'"][A-Z][a-z][a-z][^\'"]*[\'"]'''),
    ),
    (
      'hintText/labelText/helperText/tooltip: \'English\'',
      RegExp(r'''(hintText|labelText|helperText|tooltip):\s*[\'"][A-Z][a-z][a-z][^\'"]*[\'"]'''),
    ),
    (
      'Tooltip(message: \'English\')',
      RegExp(r'''Tooltip\(message:\s*[\'"][A-Z][a-z][^\'"]*[\'"]'''),
    ),
    (
      'SnackBar(content: Text(\'English\'))',
      RegExp(r'''SnackBar\(content:\s*Text\((?:const\s+)?[\'"][A-Z][a-z][a-z][^\'"]*[\'"]'''),
    ),
    (
      'AlertDialog(title: Text(\'English\'))',
      RegExp(r'''AlertDialog\([^)]*title:\s*Text\((?:const\s+)?[\'"][A-Z][a-z][^\'"]*[\'"]'''),
    ),
    (
      'semanticLabel: \'English\'',
      RegExp(r'''semanticLabel:\s*[\'"][A-Z][a-z][^\'"]*[\'"]'''),
    ),
    (
      'Ternary: cond ? \'English\' : \'English\'',
      RegExp(r'''\?\s*[\'"][A-Z][a-z][a-z][^\'"]{4,}[\'"]\s*:\s*[\'"][A-Z]'''),
    ),
  ];

  // Substrings that mark a literal as a known safe value (brands, codes,
  // single-token labels that don't need translation).
  final allowSubstrings = <String>[
    'NOVA', 'ClassMate', 'RSVP', 'PDF', 'CSV', 'JSON', 'API', 'URL',
    // Calendar abbreviations show up in headers and don't need translation.
    'Mon ', 'Tue ', 'Wed ', 'Thu ', 'Fri ', 'Sat ', 'Sun ',
    'Jan ', 'Feb ', 'Mar ', 'Apr ', 'May ', 'Jun ',
    'Jul ', 'Aug ', 'Sep ', 'Oct ', 'Nov ', 'Dec ',
  ];

  // Whole files to ignore — they don't render UI in any reachable path.
  final ignoreFiles = <String>{
    'lib/firebase_options.dart',
    'lib/main.dart',
    'lib/main_dev.dart',
  };

  // File-prefix ignores — generated codegen, l10n itself, dead backup files.
  final ignorePrefixes = <String>[
    'lib/l10n/app_localizations',
    'lib/l10n/app_',
    'lib/features/solutions/domain/solutions_models.dart', // book names
    'lib/features/practice/ui/practice_mode_specs.dart', // dead label fields
    'lib/screens/animation_demo_screen.dart', // dev-only splash demo
    'lib/features/admin/data/admin_repository.dart', // English fallback getter; UI uses gradeLabelLocalized()
    'lib/features/parent/data/parent_models.dart',   // English fallback getter; UI uses gradeLabelLocalized()
    'lib/features/lifedoc/notifications_provider.dart', // English fallback in model; renderer uses template helper
    'lib/features/lifedoc/announcements_provider.dart', // English fallback in model; renderer uses template helper
  ];
  final ignoreSuffixes = <String>['.pre_repair', '.bak', '.g.dart', '.freezed.dart'];

  final hits = <_Hit>[];

  for (final f in root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))) {
    final rel = f.path.replaceFirst('${Directory.current.path}/', '');
    if (ignoreFiles.contains(rel)) continue;
    if (ignorePrefixes.any(rel.startsWith)) continue;
    if (ignoreSuffixes.any(rel.contains)) continue;

    final lines = f.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Skip Dart comments — they're not rendered.
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('//') || trimmed.startsWith('///') || trimmed.startsWith('*')) {
        continue;
      }
      // Already going through the localizer? Safe.
      if (line.contains('AppLocalizations')) continue;

      for (final (label, re) in patterns) {
        final m = re.firstMatch(line);
        if (m == null) continue;
        final matchedText = m.group(0)!;
        if (allowSubstrings.any(matchedText.contains)) continue;
        hits.add(_Hit(rel, i + 1, label, matchedText));
        break;
      }
    }
  }

  if (hits.isEmpty) {
    stdout.writeln('No hardcoded user-visible strings found.');
    return;
  }

  stdout.writeln(
    'Found ${hits.length} potential hardcoded user-visible strings:\n',
  );
  for (final h in hits) {
    stdout.writeln('  ${h.file}:${h.line}  [${h.label}]');
    stdout.writeln('    ${h.matchedText}');
  }
  stdout.writeln(
    '\nRoute these through AppLocalizations.of(context)! — add the key to '
    'lib/l10n/app_en.arb plus all locales. Or add an allowlist entry to '
    'scripts/check_hardcoded_strings.dart if the match is genuinely safe.',
  );
  exitCode = 1;
}

class _Hit {
  _Hit(this.file, this.line, this.label, this.matchedText);
  final String file;
  final int line;
  final String label;
  final String matchedText;
}
