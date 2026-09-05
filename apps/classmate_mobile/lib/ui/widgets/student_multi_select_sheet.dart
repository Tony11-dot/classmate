import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../glass/liquid_glass_card.dart';

/// One selectable row in [showStudentMultiSelectSheet].
class MultiSelectItem {
  const MultiSelectItem({required this.id, required this.name, this.subtitle});
  final String id;
  final String name;
  final String? subtitle;
}

/// A liquid-glass bottom sheet for multi-selecting people (students).
///
/// Rows are glass cards with a check; a Select all / Unselect all toggle sits
/// in the header. Returns the chosen ids, or `null` if dismissed/cancelled.
Future<Set<String>?> showStudentMultiSelectSheet({
  required BuildContext context,
  required String title,
  required List<MultiSelectItem> items,
  Set<String>? initiallySelected,
  String? confirmLabel,
  bool requireSelection = false,
}) {
  final selected = <String>{...?initiallySelected};
  // Only long lists get a search bar — grade/short pickers don't need one.
  final searchable = items.length > 6;
  final searchCtl = TextEditingController();
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final l = AppLocalizations.of(ctx)!;
      final cs = Theme.of(ctx).colorScheme;
      final theme = Theme.of(ctx);
      return StatefulBuilder(builder: (ctx, setSheet) {
        final query = searchCtl.text.trim().toLowerCase();
        final visible = query.isEmpty
            ? items
            : items
                .where((it) =>
                    it.name.toLowerCase().contains(query) ||
                    (it.subtitle?.toLowerCase().contains(query) ?? false))
                .toList();
        final allSelected = items.isNotEmpty && selected.length >= items.length;
        // Lift the whole sheet above the keyboard so results and the confirm
        // button are never covered (QA #41).
        final keyboardInset = MediaQuery.viewInsetsOf(ctx).bottom;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (ctx, scroll) => Padding(
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                child: Row(children: [
                  Expanded(
                    child: Text(title,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  TextButton.icon(
                    onPressed: () => setSheet(() {
                      if (allSelected) {
                        selected.clear();
                      } else {
                        selected
                          ..clear()
                          ..addAll(items.map((e) => e.id));
                      }
                    }),
                    icon: Icon(allSelected ? Icons.remove_done_rounded : Icons.done_all_rounded, size: 18),
                    label: Text(allSelected ? l.pickerUnselectAll : l.pickerSelectAll),
                  ),
                ]),
              ),
              if (searchable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: searchCtl,
                    onChanged: (_) => setSheet(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l.commonSearch,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      // Clear (X) button — appears once there's text (QA #43).
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () => setSheet(() => searchCtl.clear()),
                            ),
                      filled: true,
                      fillColor: cs.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Text(l.commonNoResults,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      )
                    : ListView.separated(
                  controller: scroll,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final it = visible[i];
                    final on = selected.contains(it.id);
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setSheet(() {
                        if (on) {
                          selected.remove(it.id);
                        } else {
                          selected.add(it.id);
                        }
                      }),
                      child: LiquidGlassCard(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        color: on ? cs.primaryContainer : cs.surfaceContainerLow,
                        border: Border.all(
                            color: on ? cs.primary : cs.outlineVariant.withValues(alpha: 0.6)),
                        child: Row(children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: on ? cs.onPrimaryContainer : cs.onSurface)),
                                if (it.subtitle != null && it.subtitle!.isNotEmpty)
                                  Text(it.subtitle!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                          color: on
                                              ? cs.onPrimaryContainer.withValues(alpha: 0.8)
                                              : cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Icon(
                            on ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: on ? cs.primary : cs.outlineVariant,
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // Stays disabled until at least one row is picked when the
                      // caller requires a non-empty selection (QA #45/#46).
                      onPressed: (requireSelection && selected.isEmpty)
                          ? null
                          : () => Navigator.pop(ctx, selected),
                      child: Text(confirmLabel ?? '${l.commonSave} (${selected.length})'),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          ),
        );
      });
    },
  );
}
