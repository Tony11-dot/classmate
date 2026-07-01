import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../glass/liquid_glass_card.dart';

class LiquidGlassDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  const LiquidGlassDropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Opens the same searchable bottom-sheet picker that [LiquidGlassDropdown]
/// uses internally — handy when you have a custom trigger (chip, icon, etc.)
/// but want a consistent picker UI.
Future<T?> showLiquidGlassPicker<T>({
  required BuildContext context,
  required String title,
  required T? currentValue,
  required List<LiquidGlassDropdownItem<T>> items,
  String? searchHint,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _LiquidGlassPicker<T>(
      title: title,
      value: currentValue,
      items: items,
      searchHint: searchHint,
    ),
  );
}

class LiquidGlassDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<LiquidGlassDropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final String? searchHint;
  final bool enabled;

  const LiquidGlassDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.searchHint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: enabled ? () => _open(context) : null,
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
          border: Border.all(
            color: cs.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _labelFor(value),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
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

  String _labelFor(T v) {
    for (final it in items) {
      if (it.value == v) return it.label;
    }
    // No matching item (e.g. a null/unset value). Never render the literal
    // "null" — fall back to the first item's label if there is one, else blank.
    return items.isNotEmpty ? items.first.label : '';
  }

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _LiquidGlassPicker<T>(
        title: label,
        value: value,
        items: items,
        searchHint: searchHint,
      ),
    );

    if (selected != null && selected != value) onChanged(selected);
  }
}

/// Like [LiquidGlassDropdown] but accepts a NULLABLE value and shows a [hint]
/// when nothing is selected — for forms where no option is chosen initially.
class LiquidGlassSelectField<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<LiquidGlassDropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final String? searchHint;

  const LiquidGlassSelectField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.enabled = true,
    this.searchHint,
  });

  String? _labelFor(T? v) {
    for (final it in items) {
      if (it.value == v) return it.label;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final selectedLabel = _labelFor(value);

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: enabled ? () => _open(context) : null,
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
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedLabel ?? (hint ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selectedLabel == null ? cs.onSurfaceVariant : cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final selected = await showLiquidGlassPicker<T>(
      context: context,
      title: label,
      currentValue: value,
      items: items,
      searchHint: searchHint,
    );
    if (selected != null && selected != value) onChanged(selected);
  }
}

/// An editable text field with a dropdown to PICK a suggested value (e.g. a
/// teacher/principal name). Picking fills the field; the user can still type a
/// custom value. Used where a name should be auto-filled but stay editable.
class LiquidGlassNameField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final List<String> options;

  const LiquidGlassNameField({
    super.key,
    required this.controller,
    required this.label,
    this.options = const [],
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showLiquidGlassPicker<String>(
      context: context,
      title: label,
      currentValue: controller.text,
      items: options.map((o) => LiquidGlassDropdownItem(value: o, label: o)).toList(),
    );
    if (picked != null) controller.text = picked;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: options.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_drop_down_rounded),
                onPressed: () => _pick(context),
              ),
      ),
    );
  }
}

class _LiquidGlassPicker<T> extends StatefulWidget {
  final String title;
  final T? value;
  final List<LiquidGlassDropdownItem<T>> items;
  final String? searchHint;

  const _LiquidGlassPicker({
    required this.title,
    required this.value,
    required this.items,
    this.searchHint,
  });

  @override
  State<_LiquidGlassPicker<T>> createState() => _LiquidGlassPickerState<T>();
}

class _LiquidGlassPickerState<T> extends State<_LiquidGlassPicker<T>> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(22);
    final l = AppLocalizations.of(context)!;

    final items = widget.items
        .where((it) {
          final q = _q.trim().toLowerCase();
          if (q.isEmpty) return true;
          return it.label.toLowerCase().contains(q);
        })
        .toList(growable: false);

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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    hintText: widget.searchHint ?? l.practiceSetupSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: cs.outlineVariant,
                  ),
                  itemBuilder: (context, i) {
                    final it = items[i];
                    final selected = it.value == widget.value;
                    return ListTile(
                      leading: it.icon != null ? Icon(it.icon) : null,
                      title: Text(it.label),
                      trailing: selected ? const Icon(Icons.check_rounded) : null,
                      onTap: () => Navigator.of(context).pop<T>(it.value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
