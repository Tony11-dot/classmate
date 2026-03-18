import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'domain/insights_models.dart';
import 'providers/insights_providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  void _openTutorFromInsights(
    BuildContext context, {
    required String prompt,
    String? title,
    String? subject,
  }) {
    context.go(
      Uri(
        path: '/tutor',
        queryParameters: {
          if (prompt.trim().isNotEmpty) 'prompt': prompt.trim(),
          if ((title ?? '').trim().isNotEmpty) 'title': title!.trim(),
          if ((subject ?? '').trim().isNotEmpty) 'subject': subject!.trim(),
        },
      ).toString(),
    );
  }

  String _fmtPercent(double? value) {
    if (value == null) return '—';
    return '${value.toStringAsFixed(1)}%';
  }

  String _fmtNum(num? value) {
    if (value == null) return '—';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  String _trendLabel(UnifiedPracticeTrend? trend) {
    final delta = trend?.deltaAccuracy;
    if (delta == null) return 'Baseline';
    if (delta >= 6) return 'Improving';
    if (delta <= -6) return 'Dropping';
    return 'Stable';
  }

  IconData _trendIcon(UnifiedPracticeTrend? trend) {
    final delta = trend?.deltaAccuracy;
    if (delta == null) return Icons.timeline_rounded;
    if (delta >= 6) return Icons.trending_up_rounded;
    if (delta <= -6) return Icons.trending_down_rounded;
    return Icons.show_chart_rounded;
  }

  String _attendanceRiskText(UnifiedAttendanceSummary attendance) {
    final rate = attendance.attendanceRate;
    if (rate == null) {
      return 'Attendance data is still building. Keep checking in consistently so NOVA can spot real patterns.';
    }
    if (rate < 85) {
      return 'Attendance is in the danger zone. Missing a few more lessons can hit grades hard.';
    }
    if (rate < 92) {
      return 'Attendance is slightly shaky. Tightening this up can protect your momentum.';
    }
    return 'Attendance is healthy. Keep the streak stable.';
  }

  String _gradeRiskText(UnifiedGradesSummary grades) {
    final weak = (grades.weakestSubject ?? '').trim();
    if (weak.isEmpty) {
      return 'No clear weak subject signal yet. More assessments will sharpen the picture.';
    }
    return '$weak is the current pressure point. This is the best place to focus targeted recovery work.';
  }

  String _momentumText(
    UnifiedStudentInsights unified,
    InsightsServerSummary? server,
  ) {
    final best = (unified.grades.bestSubject ?? '').trim();
    final strongTopic = unified.practice.strongestTopics.isNotEmpty
        ? unified.practice.strongestTopics.first
        : null;
    final delta = unified.practice.trend?.deltaAccuracy;

    if (delta != null && delta >= 6) {
      return 'Your short-term practice is beating your baseline. This is a good time to push harder.';
    }
    if (best.isNotEmpty) {
      return '$best is currently giving you the strongest academic signal. Use that confidence to carry harder work.';
    }
    if (strongTopic != null) {
      return '${strongTopic.topicLabel} is a current strength in ${strongTopic.subject}.';
    }
    if ((server?.totalAttempts ?? 0) > 0) {
      return 'You already have enough practice data to start compounding small wins.';
    }
    return 'Start with a few focused practice sets and your momentum cards will get smarter fast.';
  }

  List<_SubjectDrilldownVm> _subjectCards(
    UnifiedStudentInsights unified,
    InsightsServerSummary? server,
  ) {
    final map = <String, _SubjectDrilldownVm>{};

    void ensure(String subject) {
      final key = subject.trim();
      if (key.isEmpty) return;
      map.putIfAbsent(
        key,
        () => _SubjectDrilldownVm(
          subject: key,
          latestGrade: null,
          weakTopic: null,
          strongTopic: null,
          isBestSubject: false,
          isWeakestSubject: false,
        ),
      );
    }

    for (final grade in unified.grades.latest) {
      ensure(grade.subject);
      final current = map[grade.subject]!;
      final nextGrade =
          current.latestGrade == null ||
              (grade.date ?? '').compareTo(current.latestGrade!.date ?? '') >= 0
          ? grade
          : current.latestGrade!;
      map[grade.subject] = current.copyWith(latestGrade: nextGrade);
    }

    for (final item in unified.practice.weakTopics) {
      ensure(item.subject);
      final current = map[item.subject]!;
      if (current.weakTopic == null) {
        map[item.subject] = current.copyWith(weakTopic: item);
      }
    }

    for (final item in unified.practice.strongestTopics) {
      ensure(item.subject);
      final current = map[item.subject]!;
      if (current.strongTopic == null) {
        map[item.subject] = current.copyWith(strongTopic: item);
      }
    }

    final best = (unified.grades.bestSubject ?? '').trim();
    final weak = (unified.grades.weakestSubject ?? '').trim();

    if (best.isNotEmpty) {
      ensure(best);
      map[best] = map[best]!.copyWith(isBestSubject: true);
    }

    if (weak.isNotEmpty) {
      ensure(weak);
      map[weak] = map[weak]!.copyWith(isWeakestSubject: true);
    }

    final items = map.values.toList(growable: false);

    int score(_SubjectDrilldownVm item) {
      var s = 0;
      if (item.isWeakestSubject) s += 100;
      if (item.weakTopic != null) s += 40;
      if (item.latestGrade != null) s += 20;
      if (item.isBestSubject) s += 10;
      if (item.strongTopic != null) s += 5;
      return s;
    }

    items.sort((a, b) => score(b).compareTo(score(a)));
    return items.take(4).toList(growable: false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unifiedAsync = ref.watch(unifiedStudentInsightsProvider);
    final aiAsync = ref.watch(aiInsightsSummaryProvider);
    final serverAsync = ref.watch(serverInsightsProvider);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(unifiedStudentInsightsProvider);
        ref.invalidate(aiInsightsSummaryProvider);
        ref.invalidate(serverInsightsProvider);
        await Future.wait([
          ref.read(unifiedStudentInsightsProvider.future),
          ref.read(aiInsightsSummaryProvider.future),
          ref.read(serverInsightsProvider.future),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          unifiedAsync.when(
            loading: () => const _HeroLoadingCard(),
            error: (error, _) => _StateCard(
              title: 'Insights are not ready yet',
              subtitle: error.toString(),
              child: const SizedBox.shrink(),
            ),
            data: (unified) {
              if (unified == null) {
                return const _StateCard(
                  title: 'No insight signal yet',
                  subtitle:
                      'Start practicing and using school tools so ClassMate can build your academic picture.',
                  child: SizedBox.shrink(),
                );
              }

              final server = serverAsync.maybeWhen(
                data: (v) => v,
                orElse: () => null,
              );

              final risks = <_InsightFlag>[
                _InsightFlag(
                  icon: Icons.warning_amber_rounded,
                  label: 'Attendance',
                  value: _attendanceRiskText(unified.attendance),
                ),
                _InsightFlag(
                  icon: Icons.flag_rounded,
                  label: 'Weakest subject',
                  value: _gradeRiskText(unified.grades),
                ),
                _InsightFlag(
                  icon: _trendIcon(unified.practice.trend),
                  label: 'Practice trend',
                  value:
                      '${_trendLabel(unified.practice.trend)} • 7d vs 30d delta ${_fmtNum(unified.practice.trend?.deltaAccuracy)}',
                ),
              ];

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primaryContainer.withValues(alpha: 0.96),
                      cs.secondaryContainer.withValues(alpha: 0.82),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academic command center',
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A combined view of grades, attendance, and practice so you know what matters most right now.',
                      style: text.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroMetric(
                            label: 'Grade avg',
                            value: _fmtNum(unified.grades.average),
                            icon: Icons.grade_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeroMetric(
                            label: 'Attendance',
                            value: _fmtPercent(
                              unified.attendance.attendanceRate,
                            ),
                            icon: Icons.how_to_reg_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeroMetric(
                            label: 'Accuracy',
                            value: _fmtPercent(
                              unified.practice.overallAccuracy * 100,
                            ),
                            icon: Icons.check_circle_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...risks.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _FlagRow(item: item),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _openTutorFromInsights(
                            context,
                            prompt: aiAsync.maybeWhen(
                              data: (ai) =>
                                  ai?.suggestedPrompt ??
                                  'Help me make a study recovery plan from my current insights.',
                              orElse: () =>
                                  'Help me make a study recovery plan from my current insights.',
                            ),
                            title: 'Insights Coach',
                            subject: unified.practice.weakTopics.isNotEmpty
                                ? unified.practice.weakTopics.first.subject
                                : unified.grades.weakestSubject,
                          ),
                          icon: const Icon(Icons.psychology_rounded),
                          label: const Text('Open NOVA'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/practice'),
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          label: const Text('Practice now'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/solutions'),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('Browse solutions'),
                        ),
                      ],
                    ),
                    if ((server?.totalAttempts ?? 0) > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Practice attempts logged: ${server!.totalAttempts}',
                        style: text.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          unifiedAsync.when(
            loading: () => const _SectionCard(
              title: 'Risk radar',
              subtitle: 'Detecting current academic pressure points.',
              child: _MiniLoader(),
            ),
            error: (error, _) => _StateCard(
              title: 'Risk radar',
              subtitle: error.toString(),
              child: const SizedBox.shrink(),
            ),
            data: (unified) {
              if (unified == null) {
                return const SizedBox.shrink();
              }

              final cards = <_SimpleCardVm>[
                _SimpleCardVm(
                  icon: Icons.warning_amber_rounded,
                  title: 'Attendance risk',
                  body: _attendanceRiskText(unified.attendance),
                ),
                _SimpleCardVm(
                  icon: Icons.flag_rounded,
                  title: 'Weakest subject',
                  body: _gradeRiskText(unified.grades),
                ),
                _SimpleCardVm(
                  icon: _trendIcon(unified.practice.trend),
                  title: 'Practice momentum risk',
                  body: unified.practice.trend?.deltaAccuracy == null
                      ? 'You are still building a reliable baseline.'
                      : unified.practice.trend!.deltaAccuracy! <= -6
                      ? 'Your recent performance dropped below your baseline. Slow down and rebuild fundamentals.'
                      : 'No major momentum drop detected right now.',
                ),
              ];

              return _SectionCard(
                title: 'Risk radar',
                subtitle:
                    'The three clearest places where things can slip if you ignore them.',
                child: Column(
                  children: cards
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _InsightCard(item: item),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          unifiedAsync.when(
            loading: () => const _SectionCard(
              title: 'Momentum',
              subtitle: 'Looking for strengths you can compound.',
              child: _MiniLoader(),
            ),
            error: (error, _) => _StateCard(
              title: 'Momentum',
              subtitle: error.toString(),
              child: const SizedBox.shrink(),
            ),
            data: (unified) {
              if (unified == null) {
                return const SizedBox.shrink();
              }

              final server = serverAsync.maybeWhen(
                data: (v) => v,
                orElse: () => null,
              );

              final strongTopic = unified.practice.strongestTopics.isNotEmpty
                  ? unified.practice.strongestTopics.first
                  : null;

              final cards = <_SimpleCardVm>[
                _SimpleCardVm(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Best subject',
                  body: (unified.grades.bestSubject ?? '').trim().isEmpty
                      ? 'No best-subject signal yet.'
                      : '${unified.grades.bestSubject} is currently your strongest school signal.',
                ),
                _SimpleCardVm(
                  icon: Icons.local_fire_department_rounded,
                  title: 'Practice momentum',
                  body: _momentumText(unified, server),
                ),
                _SimpleCardVm(
                  icon: Icons.bolt_rounded,
                  title: 'Strong topic',
                  body: strongTopic == null
                      ? 'No strong topic detected yet.'
                      : '${strongTopic.topicLabel} in ${strongTopic.subject} is a current strength.',
                ),
              ];

              return _SectionCard(
                title: 'Momentum',
                subtitle:
                    'Strengths you should keep pressing while your confidence is warm.',
                child: Column(
                  children: cards
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _InsightCard(item: item),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          unifiedAsync.when(
            loading: () => const _SectionCard(
              title: 'Subject drilldown',
              subtitle: 'Building per-subject readouts.',
              child: _MiniLoader(),
            ),
            error: (error, _) => _StateCard(
              title: 'Subject drilldown',
              subtitle: error.toString(),
              child: const SizedBox.shrink(),
            ),
            data: (unified) {
              if (unified == null) {
                return const SizedBox.shrink();
              }

              final server = serverAsync.maybeWhen(
                data: (v) => v,
                orElse: () => null,
              );
              final cards = _subjectCards(unified, server);

              if (cards.isEmpty) {
                return const _SectionCard(
                  title: 'Subject drilldown',
                  subtitle: 'No subject breakdown is available yet.',
                  child: _EmptyPracticeBody(),
                );
              }

              return _SectionCard(
                title: 'Subject drilldown',
                subtitle:
                    'Quick modules for the subjects that matter most right now.',
                child: Column(
                  children: cards
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SubjectDrilldownCard(
                            item: item,
                            onAskNova: () => _openTutorFromInsights(
                              context,
                              prompt: item.isWeakestSubject
                                  ? 'Help me recover in ${item.subject}. Start with the weakest area and build a step-by-step plan.'
                                  : 'Push me further in ${item.subject}. Give me a sharper study plan and a mini challenge.',
                              title: item.isWeakestSubject
                                  ? '${item.subject} Recovery'
                                  : '${item.subject} Boost',
                              subject: item.subject,
                            ),
                            onOpenPractice: () => context.go('/practice'),
                            onOpenSolutions: () => context.go('/solutions'),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          aiAsync.when(
            loading: () => const _SectionCard(
              title: 'AI study coach',
              subtitle: 'Building your coach summary.',
              child: _MiniLoader(),
            ),
            error: (error, _) => _StateCard(
              title: 'AI study coach',
              subtitle: error.toString(),
              child: const SizedBox.shrink(),
            ),
            data: (ai) {
              if (ai == null) {
                return const SizedBox.shrink();
              }

              return _SectionCard(
                title: ai.headline.isEmpty ? 'AI study coach' : ai.headline,
                subtitle: ai.summary.isEmpty
                    ? 'Personalized study guidance generated from your current signal.'
                    : ai.summary,
                child: Column(
                  children: [
                    ...ai.cards
                        .take(3)
                        .map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AiCoachCard(card: card),
                          ),
                        ),
                    _ActionBanner(
                      title: 'Send this to NOVA',
                      subtitle: ai.suggestedPrompt,
                      buttonLabel: 'Open NOVA',
                      onTap: () => _openTutorFromInsights(
                        context,
                        prompt: ai.suggestedPrompt,
                        title: 'AI Study Coach',
                        subject: unifiedAsync.maybeWhen(
                          data: (u) => u?.practice.weakTopics.isNotEmpty == true
                              ? u!.practice.weakTopics.first.subject
                              : u?.grades.weakestSubject,
                          orElse: () => null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'School tools',
            subtitle:
                'Jump straight into the system that matches the signal you just saw.',
            child: Column(
              children: [
                _QuickLinkTile(
                  icon: Icons.how_to_reg_rounded,
                  title: 'Attendance',
                  subtitle: 'Review missed lessons and attendance patterns',
                  onTap: () => context.go('/attendance'),
                ),
                const SizedBox(height: 10),
                _QuickLinkTile(
                  icon: Icons.grade_rounded,
                  title: 'Grades',
                  subtitle: 'Open your latest assessments and subject standing',
                  onTap: () => context.go('/grades'),
                ),
                const SizedBox(height: 10),
                _QuickLinkTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notifications',
                  subtitle: 'See new academic updates and reminders',
                  onTap: () => context.go('/notifications'),
                ),
                const SizedBox(height: 10),
                _QuickLinkTile(
                  icon: Icons.warning_rounded,
                  title: 'Announcements',
                  subtitle: 'See what needs attention right now',
                  onTap: () => context.go('/announcements'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLoadingCard extends StatelessWidget {
  const _HeroLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const _StateCard(
      title: 'Loading your insight engine',
      subtitle:
          'Combining grades, attendance, practice, and AI guidance into one dashboard.',
      child: _MiniLoader(),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _FlagRow extends StatelessWidget {
  const _FlagRow({required this.item});

  final _InsightFlag item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: cs.onSurface, height: 1.35),
                children: [
                  TextSpan(
                    text: '${item.label}: ',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(text: item.value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightFlag {
  const _InsightFlag({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _SimpleCardVm {
  const _SimpleCardVm({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.item});

  final _SimpleCardVm item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primaryContainer.withValues(alpha: 0.85),
            child: Icon(item.icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MiniLoader extends StatelessWidget {
  const _MiniLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyPracticeBody extends StatelessWidget {
  const _EmptyPracticeBody();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Nothing meaningful has been recorded here yet.',
        style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  const _ActionBanner({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(onPressed: onTap, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  const _QuickLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cs.primaryContainer.withValues(alpha: 0.9),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _AiCoachCard extends StatelessWidget {
  const _AiCoachCard({required this.card});

  final AiInsightCard card;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            card.body,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _SubjectDrilldownVm {
  const _SubjectDrilldownVm({
    required this.subject,
    required this.latestGrade,
    required this.weakTopic,
    required this.strongTopic,
    required this.isBestSubject,
    required this.isWeakestSubject,
  });

  final String subject;
  final UnifiedGradeInsight? latestGrade;
  final InsightsTopicSummary? weakTopic;
  final InsightsTopicSummary? strongTopic;
  final bool isBestSubject;
  final bool isWeakestSubject;

  _SubjectDrilldownVm copyWith({
    UnifiedGradeInsight? latestGrade,
    InsightsTopicSummary? weakTopic,
    InsightsTopicSummary? strongTopic,
    bool? isBestSubject,
    bool? isWeakestSubject,
  }) {
    return _SubjectDrilldownVm(
      subject: subject,
      latestGrade: latestGrade ?? this.latestGrade,
      weakTopic: weakTopic ?? this.weakTopic,
      strongTopic: strongTopic ?? this.strongTopic,
      isBestSubject: isBestSubject ?? this.isBestSubject,
      isWeakestSubject: isWeakestSubject ?? this.isWeakestSubject,
    );
  }
}

class _SubjectDrilldownCard extends StatelessWidget {
  const _SubjectDrilldownCard({
    required this.item,
    required this.onAskNova,
    required this.onOpenPractice,
    required this.onOpenSolutions,
  });

  final _SubjectDrilldownVm item;
  final VoidCallback onAskNova;
  final VoidCallback onOpenPractice;
  final VoidCallback onOpenSolutions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String headline() {
      if (item.isWeakestSubject) return 'Highest priority recovery area';
      if (item.isBestSubject) return 'Current top-performing subject';
      if (item.weakTopic != null) return 'Clear weak topic detected';
      if (item.strongTopic != null) return 'Clear strength detected';
      return 'Subject signal available';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.primaryContainer.withValues(alpha: 0.9),
                child: Text(
                  item.subject.characters.first.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      headline(),
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (item.latestGrade != null)
            _MiniLine(
              label: 'Latest grade',
              value:
                  '${item.latestGrade!.assessmentTitle} • ${item.latestGrade!.grade.toStringAsFixed(0)}',
            ),
          if (item.weakTopic != null)
            _MiniLine(
              label: 'Weak topic',
              value:
                  '${item.weakTopic!.topicLabel} • ${(item.weakTopic!.accuracy * 100).toStringAsFixed(1)}%',
            ),
          if (item.strongTopic != null)
            _MiniLine(
              label: 'Strong topic',
              value:
                  '${item.strongTopic!.topicLabel} • ${(item.strongTopic!.accuracy * 100).toStringAsFixed(1)}%',
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onAskNova,
                icon: const Icon(Icons.psychology_rounded),
                label: const Text('Ask NOVA'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenPractice,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Practice'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenSolutions,
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Solutions'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
