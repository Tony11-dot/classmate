import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/realtime/realtime_listener.dart';
import '../../core/semester/school_semester.dart';
import '../../core/util/friendly_date.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/semester_filter_bar.dart';
import 'data/exams_repository.dart';
import 'data/forms_repository.dart';
import 'domain/exam_models.dart';
import 'domain/form_models.dart';
import '../../ui/widgets/cm_loading.dart';

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
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final isFormsOnly = widget.mode == ExamsScreenMode.formsOnly;
    final asyncExams = isFormsOnly ? null : ref.watch(examsLiveProvider);
    final asyncForms = isFormsOnly ? ref.watch(formsLiveProvider) : null;

    // Refresh when grades are updated in real-time
    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'grade_updated') {
        ref.invalidate(examsLiveProvider);
      }
    });

    if ((asyncExams?.isLoading ?? false) || (asyncForms?.isLoading ?? false)) {
      return const Center(child: CmLoading());
    }

    if ((asyncExams?.hasError ?? false) || (asyncForms?.hasError ?? false)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isFormsOnly
                ? AppLocalizations.of(context)!.examsCouldNotLoadForms
                : AppLocalizations.of(context)!.examsCouldNotLoadExams,
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

    // Semester partition (exams only — forms carry no scheduled date)
    final semWindow = ref.watch(currentSemesterWindowProvider);
    final visibleExams = visibleForSemester<StudentExamItem>(
      filteredExams,
      (e) => _parseDate(e.dateLabel),
      semWindow,
      _showingPrevious,
      _selectedPast,
    );
    final showSemesterBar = !isFormsOnly && semWindow != null;

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

    Widget header() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(26),
              color: cs.primaryContainer,
              border: Border.all(color: cs.outlineVariant),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(headerIcon, color: cs.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        headerTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onPrimaryContainer,
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
                        padding: const EdgeInsetsDirectional.only(end: 8),
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
            if (showSemesterBar)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SemesterFilterBar(
                  showingPrevious: _showingPrevious,
                  onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
                  selectedPast: _selectedPast,
                  onPastChanged: (w) => setState(() => _selectedPast = w),
                ),
              ),
          ],
        ),
      );
    }

    // Everything in one flat ListView so header + items scroll together
    final items = isFormsOnly
        ? (filteredForms.isEmpty
            ? [_emptyCard(context, cs, l, filter: _filter, isForms: true)]
            : filteredForms.map((f) => _FormCard(form: f)).toList())
        : (visibleExams.isEmpty
            ? [_emptyCard(context, cs, l, filter: _filter, isForms: false)]
            : visibleExams.map((e) => _ExamCard(exam: e, status: _statusOf(e), countdown: _countdownLabel(l, e))).toList());

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      itemCount: items.length + 2, // +2 for header + spacing
      separatorBuilder: (_, i) => i == 0 ? const SizedBox(height: 8) : const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == 0) return header();
        if (i == 1) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: items[i - 2],
        );
      },
    );
  }
}

Widget _emptyCard(BuildContext context, ColorScheme cs, AppLocalizations l, {required String filter, required bool isForms}) {
  final msg = filter == _allSubjectsFilter
      ? (isForms ? l.examsNoFormsPublished : l.examsNoExamsPublished)
      : (isForms ? l.examsNoFormsForFilter(filter) : l.examsNoExamsForFilter(filter));
  return LiquidGlassCard(
    padding: const EdgeInsets.all(20),
    borderRadius: BorderRadius.circular(24),
    color: cs.surfaceContainerLow,
    border: Border.all(color: cs.outlineVariant),
    child: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
  );
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
      color: cs.surfaceContainerLow,
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
    IconData statusIcon;
    switch (status) {
      case _ExamStatus.today:
        statusColor = cs.onErrorContainer;
        statusIcon = Icons.today_rounded;
      case _ExamStatus.past:
        statusColor = cs.onSurfaceVariant;
        statusIcon = Icons.check_circle_outline_rounded;
      case _ExamStatus.upcoming:
        statusColor = cs.onTertiaryContainer;
        statusIcon = Icons.upcoming_rounded;
    }

    final locale = Localizations.localeOf(context).toString();
    final metaLine = [
          // dateLabel is a raw ISO string (kept raw for sorting); format it for
          // display so it never shows as "2026-06-20T00:00:00.000Z".
          FriendlyDate.date(exam.dateLabel, locale),
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
          color: status == _ExamStatus.today
              ? cs.errorContainer
              : cs.surfaceContainerHighest,
          border: Border.all(
            color: status == _ExamStatus.today
                ? cs.error
                : cs.outlineVariant,
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
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: cs.outlineVariant),
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
          color: cs.surfaceContainerLow,
          border: Border.all(color: cs.outlineVariant),
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
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: cs.outlineVariant),
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
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

