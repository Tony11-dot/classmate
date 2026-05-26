# Translation tooling

## `generate_pseudo_locale.dart`

Reads `lib/l10n/app_en.arb` and writes `lib/l10n/app_ps.arb`, wrapping every
translated string in `‹‹ ... ››`. Switch the app to the `ps` locale (Settings
→ Language, debug builds only) and any text still rendering in plain English
is a hardcoded leak you can spot at a glance.

```bash
dart run scripts/generate_pseudo_locale.dart
flutter pub get   # regenerates app_localizations_ps.dart
```

Run this after every batch of new ARB keys.

## `check_hardcoded_strings.dart`

Regex sweep over `lib/**/*.dart` that fails if any `Text('...')`,
`labelText:`, `hintText:`, `tooltip:`, `SnackBar(content: Text(...))`,
`AlertDialog(title: Text(...))`, or `semanticLabel:` literal looks like
user-visible English. Run pre-commit and in CI.

```bash
dart run scripts/check_hardcoded_strings.dart
```

CI wires this into `.github/workflows/i18n-lint.yml`. It runs on every
push and PR that touches `apps/classmate_mobile/**`, exits non-zero on
violations, and the PR shows a red check.

### Pre-commit hook

To run the check locally before every commit, add this to
`.git/hooks/pre-commit` (and `chmod +x` it):

```bash
#!/usr/bin/env bash
set -e
cd "$(git rev-parse --show-toplevel)/apps/classmate_mobile" || exit 0
if git diff --cached --name-only | grep -qE '^apps/classmate_mobile/.*\.dart$'; then
  dart run scripts/check_hardcoded_strings.dart
fi
```

### Adding a new translation

1. Add the key to `lib/l10n/app_en.arb` (template — required).
2. Add the same key with translations to `app_ar.arb`, `app_he.arb`,
   `app_fr.arb`, `app_ru.arb`.
3. `flutter pub get` regenerates the typed `AppLocalizations` interface.
4. `dart run scripts/generate_pseudo_locale.dart` regenerates `app_ps.arb`.
5. Use the new key: `AppLocalizations.of(context)!.myKey`.

### Allowlisting a false positive

If the regex flags a string that's genuinely safe (brand name, code token,
single-letter label), add a substring to `allowSubstrings` or a path to
`ignoreFiles` / `ignorePrefixes` in `check_hardcoded_strings.dart`.
