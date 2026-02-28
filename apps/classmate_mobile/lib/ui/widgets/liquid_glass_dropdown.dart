import 'dart:ui';
import 'package:flutter/material.dart';

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
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: enabled ? () => _open(context) : null,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
          color: cs.surface.withOpacity(0.55),
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

    final items = widget.items
        .where((it) {
          final q = _q.trim().toLowerCase();
          if (q.isEmpty) return true;
          return it.label.toLowerCase().contains(q);
        })
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: cs.surface.withOpacity(0.72),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 28,
                  spreadRadius: 2,
                  color: Colors.black.withOpacity(0.16),
                ),
              ],
            ),
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
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
                        hintText: widget.searchHint ?? 'Search...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: cs.surface.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withOpacity(0.55),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withOpacity(0.55),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: cs.primary.withOpacity(0.8),
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
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: cs.outlineVariant.withOpacity(0.35),
                      ),
                      itemBuilder: (context, i) {
                        final it = items[i];
                        final selected = it.value == widget.value;
                        return ListTile(
                          leading: it.icon != null ? Icon(it.icon) : null,
                          title: Text(it.label),
                          trailing: selected
                              ? const Icon(Icons.check_rounded)
                              : null,
                          onTap: () => Navigator.of(context).pop<T>(it.value),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
