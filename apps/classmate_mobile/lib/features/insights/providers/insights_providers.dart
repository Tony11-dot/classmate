import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../parent/data/viewed_student_context.dart';
import '../../practice/providers/practice_providers.dart';
import '../data/practice_analytics_api.dart';
import '../data/student_insights_api.dart';
import '../domain/insights_models.dart';

final serverInsightsProvider = FutureProvider<InsightsServerSummary?>((
  ref,
) async {
  final api = ref.watch(practiceAnalyticsApiProvider);
  return api.fetchProgressSummary();
});

final effectiveAccuracyPercentProvider = FutureProvider<int>((ref) async {
  final local = await ref.watch(practiceAnalyticsProvider.future);
  final server = await ref.watch(serverInsightsProvider.future);

  if (server == null || server.totalAttempts <= 0) {
    return local.overall.accuracyPercent;
  }

  return (server.overallAccuracy * 100).round();
});

final effectiveTotalSessionsProvider = FutureProvider<int>((ref) async {
  final local = await ref.watch(practiceAnalyticsProvider.future);
  final server = await ref.watch(serverInsightsProvider.future);
  return server?.totalSessions ?? local.overall.sessions;
});

final effectiveTotalAttemptsProvider = FutureProvider<int>((ref) async {
  final local = await ref.watch(practiceAnalyticsProvider.future);
  final server = await ref.watch(serverInsightsProvider.future);
  return server?.totalAttempts ?? local.overall.answered;
});

final aiInsightsSummaryProvider = FutureProvider<AiInsightsSummary?>((
  ref,
) async {
  final api = ref.watch(practiceAnalyticsApiProvider);
  return api.fetchAiInsightsSummary();
});

final unifiedStudentInsightsProvider = FutureProvider<UnifiedStudentInsights?>((
  ref,
) async {
  final api = ref.watch(studentInsightsApiProvider);
  final viewedStudentId = ref.watch(viewedStudentIdProvider);
  return api.fetchUnifiedInsights(overrideStudentId: viewedStudentId);
});
