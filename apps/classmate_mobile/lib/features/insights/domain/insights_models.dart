class InsightsTopicSummary {
  final String subject;
  final String topicLabel;
  final double accuracy;
  final int totalAnswered;

  const InsightsTopicSummary({
    required this.subject,
    required this.topicLabel,
    required this.accuracy,
    required this.totalAnswered,
  });

  factory InsightsTopicSummary.fromJson(Map<String, dynamic> json) {
    double asDouble(Object? v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse('${v ?? ''}') ?? 0;
    }

    int asInt(Object? v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? 0;
    }

    return InsightsTopicSummary(
      subject: '${json['subject'] ?? ''}',
      topicLabel: '${json['topicLabel'] ?? ''}',
      accuracy: asDouble(json['accuracy']),
      totalAnswered: asInt(json['totalAnswered']),
    );
  }
}

class InsightsServerSummary {
  final String userId;
  final int totalSessions;
  final int totalAttempts;
  final int totalCorrect;
  final double overallAccuracy;
  final List<InsightsTopicSummary> weakTopics;
  final List<InsightsTopicSummary> strongestTopics;

  const InsightsServerSummary({
    required this.userId,
    required this.totalSessions,
    required this.totalAttempts,
    required this.totalCorrect,
    required this.overallAccuracy,
    required this.weakTopics,
    required this.strongestTopics,
  });

  factory InsightsServerSummary.fromJson(Map<String, dynamic> json) {
    double asDouble(Object? v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse('${v ?? ''}') ?? 0;
    }

    int asInt(Object? v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? 0;
    }

    List<InsightsTopicSummary> parseTopics(Object? raw) {
      final list = raw is List ? raw : const [];
      return list
          .whereType<Map>()
          .map(
            (e) => InsightsTopicSummary.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(growable: false);
    }

    return InsightsServerSummary(
      userId: '${json['userId'] ?? ''}',
      totalSessions: asInt(json['totalSessions']),
      totalAttempts: asInt(json['totalAttempts']),
      totalCorrect: asInt(json['totalCorrect']),
      overallAccuracy: asDouble(json['overallAccuracy']),
      weakTopics: parseTopics(json['weakTopics']),
      strongestTopics: parseTopics(json['strongestTopics']),
    );
  }
}
