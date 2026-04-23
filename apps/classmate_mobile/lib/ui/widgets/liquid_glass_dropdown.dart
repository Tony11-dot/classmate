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
            color: cs.outlineVariant.withValues(alpha: 0.32),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              spreadRadius: -10,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.10),
            ),
          ],
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
    return v.toString();
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

class _LiquidGlassPicker<T> extends StatefulWidget {
  final String title;
  final T value;
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
        blurSigma: 18,
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
                    fillColor: cs.surface.withValues(alpha: 0.44),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.42),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.42),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.primary.withValues(alpha: 0.8),
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
                    color: cs.outlineVariant.withValues(alpha: 0.35),
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
