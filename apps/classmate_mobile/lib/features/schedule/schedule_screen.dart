import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../solutions/me_subjects_provider.dart';
import 'schedule_provider.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  static const int _center = 5000;
  late final PageController _pc = PageController(initialPage: _center);
  int _index = _center;

  DateTime get _day {
    final delta = _index - _center;
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    return base.add(Duration(days: delta));
  }

  void _jump(int delta) {
    final next = _index + delta;
    _pc.animateToPage(
      next,
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOutCubic,
    );
    setState(() => _index = next);
  }

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2035, 12, 31),
    );
    if (picked == null) return;

    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    final target = DateTime(picked.year, picked.month, picked.day);
    final delta = target.difference(base).inDays;
    final next = _center + delta;

    _pc.animateToPage(
      next,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    setState(() => _index = next);
  }

  void _today() {
    _pc.animateToPage(
      _center,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
    setState(() => _index = _center);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final df = DateFormat('EEEE • d MMM yyyy');
    final title = df.format(_day);

    final isToday = () {
      final now = DateTime.now();
      final a = DateTime(now.year, now.month, now.day);
      final b = DateTime(_day.year, _day.month, _day.day);
      return a == b;
    }();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _today,
        child: const Icon(Icons.today),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _jump(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Center(
                      child: TextButton(
                        onPressed: _pick,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: isToday ? cs.primary : cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _jump(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final delta = i - _center;
                  final now = DateTime.now();
                  final base = DateTime(now.year, now.month, now.day);
                  final day = base.add(Duration(days: delta));

                  // subtle premium motion
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Padding(
                      key: ValueKey(day.toIso8601String()),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: _DaySchedule(day: day),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySchedule extends ConsumerWidget {
  final DateTime day;
  const _DaySchedule({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final async = ref.watch(scheduleProvider(day));
    final subjectsAsync = ref.watch(meSubjectsProvider);

    String subjectName(String id) {
      return subjectsAsync.maybeWhen(
        data: (rows) {
          final hit = rows.where((x) => x.id == id).toList();
          return hit.isEmpty ? id : hit.first.name;
        },
        orElse: () => id,
      );
    }

    bool isNow(DateTime s, DateTime e) {
      final now = DateTime.now();
      return now.isAfter(s) && now.isBefore(e);
    }

    String t(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    Widget pill(String text, {bool strong = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: strong
              ? cs.primary.withValues(alpha: 0.90)
              : cs.primaryContainer.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: strong ? cs.onPrimary : cs.onPrimaryContainer,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy, size: 38, color: cs.onSurfaceVariant),
                  const SizedBox(height: 10),
                  Text(
                    "No lessons",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Swipe left/right for another day.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          final summary = "${list.length} lessons • starts ${t(list.first.startAt)}";

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(scheduleProvider(day)),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              itemCount: list.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      summary,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                final l = list[i - 1];
                final nowFlag = isNow(l.startAt, l.endAt);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: nowFlag
                        ? cs.primaryContainer.withValues(alpha: 0.60)
                        : cs.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: nowFlag
                          ? cs.primary.withValues(alpha: 0.65)
                          : cs.outline.withValues(alpha: 0.12),
                      width: nowFlag ? 1.4 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${t(l.startAt)} - ${t(l.endAt)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: pill(subjectName(l.subjectId))),
                          if (nowFlag) ...[
                            const SizedBox(width: 8),
                            pill("NOW", strong: true),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (l.room != null)
                        Text(
                          "Room: ${l.room}",
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      if (l.teacher != null)
                        Text(
                          "Teacher: ${l.teacher}",
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
