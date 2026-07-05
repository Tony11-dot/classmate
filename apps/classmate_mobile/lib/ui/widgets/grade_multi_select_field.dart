import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../glass/liquid_glass_card.dart';

/// Liquid-glass multi-select for grade levels. The trigger matches the
/// look of [LiquidGlassDropdown]; tapping it opens a glass sheet with one
/// checkbox row per grade. Used by the teacher cohort editor so picking
/// grades feels like the rest of the app's glass selectors (and lets a
/// teacher pick several grades at once, exactly like the admin flow).
class GradeMultiSelectField extends StatefulWidget {
  const GradeMultiSelectField({
    super.key,
    required this.label,
    required this.availableGrades,
    required this.selected,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final List<int> availableGrades;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;
  final String? hint;

  @override
  State<GradeMultiSelectField> createState() => _GradeMultiSelectFieldState();
}

class _GradeMultiSelectFieldState extends State<GradeMultiSelectField> {
  Future<void> _open() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _GradePickerSheet(
        title: widget.label,
        grades: widget.availableGrades,
        selected: Set<int>.from(widget.selected),
        onChanged: (next) {
          widget.onChanged(next);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  String _summary(AppLocalizations l) {
    final sel = widget.selected.toList()..sort();
    if (sel.isEmpty) return widget.hint ?? '';
    if (sel.length == 1) return l.adminCohortGradeFormat(sel.first.toString());
    return sel.map((g) => g.toString()).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final hasValue = widget.selected.isNotEmpty;

    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface.withValues(alpha: isDark ? 0.76 : 0.88),
              cs.surfaceContainerHigh.withValues(alpha: isDark ? 0.56 : 0.66),
            ],
          ),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _summary(l),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: hasValue ? null : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _GradePickerSheet extends StatefulWidget {
  const _GradePickerSheet({
    required this.title,
    required this.grades,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<int> grades;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  State<_GradePickerSheet> createState() => _GradePickerSheetState();
}

class _GradePickerSheetState extends State<_GradePickerSheet> {
  late final Set<int> _selected = Set<int>.from(widget.selected);

  void _toggle(int g) {
    setState(() {
      if (_selected.contains(g)) {
        _selected.remove(g);
      } else {
        _selected.add(g);
      }
    });
    widget.onChanged(Set<int>.from(_selected));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final radius = BorderRadius.circular(22);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: LiquidGlassCard(
        borderRadius: radius,
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: l.commonClose,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  itemCount: widget.grades.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: cs.outlineVariant),
                  itemBuilder: (context, i) {
                    final g = widget.grades[i];
                    final selected = _selected.contains(g);
                    return ListTile(
                      title: Text(l.adminCohortGradeFormat(g.toString())),
                      trailing: Checkbox(
                        value: selected,
                        onChanged: (_) => _toggle(g),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onTap: () => _toggle(g),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l.commonDone),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
