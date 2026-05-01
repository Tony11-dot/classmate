import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

class TeacherClassroomAnalyticsScreen extends ConsumerStatefulWidget {
  const TeacherClassroomAnalyticsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.subject,
  });

  final String courseId;
  final String courseName;
  final String subject;

  @override
  ConsumerState<TeacherClassroomAnalyticsScreen> createState() =>
      _TeacherClassroomAnalyticsScreenState();
}

class _TeacherClassroomAnalyticsScreenState
    extends ConsumerState<TeacherClassroomAnalyticsScreen> {
  Map<String, dynamic> _data = const {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ref.read(teacherMobileRepositoryProvider).fetchClassroomAnalytics(widget.courseId);
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Color _gradeColor(int? pct, ColorScheme cs) {
    if (pct == null) return cs.onSurfaceVariant;
    if (pct >= 80) return const Color(0xFF22C55E);
    if (pct >= 60) return const Color(0xFFF59E0B);
    return cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final totalStudents = (_data['totalStudents'] ?? 0) as int;
    final totalAssignments = (_data['totalAssignments'] ?? 0) as int;
    final attRate = _data['attendanceRate'] is int ? _data['attendanceRate'] as int : null;
    final gradeStats = _data['gradeStats'] is List ? _data['gradeStats'] as List : <dynamic>[];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.7),
                    cs.surfaceContainerHigh.withValues(alpha: 0.78),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () { if (context.canPop()) context.pop(); },
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(backgroundColor: cs.surface.withValues(alpha: 0.6), padding: const EdgeInsets.all(8)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.teacherAnalyticsTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        Text(widget.subject.isNotEmpty ? widget.subject : widget.courseName,
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.error_outline_rounded, size: 48, color: cs.error.withValues(alpha: 0.6)),
                            const SizedBox(height: 16),
                            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
                            const SizedBox(height: 20),
                            FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: Text(AppLocalizations.of(context)!.retry)),
                          ]),
                        ))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            children: [
                              // Top metrics
                              Row(
                                children: [
                                  Expanded(child: _StatCard(label: AppLocalizations.of(context)!.teacherStudentsLabel, value: '$totalStudents', icon: Icons.group_rounded, color: cs.primary)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _StatCard(
                                    label: AppLocalizations.of(context)!.navAttendance,
                                    value: attRate != null ? '$attRate%' : '—',
                                    icon: Icons.fact_check_rounded,
                                    color: attRate == null ? cs.onSurfaceVariant
                                        : attRate >= 90 ? const Color(0xFF22C55E)
                                        : attRate >= 75 ? const Color(0xFFF59E0B)
                                        : cs.error,
                                  )),
                                  const SizedBox(width: 10),
                                  Expanded(child: _StatCard(label: AppLocalizations.of(context)!.navAssignments, value: '$totalAssignments', icon: Icons.assignment_rounded, color: cs.secondary)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Assessments with grade distribution
                              if (gradeStats.isNotEmpty) ...[
                                Text(AppLocalizations.of(context)!.teacherGradeReports, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant)),
                                const SizedBox(height: 10),
                                ...gradeStats.map((stat) {
                                  final s = Map<String, dynamic>.from(stat is Map ? stat : {});
                                  final title = (s['title'] ?? '').toString();
                                  final avg = s['avg'] is int ? s['avg'] as int : null;
                                  final graded = (s['gradedCount'] ?? 0) as int;
                                  final total = (s['totalStudents'] ?? 0) as int;
                                  final below60 = (s['below60'] ?? 0) as int;
                                  final dist = s['distribution'] is Map ? Map<String, dynamic>.from(s['distribution'] as Map) : <String, dynamic>{};
                                  final maxBucket = [
                                    dist['0-39'] ?? 0, dist['40-59'] ?? 0,
                                    dist['60-79'] ?? 0, dist['80-100'] ?? 0,
                                  ].fold<int>(0, (a, b) { final bInt = b is int ? b : 0; return a > bInt ? a : bInt; });

                                  final date = (s['date'] ?? '').toString();
                                  final dt = DateTime.tryParse(date);
                                  final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                                  final dateLabel = dt != null ? '${months[dt.month-1]} ${dt.day}' : '';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: LiquidGlassCard(
                                      padding: const EdgeInsets.all(16),
                                      borderRadius: BorderRadius.circular(20),
                                      blurSigma: 12,
                                      color: cs.surface.withValues(alpha: 0.82),
                                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                                                    if (dateLabel.isNotEmpty)
                                                      Text(dateLabel, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    avg != null ? '$avg%' : '—',
                                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _gradeColor(avg, cs)),
                                                  ),
                                                  Text(AppLocalizations.of(context)!.teacherAvgLabel, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Grade distribution bars
                                          if (graded > 0) ...[
                                            Row(
                                              children: [
                                                Text(AppLocalizations.of(context)!.teacherGradedFraction(graded, total), style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                                if (below60 > 0) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: cs.errorContainer.withValues(alpha: 0.7),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(AppLocalizations.of(context)!.teacherBelow60(below60), style: TextStyle(fontSize: 11, color: cs.error, fontWeight: FontWeight.w700)),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            _DistributionBar(
                                              buckets: [
                                                _Bucket('0–39', (dist['0-39'] ?? 0) as int, cs.error),
                                                _Bucket('40–59', (dist['40-59'] ?? 0) as int, const Color(0xFFF59E0B)),
                                                _Bucket('60–79', (dist['60-79'] ?? 0) as int, const Color(0xFF60A5FA)),
                                                _Bucket('80–100', (dist['80-100'] ?? 0) as int, const Color(0xFF22C55E)),
                                              ],
                                              maxValue: maxBucket == 0 ? 1 : maxBucket,
                                            ),
                                          ] else
                                            Text(AppLocalizations.of(context)!.teacherNoGradesEntered, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ] else ...[
                                LiquidGlassCard(
                                  padding: const EdgeInsets.all(16),
                                  borderRadius: BorderRadius.circular(16),
                                  blurSigma: 10,
                                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
                                  child: Row(children: [
                                    Icon(Icons.bar_chart_rounded, color: cs.onSurfaceVariant),
                                    const SizedBox(width: 12),
                                    Text(AppLocalizations.of(context)!.teacherNoAssessmentsYet, style: TextStyle(color: cs.onSurfaceVariant)),
                                  ]),
                                ),
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.82),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Bucket {
  const _Bucket(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;
}

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({required this.buckets, required this.maxValue});
  final List<_Bucket> buckets;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: buckets.map((b) {
        final frac = maxValue > 0 ? b.count / maxValue : 0.0;
        final barH = (frac * 60).clamp(4.0, 60.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (b.count > 0)
                  Text('${b.count}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: b.color)),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: barH,
                  decoration: BoxDecoration(
                    color: b.color.withValues(alpha: b.count > 0 ? 0.85 : 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(b.label, style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
