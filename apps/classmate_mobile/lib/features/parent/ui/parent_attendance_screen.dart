import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/parent_models.dart';
import '../data/parent_repository.dart';

class ParentAttendanceScreen extends ConsumerWidget {
  const ParentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final studentId = ref.watch(selectedChildProvider);
    if (studentId == null) {
      return const Scaffold(body: Center(child: Text('Pick a child first.')));
    }
    final entries = ref.watch(parentAttendanceWeekProvider(studentId));

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(parentAttendanceWeekProvider(studentId)),
        child: entries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e'))),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No attendance recorded for this week.')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) => _AttendanceTile(entry: list[i]),
            );
          },
        ),
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.entry});
  final ParentAttendance entry;

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (entry.status) {
      case 'PRESENT':
        return const Color(0xFF2E7D32);
      case 'ABSENT':
        return cs.error;
      case 'LATE':
        return const Color(0xFFEF6C00);
      case 'EXCUSED':
        return const Color(0xFF1976D2);
      default:
        return cs.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _statusColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.date ?? '—',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if ((entry.subject ?? '').isNotEmpty)
                  Text(entry.subject!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              entry.status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
