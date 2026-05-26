// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/teacher_mobile_repository.dart';

/// Reusable audience section: cohort DDL + grade DDL + student DDL + member
/// preview. No classroom picker — use the add-assignment/material/meeting
/// screens for that.
class AudienceSection extends StatefulWidget {
  const AudienceSection({
    super.key,
    required this.cohorts,
    required this.allStudents,
    required this.selectedCohortIds,
    required this.selectedStudentIds,
    required this.selectedGrades,
    required this.availableGrades,
    required this.repo,
    required this.onChanged,
  });

  final List<({String id, String name, int grade})> cohorts;
  final List<TeacherStudentWithLevel> allStudents;
  final Set<String> selectedCohortIds;
  final Set<String> selectedStudentIds;
  /// Grade levels the teacher wants to target. Server treats this as a
  /// union OR'd with cohort/student/EVERYONE — so a student whose
  /// StudentProfile.grade is in this set will see the item even when
  /// they aren't in any matching cohort or student list.
  final Set<int> selectedGrades;
  /// Grades the teacher can choose from. Caller typically derives this
  /// from the school's min/max grade range or the unique grades across
  /// their cohorts.
  final List<int> availableGrades;
  final TeacherMobileRepository repo;
  /// Called when either set changes so parent can setState.
  final VoidCallback onChanged;

  @override
  State<AudienceSection> createState() => _AudienceSectionState();
}

class _AudienceSectionState extends State<AudienceSection> {
  final Map<String, List<String>> _memberCache = {};

  Future<void> _fetchCohortMembers(String cohortId) async {
    if (_memberCache.containsKey(cohortId)) return;
    try {
      final students = await widget.repo.fetchCohortStudents(cohortId);
      if (mounted) setState(() => _memberCache[cohortId] = students.map((s) => s.name).toList());
    } catch (_) {}
  }

  List<String> get _previewMembers {
    final seen = <String>{};
    final result = <String>[];
    for (final id in widget.selectedCohortIds) {
      for (final n in (_memberCache[id] ?? [])) {
        if (seen.add(n)) result.add(n);
      }
    }
    result.sort();
    return result;
  }

  Future<void> _openCohortPicker() async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _MultiPickerSheet(
        title: 'Select cohorts',
        items: widget.cohorts
            .map((c) => _Item(id: c.id, label: c.name, subtitle: c.grade > 0 ? 'Grade ${c.grade}' : ''))
            .toList(),
        selected: Set.from(widget.selectedCohortIds),
        onToggle: (id) {
          if (widget.selectedCohortIds.contains(id)) {
            widget.selectedCohortIds.remove(id);
          } else {
            widget.selectedCohortIds.add(id);
            _fetchCohortMembers(id);
          }
          widget.onChanged();
        },
      ),
    );
  }

  Future<void> _openStudentPicker() async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _MultiPickerSheet(
        title: 'Select students',
        items: widget.allStudents
            .map((s) => _Item(id: s.studentId, label: s.name, subtitle: s.gradeLevel != null ? 'Grade ${s.gradeLevel}' : ''))
            .toList(),
        selected: Set.from(widget.selectedStudentIds),
        onToggle: (id) {
          if (widget.selectedStudentIds.contains(id)) {
            widget.selectedStudentIds.remove(id);
          } else {
            widget.selectedStudentIds.add(id);
          }
          widget.onChanged();
        },
      ),
    );
  }

  Future<void> _openGradePicker() async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _MultiPickerSheet(
        title: 'Select grades',
        items: widget.availableGrades
            .map((g) => _Item(id: g.toString(), label: 'Grade $g'))
            .toList(),
        selected: widget.selectedGrades.map((g) => g.toString()).toSet(),
        onToggle: (id) {
          final g = int.tryParse(id);
          if (g == null) return;
          if (widget.selectedGrades.contains(g)) {
            widget.selectedGrades.remove(g);
          } else {
            widget.selectedGrades.add(g);
          }
          widget.onChanged();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final preview = _previewMembers;

    final sortedGrades = widget.selectedGrades.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cohorts row
        _AudienceRow(
          icon: Icons.groups_rounded,
          label: 'Cohorts',
          summary: widget.selectedCohortIds.isEmpty
              ? null
              : widget.cohorts
                  .where((c) => widget.selectedCohortIds.contains(c.id))
                  .map((c) => c.name)
                  .join(', '),
          onTap: _openCohortPicker,
          cs: cs,
          theme: theme,
        ),
        const SizedBox(height: 8),
        // Grades row — only show when the caller supplied options.
        if (widget.availableGrades.isNotEmpty) ...[
          _AudienceRow(
            icon: Icons.school_rounded,
            label: 'Grades',
            summary: sortedGrades.isEmpty
                ? null
                : sortedGrades.map((g) => 'Grade $g').join(', '),
            onTap: _openGradePicker,
            cs: cs,
            theme: theme,
          ),
          const SizedBox(height: 8),
        ],
        // Students row
        _AudienceRow(
          icon: Icons.person_rounded,
          label: 'Students',
          summary: widget.selectedStudentIds.isEmpty
              ? null
              : '${widget.selectedStudentIds.length} student${widget.selectedStudentIds.length == 1 ? '' : 's'}',
          onTap: _openStudentPicker,
          cs: cs,
          theme: theme,
        ),
        // Member preview
        if (preview.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${preview.length} member${preview.length == 1 ? '' : 's'} will receive this',
                style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: preview
                    .map((name) => Chip(
                          label: Text(name, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ]),
          ),
        ],
        if (widget.selectedCohortIds.isEmpty &&
            widget.selectedStudentIds.isEmpty &&
            widget.selectedGrades.isEmpty) ...[
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.adminVisibleToEveryone, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ],
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _Item {
  const _Item({required this.id, required this.label, this.subtitle = ''});
  final String id;
  final String label;
  final String subtitle;
}

class _AudienceRow extends StatelessWidget {
  const _AudienceRow({required this.icon, required this.label, required this.summary, required this.onTap, required this.cs, required this.theme});
  final IconData icon;
  final String label;
  final String? summary;
  final VoidCallback onTap;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final hasValue = summary != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasValue ? cs.primaryContainer.withValues(alpha: 0.3) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasValue ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: hasValue ? cs.primary : cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          if (hasValue) Expanded(child: Text(summary!, textAlign: TextAlign.end, style: theme.textTheme.bodyMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)) else const Spacer(),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
        ]),
      ),
    );
  }
}

class _MultiPickerSheet extends StatefulWidget {
  const _MultiPickerSheet({required this.title, required this.items, required this.selected, required this.onToggle});
  final String title;
  final List<_Item> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  State<_MultiPickerSheet> createState() => _MultiPickerSheetState();
}

class _MultiPickerSheetState extends State<_MultiPickerSheet> {
  String _query = '';
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
  }

  void _toggle(String id) {
    setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));
    widget.onToggle(id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final q = _query.toLowerCase();
    final filtered = widget.items.where((i) => q.isEmpty || i.label.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q)).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, sc) => Column(children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(children: [
            Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const Spacer(),
            if (_selected.isNotEmpty)
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)), child: Text('${_selected.length} selected', style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 12))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(onChanged: (v) => setState(() => _query = v), decoration: InputDecoration(hintText: AppLocalizations.of(context)!.teacherMaterialSearchHint, prefixIcon: const Icon(Icons.search_rounded, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14))),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.commonNothingFound, style: TextStyle(color: cs.onSurfaceVariant)))
              : ListView.builder(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final item = filtered[i];
                    final isSelected = _selected.contains(item.id);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _toggle(item.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Row(children: [
                            Container(width: 38, height: 38, decoration: BoxDecoration(color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: Text(item.label.isNotEmpty ? item.label[0].toUpperCase() : '?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant))),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                              Text(item.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: isSelected ? cs.primary : null)),
                              if (item.subtitle.isNotEmpty) Text(item.subtitle, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                            ])),
                            Checkbox(value: isSelected, onChanged: (_) => _toggle(item.id), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
