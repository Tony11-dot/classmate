import 'practice_history_models.dart';
import 'practice_models.dart';

class PracticeTopicStat {
  final String topicLabel;
  final int totalQuestions;
  final int correct;
  final int wrong;
  final int accuracyPercent;

  const PracticeTopicStat({
    required this.topicLabel,
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.accuracyPercent,
  });
}

class PracticeModeStat {
  final PracticeMode mode;
  final int sessions;
  final int answered;
  final int correct;
  final int accuracyPercent;
  final int xp;

  const PracticeModeStat({
    required this.mode,
    required this.sessions,
    required this.answered,
    required this.correct,
    required this.accuracyPercent,
    required this.xp,
  });
}

class PracticeRecentSummary {
  final int sessions;
  final int answered;
  final int correct;
  final int wrong;
  final int accuracyPercent;
  final int xp;

  const PracticeRecentSummary({
    required this.sessions,
    required this.answered,
    required this.correct,
    required this.wrong,
    required this.accuracyPercent,
    required this.xp,
  });
}

class PracticeAnalyticsSnapshot {
  final PracticeRecentSummary overall;
  final List<PracticeTopicStat> weakestTopics;
  final List<PracticeTopicStat> strongestTopics;
  final List<PracticeModeStat> modeStats;

  const PracticeAnalyticsSnapshot({
    required this.overall,
    required this.weakestTopics,
    required this.strongestTopics,
    required this.modeStats,
  });
}

class PracticeAnalyticsBuilder {
  const PracticeAnalyticsBuilder();

  PracticeAnalyticsSnapshot build(
    List<PracticeHistorySession> sessions, {
    int recentSessionWindow = 12,
    int topicMinQuestions = 2,
    int topTopicCount = 5,
  }) {
    final recent = sessions.take(recentSessionWindow).toList(growable: false);

    final overallAnswered = recent.fold<int>(0, (sum, s) => sum + s.answered);
    final overallCorrect = recent.fold<int>(0, (sum, s) => sum + s.correct);
    final overallWrong = recent.fold<int>(0, (sum, s) => sum + s.wrong);
    final overallXp = recent.fold<int>(0, (sum, s) => sum + s.xp);
    final overallAccuracy = overallAnswered == 0
        ? 0
        : ((overallCorrect / overallAnswered) * 100).round();

    final topicBuckets = <String, List<PracticeHistoryQuestion>>{};
    for (final session in sessions) {
      for (final q in session.questions) {
        topicBuckets
            .putIfAbsent(q.topicLabel, () => <PracticeHistoryQuestion>[])
            .add(q);
      }
    }

    final topicStats = topicBuckets.entries
        .map((entry) {
          final total = entry.value.length;
          final correct = entry.value.where((q) => q.isCorrect).length;
          final wrong = total - correct;
          final accuracy = total == 0 ? 0 : ((correct / total) * 100).round();

          return PracticeTopicStat(
            topicLabel: entry.key,
            totalQuestions: total,
            correct: correct,
            wrong: wrong,
            accuracyPercent: accuracy,
          );
        })
        .where((x) => x.totalQuestions >= topicMinQuestions)
        .toList(growable: false);

    final weakestTopics = [...topicStats]
      ..sort((a, b) {
        final byAccuracy = a.accuracyPercent.compareTo(b.accuracyPercent);
        if (byAccuracy != 0) return byAccuracy;
        return b.totalQuestions.compareTo(a.totalQuestions);
      });

    final strongestTopics = [...topicStats]
      ..sort((a, b) {
        final byAccuracy = b.accuracyPercent.compareTo(a.accuracyPercent);
        if (byAccuracy != 0) return byAccuracy;
        return b.totalQuestions.compareTo(a.totalQuestions);
      });

    final modeBuckets = <PracticeMode, List<PracticeHistorySession>>{};
    for (final session in sessions) {
      modeBuckets
          .putIfAbsent(session.mode, () => <PracticeHistorySession>[])
          .add(session);
    }

    final modeStats =
        modeBuckets.entries
            .map((entry) {
              final answered = entry.value.fold<int>(
                0,
                (sum, s) => sum + s.answered,
              );
              final correct = entry.value.fold<int>(
                0,
                (sum, s) => sum + s.correct,
              );
              final xp = entry.value.fold<int>(0, (sum, s) => sum + s.xp);
              final accuracy = answered == 0
                  ? 0
                  : ((correct / answered) * 100).round();

              return PracticeModeStat(
                mode: entry.key,
                sessions: entry.value.length,
                answered: answered,
                correct: correct,
                accuracyPercent: accuracy,
                xp: xp,
              );
            })
            .toList(growable: false)
          ..sort((a, b) => b.sessions.compareTo(a.sessions));

    return PracticeAnalyticsSnapshot(
      overall: PracticeRecentSummary(
        sessions: recent.length,
        answered: overallAnswered,
        correct: overallCorrect,
        wrong: overallWrong,
        accuracyPercent: overallAccuracy,
        xp: overallXp,
      ),
      weakestTopics: weakestTopics.take(topTopicCount).toList(growable: false),
      strongestTopics: strongestTopics
          .take(topTopicCount)
          .toList(growable: false),
      modeStats: modeStats,
    );
  }
}
