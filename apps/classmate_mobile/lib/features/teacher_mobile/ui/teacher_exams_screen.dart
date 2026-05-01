import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

class TeacherExamsScreen extends ConsumerStatefulWidget {
  const TeacherExamsScreen({super.key});

  @override
  ConsumerState<TeacherExamsScreen> createState() => _TeacherExamsScreenState();
}

class _TeacherExamsScreenState extends ConsumerState<TeacherExamsScreen> {
  TeacherAssessmentBundle? _bundle;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bundle = await ref.read(teacherMobileRepositoryProvider).fetchAssessments();
      if (!mounted) return;
      setState(() {
        _bundle = bundle;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();

    final assessments = _bundle?.assessments ?? [];
    final courses = _bundle?.courses ?? [];

    final upcoming = assessments.where((a) {
      final d = DateTime.tryParse(a.date);
      return d != null && !d.isBefore(now);
    }).toList();
    final past = assessments.where((a) {
      final d = DateTime.tryParse(a.date);
      return d != null && d.isBefore(now);
    }).toList();

    Widget buildCard(TeacherAssessment a) {
      final course = courses.where((c) => c.id == a.courseId).firstOrNull;
      final dateStr = a.date.split('T').first;
      final dateDisplay = () {
        final d = DateTime.tryParse(a.date);
        if (d == null) return dateStr;
        return DateFormat.yMMMd(locale).format(d);
      }();
      final isUpcoming = DateTime.tryParse(a.date)?.isAfter(now) ?? false;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LiquidGlassCard(
          gradient: LinearGradient(
            colors: [
              cs.surface.withValues(alpha: 0.88),
              cs.surfaceContainerHigh.withValues(alpha: 0.66),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isUpcoming ? cs.primary : cs.secondary).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUpcoming ? Icons.upcoming_rounded : Icons.history_edu_rounded,
                  size: 22,
                  color: isUpcoming ? cs.primary : cs.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (course != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        course.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Chip(label: dateDisplay, color: isUpcoming ? cs.primary : cs.secondary),
                        if (a.maxGrade != null)
                          _Chip(label: '/ ${a.maxGrade}', color: cs.tertiary),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isUpcoming ? cs.primary : cs.secondary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUpcoming ? l.teacherExamsUpcoming : l.teacherExamsPast,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUpcoming ? cs.primary : cs.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Hero banner
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            blurSigma: 20,
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer.withValues(alpha: 0.92),
                cs.surfaceContainerHigh.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.teacherExamsTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${upcoming.length} ${l.teacherExamsUpcoming}  ·  ${past.length} ${l.teacherExamsPast}',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.quiz_rounded, size: 24, color: cs.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LiquidGlassCard(
                color: cs.errorContainer.withValues(alpha: 0.72),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: cs.error),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: TextStyle(color: cs.onErrorContainer))),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            ),

          if (_loading && _bundle == null)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (assessments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.quiz_outlined, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      l.teacherExamsEmpty,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (upcoming.isNotEmpty) ...[
              _SectionHeader(label: l.teacherExamsUpcoming, icon: Icons.upcoming_rounded, color: cs.primary),
              const SizedBox(height: 8),
              ...upcoming.map(buildCard),
              const SizedBox(height: 8),
            ],
            if (past.isNotEmpty) ...[
              _SectionHeader(label: l.teacherExamsPast, icon: Icons.history_edu_rounded, color: cs.secondary),
              const SizedBox(height: 8),
              ...past.map(buildCard),
            ],
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: color.withValues(alpha: 0.25))),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
