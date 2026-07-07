// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';

// ── Bell schedule screen ───────────────────────────────────────────────────────
// Lets the admin set start/end times for each period (P1–P9).
// These become the default times used when creating schedule slots.

class AdminBellScheduleScreen extends ConsumerStatefulWidget {
  const AdminBellScheduleScreen({super.key});

  @override
  ConsumerState<AdminBellScheduleScreen> createState() =>
      _AdminBellScheduleScreenState();
}

class _AdminBellScheduleScreenState
    extends ConsumerState<AdminBellScheduleScreen> {
  // period → {start: "HH:MM", end: "HH:MM"}
  final Map<int, _PeriodTime> _times = {};
  bool _loading = true;
  bool _saving = false;

  static const int _periodCount = 9;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final defaults = await ref.read(adminRepositoryProvider).getPeriodDefaults();
      final map = <int, _PeriodTime>{};
      for (final d in defaults) {
        final p = (d['period'] as num?)?.toInt();
        if (p == null) continue;
        map[p] = _PeriodTime(
          start: d['startTime']?.toString() ?? '',
          end: d['endTime']?.toString() ?? '',
        );
      }
      // Fill any missing periods with empty strings
      for (var i = 1; i <= _periodCount; i++) {
        map.putIfAbsent(i, () => _PeriodTime(start: '', end: ''));
      }
      if (mounted) {
        setState(() { _times
          ..clear()
          ..addAll(map);
      });
      }
    } catch (_) {
      // Seed with empties on error
      for (var i = 1; i <= _periodCount; i++) {
        _times.putIfAbsent(i, () => _PeriodTime(start: '', end: ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    // Only save periods that have both times set
    final toSave = <Map<String, dynamic>>[];
    for (var i = 1; i <= _periodCount; i++) {
      final t = _times[i];
      if (t == null || t.start.isEmpty || t.end.isEmpty) continue;
      toSave.add({'period': i, 'startTime': t.start, 'endTime': t.end});
    }
    if (toSave.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).setPeriodDefaults(toSave);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminSchoolSaved)),
      );
      // Reload from server so the UI reflects the authoritative saved state
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime(int period, bool isStart) async {
    final current = _times[period] ?? _PeriodTime(start: '', end: '');
    final initial = _parseTime(isStart ? current.start : current.end);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      final existing = _times[period] ?? _PeriodTime(start: '', end: '');
      _times[period] = isStart
          ? _PeriodTime(start: formatted, end: existing.end)
          : _PeriodTime(start: existing.start, end: formatted);
    });
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '8') ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_save_bell',
        onPressed: (_saving || _loading) ? null : _save,
        icon: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save_rounded),
        label: Text(l.adminSave),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                    16, 12 + MediaQuery.paddingOf(context).top, 16, 120),
                children: [
                  // ── Info card ──────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.adminSchoolBellInfo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Period rows ────────────────────────────────────────────
                  for (var i = 1; i <= _periodCount; i++) ...[
                    _PeriodRow(
                      period: i,
                      times: _times[i] ?? _PeriodTime(start: '', end: ''),
                      onPickStart: () => _pickTime(i, true),
                      onPickEnd: () => _pickTime(i, false),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
    );
  }
}

// ── Period row ────────────────────────────────────────────────────────────────

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.period,
    required this.times,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final int period;
  final _PeriodTime times;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final hasTime = times.start.isNotEmpty && times.end.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasTime
              ? cs.outlineVariant.withValues(alpha: 0.5)
              : cs.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Period badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasTime ? cs.primaryContainer : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                l.adminSchedulePeriodLabel(period.toString()),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: hasTime ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Start time
          Expanded(
            child: _TimePicker(
              label: l.adminSchoolStartTime,
              time: times.start,
              onTap: onPickStart,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '→',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),

          // End time
          Expanded(
            child: _TimePicker(
              label: l.adminSchoolEndTime,
              time: times.end,
              onTap: onPickEnd,
            ),
          ),

          // Duration label
          if (hasTime) ...[
            const SizedBox(width: 8),
            Text(
              _duration(times.start, times.end),
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _duration(String start, String end) {
    try {
      final sp = start.split(':');
      final ep = end.split(':');
      final s = TimeOfDay(hour: int.parse(sp[0]), minute: int.parse(sp[1]));
      final e = TimeOfDay(hour: int.parse(ep[0]), minute: int.parse(ep[1]));
      final mins = (e.hour * 60 + e.minute) - (s.hour * 60 + s.minute);
      if (mins <= 0) return '';
      return '${mins}m';
    } catch (_) {
      return '';
    }
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({required this.label, required this.time, required this.onTap});

  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hasTime = time.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasTime ? cs.outlineVariant : cs.error.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(10),
          color: hasTime ? cs.surface : cs.errorContainer.withValues(alpha: 0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
            Text(
              hasTime ? time : '--:--',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: hasTime ? cs.onSurface : cs.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _PeriodTime {
  _PeriodTime({required this.start, required this.end});
  final String start;
  final String end;
}
