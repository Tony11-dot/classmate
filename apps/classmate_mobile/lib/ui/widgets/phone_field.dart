import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Common dial codes — Israel first (default), then the rest of the
/// Middle East + a few high-traffic westerners. List trimmed on purpose so
/// the bottom-sheet picker stays short and scannable; users with unusual
/// codes can paste the full number into the digits field and the field
/// will normalize it.
const List<({String code, String name, String flag})> kDialCodes = [
  (code: '+972', name: 'Israel',       flag: '🇮🇱'),
  (code: '+970', name: 'Palestine',    flag: '🇵🇸'),
  (code: '+961', name: 'Lebanon',      flag: '🇱🇧'),
  (code: '+962', name: 'Jordan',       flag: '🇯🇴'),
  (code: '+963', name: 'Syria',        flag: '🇸🇾'),
  (code: '+966', name: 'Saudi Arabia', flag: '🇸🇦'),
  (code: '+971', name: 'UAE',          flag: '🇦🇪'),
  (code: '+20',  name: 'Egypt',        flag: '🇪🇬'),
  (code: '+90',  name: 'Turkey',       flag: '🇹🇷'),
  (code: '+1',   name: 'USA / Canada', flag: '🇺🇸'),
  (code: '+44',  name: 'UK',           flag: '🇬🇧'),
  (code: '+33',  name: 'France',       flag: '🇫🇷'),
  (code: '+49',  name: 'Germany',      flag: '🇩🇪'),
  (code: '+7',   name: 'Russia',       flag: '🇷🇺'),
  (code: '+39',  name: 'Italy',        flag: '🇮🇹'),
  (code: '+34',  name: 'Spain',        flag: '🇪🇸'),
];

const String kDefaultDialCode = '+972';

/// Splits a stored E.164 phone (e.g. `+972525488441`) into `(dialCode,
/// localDigits)` using the longest-prefix match against [kDialCodes].
/// Falls back to `(kDefaultDialCode, '')` if the input is null/empty or
/// not recognized — never throws.
({String dialCode, String localDigits}) splitE164(String? e164) {
  final raw = (e164 ?? '').trim();
  if (raw.isEmpty || !raw.startsWith('+')) {
    return (dialCode: kDefaultDialCode, localDigits: '');
  }
  // Longest-prefix wins so '+972' isn't shadowed by '+9'.
  final sorted = [...kDialCodes]..sort((a, b) => b.code.length.compareTo(a.code.length));
  for (final c in sorted) {
    if (raw.startsWith(c.code)) {
      return (dialCode: c.code, localDigits: raw.substring(c.code.length));
    }
  }
  return (dialCode: kDefaultDialCode, localDigits: raw.replaceFirst(RegExp(r'^\+'), ''));
}

/// Joins a dial-code + arbitrary user-typed local-digits string into E.164,
/// normalizing common input formats so users don't have to think about it:
///
///   dial=+972, "0525488441"   → "+972525488441"   (strip national trunk 0)
///   dial=+972, "525488441"    → "+972525488441"   (no normalization needed)
///   dial=+972, "+972525488441" → "+972525488441"  (strip duplicate country code)
///   dial=+972, "972525488441" → "+972525488441"   (already-prefixed, no +)
///
/// Non-digits are stripped before processing. Returns null when empty.
String? joinE164(String dialCode, String localDigits) {
  var digits = localDigits.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  // If the user pasted the country code into the local field (with or
  // without a +), don't double it.
  final cc = dialCode.replaceAll(RegExp(r'[^0-9]'), '');
  if (cc.isNotEmpty && digits.startsWith(cc)) {
    digits = digits.substring(cc.length);
  }
  // Strip leading 0 (national trunk prefix in IL, FR, UK, etc.) — E.164
  // country codes already absorb it.
  digits = digits.replaceFirst(RegExp(r'^0+'), '');
  if (digits.isEmpty) return null;
  return '$dialCode$digits';
}

/// Phone input field with a tappable country-dial-code chip on the left.
/// Stateless — caller owns the controller + dial-code state.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.dialCode,
    required this.onDialCodeChanged,
    this.labelText,
    this.helperText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String dialCode;
  final ValueChanged<String> onDialCodeChanged;
  final String? labelText;
  final String? helperText;
  final bool autofocus;

  Future<void> _pickDialCode(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  l.phoneFieldCountryCode,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: kDialCodes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 2),
                  itemBuilder: (lctx, i) {
                    final c = kDialCodes[i];
                    final selected = c.code == dialCode;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(sCtx, c.code),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? cs.primaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(c.flag, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 56,
                              child: Text(
                                c.code,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: selected ? cs.primary : cs.onSurface,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                c.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: selected ? cs.primary : cs.onSurface,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (selected) Icon(Icons.check_rounded, size: 18, color: cs.primary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onDialCodeChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.phone,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: labelText ?? l.phoneFieldLabel,
        helperText: helperText ?? l.phoneFieldHelper,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pickDialCode(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  dialCode,
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
