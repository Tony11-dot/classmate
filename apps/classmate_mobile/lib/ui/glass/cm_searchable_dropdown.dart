import 'package:flutter/material.dart';

class CMSearchableDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onChanged;

  const CMSearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        final result = await showModalBottomSheet<T>(
          context: context,
          isScrollControlled: true,
          backgroundColor: cs.surface.withValues(alpha: .96),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => _DropdownSheet(items: items, itemLabel: itemLabel),
        );

        if (result != null) onChanged(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surfaceContainerHighest.withValues(alpha: .6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? label : itemLabel(value as T),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }
}

class _DropdownSheet<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;

  const _DropdownSheet({required this.items, required this.itemLabel});

  @override
  State<_DropdownSheet<T>> createState() => _DropdownSheetState<T>();
}

class _DropdownSheetState<T> extends State<_DropdownSheet<T>> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((e) {
      return widget.itemLabel(e).toLowerCase().contains(query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];

                return ListTile(
                  title: Text(widget.itemLabel(item)),
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
