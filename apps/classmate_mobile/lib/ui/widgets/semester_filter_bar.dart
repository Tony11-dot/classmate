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

/// Every PAST semester (most-recent first) for the school — drives the
/// "filter to a specific semester" dropdown under the Previous pill.
final pastSemestersProvider = Provider<List<LabeledSemester>>((ref) {
  final raw = ref.watch(authSessionProvider).schoolSemesters;
  return enumeratePastSemesters(parseSchoolSemesters(raw), DateTime.now());
});

/// Two pills — "This semester" / "Previous" — matching the teacher
/// announcements Received/Published layout. When "Previous" is selected and
/// the caller wires [onPastChanged], a liquid-glass filter button appears that
/// lets the user drill into ONE specific past semester ("Semester 1 · 26/27").
/// Renders nothing when the school has no semesters.
class SemesterFilterBar extends ConsumerWidget {
  const SemesterFilterBar({
    super.key,
    required this.showingPrevious,
    required this.onChanged,
    this.visible = true,
    this.selectedPast,
    this.onPastChanged,
  });

  /// false = This semester, true = Previous.
  final bool showingPrevious;
  final ValueChanged<bool> onChanged;
  final bool visible;

  /// The specific past semester currently filtered to (null = all previous).
  final SemesterWindow? selectedPast;

  /// When non-null, the filter button + dropdown is shown under "Previous".
  final ValueChanged<SemesterWindow?>? onPastChanged;

  String _semLabel(AppLocalizations l, LabeledSemester s) =>
      '${l.adminSchoolSemesterN(s.number.toString())} · ${s.yearLabel}';

  Future<void> _pickSemester(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final past = ref.read(pastSemestersProvider);
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l.semesterSelectTitle,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.layers_rounded, color: cs.primary),
              title: Text(l.semesterAllPrevious),
              trailing: selectedPast == null ? Icon(Icons.check_rounded, color: cs.primary) : null,
              onTap: () { Navigator.of(ctx).pop(); onPastChanged?.call(null); },
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: past.map((s) {
                  final sel = selectedPast != null &&
                      selectedPast!.start == s.window.start && selectedPast!.end == s.window.end;
                  return ListTile(
                    leading: Icon(Icons.event_rounded, color: cs.onSurfaceVariant),
                    title: Text(_semLabel(l, s)),
                    trailing: sel ? Icon(Icons.check_rounded, color: cs.primary) : null,
                    onTap: () { Navigator.of(ctx).pop(); onPastChanged?.call(s.window); },
                  );
                }).toList(growable: false),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!visible) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final past = ref.watch(pastSemestersProvider);
    final showFilter = showingPrevious && onPastChanged != null && past.isNotEmpty;

    // Resolve the selected past window to a label for the filter button.
    String filterLabel = l.semesterAllPrevious;
    if (selectedPast != null) {
      final match = past.where((s) =>
          s.window.start == selectedPast!.start && s.window.end == selectedPast!.end);
      if (match.isNotEmpty) filterLabel = _semLabel(l, match.first);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _Pill(label: l.semesterThis, selected: !showingPrevious, onTap: () => onChanged(false)),
          _Pill(label: l.semesterPrevious, selected: showingPrevious, onTap: () => onChanged(true)),
          if (showFilter)
            Material(
              color: selectedPast != null ? cs.primaryContainer : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _pickSemester(context, ref),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, size: 15, color: cs.primary),
                      const SizedBox(width: 6),
                      Text(filterLabel,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13,
                              color: selectedPast != null ? cs.onPrimaryContainer : cs.onSurfaceVariant)),
                      const SizedBox(width: 2),
                      Icon(Icons.expand_more_rounded, size: 16, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
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
