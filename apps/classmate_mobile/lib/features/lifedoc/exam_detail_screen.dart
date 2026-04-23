import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/exams_repository.dart';
import 'domain/exam_models.dart';
import '../../ui/glass/liquid_glass_card.dart';

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

Future<void> _addToCalendar(
    BuildContext context, StudentExamItem exam) async {
  // Build a Google Calendar "quick-add" URL (works cross-platform via browser).
  // Falls back to a simple date-only event if hourLabel is missing.
  final date = _parseDate(exam.dateLabel);
  final title = Uri.encodeComponent('${exam.title} — ${exam.subject}');
  String url;
  if (date != null) {
    final ymd = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    url = 'https://calendar.google.com/calendar/render?action=TEMPLATE'
        '&text=$title'
        '&dates=$ymd/$ymd'
        '${exam.teacher.isNotEmpty ? '&details=${Uri.encodeComponent('Teacher: ${exam.teacher}')}' : ''}';
  } else {
    url = 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title';
  }
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open calendar.')),
    );
  }
}

String _countdownLabel(StudentExamItem exam) {
  final date = _parseDate(exam.dateLabel);
  if (date == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final examDay = DateTime(date.year, date.month, date.day);
  final diff = examDay.difference(today).inDays;
  if (diff < 0) return 'This exam has passed';
  if (diff == 0) return "It's today!";
  if (diff == 1) return 'Tomorrow';
  return 'In $diff days';
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
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Exam')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load this exam right now.',
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
            appBar: AppBar(title: const Text('Exam')),
            body: const Center(child: Text('Exam not found')),
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
    if (exam.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam')),
        body: const Center(child: Text('Exam not found')),
      );
    }
    final cs = Theme.of(context).colorScheme;
    final status = _statusOf(exam);
    final countdown = _countdownLabel(exam);

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
          exam.dateLabel,
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
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.pop(),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: LiquidGlassCard(
                      borderRadius: BorderRadius.circular(16),
                      blurSigma: 10,
                      color: cs.surfaceContainerHigh.withValues(alpha: 0.84),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.22),
                      ),
                      child: const Icon(Icons.arrow_back_rounded),
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
            blurSigma: 18,
            color: heroBg.withValues(alpha: 0.9),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
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
                            color: heroFg.withValues(alpha: 0.8),
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (metaLine.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          metaLine,
                          style: TextStyle(
                            color: heroFg.withValues(alpha: 0.72),
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
            title: 'Details',
            child: Column(
              children: [
                infoRow(Icons.person_outline_rounded, 'Teacher', exam.teacher),
                infoRow(Icons.group_outlined, 'Audience', exam.audience.label),
                infoRow(Icons.calendar_today_rounded, 'Date', exam.dateLabel),
                infoRow(Icons.access_time_rounded, 'Time', exam.hourLabel),
                infoRow(Icons.schedule_rounded, 'Period', exam.periodLabel),
                infoRow(Icons.timer_outlined, 'Duration', exam.durationLabel),
                infoRow(Icons.subject_rounded, 'Subject', exam.subject),
                if (exam.caption != null &&
                    exam.caption!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(18),
                    blurSigma: 10,
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.2),
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
            title: 'Attached materials',
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
                      'No materials attached yet.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : Column(
                    children: exam.materials
                        .map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MaterialTile(material: m),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 14),

          // ── actions section ──
          _Section(
            title: 'Quick actions',
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
                  label: const Text('Study with NOVA'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push('/insights'),
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('Open Insights'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _addToCalendar(context, exam),
                  icon: const Icon(Icons.event_available_rounded),
                  label: const Text('Add to calendar'),
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
      blurSigma: 14,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
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

class _MaterialTile extends StatelessWidget {
  const _MaterialTile({required this.material});

  final ExamMaterialItem material;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasUrl = (material.url ?? '').trim().isNotEmpty;
    final icon = _materialIcon(material.kind);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: hasUrl
            ? () async {
                final uri = Uri.tryParse(material.url!.trim());
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            : null,
        child: LiquidGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          borderRadius: BorderRadius.circular(18),
          blurSigma: 10,
          color: cs.surface.withValues(alpha: 0.85),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.25),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.secondaryContainer,
                child: Icon(
                  icon,
                  size: 16,
                  color: cs.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      material.kind,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasUrl)
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

