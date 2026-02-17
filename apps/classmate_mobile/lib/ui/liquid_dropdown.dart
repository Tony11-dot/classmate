import 'dart:ui';
import 'package:flutter/material.dart';

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

class LiquidDropdown<T> extends StatelessWidget {
  const LiquidDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    this.hint,
    this.enabled = true,
    this.onChanged,
    this.searchable = true,
    this.sheetTitle,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String label;
  final String? hint;
  final bool enabled;
  final bool searchable;
  final String? sheetTitle;

  final ValueChanged<T?>? onChanged;

  String _labelOf(DropdownMenuItem<T> it) {
    final w = it.child;
    if (w is Text) return w.data ?? '';
    return w.toStringShort();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final current = value;
    final selectedLabel = items
        .where((it) => it.value == current)
        .map(_labelOf)
        .cast<String?>()
        .firstWhere((x) => x != null, orElse: () => null);

    // Match TextField height/feel
    final decoration = InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );

    return GestureDetector(
      onTap: !enabled
          ? null
          : () async {
              final picked = await _openSheet(context, current);
              if (picked == _NoPick.instance) return;
              onChanged?.call(picked as T?);
            },
      child: AbsorbPointer(
        child: InputDecorator(
          decoration: decoration,
          isEmpty: selectedLabel == null || selectedLabel.isEmpty,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  (selectedLabel == null || selectedLabel.isEmpty)
                      ? (hint ?? '')
                      : selectedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: (selectedLabel == null || selectedLabel.isEmpty)
                        ? cs.onSurface.withValues(alpha: 0.55)
                        : cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: cs.onSurface.withValues(alpha: enabled ? 0.8 : 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Object> _openSheet(BuildContext context, T? current) async {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    // items -> (value,label)
    final rows = <_Opt<T>>[
      for (final it in items) _Opt<T>(it.value, _labelOf(it)),
    ];

    final q = TextEditingController();
    return showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        List<_Opt<T>> filtered() {
          final s = q.text.trim().toLowerCase();
          if (s.isEmpty) return rows;
          return rows.where((r) => r.label.toLowerCase().contains(s)).toList();
        }

        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final list = filtered();

            return Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _isDark(ctx) ? 16 : 20,
                    sigmaY: _isDark(ctx) ? 16 : 20,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(
                        alpha: _isDark(ctx) ? 0.74 : 0.86,
                      ),
                      border: Border.all(
                        color: cs.outline.withValues(
                          alpha: _isDark(ctx) ? 0.30 : 0.18,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (sheetTitle != null &&
                              sheetTitle!.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  sheetTitle!,
                                  style: t.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),

                          if (searchable)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                              child: TextField(
                                controller: q,
                                onChanged: (_) => setLocal(() {}),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  hintText: 'Search…',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: cs.surface.withValues(
                                    alpha: _isDark(ctx) ? 0.55 : 0.70,
                                  ),
                                ),
                              ),
                            ),

                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                              itemCount: list.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: cs.outline.withValues(
                                  alpha: _isDark(ctx) ? 0.22 : 0.14,
                                ),
                              ),
                              itemBuilder: (ctx, i) {
                                final it = list[i];
                                final selected = it.value == current;

                                return ListTile(
                                  title: Text(
                                    it.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: selected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: cs.primary,
                                        )
                                      : null,
                                  onTap: () =>
                                      Navigator.pop(ctx, it.value as Object?),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((v) => v ?? _NoPick.instance);
  }
}

class _Opt<T> {
  final T? value;
  final String label;
  const _Opt(this.value, this.label);
}

class _NoPick {
  static final instance = _NoPick._();
  _NoPick._();
}
