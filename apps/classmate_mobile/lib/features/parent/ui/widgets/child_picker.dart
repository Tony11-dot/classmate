import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/parent_models.dart';
import '../../data/parent_repository.dart';

/// Horizontally-scrollable chip list — one chip per linked child.
/// Selecting a chip writes to selectedChildProvider; every parent
/// screen watches that provider so they re-fetch when the parent
/// switches between siblings.
class ChildPicker extends ConsumerWidget {
  const ChildPicker({super.key, required this.children});
  final List<ParentChild> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selected = ref.watch(selectedChildProvider);

    // First-render: if nothing's selected yet AND we have children, auto-pick
    // the first one so the tools don't sit in "pick a child" state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selected == null && children.isNotEmpty) {
        ref.read(selectedChildProvider.notifier).select(children.first.studentId);
      }
    });

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final c = children[i];
          final isSelected = c.studentId == selected;
          return GestureDetector(
            onTap: () => ref.read(selectedChildProvider.notifier).select(c.studentId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? cs.primaryContainer : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? cs.primary : Colors.transparent,
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isSelected ? cs.primary : cs.surfaceContainerHighest,
                    child: Text(
                      _initials(c.name),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isSelected ? cs.onPrimary : cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c.name.isEmpty ? '—' : c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (c.gradeLabel.isNotEmpty)
                          Text(
                            c.gradeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
