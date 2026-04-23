import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import 'data/exams_repository.dart';
import 'data/forms_repository.dart';
import 'domain/exam_models.dart';
import 'domain/form_models.dart';

const _allSubjectsFilter = '__all__';

DateTime? _parseDate(String? raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}

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

String _countdownLabel(AppLocalizations l, StudentExamItem exam) {
  final date = _parseDate(exam.dateLabel);
  if (date == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final examDay = DateTime(date.year, date.month, date.day);
  final diff = examDay.difference(today).inDays;
  if (diff < 0) return l.examsCountdownPast;
  if (diff == 0) return l.today;
  if (diff == 1) return l.examsCountdownTomorrow;
  return l.examsCountdownInDays(diff);
}

IconData _subjectIcon(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('math') || s.contains('calcul')) return Icons.calculate_rounded;
  if (s.contains('phys')) return Icons.science_rounded;
  if (s.contains('chem') || s.contains('bio')) return Icons.biotech_rounded;
  if (s.contains('cs') || s.contains('computer')) return Icons.computer_rounded;
  if (s.contains('english') || s.contains('lit')) return Icons.translate_rounded;
  if (s.contains('hist')) return Icons.history_edu_rounded;
  return Icons.school_rounded;
}

enum _ExamStatus { upcoming, today, past }

enum ExamsScreenMode { examsOnly, formsOnly }

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({
    super.key,
    this.mode = ExamsScreenMode.examsOnly,
  });

  final ExamsScreenMode mode;

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  String _filter = _allSubjectsFilter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final isFormsOnly = widget.mode == ExamsScreenMode.formsOnly;
    final asyncExams = isFormsOnly ? null : ref.watch(examsLiveProvider);
    final asyncForms = isFormsOnly ? ref.watch(formsLiveProvider) : null;

    if ((asyncExams?.isLoading ?? false) || (asyncForms?.isLoading ?? false)) {
      return const Center(child: CircularProgressIndicator());
    }

    if ((asyncExams?.hasError ?? false) || (asyncForms?.hasError ?? false)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isFormsOnly ? 'Could not load forms' : 'Could not load exams',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    final exams = asyncExams?.value ?? const <StudentExamItem>[];
    final forms = asyncForms?.value ?? const <StudentFormItem>[];
    final subjects = <String>{_allSubjectsFilter}
      ..addAll(exams.map((e) => e.subject))
      ..addAll(forms.map((f) => f.subject));
    final chips = subjects.toList(growable: false);

    final filteredExams = _filter == _allSubjectsFilter
        ? exams
        : exams.where((e) => e.subject == _filter).toList(growable: false);
    final filteredForms = _filter == _allSubjectsFilter
        ? forms
        : forms.where((f) => f.subject == _filter).toList(growable: false);

    final upcomingExams = exams.where((e) => _statusOf(e) != _ExamStatus.past).length;
    final openForms = forms.where((f) => f.acceptingResponses).length;
    final totalForms = forms.length;

    final headerTitle = isFormsOnly
      ? l.navForms
      : l.titleExams;
    final headerCopy = isFormsOnly
      ? l.examsFormsSubtitle
      : l.examsOnlySubtitle;
    final headerIcon = isFormsOnly
        ? Icons.article_rounded
        : Icons.fact_check_rounded;
    final content = isFormsOnly
        ? _FormsTab(filtered: filteredForms, filter: _filter)
        : _ExamsTab(filtered: filteredExams, filter: _filter);

    Widget header() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(26),
              blurSigma: 18,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.tertiaryContainer.withValues(alpha: 0.9),
                  cs.surfaceContainerHigh.withValues(alpha: 0.95),
                ],
              ),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(headerIcon, color: cs.onTertiaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        headerTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    headerCopy,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  if (isFormsOnly)
                    Row(
                      children: [
                        Expanded(
                          child: _HeaderStat(
                            label: l.examsOpenFormsStat,
                            value: '$openForms',
                            icon: Icons.assignment_turned_in_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeaderStat(
                            label: l.examsAllFilter,
                            value: '$totalForms',
                            icon: Icons.article_rounded,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _HeaderStat(
                            label: l.examsUpcomingStat,
                            value: '$upcomingExams',
                            icon: Icons.event_note_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeaderStat(
                            label: l.titleExams,
                            value: '${filteredExams.length}',
                            icon: Icons.quiz_rounded,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: chips
                    .map(
                      (subject) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            subject == _allSubjectsFilter
                                ? l.examsAllFilter
                                : subject,
                          ),
                          selected: _filter == subject,
                          onSelected: (_) => setState(() => _filter = subject),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        header(),
        const SizedBox(height: 8),
        Expanded(child: content),
      ],
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(18),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.64),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.primaryContainer,
            child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamsTab extends StatelessWidget {
  const _ExamsTab({required this.filtered, required this.filter});

  final List<StudentExamItem> filtered;
  final String filter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LiquidGlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(24),
            blurSigma: 12,
            color: cs.surfaceContainerLow.withValues(alpha: 0.78),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
            child: Text(
              _filterMessage(
                l,
                filter,
                emptyFallback: l.examsNoExamsPublished,
                filteredMessageBuilder: l.examsNoExamsForFilter,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final exam = filtered[index];
        return _ExamCard(
          exam: exam,
          status: _statusOf(exam),
          countdown: _countdownLabel(l, exam),
        );
      },
    );
  }
}

class _FormsTab extends StatelessWidget {
  const _FormsTab({required this.filtered, required this.filter});

  final List<StudentFormItem> filtered;
  final String filter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LiquidGlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(24),
            blurSigma: 12,
            color: cs.surfaceContainerLow.withValues(alpha: 0.78),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
            child: Text(
              _filterMessage(
                l,
                filter,
                emptyFallback: l.examsNoFormsPublished,
                filteredMessageBuilder: l.examsNoFormsForFilter,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _FormCard(form: filtered[index]),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.exam,
    required this.status,
    required this.countdown,
  });

  final StudentExamItem exam;
  final _ExamStatus status;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    Color statusColor;
    Color statusBg;
    IconData statusIcon;
    switch (status) {
      case _ExamStatus.today:
        statusColor = cs.onErrorContainer;
        statusBg = cs.errorContainer;
        statusIcon = Icons.today_rounded;
      case _ExamStatus.past:
        statusColor = cs.onSurfaceVariant;
        statusBg = cs.surfaceContainerHighest;
        statusIcon = Icons.check_circle_outline_rounded;
      case _ExamStatus.upcoming:
        statusColor = cs.onTertiaryContainer;
        statusBg = cs.tertiaryContainer;
        statusIcon = Icons.upcoming_rounded;
    }

    final metaLine = [
          exam.dateLabel,
          exam.hourLabel,
          exam.periodLabel,
          exam.durationLabel,
        ]
        .where((v) => (v ?? '').trim().isNotEmpty)
        .cast<String>()
        .join(' • ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push('/exams/${exam.id}', extra: exam),
        child: LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(22),
          blurSigma: 10,
          color: status == _ExamStatus.today
              ? cs.errorContainer.withValues(alpha: 0.18)
              : cs.surfaceContainerHighest.withValues(alpha: 0.75),
          border: Border.all(
            color: status == _ExamStatus.today
                ? cs.error.withValues(alpha: 0.35)
                : cs.outlineVariant.withValues(alpha: 0.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cs.primaryContainer,
                child: Icon(
                  _subjectIcon(exam.subject),
                  size: 24,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            exam.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: status == _ExamStatus.past
                                  ? cs.onSurfaceVariant
                                  : cs.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                statusBg.withValues(alpha: 0.94),
                                cs.surface.withValues(alpha: 0.48),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 11, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                countdown,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exam.topic == null || exam.topic!.trim().isEmpty
                          ? exam.subject
                          : '${exam.subject} · ${exam.topic}',
                      style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                    ),
                    if (metaLine.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(metaLine, style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                    if ((exam.caption ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        exam.caption!,
                        style: TextStyle(color: cs.onSurface, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _SmallChip(icon: Icons.groups_rounded, label: exam.audience.label),
                        if (exam.materials.isNotEmpty)
                          _SmallChip(
                            icon: Icons.attach_file_rounded,
                            label: l.examsMaterialsCount(exam.materials.length),
                          ),
                        if (exam.teacher.trim().isNotEmpty)
                          _SmallChip(icon: Icons.person_outline_rounded, label: exam.teacher),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.form});

  final StudentFormItem form;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push('/forms/${form.id}', extra: form),
        child: LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(22),
          blurSigma: 10,
          color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: cs.secondaryContainer,
                    child: Icon(Icons.assignment_rounded, color: cs.onSecondaryContainer),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${form.subject} · ${form.teacher}',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (form.acceptingResponses ? cs.primaryContainer : cs.surfaceContainerLow).withValues(alpha: 0.94),
                          cs.surface.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.12)),
                    ),
                    child: Text(
                      form.acceptingResponses ? l.examsOpenState : l.examsClosedState,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: form.acceptingResponses ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                form.description,
                style: TextStyle(color: cs.onSurface, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallChip(icon: Icons.quiz_outlined, label: l.examsQuestionsCount(form.questionCount)),
                  _SmallChip(icon: Icons.bar_chart_rounded, label: l.examsResponsesCount(form.summary.responsesCount)),
                  _SmallChip(icon: Icons.groups_rounded, label: form.audienceLabel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerLow.withValues(alpha: 0.94),
            cs.surface.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

String _filterMessage(
  AppLocalizations l,
  String filter, {
  required String emptyFallback,
  required String Function(String) filteredMessageBuilder,
}) {
  if (filter == _allSubjectsFilter) return emptyFallback;
  return filteredMessageBuilder(filter);
}
