// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/realtime/realtime_listener.dart';
import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/attachment_pill.dart';

import '../../../ui/widgets/cm_sub_bar.dart';
class TeacherAssignmentDetailScreen extends ConsumerStatefulWidget {
  const TeacherAssignmentDetailScreen({
    super.key,
    required this.assignmentId,
    this.assignmentTitle,
  });

  final String assignmentId;
  final String? assignmentTitle;

  @override
  ConsumerState<TeacherAssignmentDetailScreen> createState() =>
      _TeacherAssignmentDetailScreenState();
}

class _TeacherAssignmentDetailScreenState
    extends ConsumerState<TeacherAssignmentDetailScreen> {
  List<Map<String, dynamic>> _submissions = [];
  List<Map<String, dynamic>> _assignmentAttachments = [];
  bool _loading = true;
  String? _error;
  bool _saving = false;

  // Grade draft: studentId → gradeController
  final Map<String, TextEditingController> _gradeControllers = {};
  final Map<String, TextEditingController> _feedbackControllers = {};

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    for (final c in _gradeControllers.values) {
      c.dispose();
    }
    for (final c in _feedbackControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final assignmentDetails = await repo.listTeacherAssignments();
      final thisAssignment = assignmentDetails.firstWhere(
        (a) => a['id']?.toString() == widget.assignmentId,
        orElse: () => const {},
      );
      final rawAttach = thisAssignment['attachments'];
      final loadedAttachments = rawAttach is List
          ? rawAttach.whereType<Map>().map((a) => Map<String, dynamic>.from(a)).toList()
          : <Map<String, dynamic>>[];

      final subs = await repo.getTeacherAssignmentSubmissions(widget.assignmentId);
      if (!mounted) return;
      // Build controllers
      for (final sub in subs) {
        final sid = sub['studentId'] as String? ?? '';
        if (!_gradeControllers.containsKey(sid)) {
          final existing = sub['grade'];
          _gradeControllers[sid] = TextEditingController(
            text: existing != null ? '$existing' : '',
          );
          _feedbackControllers[sid] = TextEditingController(
            text: (sub['feedback'] as String?) ?? '',
          );
        }
      }
      setState(() {
        _submissions = subs;
        _assignmentAttachments = loadedAttachments;
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

  Future<void> _saveGrades() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final futures = _submissions.map((sub) {
        final sid = sub['studentId'] as String? ?? '';
        final gradeStr = _gradeControllers[sid]?.text.trim() ?? '';
        final feedback = _feedbackControllers[sid]?.text.trim() ?? '';
        final grade = int.tryParse(gradeStr);
        if (grade == null && feedback.isEmpty) return Future.value();
        return repo.gradeAssignmentSubmission(
          assignmentId: widget.assignmentId,
          studentId: sid,
          grade: grade,
          feedback: feedback.isNotEmpty ? feedback : null,
        );
      });
      await Future.wait(futures);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.teacherGradesSaved)),
      );
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final tk = CmTokens.of(context);

    // Refresh when student submits (teacher sees new submission live)
    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'assignment_created') _load();
    });

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CmSubBar(
        onBack: () => context.pop(),
        title: widget.assignmentTitle ?? AppLocalizations.of(context)!.teacherAssignmentDetailScreenTitle,
        actions: [
          if (_submissions.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveGrades,
                icon: _saving
                    ? const CmLoading(size: 16)
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text(AppLocalizations.of(context)!.teacherSaveGradesButton),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CmLoading())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CmEmptyState(
                        icon: Icons.error_outline_rounded,
                        title: l.commonError,
                        message: _error,
                      ),
                      FilledButton(onPressed: _load, child: Text(l.commonRetry)),
                    ],
                  ),
                )
              : _submissions.isEmpty
                  ? Center(
                      child: CmEmptyState(
                        icon: Icons.inbox_rounded,
                        title: l.teacherAssignmentDetailScreenNoSubmissions,
                      ),
                    )
                  : ListView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      children: [
                        _SummaryHero(
                          submitted: _submissions.length,
                          graded: _submissions.where((s) => s['grade'] != null).length,
                        ),
                        // Assignment attachments (files / links the teacher added)
                        if (_assignmentAttachments.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          CmSectionHeader(
                            label: l.commonAttachments,
                            icon: Icons.attach_file_rounded,
                            count: _assignmentAttachments.length,
                          ),
                          AttachmentPills(attachments: _assignmentAttachments),
                        ],
                        const SizedBox(height: 14),
                        CmSectionHeader(
                          label: l.teacherAssignmentDetailScreenSubmissionCount(_submissions.length),
                          icon: Icons.inbox_rounded,
                        ),

                        // Submissions
                        ..._submissions.map((sub) {
                          final sid = sub['studentId'] as String? ?? '';
                          final name = sub['studentName'] as String? ?? l.teacherAssignmentDetailScreenStudentFallback;
                          final submittedAt = sub['submittedAt'] as String? ?? '';
                          final note = sub['note'] as String? ?? '';
                          final gradedAt = sub['gradedAt'] as String? ?? '';
                          final returned = ((sub['status'] ?? '') as String).toUpperCase() == 'RETURNED';
                          final submittedDate = submittedAt.isNotEmpty ? DateTime.tryParse(submittedAt) : null;
                          final rawFiles = sub['files'];
                          final fileList = rawFiles is List
                              ? rawFiles.whereType<Map>().map((f) => Map<String, dynamic>.from(f)).toList()
                              : const <Map<String, dynamic>>[];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CmCard(
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Student header
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: cs.secondary.withValues(alpha: cs.brightness == Brightness.dark ? 0.24 : 0.14),
                                        child: Text(
                                          _initials(name),
                                          style: TextStyle(fontWeight: FontWeight.w900, color: cs.secondary, fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                            ),
                                            if (submittedDate != null)
                                              Text(
                                                l.teacherAssignmentDetailScreenSubmittedOn(FriendlyDate.date(submittedDate)),
                                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                              ),
                                            if (returned || gradedAt.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 6,
                                                children: [
                                                  if (gradedAt.isNotEmpty)
                                                    CmPill(
                                                      icon: Icons.check_circle_rounded,
                                                      label: l.teacherAssignmentGradedStatus,
                                                      color: tk.good,
                                                    ),
                                                  if (returned)
                                                    CmPill(
                                                      icon: Icons.replay_rounded,
                                                      label: l.teacherAssignmentReturnedStatus,
                                                      color: tk.warn,
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (note.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(CmTokens.radiusSm),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.format_quote_rounded, size: 16, color: cs.onSurfaceVariant),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text(note, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4))),
                                        ],
                                      ),
                                    ),
                                  ],
                                  // Submitted file attachments — rendered with
                                  // AttachmentPills so the teacher opens them
                                  // IN-APP (same viewer as everywhere else),
                                  // not bounced to an external browser.
                                  if (fileList.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: AttachmentPills(attachments: fileList),
                                    ),

                                  const SizedBox(height: 12),
                                  // Grade input
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: cs.brightness == Brightness.dark ? 0.12 : 0.05),
                                      borderRadius: BorderRadius.circular(CmTokens.radiusMd),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 84,
                                          child: TextField(
                                            controller: _gradeControllers[sid],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              fontFeatures: const [FontFeature.tabularFigures()],
                                            ),
                                            decoration: InputDecoration(
                                              labelText: l.teacherGradeFieldLabel,
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextField(
                                            controller: _feedbackControllers[sid],
                                            decoration: InputDecoration(
                                              labelText: l.teacherFeedbackOptionalLabel,
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              isDense: true,
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Return for re-solution — keeps the student's
                                  // work on record, flags it RETURNED, attaches
                                  // the feedback note, and reopens the student's
                                  // hand-in form so they can revise & resubmit.
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: TextButton.icon(
                                      style: TextButton.styleFrom(foregroundColor: tk.warn),
                                      icon: const Icon(Icons.replay_rounded, size: 18),
                                      label: Text(l.teacherAssignmentReturnAction),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text(AppLocalizations.of(ctx)!.teacherAssignmentReturnAction),
                                            content: Text(
                                                AppLocalizations.of(ctx)!.teacherAssignmentReturnDialogBody(name)),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx)!.commonCancel)),
                                              FilledButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: Text(AppLocalizations.of(context)!.commonReturn),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm != true || !mounted) return;
                                        try {
                                          await ref.read(teacherMobileRepositoryProvider).returnAssignmentSubmission(
                                            widget.assignmentId, sid,
                                            feedback: _feedbackControllers[sid]?.text.trim(),
                                          );
                                          _load();
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonErrorWith(e))));
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Submitted / graded counts with a progress bar of how much is graded.
class _SummaryHero extends StatelessWidget {
  const _SummaryHero({required this.submitted, required this.graded});

  final int submitted;
  final int graded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final tk = CmTokens.of(context);
    final frac = submitted == 0 ? 0.0 : graded / submitted;
    return CmCard(
      tint: cs.secondary,
      radius: CmTokens.radiusXl,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.teacherAssignmentDetailScreenSubmissionCount(submitted),
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.teacherAssignmentDetailScreenGradedCount(graded),
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CmIconTile(icon: Icons.rate_review_rounded, color: cs.secondary, size: 52, filled: true),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 8,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.35),
              valueColor: AlwaysStoppedAnimation<Color>(frac >= 1 ? tk.good : cs.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
