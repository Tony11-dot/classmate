import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../messages/providers/messages_repository_provider.dart';
import 'teacher_student_grade_detail_screen.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

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

    final tk = CmTokens.of(context);
    final l = AppLocalizations.of(context)!;

    Color gradeColor(int? pct) {
      if (pct == null) return cs.onSurfaceVariant;
      if (pct >= 80) return tk.good;
      if (pct >= 60) return tk.warn;
      return cs.error;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l.a11yBack,
                    onPressed: () { if (context.canPop()) context.pop(); },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  CmMonogram(name: widget.studentName, radius: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if ((student['email'] ?? '').toString().isNotEmpty)
                          Text(
                            student['email'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: _loading
                  ? const Center(child: CmLoading())
                  : _error != null
                      ? Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            CmEmptyState(icon: Icons.error_outline_rounded, title: l.commonError, message: _error),
                            FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: Text(l.retry)),
                          ]),
                        )
                      : CmRefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                            children: [
                              // ── Quick actions ──────────────────────────────────────
                              _QuickActionsCard(
                                studentId: widget.studentId,
                                studentName: widget.studentName,
                              ),
                              const SizedBox(height: 14),
                              // Summary cards
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: _SummaryCard(
                                      label: l.teacherGradeAvg,
                                      value: gradeAvg != null ? '$gradeAvg%' : '—',
                                      icon: Icons.grade_rounded,
                                      color: gradeColor(gradeAvg),
                                    )),
                                    const SizedBox(width: 10),
                                    Expanded(child: _SummaryCard(
                                      label: l.navAttendance,
                                      value: attRate != null ? '$attRate%' : '—',
                                      icon: Icons.fact_check_rounded,
                                      color: attRate == null ? cs.onSurfaceVariant
                                          : attRate >= 90 ? tk.good
                                          : attRate >= 75 ? tk.warn
                                          : cs.error,
                                    )),
                                    const SizedBox(width: 10),
                                    Expanded(child: _SummaryCard(
                                      label: l.teacherSubmittedLabel,
                                      value: '$submissionsCount',
                                      icon: Icons.upload_file_rounded,
                                      color: cs.secondary,
                                    )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Attendance breakdown
                              if (attBreakdown.isNotEmpty) ...[
                                CmFormSection(
                                  icon: Icons.fact_check_rounded,
                                  title: l.teacherAttendanceLast30,
                                  child: Row(
                                    children: [
                                      _AttPill(label: l.attendanceStatusPresent, count: (attBreakdown['PRESENT'] ?? 0) as int, color: tk.good),
                                      const SizedBox(width: 8),
                                      _AttPill(label: l.attendanceStatusAbsent, count: (attBreakdown['ABSENT'] ?? 0) as int, color: cs.error),
                                      const SizedBox(width: 8),
                                      _AttPill(label: l.attendanceStatusLate, count: (attBreakdown['LATE'] ?? 0) as int, color: tk.warn),
                                      const SizedBox(width: 8),
                                      _AttPill(label: l.attendanceStatusExcused, count: (attBreakdown['EXCUSED'] ?? 0) as int, color: cs.tertiary),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Grades list
                              CmSectionHeader(
                                label: l.teacherRecentGrades,
                                icon: Icons.grade_rounded,
                                count: grades.isEmpty ? null : grades.length,
                              ),
                              if (grades.isNotEmpty) ...[
                                ...grades.map((g) {
                                  final item = Map<String, dynamic>.from(g is Map ? g : {});
                                  final title = (item['title'] ?? '').toString();
                                  final subject = (item['subject'] ?? item['courseName'] ?? '').toString();
                                  final pct = item['pct'] is int ? item['pct'] as int : null;
                                  final raw = item['raw'];
                                  final max = item['max'];
                                  final date = (item['date'] ?? '').toString();
                                  final dateLabel = date.isNotEmpty ? FriendlyDate.date(date) : '';
                                  final meta = [subject, dateLabel].where((x) => x.isNotEmpty).join(' · ');
                                  final tone = gradeColor(pct);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: CmCard(
                                      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                                if (meta.isNotEmpty)
                                                  Text(meta, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            constraints: const BoxConstraints(minWidth: 60),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: tone.withValues(alpha: cs.brightness == Brightness.dark ? 0.2 : 0.12),
                                              borderRadius: BorderRadius.circular(CmTokens.radiusSm),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  pct != null ? '$pct%' : '—',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w900,
                                                    color: tone,
                                                    fontFeatures: const [FontFeature.tabularFigures()],
                                                  ),
                                                ),
                                                if (raw != null && max != null)
                                                  Text('$raw/$max', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ] else
                                CmEmptyState(icon: Icons.grade_outlined, title: l.teacherNoGradesRecorded),
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
    return CmCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CmIconTile(icon: icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick actions card — grades, add grade, certificate, DM
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsCard extends ConsumerStatefulWidget {
  const _QuickActionsCard({required this.studentId, required this.studentName});
  final String studentId;
  final String studentName;

  @override
  ConsumerState<_QuickActionsCard> createState() => _QuickActionsCardState();
}

class _QuickActionsCardState extends ConsumerState<_QuickActionsCard> {
  bool _dmLoading = false;

  Future<void> _startDm() async {
    if (_dmLoading) return;
    setState(() => _dmLoading = true);
    try {
      final detail = await ref
          .read(messagesRepositoryProvider)
          .createDirectRequest(recipientUserId: widget.studentId, firstMessage: '');
      if (!mounted) return;
      context.pushNamed('dm_thread', pathParameters: {'id': detail.id});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.teacherProfileChatError)),
      );
    } finally {
      if (mounted) setState(() => _dmLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // View grades — opens dedicated grade detail screen for this student
          Expanded(
            child: _ActionChip(
              icon: Icons.grade_rounded,
              label: l.navGrades,
              color: cs.secondary,
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (_) => TeacherStudentGradeDetailScreen(
                    student: TeacherStudentWithLevel(
                      studentId: widget.studentId,
                      name: widget.studentName,
                      email: '',
                      gradeLevel: null,
                      cohortId: '',
                      cohortName: '',
                      subjects: const [],
                      coursesBySubject: const {},
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Add a grade
          Expanded(
            child: _ActionChip(
              icon: Icons.add_chart_rounded,
              label: l.teacherAddGradeTitle,
              color: cs.tertiary,
              onTap: () => context.push('/teacher/grades/add', extra: <String, dynamic>{
                'prefillStudentId': widget.studentId,
                'prefillStudentName': widget.studentName,
              }),
            ),
          ),
          const SizedBox(width: 10),
          // Direct message
          Expanded(
            child: _ActionChip(
              icon: Icons.chat_bubble_rounded,
              label: l.navMessages,
              color: cs.primary,
              loading: _dmLoading,
              onTap: _startDm,
            ),
          ),
        ],
      ),
    );
  }
}

/// Square-ish action tile: filled icon tile over a label.
class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.color, required this.onTap, this.loading = false});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return CmCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loading
              ? SizedBox(width: 40, height: 40, child: Center(child: CmLoading(size: 20, color: color)))
              : CmIconTile(icon: icon, color: color, size: 40, filled: true),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
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
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: cs.brightness == Brightness.dark ? 0.2 : 0.12),
          borderRadius: BorderRadius.circular(CmTokens.radiusSm),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: color,
                fontSize: 20,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
