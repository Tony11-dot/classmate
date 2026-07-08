import 'package:flutter/material.dart';

import '../../../core/contracts/school_subject.dart';
import '../../../core/util/subject_color.dart';
import '../../../l10n/app_localizations.dart';

/// Edits the 5-language names for a single school subject. Returns the
/// updated [SchoolSubject] via Navigator.pop when the user taps save.
class AdminSubjectDetailScreen extends StatefulWidget {
  const AdminSubjectDetailScreen({super.key, required this.initial});
  final SchoolSubject initial;

  @override
  State<AdminSubjectDetailScreen> createState() => _AdminSubjectDetailScreenState();
}

class _AdminSubjectDetailScreenState extends State<AdminSubjectDetailScreen> {
  late final TextEditingController _en;
  late final TextEditingController _ar;
  late final TextEditingController _he;
  late final TextEditingController _fr;
  late final TextEditingController _ru;
  String? _colorHex;

  @override
  void initState() {
    super.initState();
    _en = TextEditingController(text: widget.initial.nameEn);
    _ar = TextEditingController(text: widget.initial.nameAr ?? '');
    _he = TextEditingController(text: widget.initial.nameHe ?? '');
    _fr = TextEditingController(text: widget.initial.nameFr ?? '');
    _ru = TextEditingController(text: widget.initial.nameRu ?? '');
    _colorHex = widget.initial.color;
  }

  @override
  void dispose() {
    for (final c in [_en, _ar, _he, _fr, _ru]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final nameEn = _en.text.trim();
    if (nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminSubjectEnglishNameRequired)),
      );
      return;
    }
    Navigator.pop(context, SchoolSubject(
      nameEn: nameEn,
      nameAr: _trimOrNull(_ar.text),
      nameHe: _trimOrNull(_he.text),
      nameFr: _trimOrNull(_fr.text),
      nameRu: _trimOrNull(_ru.text),
      color: _colorHex,
    ));
  }

  String? _trimOrNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  Widget _field(BuildContext context, TextEditingController c, String label, String langCode, {TextDirection? dir}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        textDirection: dir,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          hintText: AppLocalizations.of(context)!.adminSubjectNameInLang(label),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixText: langCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isNew = widget.initial.nameEn.isEmpty;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_subject_detail',
        onPressed: _save,
        icon: const Icon(Icons.check_rounded),
        label: Text(AppLocalizations.of(context)!.commonSave),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // ── Header row: back chevron + breadcrumb pill ───────────────
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  tooltip: AppLocalizations.of(context)!.a11yBack,
                  onPressed: () => Navigator.maybePop(context),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_rounded, size: 14, color: cs.onPrimaryContainer),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.adminSubjectDetailScreenSchoolSettings,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isNew ? AppLocalizations.of(context)!.adminSubjectDetailScreenNewSubject : widget.initial.nameEn,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _field(context, _en, AppLocalizations.of(context)!.adminSubjectDetailScreenLangEnglish, 'EN'),
            _field(context, _ar, AppLocalizations.of(context)!.adminSubjectDetailScreenLangArabic,  'AR', dir: TextDirection.rtl),
            _field(context, _he, AppLocalizations.of(context)!.adminSubjectDetailScreenLangHebrew,  'HE', dir: TextDirection.rtl),
            _field(context, _fr, AppLocalizations.of(context)!.adminSubjectDetailScreenLangFrench,  'FR'),
            _field(context, _ru, AppLocalizations.of(context)!.adminSubjectDetailScreenLangRussian, 'RU'),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.adminSubjectDetailScreenColor,
              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            _ColorSwatchPicker(
              value: _colorHex,
              fallbackSeed: _en.text.trim(),
              onChanged: (hex) => setState(() => _colorHex = hex),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact swatch grid for picking a subject color. `null` = use the
/// deterministic fallback derived from the subject name.
class _ColorSwatchPicker extends StatelessWidget {
  const _ColorSwatchPicker({
    required this.value,
    required this.fallbackSeed,
    required this.onChanged,
  });

  final String? value;
  final String fallbackSeed;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final current = parseSubjectColor(value);
    final fallback = subjectColorOrFallback(null, fallbackSeed);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Auto/default tile — shows the deterministic fallback hue.
        _SwatchTile(
          color: fallback,
          selected: value == null,
          icon: Icons.auto_awesome_rounded,
          onTap: () => onChanged(null),
        ),
        ...kSubjectPalette.map((c) {
          final hex = colorToHex(c);
          final isSelected = current != null && sameRgb(current, c);
          return _SwatchTile(
            color: c,
            selected: isSelected,
            onTap: () => onChanged(hex),
          );
        }),
        if (value != null)
          TextButton(
            onPressed: () => onChanged(null),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 32),
              foregroundColor: cs.onSurfaceVariant,
            ),
            child: Text(AppLocalizations.of(context)!.adminSubjectResetButton, style: theme.textTheme.labelSmall),
          ),
      ],
    );
  }
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile({
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
            width: selected ? 2.2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 4, spreadRadius: 0.5)]
              : null,
        ),
        child: icon != null
            ? Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.85))
            : (selected ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null),
      ),
    );
  }
}
