// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../lifedoc/announcements_provider.dart';
import '../data/teacher_mobile_repository.dart';

// Role descriptor
class _Role {
  const _Role(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
}

const _kRoles = [
  _Role('STUDENT', 'Students', Icons.school_rounded),
  _Role('PARENT', 'Parents', Icons.family_restroom_rounded),
  _Role('TEACHER', 'Teachers', Icons.person_rounded),
  _Role('ADMIN', 'Admins', Icons.admin_panel_settings_rounded),
  _Role('SECRETARY', 'Secretaries', Icons.support_agent_rounded),
];

class TeacherNewAnnouncementScreen extends ConsumerStatefulWidget {
  const TeacherNewAnnouncementScreen({super.key});

  @override
  ConsumerState<TeacherNewAnnouncementScreen> createState() =>
      _TeacherNewAnnouncementScreenState();
}

class _TeacherNewAnnouncementScreenState
    extends ConsumerState<TeacherNewAnnouncementScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _saving = false;

  // ── Audience ──────────────────────────────────────────────────────────────
  final Set<String> _selectedRoles = {};        // e.g. {'STUDENT', 'PARENT'}
  final Set<String> _selectedStudentIds = {};   // individual userId targets
  final Set<String> _selectedCohortIds = {};    // cohort targets

  // loaded once
  List<TeacherStudentWithLevel> _allStudents = [];
  List<({String id, String name, int grade})> _cohorts = [];
  final Map<String, List<String>> _cohortMemberCache = {};
  bool _loadingPeople = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadPeople);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPeople() async {
    setState(() => _loadingPeople = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait([
        repo.fetchAllStudents(),
        repo.fetchCohortsForPicker(),
      ]);
      if (!mounted) return;
      final cohortMaps = results[1] as List<Map<String, dynamic>>;
      setState(() {
        _allStudents = results[0] as List<TeacherStudentWithLevel>;
        _cohorts = cohortMaps.map((c) => (
          id: (c['id'] ?? '').toString(),
          name: (c['name'] ?? '').toString(),
          grade: c['grade'] is int ? c['grade'] as int : int.tryParse('${c['grade'] ?? ''}') ?? 0,
        )).where((c) => c.id.isNotEmpty).toList()
          ..sort((a, b) => a.grade.compareTo(b.grade));
        _loadingPeople = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPeople = false);
    }
  }

  // Build the targets array for the API
  List<Map<String, dynamic>> get _targets {
    final targets = <Map<String, dynamic>>[];
    for (final r in _selectedRoles) {
      targets.add({'role': r});
    }
    for (final uid in _selectedStudentIds) {
      targets.add({'userId': uid});
    }
    for (final cid in _selectedCohortIds) {
      targets.add({'cohortId': cid});
    }
    return targets;
  }

  Future<void> _publish() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherTitleAndMessageRequired)),
      );
      return;
    }
    // Confirm broadcast when no specific audience is selected
    final targetsNow = _targets;
    if (targetsNow.isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dCtx) => AlertDialog(
          title: const Text('Broadcast to everyone?'),
          content: const Text(
            'No specific audience selected. This announcement will be visible to ALL students and teachers in the school.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dCtx, true), child: const Text('Send to everyone')),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(teacherMobileRepositoryProvider).createAnnouncement(
        title: title,
        body: body,
        targets: _targets,
      );
      ref.invalidate(publishedAnnouncementsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherAnnouncementPublished)),
      );
      if (context.canPop()) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherFailedToPublish(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Student picker bottom sheet ───────────────────────────────────────────

  Future<void> _openStudentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _PersonPickerSheet(
        title: 'Select students',
        items: _allStudents
            .map((s) => _PickerItem(
                  id: s.studentId,
                  label: s.name,
                  subtitle: s.gradeLevel != null ? 'Grade ${s.gradeLevel}' : '',
                ))
            .toList(),
        selected: Set.from(_selectedStudentIds),
        onToggle: (id) => setState(() {
          if (_selectedStudentIds.contains(id)) {
            _selectedStudentIds.remove(id);
          } else {
            _selectedStudentIds.add(id);
          }
        }),
      ),
    );
  }

  List<String> get _previewCohortMembers {
    final seen = <String>{};
    final result = <String>[];
    for (final id in _selectedCohortIds) {
      for (final n in (_cohortMemberCache[id] ?? [])) {
        if (seen.add(n)) result.add(n);
      }
    }
    result.sort();
    return result;
  }

  Future<void> _fetchCohortMembers(String cohortId) async {
    if (_cohortMemberCache.containsKey(cohortId)) return;
    try {
      final students = await ref.read(teacherMobileRepositoryProvider).fetchCohortStudents(cohortId);
      if (mounted) setState(() => _cohortMemberCache[cohortId] = students.map((s) => s.name).toList());
    } catch (_) {}
  }

  Future<void> _openCohortPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _PersonPickerSheet(
        title: 'Select cohorts',
        items: _cohorts
            .map((c) => _PickerItem(
                  id: c.id,
                  label: c.name,
                  subtitle: c.grade > 0 ? 'Grade ${c.grade}' : '',
                ))
            .toList(),
        selected: Set.from(_selectedCohortIds),
        onToggle: (id) {
          setState(() {
            if (_selectedCohortIds.contains(id)) {
              _selectedCohortIds.remove(id);
            } else {
              _selectedCohortIds.add(id);
              _fetchCohortMembers(id);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    final hasAudience = _selectedRoles.isNotEmpty ||
        _selectedStudentIds.isNotEmpty ||
        _selectedCohortIds.isNotEmpty;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/announcements'),
        ),
        title: Text(
          l.teacherNewAnnouncementAction,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _publish,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                  _saving ? l.teacherPublishingAction : l.teacherPublishAction),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Content card ────────────────────────────────────────────
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            color: cs.surfaceContainerLow,
            border:
                Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.teacherAnnouncementSectionTitle,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: l.teacherAnnounceTitleLabel,
                    hintText: l.teacherAnnounceTitleHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _bodyCtrl,
                  decoration: InputDecoration(
                    labelText: l.teacherAnnounceMessageLabel,
                    hintText: l.teacherAnnounceMessageHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    alignLabelWithHint: true,
                  ),
                  minLines: 5,
                  maxLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Audience card ───────────────────────────────────────────
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            color: cs.surfaceContainerLow,
            border:
                Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l.teacherAudienceSectionTitle,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    if (hasAudience)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_selectedRoles.length + _selectedStudentIds.length + _selectedCohortIds.length} selected',
                          style: TextStyle(
                              color: cs.onPrimaryContainer,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose roles, individual students, or whole cohorts',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 14),

                // Role pills
                Text(
                  'Roles',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _kRoles.map((r) {
                    final selected = _selectedRoles.contains(r.id);
                    return _AudienceChip(
                      label: r.label,
                      icon: r.icon,
                      selected: selected,
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedRoles.remove(r.id);
                        } else {
                          _selectedRoles.add(r.id);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Students DDL trigger
                Text(
                  'Individual students',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                _loadingPeople
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _PickerTrigger(
                        icon: Icons.person_search_rounded,
                        label: _selectedStudentIds.isEmpty
                            ? 'Tap to select students…'
                            : '${_selectedStudentIds.length} student${_selectedStudentIds.length == 1 ? "" : "s"} selected',
                        hasSelection: _selectedStudentIds.isNotEmpty,
                        onTap: _openStudentPicker,
                      ),
                if (_selectedStudentIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _allStudents
                        .where(
                            (s) => _selectedStudentIds.contains(s.studentId))
                        .map((s) => _MiniChip(
                              label: s.name,
                              onRemove: () => setState(
                                  () => _selectedStudentIds.remove(s.studentId)),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),

                // Cohorts DDL trigger
                Text(
                  'Cohorts',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                _cohorts.isEmpty
                    ? Text('No cohorts available',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 13))
                    : _PickerTrigger(
                        icon: Icons.groups_rounded,
                        label: _selectedCohortIds.isEmpty
                            ? 'Tap to select cohorts…'
                            : '${_selectedCohortIds.length} cohort${_selectedCohortIds.length == 1 ? "" : "s"} selected',
                        hasSelection: _selectedCohortIds.isNotEmpty,
                        onTap: _openCohortPicker,
                      ),
                if (_selectedCohortIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _cohorts
                        .where((c) => _selectedCohortIds.contains(c.id))
                        .map((c) => _MiniChip(
                              label: c.name,
                              onRemove: () => setState(
                                  () => _selectedCohortIds.remove(c.id)),
                            ))
                        .toList(),
                  ),
                  // Member preview
                  if (_previewCohortMembers.isNotEmpty) ...[
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
                        Text('${_previewCohortMembers.length} student${_previewCohortMembers.length == 1 ? '' : 's'} in selected cohorts',
                            style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, runSpacing: 4, children: _previewCohortMembers.map((name) => Chip(
                          label: Text(name, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: VisualDensity.compact,
                        )).toList()),
                      ]),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared picker widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PickerItem {
  const _PickerItem({required this.id, required this.label, this.subtitle = ''});
  final String id;
  final String label;
  final String subtitle;
}

class _PersonPickerSheet extends StatefulWidget {
  const _PersonPickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
  });
  final String title;
  final List<_PickerItem> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  State<_PersonPickerSheet> createState() => _PersonPickerSheetState();
}

class _PersonPickerSheetState extends State<_PersonPickerSheet> {
  String _query = '';
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
    widget.onToggle(id);
  }

  List<_PickerItem> get _filtered {
    if (_query.isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items
        .where((i) =>
            i.label.toLowerCase().contains(q) ||
            i.subtitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final filtered = _filtered;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text(widget.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (_selected.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${_selected.length} selected',
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('Nothing found',
                        style: TextStyle(color: cs.onSurfaceVariant)))
                : ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final isSelected =
                          _selected.contains(item.id);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _toggle(item.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cs.primaryContainer
                                        : cs.surfaceContainerHighest
                                            .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.label.isNotEmpty
                                          ? item.label[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: isSelected
                                            ? cs.onPrimaryContainer
                                            : cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(item.label,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? cs.primary
                                                      : null)),
                                      if (item.subtitle.isNotEmpty)
                                        Text(item.subtitle,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    color:
                                                        cs.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggle(item.id),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(6)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable chips
// ─────────────────────────────────────────────────────────────────────────────

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? cs.primaryContainer
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15,
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
                color: selected ? cs.onPrimaryContainer : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTrigger extends StatelessWidget {
  const _PickerTrigger({
    required this.icon,
    required this.label,
    required this.hasSelection,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool hasSelection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: hasSelection ? null : cs.onSurfaceVariant,
                  fontWeight: hasSelection
                      ? FontWeight.w600
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 14,
                color: cs.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
