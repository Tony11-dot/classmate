// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/http/cm_api.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';

// ── Data helpers ─────────────────────────────────────────────────────────────

class _AdminApi {
  _AdminApi(String token) : _api = CMApi(token: token);
  final CMApi _api;

  Future<List<Map<String, dynamic>>> getDefaults() async {
    final raw = await _api.getJson('/admin/period-defaults');
    final list = raw is Map ? (raw['defaults'] ?? []) : raw;
    return (list as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getTeachers() async {
    final raw = await _api.getJson('/admin/ddl/teachers');
    final list = raw is Map ? (raw['teachers'] ?? []) : raw;
    return (list as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getStudents({String? q}) async {
    final raw = await _api.getJson('/admin/ddl/students', query: q != null && q.isNotEmpty ? {'q': q} : null);
    final list = raw is Map ? (raw['students'] ?? []) : raw;
    return (list as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getCohorts() async {
    final raw = await _api.getJson('/admin/ddl/cohorts');
    final list = raw is Map ? (raw['cohorts'] ?? []) : raw;
    return (list as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getClassroomsForTeacher(String teacherId) async {
    final raw = await _api.getJson('/admin/ddl/classrooms', query: {'teacherId': teacherId});
    final list = raw is Map ? (raw['classrooms'] ?? []) : raw;
    return (list as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getPeriods() async {
    final raw = await _api.getJson('/admin/periods');
    final list = raw is Map ? (raw['slots'] ?? []) : raw;
    return (list as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> createPeriod(Map<String, dynamic> body) => _api.postJson('/admin/periods', body: body);
  Future<void> deletePeriod(String id) => _api.deleteJson('/admin/periods/$id');
}

// ── Provider ──────────────────────────────────────────────────────────────────

final _adminApiProvider = Provider.autoDispose<_AdminApi>((ref) {
  final token = ref.watch(authSessionProvider).token ?? '';
  return _AdminApi(token);
});

final _periodsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(_adminApiProvider).getPeriods();
});

// ── Locale-aware weekday names ──────────────────────────────────────────────────

// dayOfWeek index: 0 = Sunday … 6 = Saturday.
// 2024-01-07 is a Sunday; adding [dow] days yields the matching weekday.
DateTime _refDateForDow(int dow) => DateTime(2024, 1, 7).add(Duration(days: dow));

String _shortDayName(BuildContext context, int dow) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.E(locale).format(_refDateForDow(dow));
}

String _longDayName(BuildContext context, int dow) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.EEEE(locale).format(_refDateForDow(dow));
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminPeriodsScreen extends ConsumerWidget {
  const AdminPeriodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final periodsAsync = ref.watch(_periodsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.adminPeriodsTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_period',
        onPressed: () => _showCreateSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context)!.adminPeriodsAddPeriod),
      ),
      body: periodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.teacherClassroomGenericError(e.toString()))),
        data: (periods) {
          if (periods.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_note_rounded, size: 64, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.adminPeriodsNoPeriods, style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(AppLocalizations.of(context)!.adminPeriodsTapToAdd, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }

          // Group by day
          final byDay = <int, List<Map<String, dynamic>>>{};
          for (final p in periods) {
            final dow = (p['dayOfWeek'] as num?)?.toInt() ?? 0;
            byDay.putIfAbsent(dow, () => []).add(p);
          }
          final sortedDays = byDay.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: sortedDays.expand((dow) {
              final daySlots = byDay[dow]!..sort((a, b) => ((a['period'] as num?)?.toInt() ?? 0).compareTo((b['period'] as num?)?.toInt() ?? 0));
              return [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
                  child: Text(
                    (dow >= 0 && dow <= 6) ? _shortDayName(context, dow) : AppLocalizations.of(context)!.adminPeriodsScreenDayN(dow),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ...daySlots.map((slot) => _PeriodTile(
                  slot: slot,
                  onDelete: () async {
                    await ref.read(_adminApiProvider).deletePeriod(slot['id'].toString());
                    ref.invalidate(_periodsProvider);
                  },
                )),
              ];
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context, WidgetRef ref) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _CreatePeriodSheet(api: ref.read(_adminApiProvider)),
    );
    if (created == true) ref.invalidate(_periodsProvider);
  }
}

// ── Period tile ────────────────────────────────────────────────────────────────

class _PeriodTile extends StatelessWidget {
  const _PeriodTile({required this.slot, required this.onDelete});
  final Map<String, dynamic> slot;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final period = (slot['period'] as num?)?.toInt() ?? 0;
    final start = slot['startTime']?.toString() ?? '--:--';
    final end = slot['endTime']?.toString() ?? '--:--';
    final subject = slot['subject']?.toString() ?? '';
    final teacherName = (slot['teacher'] is Map) ? slot['teacher']['name']?.toString() ?? '' : '';
    final classroom = (slot['classroom'] is Map) ? slot['classroom']['name']?.toString() ?? '' : '';
    final cohorts = slot['cohorts'] as List? ?? [];
    final cohortNames = cohorts
        .whereType<Map>()
        .map((c) => (c['cohort'] is Map ? c['cohort']['name'] : null)?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cs.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('P$period', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: cs.onPrimaryContainer)),
              Text(start, style: TextStyle(fontSize: 10, color: cs.onPrimaryContainer.withValues(alpha: 0.75))),
            ],
          ),
        ),
        title: Text(
          classroom.isNotEmpty ? classroom : (subject.isNotEmpty ? subject : AppLocalizations.of(context)!.adminPeriodsScreenPeriodN(period)),
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [if (teacherName.isNotEmpty) teacherName, if (cohortNames.isNotEmpty) cohortNames, '$start – $end'].join(' · '),
          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: l.a11yDelete,
          icon: Icon(Icons.delete_outline_rounded, color: cs.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ── Create period sheet ────────────────────────────────────────────────────────

class _CreatePeriodSheet extends StatefulWidget {
  const _CreatePeriodSheet({required this.api});
  final _AdminApi api;

  @override
  State<_CreatePeriodSheet> createState() => _CreatePeriodSheetState();
}

class _CreatePeriodSheetState extends State<_CreatePeriodSheet> {
  static const _schoolDays = [0, 1, 2, 3, 4]; // Sun-Thu

  int _dayOfWeek = 0;
  int _period = 1;
  String _startTime = '08:00';
  String _endTime = '08:45';
  String? _teacherId;
  String? _classroomId;
  final Set<String> _cohortIds = {};
  final Set<String> _studentIds = {};
  String _studentSearch = '';

  List<Map<String, dynamic>> _defaults = [];
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _cohorts = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _classrooms = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        widget.api.getDefaults(),
        widget.api.getTeachers(),
        widget.api.getCohorts(),
        widget.api.getStudents(),
      ]);
      if (!mounted) return;
      setState(() {
        _defaults = results[0];
        _teachers = results[1];
        _cohorts = results[2];
        _students = results[3];
        _loading = false;
        _applyDefaultTimes();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _applyDefaultTimes() {
    final def = _defaults.firstWhere(
      (d) => (d['period'] as num?)?.toInt() == _period,
      orElse: () => const {},
    );
    if (def.isNotEmpty) {
      _startTime = def['startTime']?.toString() ?? _startTime;
      _endTime = def['endTime']?.toString() ?? _endTime;
    }
  }

  Future<void> _onPeriodChanged(int p) async {
    setState(() { _period = p; _applyDefaultTimes(); });
  }

  Future<void> _onTeacherChanged(String? id) async {
    setState(() { _teacherId = id; _classroomId = null; _classrooms = []; });
    if (id != null && id.isNotEmpty) {
      try {
        final cls = await widget.api.getClassroomsForTeacher(id);
        if (mounted) setState(() => _classrooms = cls);
      } catch (_) {}
    }
  }

  Future<void> _pickTime(BuildContext ctx, bool isStart) async {
    final initial = _parseTime(isStart ? _startTime : _endTime);
    final picked = await showTimePicker(context: ctx, initialTime: initial);
    if (picked == null || !mounted) return;
    final fmt = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() { isStart ? _startTime = fmt : _endTime = fmt; });
  }

  TimeOfDay _parseTime(String hhmm) {
    final p = hhmm.split(':');
    return TimeOfDay(hour: int.tryParse(p[0]) ?? 8, minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.api.createPeriod({
        'dayOfWeek': _dayOfWeek,
        'period': _period,
        'startTime': _startTime,
        'endTime': _endTime,
        if (_teacherId != null) 'teacherId': _teacherId,
        if (_classroomId != null) 'classroomId': _classroomId,
        if (_cohortIds.isNotEmpty) 'cohortIds': _cohortIds.toList(),
        if (_studentIds.isNotEmpty) 'studentIds': _studentIds.toList(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.teacherClassroomGenericError(e.toString())), backgroundColor: Theme.of(context).colorScheme.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final q = _studentSearch.toLowerCase();
    final filteredStudents = _students.where((s) {
      if (q.isEmpty) return true;
      return (s['name']?.toString() ?? '').toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _loading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                // Header
                Row(
                  children: [
                    Expanded(child: Text(AppLocalizations.of(context)!.adminPeriodsNewPeriod, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_rounded, size: 16),
                      label: Text(AppLocalizations.of(context)!.commonSave),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Day
                Text(AppLocalizations.of(context)!.adminPeriodsDayLabel, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _schoolDays.map((d) => ChoiceChip(
                    label: Text(_longDayName(context, d)),
                    selected: _dayOfWeek == d,
                    onSelected: (_) => setState(() => _dayOfWeek = d),
                  )).toList(),
                ),
                const SizedBox(height: 16),

                // Period + time
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.adminPeriodsPeriodLabel, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                          const SizedBox(height: 8),
                          LiquidGlassDropdown<int>(
                            label: AppLocalizations.of(context)!.adminPeriodsScreenPeriodDropdownLabel,
                            value: _period,
                            items: List.generate(10, (i) => i + 1).map((p) {
                              final def = _defaults.firstWhere((d) => (d['period'] as num?)?.toInt() == p, orElse: () => const {});
                              final hint = def.isNotEmpty && (def['startTime'] ?? '').toString().isNotEmpty ? ' · ${def['startTime']}' : '';
                              return LiquidGlassDropdownItem(value: p, label: 'P$p$hint');
                            }).toList(),
                            onChanged: (v) => _onPeriodChanged(v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.adminPeriodsTimeLabel, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _TimePill(time: _startTime, onTap: () => _pickTime(context, true), cs: cs, theme: theme)),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('–', style: TextStyle(color: cs.onSurfaceVariant))),
                              Expanded(child: _TimePill(time: _endTime, onTap: () => _pickTime(context, false), cs: cs, theme: theme)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Teacher DDL
                Text(AppLocalizations.of(context)!.adminPeriodsTeacherLabel, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                const SizedBox(height: 8),
                LiquidGlassDropdown<String>(
                  label: AppLocalizations.of(context)!.adminPeriodsScreenSelectTeacher,
                  value: _teacherId ?? '',
                  items: [
                    LiquidGlassDropdownItem(value: '', label: AppLocalizations.of(context)!.adminPeriodsScreenNone),
                    ..._teachers.map((t) => LiquidGlassDropdownItem(value: t['id']?.toString() ?? '', label: t['name']?.toString() ?? '')),
                  ],
                  onChanged: (v) => _onTeacherChanged(v.isEmpty ? null : v),
                ),
                const SizedBox(height: 16),

                // Classroom DDL (only shown when teacher is selected)
                if (_teacherId != null && _teacherId!.isNotEmpty) ...[
                  Text(AppLocalizations.of(context)!.adminPeriodsClassroomOptional, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 8),
                  LiquidGlassDropdown<String>(
                    label: AppLocalizations.of(context)!.adminPeriodsScreenLinkClassroom,
                    value: _classroomId ?? '',
                    items: [
                      LiquidGlassDropdownItem(value: '', label: AppLocalizations.of(context)!.adminPeriodsScreenNone),
                      ..._classrooms.map((c) => LiquidGlassDropdownItem(value: c['id']?.toString() ?? '', label: '${c['name']} (${c['subject']})')),
                    ],
                    onChanged: (v) => setState(() => _classroomId = v.isEmpty ? null : v),
                  ),
                  const SizedBox(height: 16),
                ],

                // Cohorts (multiselect chips)
                if (_cohorts.isNotEmpty) ...[
                  Text(AppLocalizations.of(context)!.adminPeriodsCohortsLabel, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _cohorts.map((c) {
                      final id = c['id']?.toString() ?? '';
                      final name = c['name']?.toString() ?? '';
                      final grade = c['grade'];
                      return FilterChip(
                        label: Text(grade != null ? AppLocalizations.of(context)!.adminPeriodsScreenCohortGradeName(grade.toString(), name) : name, style: const TextStyle(fontSize: 12)),
                        selected: _cohortIds.contains(id),
                        onSelected: (_) => setState(() => _cohortIds.contains(id) ? _cohortIds.remove(id) : _cohortIds.add(id)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Students (searchable multiselect)
                Row(children: [
                  Text(AppLocalizations.of(context)!.adminPeriodsStudentsOptional, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const Spacer(),
                  if (_studentIds.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(99)),
                      child: Text('${_studentIds.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: cs.onPrimaryContainer)),
                    ),
                ]),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (v) => setState(() => _studentSearch = v),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.adminPeriodsSearchByName,
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 6),
                ...filteredStudents.map((s) {
                  final id = s['id']?.toString() ?? '';
                  final name = s['name']?.toString() ?? '';
                  final grade = s['grade'];
                  final sub = grade != null ? AppLocalizations.of(context)!.adminPeriodsScreenGradeN(grade.toString()) : '';
                  final selected = _studentIds.contains(id);
                  return CheckboxListTile(
                    dense: true,
                    value: selected,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (_) => setState(() => selected ? _studentIds.remove(id) : _studentIds.add(id)),
                    title: Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: sub.isNotEmpty ? Text(sub, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)) : null,
                  );
                }),
              ],
            ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.time, required this.onTap, required this.cs, required this.theme});
  final String time;
  final VoidCallback onTap;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(time, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
