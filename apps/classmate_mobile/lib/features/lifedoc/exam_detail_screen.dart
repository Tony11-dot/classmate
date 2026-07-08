import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/util/friendly_date.dart';
import '../../l10n/app_localizations.dart';
import 'data/exams_repository.dart';
import 'domain/exam_models.dart';
import '../../ui/glass/liquid_glass_card.dart';
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

Future<void> _addToCalendar(
    BuildContext context, StudentExamItem exam) async {
  final date = _parseDate(exam.dateLabel);

  if (date != null) {
    // Android: open Google Calendar's event-template URL. The Calendar app
    // (or browser fallback) handles `calendar.google.com/calendar/render`
    // intents and pre-fills the title + start/end date.
    if (Platform.isAndroid) {
      String pad(int v) => v.toString().padLeft(2, '0');
      final start = '${date.year}${pad(date.month)}${pad(date.day)}T080000';
      final end = '${date.year}${pad(date.month)}${pad(date.day)}T100000';
      final params = <String, String>{
        'action': 'TEMPLATE',
        'text': exam.title,
        'dates': '$start/$end',
        if (exam.teacher.isNotEmpty) 'details': 'Teacher: ${exam.teacher}',
      };
      final gcalUri = Uri.https('calendar.google.com', '/calendar/render', params);
      if (await canLaunchUrl(gcalUri)) {
        await launchUrl(gcalUri, mode: LaunchMode.externalApplication);
        return;
      }
    } else {
      // iOS: open the native Calendar app at the exam's date.
      final calShowUri =
          Uri.parse('calshow://${date.millisecondsSinceEpoch ~/ 1000}');
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
    final ics = 'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'BEGIN:VEVENT\r\n'
        'UID:$uid\r\n'
        'DTSTART:${ymd}T080000Z\r\n'
        'DTEND:${ymd}T100000Z\r\n'
        'SUMMARY:${exam.title}\r\n'
        '${exam.teacher.isNotEmpty ? 'DESCRIPTION:Teacher: ${exam.teacher}\r\n' : ''}'
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
      SnackBar(content: Text(AppLocalizations.of(context)!.examCouldNotOpenCalendar)),
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
      loading: () => const Scaffold(
        body: Center(child: CmLoading()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.examTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppLocalizations.of(context)!.examDetailScreenCouldNotLoad,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.examTitle)),
            body: Center(child: Text(AppLocalizations.of(context)!.examNotFound)),
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
    final status = _statusOf(exam);
    final countdown = _countdownLabel(context, exam);

    // ── countdown hero colors ──
    Color heroBg;
    Color heroFg;
    switch (status) {
      case _ExamStatus.today:
        heroBg = cs.errorContainer;
        heroFg = cs.onErrorContainer;
      case _ExamStatus.past:
        heroBg = cs.surfaceContainerHighest;
        heroFg = cs.onSurfaceVariant;
      case _ExamStatus.upcoming:
        heroBg = cs.tertiaryContainer;
        heroFg = cs.onTertiaryContainer;
    }

    Widget infoRow(IconData icon, String label, String? value) {
      if ((value ?? '').trim().isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '$label  ',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: value),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final metaLine = [
          _fmtDate(exam.dateLabel),
          exam.hourLabel,
          exam.periodLabel,
          exam.durationLabel,
        ]
        .where((v) => (v ?? '').trim().isNotEmpty)
        .cast<String>()
        .join('  ·  ');

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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.pop(),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: LiquidGlassCard(
                        borderRadius: BorderRadius.circular(16),
                        color: cs.surfaceContainerHigh,
                        padding: EdgeInsets.zero,
                        border: Border.all(color: cs.outlineVariant),
                        child: const Center(child: Icon(Icons.arrow_back_rounded, size: 20)),
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
          LiquidGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            borderRadius: BorderRadius.circular(26),
            color: heroBg,
            border: Border.all(color: cs.outlineVariant),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: heroFg,
                        ),
                      ),
                      if (exam.topic != null &&
                          exam.topic!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          exam.topic!,
                          style: TextStyle(
                            color: heroFg,
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (metaLine.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          metaLine,
                          style: TextStyle(
                            color: heroFg,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      status == _ExamStatus.today
                          ? Icons.today_rounded
                          : status == _ExamStatus.past
                          ? Icons.check_circle_rounded
                          : Icons.upcoming_rounded,
                      size: 28,
                      color: heroFg,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      countdown,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: heroFg,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── info section ──
          _Section(
            title: l.examDetailsSection,
            child: Column(
              children: [
                if (exam.teacher.trim().isNotEmpty)
                  infoRow(Icons.person_outline_rounded, l.examInfoTeacher, exam.teacher),
                infoRow(Icons.calendar_today_rounded, l.examInfoDate, _fmtDate(exam.dateLabel)),
                if ((exam.hourLabel ?? '').trim().isNotEmpty)
                  infoRow(Icons.access_time_rounded, l.examInfoTime,
                      _fmtTimeRange(exam.hourLabel, exam.durationLabel)),
                if ((exam.periodLabel ?? '').trim().isNotEmpty)
                  infoRow(Icons.schedule_rounded, l.examInfoPeriod, exam.periodLabel!),
                if (exam.subject.trim().isNotEmpty)
                  infoRow(Icons.subject_rounded, l.examInfoSubject, exam.subject),
                if (exam.caption != null &&
                    exam.caption!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(18),
                    color: cs.surfaceContainerLow,
                    border: Border.all(
                      color: cs.outlineVariant,
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
                : Text(
                    '${exam.materials.length}',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            child: exam.materials.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l.examNoMaterials,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exam.materials
                          .map((m) => _MaterialPill(material: m))
                          .toList(),
                    ),
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
                    // Show the actual grade prominently
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grade_rounded, size: 28, color: cs.primary),
                          const SizedBox(width: 12),
                          Text(
                            '${exam.grade} / ${exam.maxGrade ?? 100}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else ...[
                    Row(
                      children: [
                        Icon(Icons.grade_rounded, size: 20, color: cs.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.examViewGradeBody,
                            style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton.icon(
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
                  onPressed: () => context.push(
                    Uri(
                      path: '/tutor',
                      queryParameters: {
                        'title': exam.title,
                        'subject': exam.subject,
                        'prompt':
                            'Help me prepare for ${exam.title} in ${exam.subject}. Focus on ${exam.topic ?? exam.subject}.',
                      },
                    ).toString(),
                  ),
                  icon: const Icon(Icons.psychology_rounded),
                  label: Text(l.examStudyWithNova),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
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

// ─── material tile ────────────────────────────────────────────────────────────

/// Compact pill version of [_MaterialTile] — used in the student exam
/// detail materials section so multiple attachments line up like tags
/// rather than full-width rows.
class _MaterialPill extends StatelessWidget {
  const _MaterialPill({required this.material});

  final ExamMaterialItem material;

  Future<void> _open(BuildContext context) async {
    final url = (material.url ?? '').trim();
    if (url.isEmpty) return;
    final kind = material.kind.toLowerCase();
    final lower = url.toLowerCase();
    final isImage = kind.contains('image') ||
        kind.contains('photo') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
    final isPdf = kind.contains('pdf') || lower.endsWith('.pdf');

    if (isImage) {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => ImageViewerScreen(url: url, title: material.name),
        ),
      );
    } else if (isPdf) {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => PdfViewerScreen(url: url, title: material.name),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: hasUrl ? () => _open(context) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_materialIcon(material.kind),
                  size: 14, color: cs.onSecondaryContainer),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  material.name,
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
                Icon(Icons.open_in_new_rounded,
                    size: 12, color: cs.onSecondaryContainer),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


