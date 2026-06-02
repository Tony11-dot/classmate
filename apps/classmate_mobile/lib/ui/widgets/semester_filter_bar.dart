import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/semester/school_semester.dart';
import '../../l10n/app_localizations.dart';

/// The concrete semester window for "now", or null when the school configured
/// no semesters. Pages use this to split data into This-semester vs Previous.
final currentSemesterWindowProvider = Provider<SemesterWindow?>((ref) {
  final raw = ref.watch(authSessionProvider).schoolSemesters;
  final sems = parseSchoolSemesters(raw);
  return currentSemesterWindow(sems, DateTime.now());
});

/// Two pills — "This semester" / "Previous" — matching the teacher
/// announcements Received/Published layout. Renders nothing when the school
/// has no semesters (so non-semester schools see the plain list).
class SemesterFilterBar extends StatelessWidget {
  const SemesterFilterBar({
    super.key,
    required this.showingPrevious,
    required this.onChanged,
    this.visible = true,
  });

  /// false = This semester, true = Previous.
  final bool showingPrevious;
  final ValueChanged<bool> onChanged;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          _Pill(
            label: l.semesterThis,
            selected: !showingPrevious,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 8),
          _Pill(
            label: l.semesterPrevious,
            selected: showingPrevious,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primary : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders [children] incrementally: shows the first [step] and a "Show more"
/// button that reveals [step] more each tap. Resets when the child list shrinks
/// (e.g. switching pills/filters).
class ShowMoreList extends StatefulWidget {
  const ShowMoreList({super.key, required this.children, this.step = 10});
  final List<Widget> children;
  final int step;

  @override
  State<ShowMoreList> createState() => _ShowMoreListState();
}

class _ShowMoreListState extends State<ShowMoreList> {
  late int _visible = widget.step;

  @override
  void didUpdateWidget(ShowMoreList old) {
    super.didUpdateWidget(old);
    // If the underlying list changed length a lot (filter switch), clamp.
    if (widget.children.length < _visible) _visible = widget.step;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final total = widget.children.length;
    final shown = _visible.clamp(0, total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.children.take(shown),
        if (shown < total)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _visible += widget.step),
              icon: const Icon(Icons.expand_more_rounded),
              label: Text(l.showMore),
            ),
          ),
      ],
    );
  }
}
