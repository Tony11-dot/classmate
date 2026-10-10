import 'package:classmate_mobile/ui/widgets/cm_press.dart';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/util/friendly_date.dart';
import '../../l10n/app_localizations.dart';
import 'lifedoc_labels.dart';
import 'data/exams_repository.dart';
import 'domain/exam_models.dart';
import '../../core/theme/cm_tokens.dart';
import '../common/media/image_viewer_screen.dart';
import '../common/media/pdf_viewer_screen.dart';
import '../../ui/widgets/cm_loading.dart';

// ─── helpers (duplicated locally so the detail screen is self-contained) ─────

DateTime? _parseDate(String? raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}

enum _ExamStatus { upcoming, today, past }

_ExamStatus _statusOf(StudentExamItem exam) {
  final date = _parseDate(exam.dateLabel);
  if (date == null) return _ExamStatus.upcoming;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final examDay = DateTime(date.year, date.month, date.day);
  if (examDay.isBefore(today)) return _ExamStatus.past;
  if (examDay == today) return _ExamStatus.today;
  return _ExamStatus.upcoming;
}

/// Format ISO date string → DD/MM/YYYY
String _fmtDate(String? raw) {
  if ((raw ?? '').trim().isEmpty) return '—';
  return FriendlyDate.date(raw);
}

/// Format two HH:MM time strings → "HH:MM – HH:MM"
String _fmtTimeRange(String? start, String? end) {
  final s = (start ?? '').trim();
  final e = (end ?? '').trim();
  if (s.isEmpty && e.isEmpty) return '';
  if (s.isEmpty) return e;
  if (e.isEmpty) return s;
  return '$s – $e';
}

Future<void> _addToCalendar(BuildContext context, StudentExamItem exam) async {
  final l = AppLocalizations.of(context)!;
  final examTitle = examTitleLabel(l, exam.title);
  final teacherLine = '${l.examInfoTeacher}: ${exam.teacher}';
  final date = _parseDate(exam.dateLabel);

  if (date != null) {
    // Web / Android: open Google Calendar's event-template URL. On web
    // `dart:io Platform` isn't available at all (it throws), so the browser
    // must take this branch — the Google Calendar render URL opens in a new
    // tab and pre-fills the title + start/end date (web QA #50).
    if (kIsWeb || Platform.isAndroid) {
      String pad(int v) => v.toString().padLeft(2, '0');
      final start = '${date.year}${pad(date.month)}${pad(date.day)}T080000';
      final end = '${date.year}${pad(date.month)}${pad(date.day)}T100000';
      final params = <String, String>{
        'action': 'TEMPLATE',
        'text': examTitle,
        'dates': '$start/$end',
        if (exam.teacher.isNotEmpty) 'details': teacherLine,
      };
      final gcalUri = Uri.https(
        'calendar.google.com',
        '/calendar/render',
        params,
      );
      if (kIsWeb) {
        await launchUrl(gcalUri, webOnlyWindowName: '_blank');
        return;
      }
      if (await canLaunchUrl(gcalUri)) {
        await launchUrl(gcalUri, mode: LaunchMode.externalApplication);
        return;
      }
    } else {
      // iOS: open the native Calendar app at the exam's date.
      final calShowUri = Uri.parse(
        'calshow://${date.millisecondsSinceEpoch ~/ 1000}',
      );
      if (await canLaunchUrl(calShowUri)) {
        await launchUrl(calShowUri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // Universal fallback: .ics data URI. iOS Mail/Safari and some Android
    // calendar apps will offer to import this directly.
    final ymd =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final uid = 'exam-${exam.id}@classmate';
    final ics =
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'BEGIN:VEVENT\r\n'
        'UID:$uid\r\n'
        'DTSTART:${ymd}T080000Z\r\n'
        'DTEND:${ymd}T100000Z\r\n'
        'SUMMARY:$examTitle\r\n'
        '${exam.teacher.isNotEmpty ? 'DESCRIPTION:$teacherLine\r\n' : ''}'
        'END:VEVENT\r\n'
        'END:VCALENDAR';
    final encoded = Uri.encodeComponent(ics);
    final icsUri = Uri.parse('data:text/calendar;charset=utf-8,$encoded');
    if (await canLaunchUrl(icsUri)) {
      await launchUrl(icsUri, mode: LaunchMode.externalApplication);
      return;
    }
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.examCouldNotOpenCalendar),
      ),
    );
  }
}

String _countdownLabel(BuildContext context, StudentExamItem exam) {
  final l = AppLocalizations.of(context)!;
  final date = _parseDate(exam.dateLabel);
  if (date == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final examDay = DateTime(date.year, date.month, date.day);
  final diff = examDay.difference(today).inDays;
  if (diff < 0) return l.examDetailScreenCountdownPassed;
  if (diff == 0) return l.examDetailScreenCountdownToday;
  if (diff == 1) return l.examsCountdownTomorrow;
  return l.examsCountdownInDays(diff);
}

IconData _materialIcon(String kind) {
  final k = kind.toLowerCase();
  if (k.contains('pdf')) return Icons.picture_as_pdf_rounded;
  if (k.contains('link') || k.contains('url') || k.contains('web')) {
    return Icons.open_in_new_rounded;
  }
  if (k.contains('image') || k.contains('photo') || k.contains('img')) {
    return Icons.image_rounded;
  }
  if (k.contains('video')) return Icons.play_circle_outline_rounded;
  return Icons.attach_file_rounded;
}

// ─── screen ──────────────────────────────────────────────────────────────────

class ExamDetailScreen extends ConsumerWidget {
  const ExamDetailScreen({super.key, required this.examId, this.initialExam});

  final String examId;
  final StudentExamItem? initialExam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialExam != null) {
      return _ExamDetailBody(exam: initialExam!);
    }

    final asyncExam = ref.watch(examsLiveProvider);
    return asyncExam.when(
      loading: () => const Scaffold(body: Center(child: CmLoading())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.examTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppLocalizations.of(context)!.examDetailScreenCouldNotLoad,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (items) {
        final exam = items.cast<StudentExamItem?>().firstWhere(
          (item) => item?.id == examId,
          orElse: () => ref.read(examsRepositoryProvider).byId(examId),
        );
        if (exam == null || exam.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.examTitle),
            ),
            body: Center(
              child: Text(AppLocalizations.of(context)!.examNotFound),
            ),
          );
        }
        return _ExamDetailBody(exam: exam);
      },
    );
  }
}

class _ExamDetailBody extends StatelessWidget {
  const _ExamDetailBody({required this.exam});

  final StudentExamItem exam;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (exam.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l.examTitle)),
        body: Center(child: Text(l.examNotFound)),
      );
    }
    final cs = Theme.of(context).colorScheme;
    final tokens = CmTokens.of(context);
    final dark = cs.brightness == Brightness.dark;
    final status = _statusOf(exam);
    final countdown = _countdownLabel(context, exam);

    // ── status tone: today = urgent, upcoming = brand, past = neutral ──
    final Color tone = switch (status) {
      _ExamStatus.today => cs.error,
      _ExamStatus.past => cs.onSurfaceVariant,
      _ExamStatus.upcoming => cs.primary,
    };
    final IconData statusIcon = switch (status) {
      _ExamStatus.today => Icons.today_rounded,
      _ExamStatus.past => Icons.check_circle_rounded,
      _ExamStatus.upcoming => Icons.upcoming_rounded,
    };

    final metaChips = <(IconData, String)>[
      (Icons.calendar_today_rounded, _fmtDate(exam.dateLabel)),
      if ((exam.hourLabel ?? '').trim().isNotEmpty)
        (Icons.access_time_rounded, exam.hourLabel!.trim()),
      if ((exam.periodLabel ?? '').trim().isNotEmpty)
        (Icons.schedule_rounded, exam.periodLabel!.trim()),
      if ((exam.durationLabel ?? '').trim().isNotEmpty)
        (Icons.timer_outlined, exam.durationLabel!.trim()),
    ];

    final infoRows = <Widget>[
      if (exam.teacher.trim().isNotEmpty)
        _InfoRow(
          icon: Icons.person_outline_rounded,
          label: l.examInfoTeacher,
          value: exam.teacher,
        ),
      _InfoRow(
        icon: Icons.calendar_today_rounded,
        label: l.examInfoDate,
        value: _fmtDate(exam.dateLabel),
      ),
      if ((exam.hourLabel ?? '').trim().isNotEmpty)
        _InfoRow(
          icon: Icons.access_time_rounded,
          label: l.examInfoTime,
          value: _fmtTimeRange(exam.hourLabel, exam.durationLabel),
        ),
      if ((exam.periodLabel ?? '').trim().isNotEmpty)
        _InfoRow(
          icon: Icons.schedule_rounded,
          label: l.examInfoPeriod,
          value: exam.periodLabel!,
        ),
      if (exam.subject.trim().isNotEmpty)
        _InfoRow(
          icon: Icons.subject_rounded,
          label: l.examInfoSubject,
          value: exam.subject,
        ),
    ];

    final gradeMax = exam.maxGrade ?? 100;
    final gradePct = exam.grade == null || gradeMax <= 0
        ? 0.0
        : (exam.grade! / gradeMax).clamp(0.0, 1.0);
    final gradeTone = gradePct >= 0.8
        ? tokens.good
        : gradePct >= 0.55
        ? tokens.warn
        : cs.error;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ── back button ──
            Row(
              children: [
                Semantics(
                  button: true,
                  label: l.a11yBack,
                  child: CmPress(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(CmTokens.radiusMd),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exam.subject,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── hero ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CmTokens.radiusXl),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tone.withValues(alpha: dark ? 0.24 : 0.12),
                    cs.surfaceContainerLow,
                  ],
                ),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                  width: 0.8,
                ),
                boxShadow: tokens.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (countdown.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
                      decoration: BoxDecoration(
                        color: status == _ExamStatus.past
                            ? cs.surfaceContainerHighest
                            : tone,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 16,
                            color: status == _ExamStatus.past
                                ? cs.onSurfaceVariant
                                : (status == _ExamStatus.today
                                      ? cs.onError
                                      : cs.onPrimary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            countdown,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              color: status == _ExamStatus.past
                                  ? cs.onSurfaceVariant
                                  : (status == _ExamStatus.today
                                        ? cs.onError
                                        : cs.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    examTitleLabel(l, exam.title),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  if (exam.topic != null && exam.topic!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      exam.topic!,
                      style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final (icon, text) in metaChips)
                        _MetaChip(icon: icon, text: text),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── info section ──
            _Section(
              title: l.examDetailsSection,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < infoRows.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        indent: 46,
                        color: cs.outlineVariant.withValues(alpha: 0.45),
                      ),
                    infoRows[i],
                  ],
                  if (exam.caption != null &&
                      exam.caption!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: dark ? cs.surfaceContainerHigh : cs.surface,
                        borderRadius: BorderRadius.circular(CmTokens.radiusMd),
                      ),
                      child: Text(
                        exam.caption!,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          height: 1.45,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── materials section ──
            _Section(
              title: l.examMaterialsSection,
              trailing: exam.materials.isEmpty
                  ? null
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${exam.materials.length}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
              child: exam.materials.isEmpty
                  ? Row(
                      children: [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.examNoMaterials,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exam.materials
                          .map((m) => _MaterialPill(material: m))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 14),

            // ── grade result card (past exams only) ──
            if (status == _ExamStatus.past) ...[
              _Section(
                title: l.examViewGradeTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (exam.grade != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: gradeTone.withValues(
                            alpha: dark ? 0.18 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(
                            CmTokens.radiusMd,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: gradePct,
                                    strokeWidth: 5,
                                    strokeCap: StrokeCap.round,
                                    color: gradeTone,
                                    backgroundColor: gradeTone.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                  Icon(
                                    Icons.grade_rounded,
                                    size: 22,
                                    color: gradeTone,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${exam.grade} / $gradeMax',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                                color: cs.onSurface,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Row(
                        children: [
                          Icon(
                            Icons.grade_rounded,
                            size: 20,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l.examViewGradeBody,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => context.go('/grades'),
                      icon: const Icon(Icons.grade_rounded),
                      label: Text(l.examViewGradeAction),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── actions section ──
            _Section(
              title: l.examQuickActionsSection,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () => context.push(
                      Uri(
                        path: '/tutor',
                        queryParameters: {
                          'title': examTitleLabel(l, exam.title),
                          'subject': exam.subject,
                          'prompt': l.examNovaPrepPrompt(
                            examTitleLabel(l, exam.title),
                            exam.subject,
                            exam.topic ?? exam.subject,
                          ),
                        },
                      ).toString(),
                    ),
                    icon: const Icon(Icons.psychology_rounded),
                    label: Text(l.examStudyWithNova),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () => _addToCalendar(context, exam),
                    icon: const Icon(Icons.event_available_rounded),
                    label: Text(l.examAddToCalendar),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── section wrapper ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(CmTokens.radiusXl),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: CmTokens.of(context).shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// One detail line: tinted icon tile, small label above the value.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.primary.withValues(
                alpha: cs.brightness == Brightness.dark ? 0.20 : 0.10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact icon + text chip on the hero (date / time / period / duration).
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.brightness == Brightness.dark
            ? cs.surfaceContainerHigh
            : cs.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── material tile ────────────────────────────────────────────────────────────

/// Compact pill version of [_MaterialTile] — used in the student exam
/// detail materials section so multiple attachments line up like tags
/// rather than full-width rows.
class _MaterialPill extends StatelessWidget {
  const _MaterialPill({required this.material});

  final ExamMaterialItem material;

  String _name(BuildContext context) =>
      attachmentNameLabel(AppLocalizations.of(context)!, material.name);

  Future<void> _open(BuildContext context) async {
    final url = (material.url ?? '').trim();
    if (url.isEmpty) return;
    final kind = material.kind.toLowerCase();
    final lower = url.toLowerCase();
    final isImage =
        kind.contains('image') ||
        kind.contains('photo') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
    final isPdf = kind.contains('pdf') || lower.endsWith('.pdf');

    if (isImage) {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => ImageViewerScreen(url: url, title: _name(context)),
        ),
      );
    } else if (isPdf) {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => PdfViewerScreen(url: url, title: _name(context)),
        ),
      );
    } else {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasUrl = (material.url ?? '').trim().isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: CmPress(
        onTap: hasUrl ? () => _open(context) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _materialIcon(material.kind),
                size: 14,
                color: cs.onSecondaryContainer,
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  _name(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              if (hasUrl) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 12,
                  color: cs.onSecondaryContainer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
