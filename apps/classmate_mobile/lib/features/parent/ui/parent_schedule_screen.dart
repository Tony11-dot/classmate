import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/parent_models.dart';
import '../data/parent_repository.dart';

class ParentScheduleScreen extends ConsumerWidget {
  const ParentScheduleScreen({super.key});

  static const _dayOrder = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  static const _dayLabels = {
    'SUN': 'Sunday', 'MON': 'Monday', 'TUE': 'Tuesday', 'WED': 'Wednesday',
    'THU': 'Thursday', 'FRI': 'Friday', 'SAT': 'Saturday',
    '0': 'Sunday', '1': 'Monday', '2': 'Tuesday', '3': 'Wednesday',
    '4': 'Thursday', '5': 'Friday', '6': 'Saturday',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final studentId = ref.watch(selectedChildProvider);
    if (studentId == null) {
      return const Scaffold(body: Center(child: Text('Pick a child first.')));
    }
    final slots = ref.watch(parentScheduleWeekProvider(studentId));

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(parentScheduleWeekProvider(studentId)),
        child: slots.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e'))),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No schedule data for this week.')),
                ],
              );
            }
            final grouped = <String, List<ParentScheduleSlot>>{};
            for (final s in list) {
              final key = (s.dayOfWeek ?? '').toUpperCase();
              grouped.putIfAbsent(key, () => []).add(s);
            }
            final orderedKeys = [
              ..._dayOrder.where(grouped.containsKey),
              ...grouped.keys.where((k) => !_dayOrder.contains(k)),
            ];
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                for (final key in orderedKeys) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
                    child: Text(
                      _dayLabels[key] ?? key,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  ...grouped[key]!.map((s) => _SlotTile(slot: s)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot});
  final ParentScheduleSlot slot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeRange = [
      slot.startTime ?? '', if ((slot.endTime ?? '').isNotEmpty) '–', slot.endTime ?? ''
    ].where((s) => s.isNotEmpty).join(' ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (slot.subject ?? '').isEmpty ? '—' : slot.subject!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if ((slot.teacher ?? '').isNotEmpty)
                  Text(slot.teacher!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (timeRange.isNotEmpty)
                Text(timeRange, style: const TextStyle(fontWeight: FontWeight.w700)),
              if ((slot.room ?? '').isNotEmpty)
                Text(slot.room!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
