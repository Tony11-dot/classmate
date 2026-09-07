// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/teacher_mobile_repository.dart';

class TeacherCreateClassroomScreen extends ConsumerStatefulWidget {
  const TeacherCreateClassroomScreen({super.key, this.onCreated});

  final VoidCallback? onCreated;

  @override
  ConsumerState<TeacherCreateClassroomScreen> createState() =>
      _TeacherCreateClassroomScreenState();
}

class _TeacherCreateClassroomScreenState
    extends ConsumerState<TeacherCreateClassroomScreen> {
  final _nameCtrl = TextEditingController();
  List<String> _schoolSubjects = [];
  String? _selectedSubject;
  List<TeacherStudentWithLevel> _allStudents = [];
  List<Map<String, dynamic>> _allCohorts = [];
  final Set<String> _selectedStudentIds = {};
  final Set<String> _selectedCohortIds = {};
  // Students fetched from selected cohorts (preview)
  final Map<String, List<TeacherStudent>> _cohortStudentsCache = {};
  // Cohorts whose student list is currently being fetched.
  final Set<String> _loadingCohorts = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait<dynamic>([
        repo.fetchSubjects(),
        repo.fetchAllStudents(),
        repo.fetchCohortsForPicker(),
      ]);
      if (!mounted) return;
      setState(() {
        _schoolSubjects = results[0] as List<String>;
        _allStudents = results[1] as List<TeacherStudentWithLevel>;
        _allCohorts = results[2] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleCohort(String cohortId) async {
    setState(() {
      if (_selectedCohortIds.contains(cohortId)) {
        _selectedCohortIds.remove(cohortId);
      } else {
        _selectedCohortIds.add(cohortId);
      }
    });
    // Fetch students for newly selected cohort
    if (_selectedCohortIds.contains(cohortId) && !_cohortStudentsCache.containsKey(cohortId)) {
      if (mounted) setState(() => _loadingCohorts.add(cohortId));
      try {
        final students = await ref.read(teacherMobileRepositoryProvider).fetchCohortStudents(cohortId);
        // Always record the result (even an empty list) so the preview stops
        // showing a spinner once the fetch completes.
        if (mounted) setState(() => _cohortStudentsCache[cohortId] = students);
      } catch (_) {
        // On failure, record an empty list so we don't spin forever.
        if (mounted) setState(() => _cohortStudentsCache[cohortId] = const []);
      } finally {
        if (mounted) setState(() => _loadingCohorts.remove(cohortId));
      }
    }
  }

  // True only while at least one selected cohort is still being fetched.
  bool get _cohortsLoading =>
      _selectedCohortIds.any((id) => _loadingCohorts.contains(id));

  List<TeacherStudent> get _studentsFromSelectedCohorts {
    final seen = <String>{};
    final result = <TeacherStudent>[];
    for (final id in _selectedCohortIds) {
      for (final s in (_cohortStudentsCache[id] ?? [])) {
        if (!seen.contains(s.studentId)) {
          seen.add(s.studentId);
          result.add(s);
        }
      }
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final subject = _selectedSubject?.trim() ?? '';
    if (name.isEmpty) { _snack('Enter a classroom name.'); return; }
    if (subject.isEmpty) { _snack('Select a subject.'); return; }

    setState(() => _saving = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      await repo.createClassroom(
        name: name,
        subject: subject,
        studentIds: _selectedStudentIds.toList(),
        cohortIds: _selectedCohortIds.toList(),
      );
      if (!mounted) return;
      _snack('Classroom created!');
      widget.onCreated?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    ));
  }

  Future<void> _openCohortPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _MultiPickerSheet(
        title: AppLocalizations.of(context)!.pickerSelectCohorts,
        items: _allCohorts.map((c) => _PickerItem(
          id: c['id']?.toString() ?? '',
          label: (c['name'] ?? '').toString().replaceFirst(RegExp(r'^\d+\s*-\s*'), ''),
          subtitle: c['grade'] != null ? AppLocalizations.of(context)!.adminCohortGradeFormat(c['grade'].toString()) : '',
        )).toList(),
        selected: Set.from(_selectedCohortIds),
        onToggle: (id) => _toggleCohort(id),
      ),
    );
  }

  Future<void> _openStudentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _MultiPickerSheet(
        title: AppLocalizations.of(context)!.pickerSelectStudents,
        items: _allStudents.map((s) => _PickerItem(
          id: s.studentId,
          label: s.name,
          subtitle: s.gradeLevel != null ? 'Grade ${s.gradeLevel}' : '',
        )).toList(),
        selected: Set.from(_selectedStudentIds),
        onToggle: (id) => setState(() {
          _selectedStudentIds.contains(id)
              ? _selectedStudentIds.remove(id)
              : _selectedStudentIds.add(id);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cohortStudents = _studentsFromSelectedCohorts;
    final totalMembers = _selectedCohortIds.length + _selectedStudentIds.length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: l.a11yClose,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.of(context)!.teacherCreateClassroomNewTitle,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: _saving || _loading ? null : _save,
              icon: _saving
                  ? const CmLoading(size: 16, color: Colors.white)
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.commonCreate),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CmLoading())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                // ── Name ──────────────────────────────────────────────────────
                _SectionHeader(icon: Icons.class_rounded, title: AppLocalizations.of(context)!.teacherClassroomNameSection),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.teacherClassroomNameHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Subject ────────────────────────────────────────────────────
                _SectionHeader(icon: Icons.menu_book_rounded, title: AppLocalizations.of(context)!.assignmentsSubjectLabel),
                const SizedBox(height: 10),
                LiquidGlassDropdown<String>(
                  label: _selectedSubject ?? AppLocalizations.of(context)!.teacherSelectSubject,
                  value: _selectedSubject ?? '',
                  items: [
                    LiquidGlassDropdownItem(value: '', label: AppLocalizations.of(context)!.teacherSelectSubject, icon: Icons.auto_stories_outlined),
                    ..._schoolSubjects.map((s) => LiquidGlassDropdownItem(value: s, label: s, icon: Icons.menu_book_rounded)),
                  ],
                  onChanged: (v) => setState(() => _selectedSubject = v.isEmpty ? null : v),
                  searchHint: AppLocalizations.of(context)!.teacherMaterialSubjectSearch,
                ),
                const SizedBox(height: 24),

                // ── Cohorts DDL ────────────────────────────────────────────────
                Row(children: [
                  _SectionHeader(icon: Icons.groups_rounded, title: AppLocalizations.of(context)!.teacherAddByCohortSection),
                  const Spacer(),
                  if (_selectedCohortIds.isNotEmpty)
                    _CountPill(count: _selectedCohortIds.length, cs: cs),
                ]),
                const SizedBox(height: 10),
                _DDLButton(
                  label: _selectedCohortIds.isEmpty
                      ? 'Select cohorts…'
                      : _allCohorts
                          .where((c) => _selectedCohortIds.contains(c['id']?.toString()))
                          .map((c) => (c['name'] ?? '').toString().replaceFirst(RegExp(r'^\d+\s*-\s*'), ''))
                          .join(', '),
                  icon: Icons.groups_rounded,
                  onTap: _openCohortPicker,
                  cs: cs,
                  theme: theme,
                ),
                // Student preview from selected cohorts
                if (_selectedCohortIds.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: _cohortsLoading
                        ? Row(children: [
                            CmLoading(size: 14, color: cs.primary),
                            const SizedBox(width: 10),
                            Text(AppLocalizations.of(context)!.teacherCreateClassroomLoadingStudents, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          ])
                        : cohortStudents.isEmpty
                        ? Row(children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: cs.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Expanded(child: Text(AppLocalizations.of(context)!.teacherCreateClassroomNoStudentsInCohort, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant))),
                          ])
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${cohortStudents.length} student${cohortStudents.length == 1 ? '' : 's'} from selected cohorts',
                                  style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: cohortStudents.map((s) => Chip(
                                  label: Text(s.name, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                )).toList(),
                              ),
                            ],
                          ),
                  ),
                ],
                const SizedBox(height: 24),

                // ── Students DDL ───────────────────────────────────────────────
                Row(children: [
                  _SectionHeader(icon: Icons.person_add_rounded, title: AppLocalizations.of(context)!.teacherAddIndividualStudentsSection),
                  const Spacer(),
                  if (_selectedStudentIds.isNotEmpty)
                    _CountPill(count: _selectedStudentIds.length, cs: cs),
                ]),
                const SizedBox(height: 10),
                _DDLButton(
                  label: _selectedStudentIds.isEmpty
                      ? 'Select students…'
                      : _allStudents
                          .where((s) => _selectedStudentIds.contains(s.studentId))
                          .map((s) => s.name)
                          .join(', '),
                  icon: Icons.person_rounded,
                  onTap: _openStudentPicker,
                  cs: cs,
                  theme: theme,
                ),
                const SizedBox(height: 16),

                // ── Total summary ──────────────────────────────────────────────
                if (totalMembers > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      Icon(Icons.people_rounded, size: 18, color: cs.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedCohortIds.isNotEmpty ? '${_selectedCohortIds.length} cohort${_selectedCohortIds.length == 1 ? '' : 's'}' : ''}'
                        '${_selectedCohortIds.isNotEmpty && _selectedStudentIds.isNotEmpty ? ' + ' : ''}'
                        '${_selectedStudentIds.isNotEmpty ? '${_selectedStudentIds.length} student${_selectedStudentIds.length == 1 ? '' : 's'}' : ''}'
                        ' will be added',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ]),
                  ),
              ],
            ),
    );
  }
}

// ── DDL tap button ─────────────────────────────────────────────────────────────

class _DDLButton extends StatelessWidget {
  const _DDLButton({required this.label, required this.icon, required this.onTap, required this.cs, required this.theme});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: label.endsWith('…') ? cs.onSurfaceVariant : cs.onSurface,
                fontWeight: label.endsWith('…') ? FontWeight.w400 : FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.expand_more_rounded, size: 20, color: cs.onSurfaceVariant),
        ]),
      ),
    );
  }
}

// ── Multi-picker sheet ─────────────────────────────────────────────────────────

class _PickerItem {
  const _PickerItem({required this.id, required this.label, this.subtitle = ''});
  final String id;
  final String label;
  final String subtitle;
}

class _MultiPickerSheet extends StatefulWidget {
  const _MultiPickerSheet({required this.title, required this.items, required this.selected, required this.onToggle});
  final String title;
  final List<_PickerItem> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  State<_MultiPickerSheet> createState() => _MultiPickerSheetState();
}

class _MultiPickerSheetState extends State<_MultiPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));
    widget.onToggle(id);
  }

  List<_PickerItem> get _filtered {
    if (_query.isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((i) => i.label.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final filtered = _filtered;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, scrollCtrl) => Column(children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(children: [
            Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const Spacer(),
            if (_selected.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
                child: Text(AppLocalizations.of(context)!.chatSelectedCount(_selected.length),
                    style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.teacherMaterialSearchHint,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              // Clear (X) to reset the search text (QA #65).
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: AppLocalizations.of(context)!.clear,
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.commonNothingFound, style: TextStyle(color: cs.onSurfaceVariant)))
              : ListView.builder(
                  controller: scrollCtrl,
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
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item.label.isNotEmpty ? item.label[0].toUpperCase() : '?',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15,
                                    color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                              Text(item.label, style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700, color: isSelected ? cs.primary : null)),
                              if (item.subtitle.isNotEmpty)
                                Text(item.subtitle, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                            ])),
                            Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggle(item.id),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
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

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.cs});
  final int count;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
      child: Text('$count',
          style: TextStyle(color: cs.onPrimaryContainer, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Row(children: [
      Icon(icon, size: 18, color: cs.primary),
      const SizedBox(width: 8),
      Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
    ]);
  }
}
