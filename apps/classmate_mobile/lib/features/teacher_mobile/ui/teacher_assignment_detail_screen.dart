// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/realtime/realtime_listener.dart';
import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/attachment_pill.dart';

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
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Refresh when student submits (teacher sees new submission live)
    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'assignment_created') _load();
    });

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.assignmentTitle ?? AppLocalizations.of(context)!.teacherAssignmentDetailScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_submissions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveGrades,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _load, child: Text(AppLocalizations.of(context)!.commonRetry)),
                      ],
                    ),
                  ),
                )
              : _submissions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_rounded, size: 56, color: cs.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.teacherAssignmentDetailScreenNoSubmissions,
                              style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      children: [
                        // Assignment attachments (files / links the teacher added)
                        if (_assignmentAttachments.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.commonAttachments, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                const SizedBox(height: 6),
                                AttachmentPills(attachments: _assignmentAttachments),
                              ],
                            ),
                          ),
                        ],
                        // Hero
                        LiquidGlassCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: cs.secondary),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.teacherAssignmentDetailScreenSubmissionCount(_submissions.length),
                                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.of(context)!.teacherAssignmentDetailScreenGradedCount(_submissions.where((s) => s['grade'] != null).length),
                                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: cs.secondary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.rate_review_rounded, size: 24, color: cs.onSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Submissions
                        ..._submissions.map((sub) {
                          final sid = sub['studentId'] as String? ?? '';
                          final name = sub['studentName'] as String? ?? AppLocalizations.of(context)!.teacherAssignmentDetailScreenStudentFallback;
                          final submittedAt = sub['submittedAt'] as String? ?? '';
                          final note = sub['note'] as String? ?? '';
                          final gradedAt = sub['gradedAt'] as String? ?? '';

                          DateTime? submittedDate;
                          if (submittedAt.isNotEmpty) submittedDate = DateTime.tryParse(submittedAt);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: LiquidGlassCard(
                              padding: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(20),
                              color: cs.surfaceContainerLow,
                              border: Border.all(color: cs.outlineVariant),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Student header
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: cs.secondaryContainer,
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSecondaryContainer),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                            if (submittedDate != null)
                                              Text(
                                                AppLocalizations.of(context)!.teacherAssignmentDetailScreenSubmittedOn(FriendlyDate.date(submittedDate)),
                                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (gradedAt.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)!.teacherAssignmentGradedStatus,
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF22C55E)),
                                          ),
                                        ),
                                    ],
                                  ),

                                  if (note.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: cs.outlineVariant),
                                      ),
                                      child: Text(note, style: theme.textTheme.bodySmall),
                                    ),
                                  ],
                                  // Submitted file attachments — rendered with
                                  // AttachmentPills so the teacher opens them
                                  // IN-APP (same viewer as everywhere else),
                                  // not bounced to an external browser.
                                  () {
                                    final rawFiles = sub['files'];
                                    final fileList = rawFiles is List
                                        ? rawFiles
                                            .whereType<Map>()
                                            .map((f) => Map<String, dynamic>.from(f))
                                            .toList()
                                        : const <Map<String, dynamic>>[];
                                    if (fileList.isEmpty) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: AttachmentPills(attachments: fileList),
                                    );
                                  }(),

                                  if (((sub['status'] ?? '') as String).toUpperCase() == 'RETURNED') ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                                      ),
                                      child: Text(AppLocalizations.of(context)!.teacherAssignmentReturnedStatus,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  // Return for re-solution — keeps the student's
                                  // work on record, flags it RETURNED, attaches
                                  // the feedback note, and reopens the student's
                                  // hand-in form so they can revise & resubmit.
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFFB45309),
                                        textStyle: const TextStyle(fontSize: 12),
                                      ),
                                      icon: const Icon(Icons.replay_rounded, size: 14),
                                      label: Text(AppLocalizations.of(context)!.teacherAssignmentReturnAction),
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
                                  const SizedBox(height: 8),

                                  // Grade input
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: TextField(
                                          controller: _gradeControllers[sid],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(context)!.teacherGradeFieldLabel,
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _feedbackControllers[sid],
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(context)!.teacherFeedbackOptionalLabel,
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
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
}
