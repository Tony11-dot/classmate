import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

class TeacherStudentProfileScreen extends ConsumerStatefulWidget {
  const TeacherStudentProfileScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  final String studentId;
  final String studentName;

  @override
  ConsumerState<TeacherStudentProfileScreen> createState() =>
      _TeacherStudentProfileScreenState();
}

class _TeacherStudentProfileScreenState
    extends ConsumerState<TeacherStudentProfileScreen> {
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
      final data = await ref.read(teacherMobileRepositoryProvider).fetchStudentProfile(widget.studentId);
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final student = _data['student'] is Map ? Map<String, dynamic>.from(_data['student'] as Map) : <String, dynamic>{};
    final grades = _data['grades'] is List ? _data['grades'] as List : <dynamic>[];
    final gradeAvg = _data['gradeAverage'] is int ? _data['gradeAverage'] as int : null;
    final attRate = _data['attendanceRate'] is int ? _data['attendanceRate'] as int : null;
    final submissionsCount = (_data['submissionsCount'] ?? 0) as int;
    final attBreakdown = _data['attendanceBreakdown'] is Map
        ? Map<String, dynamic>.from(_data['attendanceBreakdown'] as Map)
        : <String, dynamic>{};

    String _initials() {
      final parts = widget.studentName.trim().split(RegExp(r'\s+'));
      if (parts.isEmpty) return '?';
      if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    Color _gradeColor(int? pct) {
      if (pct == null) return cs.onSurfaceVariant;
      if (pct >= 80) return const Color(0xFF22C55E); // green
      if (pct >= 60) return const Color(0xFFF59E0B); // amber
      return cs.error;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.75),
                    cs.surfaceContainerHigh.withValues(alpha: 0.8),
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
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.primary,
                    child: Text(_initials(), style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.studentName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        if ((student['email'] ?? '').toString().isNotEmpty)
                          Text(student['email'].toString(), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body
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
                            FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
                          ]),
                        ))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            children: [
                              // Summary cards
                              Row(
                                children: [
                                  Expanded(child: _SummaryCard(
                                    label: 'Grade Avg',
                                    value: gradeAvg != null ? '$gradeAvg%' : '—',
                                    icon: Icons.grade_rounded,
                                    color: _gradeColor(gradeAvg),
                                  )),
                                  const SizedBox(width: 10),
                                  Expanded(child: _SummaryCard(
                                    label: 'Attendance',
                                    value: attRate != null ? '$attRate%' : '—',
                                    icon: Icons.fact_check_rounded,
                                    color: attRate == null ? cs.onSurfaceVariant
                                        : attRate >= 90 ? const Color(0xFF22C55E)
                                        : attRate >= 75 ? const Color(0xFFF59E0B)
                                        : cs.error,
                                  )),
                                  const SizedBox(width: 10),
                                  Expanded(child: _SummaryCard(
                                    label: 'Submitted',
                                    value: '$submissionsCount',
                                    icon: Icons.upload_file_rounded,
                                    color: cs.secondary,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Attendance breakdown
                              if (attBreakdown.isNotEmpty) ...[
                                LiquidGlassCard(
                                  padding: const EdgeInsets.all(16),
                                  borderRadius: BorderRadius.circular(20),
                                  blurSigma: 12,
                                  color: cs.surface.withValues(alpha: 0.82),
                                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Attendance (last 30 days)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _AttPill(label: 'Present', count: (attBreakdown['PRESENT'] ?? 0) as int, color: const Color(0xFF22C55E)),
                                          const SizedBox(width: 8),
                                          _AttPill(label: 'Absent', count: (attBreakdown['ABSENT'] ?? 0) as int, color: cs.error),
                                          const SizedBox(width: 8),
                                          _AttPill(label: 'Late', count: (attBreakdown['LATE'] ?? 0) as int, color: const Color(0xFFF59E0B)),
                                          const SizedBox(width: 8),
                                          _AttPill(label: 'Excused', count: (attBreakdown['EXCUSED'] ?? 0) as int, color: cs.tertiary),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Grades list
                              if (grades.isNotEmpty) ...[
                                Text('Recent Grades', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant)),
                                const SizedBox(height: 10),
                                ...grades.map((g) {
                                  final item = Map<String, dynamic>.from(g is Map ? g : {});
                                  final title = (item['title'] ?? '').toString();
                                  final subject = (item['subject'] ?? item['courseName'] ?? '').toString();
                                  final pct = item['pct'] is int ? item['pct'] as int : null;
                                  final raw = item['raw'];
                                  final max = item['max'];
                                  final date = (item['date'] ?? '').toString();
                                  final dt = DateTime.tryParse(date);
                                  final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                                  final dateLabel = dt != null ? '${months[dt.month-1]} ${dt.day}' : '';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: LiquidGlassCard(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      borderRadius: BorderRadius.circular(16),
                                      blurSigma: 8,
                                      color: cs.surface.withValues(alpha: 0.8),
                                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                                if (subject.isNotEmpty)
                                                  Text(subject, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                pct != null ? '$pct%' : '—',
                                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _gradeColor(pct)),
                                              ),
                                              if (raw != null && max != null)
                                                Text('$raw/$max', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                                              if (dateLabel.isNotEmpty)
                                                Text(dateLabel, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                                            ],
                                          ),
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
                                  child: Row(
                                    children: [
                                      Icon(Icons.grade_outlined, color: cs.onSurfaceVariant),
                                      const SizedBox(width: 12),
                                      Text('No grades recorded yet', style: TextStyle(color: cs.onSurfaceVariant)),
                                    ],
                                  ),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});
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
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _AttPill extends StatelessWidget {
  const _AttPill({required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 18)),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
