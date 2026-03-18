import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../practice/domain/practice_analytics_models.dart';
import '../practice/domain/practice_history_models.dart';
import '../practice/domain/practice_models.dart';
import '../practice/providers/practice_providers.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(practiceHistoryProvider);
    final analyticsAsync = ref.watch(practiceAnalyticsProvider);
    final serverSummaryAsync = ref.watch(serverInsightsProvider);
    final aiInsightsAsync = ref.watch(aiInsightsSummaryProvider);
    final unifiedInsightsAsync = ref.watch(unifiedStudentInsightsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(practiceHistoryProvider);
        ref.invalidate(practiceAnalyticsProvider);
        ref.invalidate(serverInsightsProvider);
        await Future.wait([
          ref.read(practiceHistoryProvider.future),
          ref.read(practiceAnalyticsProvider.future),
          ref.read(serverInsightsProvider.future),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          historyAsync.when(
            loading: () => _HeroShell(
              child: _LoadingCard(
                title: 'Loading your insights',
                subtitle:
                    'Pulling together practice signals and school shortcuts.',
              ),
            ),
            error: (error, _) => _HeroShell(
              child: _ErrorCard(
                title: 'Could not load insights yet',
                subtitle: '$error',
                onRetry: () {
                  ref.invalidate(practiceHistoryProvider);
                  ref.invalidate(practiceAnalyticsProvider);
                },
              ),
            ),
            data: (sessions) {
              return analyticsAsync.when(
                loading: () => _HeroShell(
                  child: _LoadingCard(
                    title: 'Loading your insights',
                    subtitle: 'Crunching practice performance.',
                  ),
                ),
                error: (error, _) => _HeroShell(
                  child: _ErrorCard(
                    title: 'Could not load analytics yet',
                    subtitle: '$error',
                    onRetry: () {
                      ref.invalidate(practiceHistoryProvider);
                      ref.invalidate(practiceAnalyticsProvider);
                    },
                  ),
                ),
                data: (snapshot) {
                  final vm = _InsightsViewModel.from(sessions, snapshot);
                  return _HeroShell(child: _HeroCard(viewModel: vm));
                },
              );
            },
          ),
          const SizedBox(height: 16),
          unifiedInsightsAsync.when(
            loading: () => const _SectionCard(
              title: 'Academic snapshot',
              subtitle:
                  'Building a combined grades, attendance, and practice signal.',
              child: _MiniLoader(),
            ),
            error: (error, stackTrace) => _SectionCard(
              title: 'Academic snapshot',
              subtitle: 'Could not load the combined student signal yet.',
              child: Text(error.toString()),
            ),
            data: (unified) {
              if (unified == null) {
                return const _SectionCard(
                  title: 'Academic snapshot',
                  subtitle: 'No combined student signal available yet.',
                  child: _EmptyPracticeBody(),
                );
              }

              return _SectionCard(
                title: 'Academic snapshot',
                subtitle:
                    'Your all-in-one academic signal across grades, attendance, and practice.',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.grade_rounded,
                            label: 'Grade avg',
                            value: unified.grades.average == null
                                ? '—'
                                : unified.grades.average!.toStringAsFixed(1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.how_to_reg_rounded,
                            label: 'Attendance',
                            value: unified.attendance.attendanceRate == null
                                ? '—'
                                : '${unified.attendance.attendanceRate!.toStringAsFixed(1)}%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.workspace_premium_rounded,
                            label: 'Best subject',
                            value: (unified.grades.bestSubject ?? '').isEmpty
                                ? '—'
                                : unified.grades.bestSubject!,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.flag_rounded,
                            label: 'Needs work',
                            value: (unified.grades.weakestSubject ?? '').isEmpty
                                ? '—'
                                : unified.grades.weakestSubject!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (unified.grades.latest.isNotEmpty)
                      _ActionBanner(
                        title:
                            'Latest grade: ${unified.grades.latest.first.assessmentTitle}',
                        subtitle:
                            '${unified.grades.latest.first.subject} • ${unified.grades.latest.first.grade.toStringAsFixed(0)}',
                        buttonLabel: 'Open grades',
                        onTap: () => context.go('/grades'),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'School record',
            subtitle:
                'One place to jump into your official school data and the study systems around it.',
            child: Column(
              children: [
                _QuickLinkTile(
                  icon: Icons.how_to_reg_rounded,
                  title: 'Attendance',
                  subtitle: 'Open your attendance record and missed lessons',
                  onTap: () => context.go('/attendance'),
                ),
                const SizedBox(height: 10),
                _QuickLinkTile(
                  icon: Icons.grade_rounded,
                  title: 'Grades',
                  subtitle:
                      'Open recent grades, subjects, and academic standing',
                  onTap: () => context.go('/grades'),
                ),
                const SizedBox(height: 10),
                _QuickLinkTile(
                  icon: Icons.assignment_rounded,
                  title: 'Assignments',
                  subtitle: 'Review work that still needs your attention',
                  onTap: () => context.go('/assignments'),
                ),
                const SizedBox(height: 10),
                _QuickLinkTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notifications',
                  subtitle: 'See the latest academic updates and reminders',
                  onTap: () => context.go('/notifications'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          analyticsAsync.when(
            loading: () => const _SectionCard(
              title: 'Practice intelligence',
              subtitle: 'Building your latest performance profile.',
              child: _MiniLoader(),
            ),
            error: (error, _) => _SectionCard(
              title: 'Practice intelligence',
              subtitle: 'Could not load practice analytics.',
              child: Text(error.toString()),
            ),
            data: (snapshot) {
              return historyAsync.when(
                loading: () => const _SectionCard(
                  title: 'Practice intelligence',
                  subtitle: 'Building your latest performance profile.',
                  child: _MiniLoader(),
                ),
                error: (error, _) => _SectionCard(
                  title: 'Practice intelligence',
                  subtitle: 'Could not load practice history.',
                  child: Text(error.toString()),
                ),
                data: (sessions) {
                  final vm = _InsightsViewModel.from(sessions, snapshot);

                  return Column(
                    children: [
                      _SectionCard(
                        title: 'Practice intelligence',
                        subtitle:
                            'A reliable look at how you perform, where you struggle, and what to do next.',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricTile(
                                    icon: Icons.quiz_rounded,
                                    label: 'Answered',
                                    value: '${snapshot.overall.answered}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MetricTile(
                                    icon: Icons.check_circle_rounded,
                                    label: 'Accuracy',
                                    value:
                                        '${snapshot.overall.accuracyPercent}%',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricTile(
                                    icon: Icons.local_fire_department_rounded,
                                    label: 'Sessions',
                                    value: serverSummaryAsync.maybeWhen(
                                      data: (server) =>
                                          '${server?.totalSessions ?? snapshot.overall.sessions}',
                                      orElse: () =>
                                          '${snapshot.overall.sessions}',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MetricTile(
                                    icon: Icons.bolt_rounded,
                                    label: 'XP',
                                    value: '${snapshot.overall.xp}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _ActionBanner(
                              title: vm.focusMessageTitle,
                              subtitle: vm.focusMessageBody,
                              buttonLabel: 'Open practice',
                              onTap: () => context.go('/practice'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'AI study coach',
                        subtitle:
                            'Grounded guidance generated from your actual practice data.',
                        child: aiInsightsAsync.when(
                          loading: () => const _MiniLoader(),
                          error: (error, stackTrace) => _ActionBanner(
                            title: vm.focusMessageTitle,
                            subtitle: vm.focusMessageBody,
                            buttonLabel: 'Ask NOVA',
                            onTap: () => _openTutorFromInsights(
                              context,
                              prompt: vm.focusMessageBody,
                              title: vm.focusMessageTitle,
                              subject: unifiedInsightsAsync.maybeWhen(
                                data: (u) =>
                                    u?.practice.weakTopics.isNotEmpty == true
                                    ? u!.practice.weakTopics.first.subject
                                    : u?.grades.weakestSubject,
                                orElse: () => null,
                              ),
                            ),
                          ),
                          data: (ai) {
                            if (ai == null) {
                              return _ActionBanner(
                                title: vm.focusMessageTitle,
                                subtitle: vm.focusMessageBody,
                                buttonLabel: 'Ask NOVA',
                                onTap: () => _openTutorFromInsights(
                                  context,
                                  prompt: vm.focusMessageBody,
                                  title: vm.focusMessageTitle,
                                  subject: unifiedInsightsAsync.maybeWhen(
                                    data: (u) =>
                                        u?.practice.weakTopics.isNotEmpty ==
                                            true
                                        ? u!.practice.weakTopics.first.subject
                                        : u?.grades.weakestSubject,
                                    orElse: () => null,
                                  ),
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer
                                            .withValues(alpha: 0.92),
                                        Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer
                                            .withValues(alpha: 0.82),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ai.headline,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        ai.summary,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...ai.cards.map(
                                  (card) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _AiInsightCardView(card: card),
                                  ),
                                ),
                                if (ai.suggestedPrompt.trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  _ActionBanner(
                                    title: 'Send this to NOVA',
                                    subtitle: ai.suggestedPrompt,
                                    buttonLabel: 'Open NOVA',
                                    onTap: () => _openTutorFromInsights(
                                      context,
                                      prompt: ai.suggestedPrompt,
                                      title: 'AI Study Coach',
                                      subject: unifiedInsightsAsync.maybeWhen(
                                        data: (u) =>
                                            u?.practice.weakTopics.isNotEmpty ==
                                                true
                                            ? u!
                                                  .practice
                                                  .weakTopics
                                                  .first
                                                  .subject
                                            : u?.grades.weakestSubject,
                                        orElse: () => null,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (unifiedInsightsAsync.maybeWhen(
                        data: (value) => value != null,
                        orElse: () => false,
                      ))
                        unifiedInsightsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                          data: (unified) {
                            final trend = unified?.practice.trend;
                            if (trend == null) return const SizedBox.shrink();

                            String trendLabel() {
                              final delta = trend.deltaAccuracy;
                              if (delta == null) return 'Building baseline';
                              if (delta >= 6) return 'Improving';
                              if (delta <= -6) return 'Needs attention';
                              return 'Stable';
                            }

                            String deltaLabel() {
                              final delta = trend.deltaAccuracy;
                              if (delta == null) return 'Need more attempts';
                              if (delta == 0) return '0 pts';
                              return '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} pts';
                            }

                            return Column(
                              children: [
                                _SectionCard(
                                  title: 'Practice trend windows',
                                  subtitle:
                                      'Backend-driven short-term and monthly practice momentum.',
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _MetricTile(
                                              icon: Icons.date_range_rounded,
                                              label: 'Last 7d',
                                              value:
                                                  trend.last7d.accuracy == null
                                                  ? '—'
                                                  : '${trend.last7d.accuracy!.toStringAsFixed(1)}%',
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _MetricTile(
                                              icon: Icons
                                                  .calendar_view_month_rounded,
                                              label: 'Last 30d',
                                              value:
                                                  trend.last30d.accuracy == null
                                                  ? '—'
                                                  : '${trend.last30d.accuracy!.toStringAsFixed(1)}%',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _MetricTile(
                                              icon: Icons.timeline_rounded,
                                              label: 'Direction',
                                              value: trendLabel(),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _MetricTile(
                                              icon: Icons.show_chart_rounded,
                                              label: 'Delta',
                                              value: deltaLabel(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                      _SectionCard(
                        title: 'Performance trend',
                        subtitle:
                            'Recent momentum based on your latest saved practice sessions.',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _TrendCallout(
                                    label: 'Momentum',
                                    value: vm.trendLabel,
                                    icon: vm.trendIcon,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _TrendCallout(
                                    label: 'Direction',
                                    value: vm.deltaLabel,
                                    icon: Icons.timeline_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _SparkBars(points: vm.weeklyBars),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Subject profile',
                        subtitle:
                            'How your recent sessions are distributed across subjects.',
                        child: vm.subjectStats.isEmpty
                            ? const _EmptyPracticeBody()
                            : Column(
                                children: vm.subjectStats
                                    .map(
                                      (row) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: _SubjectRow(row: row),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SectionCard(
                              title: 'Weak areas',
                              subtitle:
                                  'Topics that currently need more reps and attention.',
                              child: (() {
                                final serverWeak = serverSummaryAsync.maybeWhen(
                                  data: (server) =>
                                      server?.weakTopics ?? const [],
                                  orElse: () => const [],
                                );

                                if (serverWeak.isNotEmpty) {
                                  return Column(
                                    children: serverWeak
                                        .map(
                                          (topic) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: _ServerTopicInsightRow(
                                              topic: topic,
                                              tone: _TopicTone.weak,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                }

                                if (snapshot.weakestTopics.isEmpty) {
                                  return const _EmptyPracticeBody();
                                }

                                return Column(
                                  children: snapshot.weakestTopics
                                      .map(
                                        (topic) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: _TopicInsightRow(
                                            topic: topic,
                                            tone: _TopicTone.weak,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              })(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SectionCard(
                              title: 'Strong areas',
                              subtitle:
                                  'Topics where you are currently performing well.',
                              child: (() {
                                final serverStrong = serverSummaryAsync
                                    .maybeWhen(
                                      data: (server) =>
                                          server?.strongestTopics ?? const [],
                                      orElse: () => const [],
                                    );

                                if (serverStrong.isNotEmpty) {
                                  return Column(
                                    children: serverStrong
                                        .map(
                                          (topic) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: _ServerTopicInsightRow(
                                              topic: topic,
                                              tone: _TopicTone.strong,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                }

                                if (snapshot.strongestTopics.isEmpty) {
                                  return const _EmptyPracticeBody();
                                }

                                return Column(
                                  children: snapshot.strongestTopics
                                      .map(
                                        (topic) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: _TopicInsightRow(
                                            topic: topic,
                                            tone: _TopicTone.strong,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              })(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Mode breakdown',
                        subtitle:
                            'See which learning modes you use most and how well they go.',
                        child: snapshot.modeStats.isEmpty
                            ? const _EmptyPracticeBody()
                            : Column(
                                children: snapshot.modeStats
                                    .map(
                                      (row) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: _ModeRow(row: row),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InsightsViewModel {
  final String trendLabel;
  final String deltaLabel;
  final IconData trendIcon;
  final String focusMessageTitle;
  final String focusMessageBody;
  final List<_SubjectInsightStat> subjectStats;
  final List<double> weeklyBars;

  const _InsightsViewModel({
    required this.trendLabel,
    required this.deltaLabel,
    required this.trendIcon,
    required this.focusMessageTitle,
    required this.focusMessageBody,
    required this.subjectStats,
    required this.weeklyBars,
  });

  factory _InsightsViewModel.from(
    List<PracticeHistorySession> sessions,
    PracticeAnalyticsSnapshot snapshot,
  ) {
    final recent = sessions.take(6).toList(growable: false);
    final previous = sessions.skip(6).take(6).toList(growable: false);

    int accuracyOf(List<PracticeHistorySession> items) {
      final answered = items.fold<int>(0, (sum, s) => sum + s.answered);
      final correct = items.fold<int>(0, (sum, s) => sum + s.correct);
      if (answered == 0) return 0;
      return ((correct / answered) * 100).round();
    }

    final recentAccuracy = accuracyOf(recent);
    final previousAccuracy = accuracyOf(previous);
    final delta = recentAccuracy - previousAccuracy;

    final trendLabel = sessions.isEmpty
        ? 'No data yet'
        : previous.isEmpty
        ? 'Building baseline'
        : delta >= 6
        ? 'Improving'
        : delta <= -6
        ? 'Needs attention'
        : 'Stable';

    final trendIcon = sessions.isEmpty
        ? Icons.insights_rounded
        : previous.isEmpty
        ? Icons.hourglass_bottom_rounded
        : delta >= 6
        ? Icons.trending_up_rounded
        : delta <= -6
        ? Icons.trending_down_rounded
        : Icons.trending_flat_rounded;

    String deltaLabel;
    if (sessions.isEmpty) {
      deltaLabel = 'Start practicing';
    } else if (previous.isEmpty) {
      deltaLabel = 'Need more history';
    } else {
      deltaLabel = delta == 0
          ? '0 pts vs prior block'
          : '${delta > 0 ? '+' : ''}$delta pts';
    }

    final focusMessageTitle = snapshot.weakestTopics.isNotEmpty
        ? 'Focus next: ${snapshot.weakestTopics.first.topicLabel}'
        : snapshot.strongestTopics.isNotEmpty
        ? 'Keep pushing ${snapshot.strongestTopics.first.topicLabel}'
        : 'Start building practice history';

    final focusMessageBody = snapshot.weakestTopics.isNotEmpty
        ? 'This topic is your weakest current signal. A short targeted session here should move the needle fastest.'
        : snapshot.strongestTopics.isNotEmpty
        ? 'You are doing well here. Keep momentum and start increasing challenge level.'
        : 'Once you complete a few sessions, this page will turn into your performance hub.';

    final bySubject = <String, List<PracticeHistorySession>>{};
    for (final session in sessions) {
      bySubject
          .putIfAbsent(session.subject, () => <PracticeHistorySession>[])
          .add(session);
    }

    final subjectStats =
        bySubject.entries.map((entry) {
          final subjectSessions = entry.value;
          final answered = subjectSessions.fold<int>(
            0,
            (sum, s) => sum + s.answered,
          );
          final correct = subjectSessions.fold<int>(
            0,
            (sum, s) => sum + s.correct,
          );
          final xp = subjectSessions.fold<int>(0, (sum, s) => sum + s.xp);
          final accuracy = answered == 0
              ? 0
              : ((correct / answered) * 100).round();

          final topics = <String, List<PracticeHistorySession>>{};
          for (final s in subjectSessions) {
            topics
                .putIfAbsent(s.topicLabel, () => <PracticeHistorySession>[])
                .add(s);
          }

          String? strongestTopic;
          String? weakestTopic;
          int strongest = -1;
          int weakest = 101;

          for (final topicEntry in topics.entries) {
            final topicAnswered = topicEntry.value.fold<int>(
              0,
              (sum, s) => sum + s.answered,
            );
            final topicCorrect = topicEntry.value.fold<int>(
              0,
              (sum, s) => sum + s.correct,
            );
            if (topicAnswered == 0) continue;
            final topicAccuracy = ((topicCorrect / topicAnswered) * 100)
                .round();

            if (topicAccuracy > strongest) {
              strongest = topicAccuracy;
              strongestTopic = topicEntry.key;
            }
            if (topicAccuracy < weakest) {
              weakest = topicAccuracy;
              weakestTopic = topicEntry.key;
            }
          }

          return _SubjectInsightStat(
            subject: entry.key,
            sessions: subjectSessions.length,
            answered: answered,
            accuracyPercent: accuracy,
            xp: xp,
            strongestTopic: strongestTopic,
            weakestTopic: weakestTopic,
          );
        }).toList()..sort((a, b) {
          final bySessions = b.sessions.compareTo(a.sessions);
          if (bySessions != 0) return bySessions;
          return b.answered.compareTo(a.answered);
        });

    final now = DateTime.now();
    final bars = List<double>.generate(7, (index) {
      final targetDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
      final count = sessions.where((s) {
        final d = DateTime(
          s.completedAt.year,
          s.completedAt.month,
          s.completedAt.day,
        );
        return d == targetDay;
      }).length;
      return count.toDouble();
    });

    final maxBar = bars.fold<double>(0, math.max);
    final normalizedBars = maxBar <= 0
        ? List<double>.filled(7, 0)
        : bars.map((v) => v / maxBar).toList(growable: false);

    return _InsightsViewModel(
      trendLabel: trendLabel,
      deltaLabel: deltaLabel,
      trendIcon: trendIcon,
      focusMessageTitle: focusMessageTitle,
      focusMessageBody: focusMessageBody,
      subjectStats: subjectStats,
      weeklyBars: normalizedBars,
    );
  }
}

class _SubjectInsightStat {
  final String subject;
  final int sessions;
  final int answered;
  final int accuracyPercent;
  final int xp;
  final String? strongestTopic;
  final String? weakestTopic;

  const _SubjectInsightStat({
    required this.subject,
    required this.sessions,
    required this.answered,
    required this.accuracyPercent,
    required this.xp,
    required this.strongestTopic,
    required this.weakestTopic,
  });
}

class _HeroShell extends StatelessWidget {
  const _HeroShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.viewModel});
  final _InsightsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.96),
            cs.surfaceContainerHigh.withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your insights',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everything important about your learning in one place.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatPill(
                icon: viewModel.trendIcon,
                label: 'Momentum',
                value: viewModel.trendLabel,
              ),
              _StatPill(
                icon: Icons.timeline_rounded,
                label: 'Recent change',
                value: viewModel.deltaLabel,
              ),
              _StatPill(
                icon: Icons.track_changes_rounded,
                label: 'Focus',
                value: viewModel.focusMessageTitle.replaceFirst(
                  'Focus next: ',
                  '',
                ),
              ),
            ],
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          child,
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
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.secondaryContainer.withValues(alpha: 0.92),
            cs.tertiaryContainer.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
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
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _TrendCallout extends StatelessWidget {
  const _TrendCallout({
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
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
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

class _SparkBars extends StatelessWidget {
  const _SparkBars({required this.points});
  final List<double> points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            final value = index < points.length ? points[index] : 0.0;
            final height = 14 + (74 * value);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [cs.primary, cs.primaryContainer],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.row});
  final _SubjectInsightStat row;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = (row.accuracyPercent.clamp(0, 100)) / 100.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.subject,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${row.accuracyPercent}%',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.isNaN ? 0 : progress,
              minHeight: 10,
              backgroundColor: cs.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(label: '${row.sessions} sessions'),
              _MiniChip(label: '${row.answered} answered'),
              _MiniChip(label: 'XP ${row.xp}'),
              if ((row.strongestTopic ?? '').isNotEmpty)
                _MiniChip(label: 'Best: ${row.strongestTopic}'),
              if ((row.weakestTopic ?? '').isNotEmpty)
                _MiniChip(label: 'Needs work: ${row.weakestTopic}'),
            ],
          ),
        ],
      ),
    );
  }
}

enum _TopicTone { weak, strong }

class _TopicInsightRow extends StatelessWidget {
  const _TopicInsightRow({required this.topic, required this.tone});

  final PracticeTopicStat topic;
  final _TopicTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWeak = tone == _TopicTone.weak;
    final bg = isWeak
        ? cs.errorContainer.withValues(alpha: 0.38)
        : cs.secondaryContainer.withValues(alpha: 0.46);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.topicLabel,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(label: '${topic.accuracyPercent}% accuracy'),
              _MiniChip(label: '${topic.totalQuestions} questions'),
              _MiniChip(label: '${topic.correct} correct'),
              _MiniChip(label: '${topic.wrong} wrong'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServerTopicInsightRow extends StatelessWidget {
  const _ServerTopicInsightRow({required this.topic, required this.tone});

  final InsightsTopicSummary topic;
  final _TopicTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWeak = tone == _TopicTone.weak;
    final bg = isWeak
        ? cs.errorContainer.withValues(alpha: 0.38)
        : cs.secondaryContainer.withValues(alpha: 0.46);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${topic.subject} • ${topic.topicLabel}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(label: '${(topic.accuracy * 100).round()}% accuracy'),
              _MiniChip(label: '${topic.totalAnswered} questions'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiInsightCardView extends StatelessWidget {
  const _AiInsightCardView({required this.card});

  final AiInsightCard card;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    switch (card.tone) {
      case 'focus':
        bg = cs.errorContainer.withValues(alpha: 0.42);
        break;
      case 'strength':
        bg = cs.secondaryContainer.withValues(alpha: 0.46);
        break;
      case 'next_step':
        bg = cs.primaryContainer.withValues(alpha: 0.46);
        break;
      default:
        bg = cs.surface.withValues(alpha: 0.72);
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
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

class _ModeRow extends StatelessWidget {
  const _ModeRow({required this.row});
  final PracticeModeStat row;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.layers_rounded, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _modeLabel(row.mode),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${row.sessions} sessions • ${row.answered} answered • ${row.accuracyPercent}% accuracy',
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'XP ${row.xp}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: cs.surfaceContainerHigh.withValues(alpha: 0.78),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: cs.errorContainer.withValues(alpha: 0.5),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _MiniLoader extends StatelessWidget {
  const _MiniLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CircularProgressIndicator(),
      ),
    );
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
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Complete a few practice sessions to unlock this part of Insights.',
        style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(
                label,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

String _modeLabel(PracticeMode mode) {
  switch (mode) {
    case PracticeMode.practice:
      return 'Practice';
    case PracticeMode.flashcards:
      return 'Flashcards';
    case PracticeMode.speedRound:
      return 'Speed round';
    case PracticeMode.examPrep:
      return 'Exam prep';
    case PracticeMode.conceptBuilder:
      return 'Concept builder';
    case PracticeMode.bagrut:
      return 'Bagrut';
    case PracticeMode.adaptive:
      return 'Adaptive';
  }
}
