// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _periodsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getPeriods();
});

final _defaultsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getPeriodDefaults();
});

final _teachersDdlProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getDdlTeachers();
});

final _cohortsDdlProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getDdlCohorts();
});

final _studentsDdlProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getDdlStudents();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminScheduleScreen extends ConsumerWidget {
  const AdminScheduleScreen({super.key});

  static const _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _dayNamesFull = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final periodsAsync = ref.watch(_periodsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_periodsProvider),
        child: periodsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (periods) {
            if (periods.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_note_rounded, size: 64, color: cs.outlineVariant),
                    const SizedBox(height: 16),
                    Text(l.adminScheduleNoSlots,
                        style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text(l.adminScheduleNoSlotsHint,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.outlineVariant)),
                  ],
                ),
              );
            }

            // Group by dayOfWeek
            final byDay = <int, List<Map<String, dynamic>>>{};
            for (final p in periods) {
              final dow = (p['dayOfWeek'] as num?)?.toInt() ?? 0;
              byDay.putIfAbsent(dow, () => []).add(p);
            }
            final sortedDays = byDay.keys.toList()..sort();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: sortedDays.expand((dow) {
                final daySlots = byDay[dow]!
                  ..sort((a, b) => ((a['period'] as num?)?.toInt() ?? 0)
                      .compareTo((b['period'] as num?)?.toInt() ?? 0));
                return [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                    child: Text(
                      dow < _dayNamesFull.length ? _dayNamesFull[dow] : 'Day $dow',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...daySlots.map((slot) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PeriodCard(
                      slot: slot,
                      onDelete: () async {
                        await ref.read(adminRepositoryProvider).deletePeriod(slot['id'].toString());
                        ref.invalidate(_periodsProvider);
                      },
                    ),
                  )),
                ];
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_admin_schedule',
        onPressed: () => _showAddPeriodSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.adminScheduleAddPeriod),
      ),
    );
  }

  Future<void> _showAddPeriodSheet(BuildContext context, WidgetRef ref) async {
    final teachers = await ref.read(_teachersDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final cohorts = await ref.read(_cohortsDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final students = await ref.read(_studentsDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final defaults = await ref.read(_defaultsProvider.future).catchError((_) => <Map<String, dynamic>>[]);

    if (!context.mounted) return;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _AddPeriodSheet(
        repo: ref.read(adminRepositoryProvider),
        teachers: teachers,
        cohorts: cohorts,
        students: students,
        defaults: defaults,
      ),
    );
    if (created == true) ref.invalidate(_periodsProvider);
  }
}

// ── Period card ────────────────────────────────────────────────────────────────

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.slot, required this.onDelete});
  final Map<String, dynamic> slot;
  final VoidCallback onDelete;

  static const _dayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _freqLabels = {1: 'Weekly', 2: 'Bi-weekly', 4: 'Monthly'};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final period = (slot['period'] as num?)?.toInt() ?? 0;
    final dow = (slot['dayOfWeek'] as num?)?.toInt() ?? 0;
    final start = slot['startTime']?.toString() ?? '';
    final end = slot['endTime']?.toString() ?? '';
    final freq = (slot['frequencyWeeks'] as num?)?.toInt() ?? 1;
    final teacherName = (slot['teacher'] is Map) ? slot['teacher']['name']?.toString() ?? '' : '';
    final cohorts = slot['cohorts'] as List? ?? [];
    final cohortNames = cohorts
        .whereType<Map>()
        .map((c) => (c['cohort'] is Map ? c['cohort']['name'] : null)?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');
    final freqLabel = _freqLabels[freq] ?? 'Every $freq wks';

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('P$period',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: cs.onPrimaryContainer)),
              if (dow < _dayShort.length)
                Text(_dayShort[dow],
                    style: TextStyle(fontSize: 10, color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
            ],
          ),
        ),
        title: Text(
          teacherName.isNotEmpty ? teacherName : 'No teacher',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            if (cohortNames.isNotEmpty) cohortNames,
            if (start.isNotEmpty && end.isNotEmpty) '$start–$end',
            freqLabel,
          ].join(' · '),
          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: cs.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ── Add Period Sheet ───────────────────────────────────────────────────────────
// Multi-slot: admin can add N day+period pairs, shared teacher/cohort/frequency

class _AddPeriodSheet extends StatefulWidget {
  const _AddPeriodSheet({
    required this.repo,
    required this.teachers,
    required this.cohorts,
    required this.students,
    required this.defaults,
  });

  final AdminRepository repo;
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> cohorts;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> defaults;

  @override
  State<_AddPeriodSheet> createState() => _AddPeriodSheetState();
}

class _DayPeriodSlot {
  int dayOfWeek;
  int period;
  _DayPeriodSlot({this.dayOfWeek = 0, this.period = 1});
}

class _AddPeriodSheetState extends State<_AddPeriodSheet> {
  // Multiple day+period combos
  final List<_DayPeriodSlot> _slots = [_DayPeriodSlot()];

  // Shared settings
  String? _teacherId;
  String? _teacherName;
  final Set<String> _cohortIds = {};
  final Set<String> _studentIds = {};
  bool _useCohorts = true; // false = individual students

  // Frequency
  int _frequencyWeeks = 1;
  bool _customFreq = false;
  final _customFreqCtrl = TextEditingController();

  bool _saving = false;

  static const _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _schoolDays = [0, 1, 2, 3, 4];

  @override
  void dispose() {
    _customFreqCtrl.dispose();
    super.dispose();
  }

  String _defaultTime(int period, bool isStart) {
    final def = widget.defaults.firstWhere(
      (d) => (d['period'] as num?)?.toInt() == period,
      orElse: () => const {},
    );
    if (isStart) return def['startTime']?.toString() ?? '';
    return def['endTime']?.toString() ?? '';
  }

  Future<void> _save() async {
    final freq = _customFreq
        ? (int.tryParse(_customFreqCtrl.text.trim()) ?? 1).clamp(1, 52)
        : _frequencyWeeks;

    setState(() => _saving = true);
    int created = 0;
    String? firstError;

    for (final slot in _slots) {
      try {
        await widget.repo.createPeriod(
          dayOfWeek: slot.dayOfWeek,
          period: slot.period,
          teacherId: _teacherId,
          cohortIds: _useCohorts && _cohortIds.isNotEmpty ? _cohortIds.toList() : null,
          studentIds: !_useCohorts && _studentIds.isNotEmpty ? _studentIds.toList() : null,
          startTime: _defaultTime(slot.period, true).isNotEmpty ? _defaultTime(slot.period, true) : null,
          endTime: _defaultTime(slot.period, false).isNotEmpty ? _defaultTime(slot.period, false) : null,
          frequencyWeeks: freq,
        );
        created++;
      } catch (e) {
        firstError ??= e.toString();
      }
    }

    if (!mounted) { setState(() => _saving = false); return; }
    setState(() => _saving = false);

    if (created == 0) {
      // All failed
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(firstError ?? 'Failed to create slots'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } else {
      if (created < _slots.length && firstError != null) {
        // Partial success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Created $created/${_slots.length} slots. ${firstError}'),
          duration: const Duration(seconds: 5),
        ));
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.98,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(l.adminScheduleNewPeriod,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                ),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded, size: 16),
                  label: Text(l.adminScheduleSave),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Day + Period slots ────────────────────────────────────────
            _SectionLabel(label: l.adminScheduleDayLabel, cs: cs, theme: theme),
            const SizedBox(height: 10),
            ..._slots.asMap().entries.map((entry) {
              final i = entry.key;
              final slot = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DayPeriodRow(
                  slot: slot,
                  index: i,
                  total: _slots.length,
                  defaults: widget.defaults,
                  onChanged: () => setState(() {}),
                  onRemove: _slots.length > 1 ? () => setState(() => _slots.removeAt(i)) : null,
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() => _slots.add(_DayPeriodSlot())),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l.adminScheduleAddAnother),
            ),
            const SizedBox(height: 16),

            // ── Teacher DDL ───────────────────────────────────────────────
            _SectionLabel(label: l.adminScheduleTeacherLabel, cs: cs, theme: theme),
            const SizedBox(height: 8),
            _SearchPickerField(
              value: _teacherName,
              hintText: l.adminScheduleSelectTeacher,
              searchHint: l.adminScheduleSearchTeacher,
              items: widget.teachers,
              nameKey: 'name',
              subtitleKey: null,
              onSelected: (item) => setState(() {
                _teacherId = item['id']?.toString();
                _teacherName = item['name']?.toString();
              }),
              onClear: () => setState(() { _teacherId = null; _teacherName = null; }),
            ),
            const SizedBox(height: 16),

            // ── Audience: cohort or students ──────────────────────────────
            _SectionLabel(label: l.adminScheduleCohortLabel, cs: cs, theme: theme),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(value: true, label: Text(l.adminScheduleSelectCohort)),
                      ButtonSegment(value: false, label: Text(l.adminStudents)),
                    ],
                    selected: {_useCohorts},
                    onSelectionChanged: (s) => setState(() {
                      _useCohorts = s.first;
                      _cohortIds.clear();
                      _studentIds.clear();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_useCohorts)
              _MultiPickerList(
                items: widget.cohorts,
                selected: _cohortIds,
                nameKey: 'name',
                subtitleBuilder: (item) {
                  final g = item['grade'];
                  return g != null ? 'Grade $g' : null;
                },
                searchHint: l.adminScheduleSearchCohort,
                onToggle: (id) => setState(() =>
                  _cohortIds.contains(id) ? _cohortIds.remove(id) : _cohortIds.add(id)),
              )
            else
              _MultiPickerList(
                items: widget.students,
                selected: _studentIds,
                nameKey: 'name',
                subtitleBuilder: (item) {
                  final g = item['grade'];
                  final cn = item['cohortName']?.toString() ?? '';
                  if (g != null) return 'Grade $g${cn.isNotEmpty ? ' · $cn' : ''}';
                  return cn.isNotEmpty ? cn : null;
                },
                searchHint: l.adminSearchStudents,
                onToggle: (id) => setState(() =>
                  _studentIds.contains(id) ? _studentIds.remove(id) : _studentIds.add(id)),
              ),
            const SizedBox(height: 16),

            // ── Frequency ─────────────────────────────────────────────────
            _SectionLabel(label: l.adminScheduleFrequencyLabel, cs: cs, theme: theme),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FreqChip(label: l.adminScheduleFreqWeekly, selected: !_customFreq && _frequencyWeeks == 1,
                    onTap: () => setState(() { _frequencyWeeks = 1; _customFreq = false; })),
                _FreqChip(label: l.adminScheduleFreqBiweekly, selected: !_customFreq && _frequencyWeeks == 2,
                    onTap: () => setState(() { _frequencyWeeks = 2; _customFreq = false; })),
                _FreqChip(label: l.adminScheduleFreqMonthly, selected: !_customFreq && _frequencyWeeks == 4,
                    onTap: () => setState(() { _frequencyWeeks = 4; _customFreq = false; })),
                _FreqChip(label: l.adminScheduleFreqCustom, selected: _customFreq,
                    onTap: () => setState(() => _customFreq = true)),
              ],
            ),
            if (_customFreq) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Every ', style: theme.textTheme.bodyMedium),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _customFreqCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                    ),
                  ),
                  Text(' weeks', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Day + Period row ───────────────────────────────────────────────────────────

class _DayPeriodRow extends StatefulWidget {
  const _DayPeriodRow({
    required this.slot,
    required this.index,
    required this.total,
    required this.defaults,
    required this.onChanged,
    required this.onRemove,
  });

  final _DayPeriodSlot slot;
  final int index;
  final int total;
  final List<Map<String, dynamic>> defaults;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  State<_DayPeriodRow> createState() => _DayPeriodRowState();
}

class _DayPeriodRowState extends State<_DayPeriodRow> {
  static const _dayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _schoolDays = [0, 1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Slot ${widget.index + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700, color: cs.primary)),
              const Spacer(),
              if (widget.onRemove != null)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Icon(Icons.close_rounded, size: 18, color: cs.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Days row
          Wrap(
            spacing: 6,
            children: _schoolDays.map((d) => ChoiceChip(
              label: Text(_dayShort[d], style: const TextStyle(fontSize: 12)),
              selected: widget.slot.dayOfWeek == d,
              visualDensity: VisualDensity.compact,
              onSelected: (_) {
                setState(() => widget.slot.dayOfWeek = d);
                widget.onChanged();
              },
            )).toList(),
          ),
          const SizedBox(height: 10),
          // Period dropdown
          DropdownButtonFormField<int>(
            value: widget.slot.period,
            isDense: true,
            decoration: InputDecoration(
              labelText: 'Period',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: List.generate(9, (i) => i + 1).map((p) {
              final def = widget.defaults.firstWhere(
                (d) => (d['period'] as num?)?.toInt() == p, orElse: () => const {});
              final hint = def.isNotEmpty ? '  ${def['startTime'] ?? ''}' : '';
              return DropdownMenuItem(value: p, child: Text('P$p$hint'));
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => widget.slot.period = v);
                widget.onChanged();
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Search picker field (single selection) ────────────────────────────────────

class _SearchPickerField extends StatelessWidget {
  const _SearchPickerField({
    required this.value,
    required this.hintText,
    required this.searchHint,
    required this.items,
    required this.nameKey,
    required this.subtitleKey,
    required this.onSelected,
    required this.onClear,
  });

  final String? value;
  final String hintText;
  final String searchHint;
  final List<Map<String, dynamic>> items;
  final String nameKey;
  final String? subtitleKey;
  final void Function(Map<String, dynamic> item) onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          color: cs.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : hintText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasValue ? cs.onSurface : cs.onSurfaceVariant,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (hasValue)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 18, color: cs.onSurfaceVariant),
              )
            else
              Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext ctx) async {
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: ctx,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bCtx) => _SearchPickerSheet(
        searchHint: searchHint,
        items: items,
        nameKey: nameKey,
        subtitleKey: subtitleKey,
      ),
    );
    if (selected != null) onSelected(selected);
  }
}

class _SearchPickerSheet extends StatefulWidget {
  const _SearchPickerSheet({
    required this.searchHint,
    required this.items,
    required this.nameKey,
    required this.subtitleKey,
  });

  final String searchHint;
  final List<Map<String, dynamic>> items;
  final String nameKey;
  final String? subtitleKey;

  @override
  State<_SearchPickerSheet> createState() => _SearchPickerSheetState();
}

class _SearchPickerSheetState extends State<_SearchPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final q = _q.toLowerCase();
    final filtered = widget.items.where((item) {
      final name = (item[widget.nameKey] ?? '').toString().toLowerCase();
      return q.isEmpty || name.contains(q);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              isDense: true,
              filled: true,
              fillColor: cs.surfaceContainerHigh,
            ),
          ),
        ),
        if (widget.items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_search_rounded, size: 40, color: cs.outlineVariant),
                const SizedBox(height: 12),
                Text(
                  'No ${widget.searchHint.replaceAll('…', '').replaceAll('Search ', '').trim()} yet.\nCreate them in the People section first.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filtered.isEmpty && _q.isNotEmpty ? 0 : filtered.length,
            itemBuilder: (ctx, i) {
              final item = filtered[i];
              final name = item[widget.nameKey]?.toString() ?? '';
              final sub = widget.subtitleKey != null ? item[widget.subtitleKey!]?.toString() : null;
              return ListTile(
                title: Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: sub != null
                    ? Text(sub, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant))
                    : null,
                onTap: () => Navigator.pop(ctx, item),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Multi-select picker list ───────────────────────────────────────────────────

class _MultiPickerList extends StatefulWidget {
  const _MultiPickerList({
    required this.items,
    required this.selected,
    required this.nameKey,
    required this.subtitleBuilder,
    required this.searchHint,
    required this.onToggle,
  });

  final List<Map<String, dynamic>> items;
  final Set<String> selected;
  final String nameKey;
  final String? Function(Map<String, dynamic>) subtitleBuilder;
  final String searchHint;
  final void Function(String id) onToggle;

  @override
  State<_MultiPickerList> createState() => _MultiPickerListState();
}

class _MultiPickerListState extends State<_MultiPickerList> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final q = _q.toLowerCase();
    final filtered = widget.items.where((item) {
      final name = (item[widget.nameKey] ?? '').toString().toLowerCase();
      return q.isEmpty || name.contains(q);
    }).toList();

    return Column(
      children: [
        TextField(
          onChanged: (v) => setState(() => _q = v),
          decoration: InputDecoration(
            hintText: widget.searchHint,
            prefixIcon: const Icon(Icons.search_rounded, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          ),
        ),
        const SizedBox(height: 4),
        if (widget.selected.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 14, color: cs.primary),
                const SizedBox(width: 6),
                Text('${widget.selected.length} selected',
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700, color: cs.primary)),
              ],
            ),
          ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final item = filtered[i];
              final id = item['id']?.toString() ?? '';
              final name = item[widget.nameKey]?.toString() ?? '';
              final sub = widget.subtitleBuilder(item);
              final sel = widget.selected.contains(id);
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: sel,
                onChanged: (_) => widget.onToggle(id),
                title: Text(name,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: sub != null
                    ? Text(sub,
                        style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant))
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Frequency chip ─────────────────────────────────────────────────────────────

class _FreqChip extends StatelessWidget {
  const _FreqChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.cs, required this.theme});
  final String label;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.primary,
      ),
    );
  }
}
