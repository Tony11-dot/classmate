import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/schedule_providers.dart';
import '../classrooms/ui/classroom_detail_screen.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime _selectedDate;

  String _friendlyScheduleError(Object error) {
    final raw = error.toString();
    if (raw.contains('HTTP 429') || raw.contains('Too Many Requests')) {
      return 'Schedule is refreshing too fast right now. Wait a moment and try again.';
    }
    if (raw.contains('Student not onboarded')) {
      return 'Your student profile is not fully set up yet.';
    }
    return 'Could not load schedule.';
  }

  Future<void> _retryWeek(String weekOf) async {
    ref.invalidate(weekScheduleProvider(weekOf));
    await ref.read(weekScheduleProvider(weekOf).future);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final weekOf = _weekStartYmd(_selectedDate);
    final weekAsync = ref.watch(weekScheduleProvider(weekOf));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () => _retryWeek(weekOf),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -50) {
            _shiftDay(1);
          } else if (v > 50) {
            _shiftDay(-1);
          }
        },
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            weekAsync.when(
              data: (data) => _heroCard(context, data),
              loading: () => _heroLoadingCard(context),
              error: (error, _) =>
                  _heroErrorCard(context, _friendlyScheduleError(error), () {
                    _retryWeek(weekOf);
                  }),
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  _navBtn(
                    context,
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _shiftDay(-1),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _pickDate(context),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '${_friendlyDate(_ymd(_selectedDate))} · ${_weekdayLong(_selectedDate)}',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _navBtn(
                    context,
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _shiftDay(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            weekAsync.when(
              data: (data) => _daySection(context, data),
              loading: () => const _LoadingState(),
              error: (error, _) => _ErrorState(
                message: _friendlyScheduleError(error),
                onRetry: () {
                  _retryWeek(weekOf);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final days = _weekDays(data);
    final selectedItems = _itemsForSelectedDate(data);
    final next = selectedItems.isNotEmpty ? selectedItems.first : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.95),
            cs.surfaceContainerHigh.withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your schedule',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statPill(
                context,
                icon: Icons.today_rounded,
                label: 'Selected day',
                value: '${selectedItems.length} classes',
              ),
              _statPill(
                context,
                icon: Icons.calendar_view_week_rounded,
                label: 'This week',
                value:
                    '${days.fold<int>(0, (sum, day) => sum + (((day['items'] as List?)?.length) ?? 0))} classes',
              ),
              _statPill(
                context,
                icon: Icons.schedule_rounded,
                label: 'Next up',
                value: next == null
                    ? 'No more classes'
                    : '${_timeLabel(next)} • ${_titleOf(next)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroLoadingCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: cs.surfaceContainerHigh.withValues(alpha: 0.75),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _heroErrorCard(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: cs.errorContainer.withValues(alpha: 0.45),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your schedule',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            'Could not load schedule',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
          const SizedBox(height: 8),
          Text(message, maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _navBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget _daySection(BuildContext context, Map<String, dynamic> data) {
    final items = _itemsForSelectedDate(data);

    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.free_breakfast_rounded,
        title: 'No classes on this day',
        subtitle: '${_weekdayLong(_selectedDate)} looks clear.',
      );
    }

    final sorted = [...items]
      ..sort((a, b) {
        final ap = (a['period'] as num?)?.toInt() ?? 999;
        final bp = (b['period'] as num?)?.toInt() ?? 999;
        if (ap != bp) return ap.compareTo(bp);
        return _startsAt(a).compareTo(_startsAt(b));
      });

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _weekdayLong(_selectedDate),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _friendlyDate(_ymd(_selectedDate)),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        ...sorted.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ScheduleTile(item: item),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() => _selectedDate = _dateOnly(picked));
  }

  void _shiftDay(int delta) {
    setState(() {
      _selectedDate = _dateOnly(_selectedDate.add(Duration(days: delta)));
    });
  }

  List<Map<String, dynamic>> _weekDays(Map<String, dynamic>? data) {
    final raw = (((data ?? const {})['items'] ?? const {})['days']) as List?;
    return raw
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _itemsForSelectedDate(Map<String, dynamic>? data) {
    final date = _ymd(_selectedDate);
    final days = _weekDays(data);
    final match = days.cast<Map<String, dynamic>?>().firstWhere(
      (d) => (d?['date']?.toString() ?? '') == date,
      orElse: () => null,
    );

    if (match == null) return <Map<String, dynamic>>[];

    final raw = (match['items'] as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _ymd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _weekStartYmd(DateTime d) {
    final local = _dateOnly(d);
    final sundayBased = local.weekday % 7;
    final start = local.subtract(Duration(days: sundayBased));
    return _ymd(start);
  }

  String _friendlyDate(String ymd) {
    try {
      final d = DateTime.parse(ymd);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return ymd;
    }
  }

  String _weekdayLong(DateTime d) {
    const names = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return names[d.weekday % 7];
  }

  String _startsAt(Map<String, dynamic> item) => '${item['startsAt'] ?? ''}';
  String _timeLabel(Map<String, dynamic> item) =>
      '${item['startsAt'] ?? '--:--'}–${item['endsAt'] ?? '--:--'}';
  String _titleOf(Map<String, dynamic> item) => '${item['title'] ?? 'Class'}';
}

Widget _statPill(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  return Container(
    constraints: const BoxConstraints(minWidth: 150),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: cs.surface.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final title = '${item['title'] ?? 'Class'}';
    final subject = (item['subject'] ?? '').toString().trim();
    final location = (item['location'] ?? '').toString().trim();
    final startsAt = '${item['startsAt'] ?? '--:--'}';
    final endsAt = '${item['endsAt'] ?? '--:--'}';
    final period = (item['period'] as num?)?.toInt();
    final courseId = (item['courseId'] ?? '').toString().trim();

    final subtitleParts = <String>[
      if (subject.isNotEmpty) subject,
      if (location.isNotEmpty) location,
    ];

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: courseId.isEmpty
          ? null
          : () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (_) => ClassroomDetailScreen(courseId: courseId),
              ),
            ),
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 68,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      startsAt,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endsAt,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (period != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'P$period',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitleParts.isEmpty
                          ? 'No subject/location yet'
                          : subtitleParts.join(' • '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                courseId.isEmpty
                    ? Icons.drag_handle_rounded
                    : Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 34),
          const SizedBox(height: 10),
          const Text(
            'Could not load schedule',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
