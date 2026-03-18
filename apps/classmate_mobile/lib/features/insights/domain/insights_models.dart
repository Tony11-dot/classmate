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

class AiInsightCard {
  final String title;
  final String body;
  final String tone;

  const AiInsightCard({
    required this.title,
    required this.body,
    required this.tone,
  });

  factory AiInsightCard.fromJson(Map<String, dynamic> json) {
    return AiInsightCard(
      title: '${json['title'] ?? ''}',
      body: '${json['body'] ?? ''}',
      tone: '${json['tone'] ?? 'baseline'}',
    );
  }
}

class AiInsightsSummary {
  final bool ok;
  final String source;
  final String headline;
  final String summary;
  final List<AiInsightCard> cards;
  final String suggestedPrompt;

  const AiInsightsSummary({
    required this.ok,
    required this.source,
    required this.headline,
    required this.summary,
    required this.cards,
    required this.suggestedPrompt,
  });

  factory AiInsightsSummary.fromJson(Map<String, dynamic> json) {
    final rawCards = (json['cards'] is List)
        ? (json['cards'] as List)
        : const [];
    return AiInsightsSummary(
      ok: json['ok'] == true,
      source: '${json['source'] ?? 'deterministic'}',
      headline: '${json['headline'] ?? ''}',
      summary: '${json['summary'] ?? ''}',
      cards: rawCards
          .whereType<Map>()
          .map(
            (e) => AiInsightCard.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(growable: false),
      suggestedPrompt: '${json['suggestedPrompt'] ?? ''}',
    );
  }
}
