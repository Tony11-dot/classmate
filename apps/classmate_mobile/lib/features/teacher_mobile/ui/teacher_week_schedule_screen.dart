// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

const _dayNamesFull = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

class TeacherWeekScheduleScreen extends ConsumerStatefulWidget {
  const TeacherWeekScheduleScreen({super.key});

  @override
  ConsumerState<TeacherWeekScheduleScreen> createState() =>
      _TeacherWeekScheduleScreenState();
}

class _TeacherWeekScheduleScreenState
    extends ConsumerState<TeacherWeekScheduleScreen> {
  Map<String, dynamic> _data = const {};
  bool _loading = true;
  String? _error;
  DateTime _weekAnchor = _mondayOf(DateTime.now());

  static DateTime _mondayOf(DateTime d) {
    final diff = (d.weekday - DateTime.monday) % 7;
    return DateTime(d.year, d.month, d.day - diff);
  }

  String get _weekOfParam {
    final d = _weekAnchor;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ref.read(teacherMobileRepositoryProvider).fetchWeekSchedule(weekOf: _weekOfParam);
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _prevWeek() {
    setState(() => _weekAnchor = _weekAnchor.subtract(const Duration(days: 7)));
    _load();
  }

  void _nextWeek() {
    final next = _weekAnchor.add(const Duration(days: 7));
    final now = DateTime.now();
    if (next.isAfter(DateTime(now.year, now.month, now.day + 7))) return;
    setState(() => _weekAnchor = next);
    _load();
  }

  void _goToday() {
    setState(() => _weekAnchor = _mondayOf(DateTime.now()));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final days = _data['days'] is List ? _data['days'] as List : <dynamic>[];
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.65),
                    cs.surfaceContainerHigh.withValues(alpha: 0.72),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () { if (context.canPop()) context.pop(); },
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(backgroundColor: cs.surface.withValues(alpha: 0.6), padding: const EdgeInsets.all(8)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Week Schedule', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      ),
                      TextButton(onPressed: _goToday, child: const Text('Today')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Week navigator
                  Row(
                    children: [
                      IconButton(
                        onPressed: _prevWeek,
                        icon: const Icon(Icons.chevron_left_rounded),
                        style: IconButton.styleFrom(backgroundColor: cs.surface.withValues(alpha: 0.6), padding: const EdgeInsets.all(6)),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _weekLabel(),
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _nextWeek,
                        icon: const Icon(Icons.chevron_right_rounded),
                        style: IconButton.styleFrom(backgroundColor: cs.surface.withValues(alpha: 0.6), padding: const EdgeInsets.all(6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _ErrorState(message: _error!, onRetry: _load)
                      : days.isEmpty
                          ? _EmptyState(
                              icon: Icons.event_busy_rounded,
                              title: 'No classes this week',
                              subtitle: 'Your schedule for this week is empty',
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                                itemCount: days.length,
                                itemBuilder: (context, i) {
                                  final day = Map<String, dynamic>.from(days[i] is Map ? days[i] as Map : {});
                                  final dateStr = (day['date'] ?? '').toString();
                                  final dayOfWeek = day['dayOfWeek'] as int? ?? 0;
                                  final slots = day['slots'] is List ? day['slots'] as List : <dynamic>[];
                                  final isToday = dateStr == todayStr;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Day header
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: isToday ? cs.primary : cs.primaryContainer.withValues(alpha: 0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _dayNum(dateStr),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 16,
                                                    color: isToday ? cs.onPrimary : cs.onPrimaryContainer,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _dayNamesFull[dayOfWeek],
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: isToday ? cs.primary : cs.onSurface,
                                                  ),
                                                ),
                                                Text(
                                                  _formatDate(dateStr),
                                                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                                ),
                                              ],
                                            ),
                                            if (isToday) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: cs.primary,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text('Today', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        ...slots.map((slot) {
                                          final s = Map<String, dynamic>.from(slot is Map ? slot : {});
                                          final period = (s['period'] ?? 0).toString();
                                          final course = Map<String, dynamic>.from(s['course'] is Map ? s['course'] as Map : {});
                                          final cohort = Map<String, dynamic>.from(s['cohort'] is Map ? s['cohort'] as Map : {});
                                          final courseName = (course['name'] ?? '').toString();
                                          final subject = (course['subject'] ?? '').toString();
                                          final cohortName = (cohort['name'] ?? '').toString();
                                          final grade = (cohort['grade'] ?? 0).toString();
                                          final courseId = (course['id'] ?? '').toString();

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8, left: 50),
                                            child: InkWell(
                                              onTap: courseId.isNotEmpty
                                                  ? () => context.push('/teacher/classroom/$courseId', extra: <String, dynamic>{
                                                      'name': courseName,
                                                      'subject': subject,
                                                      'cohortName': cohortName,
                                                      'grade': int.tryParse(grade) ?? 0,
                                                    })
                                                  : null,
                                              borderRadius: BorderRadius.circular(16),
                                              child: LiquidGlassCard(
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                borderRadius: BorderRadius.circular(16),
                                                blurSigma: 10,
                                                color: isToday ? cs.primaryContainer.withValues(alpha: 0.35) : cs.surface.withValues(alpha: 0.82),
                                                border: Border.all(
                                                  color: isToday ? cs.primary.withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.2),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Period badge
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: cs.secondaryContainer.withValues(alpha: 0.8),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          period,
                                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: cs.secondary),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            subject.isNotEmpty ? subject : courseName,
                                                            style: const TextStyle(fontWeight: FontWeight.w800),
                                                          ),
                                                          Text(
                                                            'Grade $grade · $cohortName',
                                                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 18),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekLabel() {
    final end = _weekAnchor.add(const Duration(days: 6));
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (_weekAnchor.month == end.month) {
      return '${months[_weekAnchor.month - 1]} ${_weekAnchor.day}–${end.day}, ${_weekAnchor.year}';
    }
    return '${months[_weekAnchor.month - 1]} ${_weekAnchor.day} – ${months[end.month - 1]} ${end.day}';
  }

  String _dayNum(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length < 3) return '';
    return parts[2].replaceFirst(RegExp('^0'), '');
  }

  String _formatDate(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Theme.of(context).colorScheme.error.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text('Could not load schedule', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
