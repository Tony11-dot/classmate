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
  final UnifiedPracticeTrend? trend;

  const InsightsServerSummary({
    required this.userId,
    required this.totalSessions,
    required this.totalAttempts,
    required this.totalCorrect,
    required this.overallAccuracy,
    required this.weakTopics,
    required this.strongestTopics,
    required this.trend,
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

    final rawTrend = json['trend'];

    return InsightsServerSummary(
      userId: '${json['userId'] ?? ''}',
      totalSessions: asInt(json['totalSessions']),
      totalAttempts: asInt(json['totalAttempts']),
      totalCorrect: asInt(json['totalCorrect']),
      overallAccuracy: asDouble(json['overallAccuracy']),
      weakTopics: parseTopics(json['weakTopics']),
      strongestTopics: parseTopics(json['strongestTopics']),
      trend: rawTrend is Map
          ? UnifiedPracticeTrend.fromJson(
              rawTrend.map((k, v) => MapEntry(k.toString(), v)),
            )
          : null,
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

class UnifiedGradeInsight {
  final String id;
  final String subject;
  final String courseName;
  final String assessmentTitle;
  final double grade;
  final String? date;

  const UnifiedGradeInsight({
    required this.id,
    required this.subject,
    required this.courseName,
    required this.assessmentTitle,
    required this.grade,
    required this.date,
  });

  factory UnifiedGradeInsight.fromJson(Map<String, dynamic> json) {
    double asDouble(Object? v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse('${v ?? ''}') ?? 0;
    }

    return UnifiedGradeInsight(
      id: '${json['id'] ?? ''}',
      subject: '${json['subject'] ?? ''}',
      courseName: '${json['courseName'] ?? ''}',
      assessmentTitle: '${json['assessmentTitle'] ?? ''}',
      grade: asDouble(json['grade']),
      date: json['date'] == null ? null : '${json['date']}',
    );
  }
}

class UnifiedAttendanceInsight {
  final String date;
  final int period;
  final String status;
  final String? subject;
  final String? courseName;

  const UnifiedAttendanceInsight({
    required this.date,
    required this.period,
    required this.status,
    required this.subject,
    required this.courseName,
  });

  factory UnifiedAttendanceInsight.fromJson(Map<String, dynamic> json) {
    int asInt(Object? v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? 0;
    }

    return UnifiedAttendanceInsight(
      date: '${json['date'] ?? ''}',
      period: asInt(json['period']),
      status: '${json['status'] ?? ''}',
      subject: json['subject'] == null ? null : '${json['subject']}',
      courseName: json['courseName'] == null ? null : '${json['courseName']}',
    );
  }
}

class UnifiedGradesSummary {
  final int count;
  final double? average;
  final String? bestSubject;
  final String? weakestSubject;
  final List<UnifiedGradeInsight> latest;

  const UnifiedGradesSummary({
    required this.count,
    required this.average,
    required this.bestSubject,
    required this.weakestSubject,
    required this.latest,
  });

  factory UnifiedGradesSummary.fromJson(Map<String, dynamic> json) {
    double? asNullableDouble(Object? v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    int asInt(Object? v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? 0;
    }

    final list = json['latest'] is List ? json['latest'] as List : const [];

    return UnifiedGradesSummary(
      count: asInt(json['count']),
      average: asNullableDouble(json['average']),
      bestSubject: json['bestSubject'] == null
          ? null
          : '${json['bestSubject']}',
      weakestSubject: json['weakestSubject'] == null
          ? null
          : '${json['weakestSubject']}',
      latest: list
          .whereType<Map>()
          .map(
            (e) => UnifiedGradeInsight.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(growable: false),
    );
  }
}

class UnifiedAttendanceSummary {
  final int total;
  final int present;
  final int absent;
  final int late;
  final int justified;
  final double? attendanceRate;
  final List<UnifiedAttendanceInsight> latest;

  const UnifiedAttendanceSummary({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.justified,
    required this.attendanceRate,
    required this.latest,
  });

  factory UnifiedAttendanceSummary.fromJson(Map<String, dynamic> json) {
    double? asNullableDouble(Object? v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    int asInt(Object? v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? 0;
    }

    final list = json['latest'] is List ? json['latest'] as List : const [];

    return UnifiedAttendanceSummary(
      total: asInt(json['total']),
      present: asInt(json['present']),
      absent: asInt(json['absent']),
      late: asInt(json['late']),
      justified: asInt(json['justified']),
      attendanceRate: asNullableDouble(json['attendanceRate']),
      latest: list
          .whereType<Map>()
          .map(
            (e) => UnifiedAttendanceInsight.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(growable: false),
    );
  }
}

class UnifiedStudentInsights {
  final bool ok;
  final String studentId;
  final String generatedAt;
  final UnifiedGradesSummary grades;
  final UnifiedAttendanceSummary attendance;
  final InsightsServerSummary practice;

  const UnifiedStudentInsights({
    required this.ok,
    required this.studentId,
    required this.generatedAt,
    required this.grades,
    required this.attendance,
    required this.practice,
  });

  factory UnifiedStudentInsights.fromJson(Map<String, dynamic> json) {
    final gradesRaw = json['grades'];
    final attendanceRaw = json['attendance'];
    final practiceRaw = json['practice'];

    final gradesMap = gradesRaw is Map
        ? gradesRaw.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};

    final attendanceMap = attendanceRaw is Map
        ? attendanceRaw.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};

    final practiceMap = practiceRaw is Map
        ? practiceRaw.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};

    return UnifiedStudentInsights(
      ok: json['ok'] == true,
      studentId: '${json['studentId'] ?? ''}',
      generatedAt: '${json['generatedAt'] ?? ''}',
      grades: UnifiedGradesSummary.fromJson(gradesMap),
      attendance: UnifiedAttendanceSummary.fromJson(attendanceMap),
      practice: InsightsServerSummary.fromJson(practiceMap),
    );
  }
}

class UnifiedPracticeTrendWindow {
  final String label;
  final int attempts;
  final int correct;
  final double? accuracy;

  const UnifiedPracticeTrendWindow({
    required this.label,
    required this.attempts,
    required this.correct,
    required this.accuracy,
  });

  factory UnifiedPracticeTrendWindow.fromJson(Map<String, dynamic> json) {
    double? asNullableDouble(Object? v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    int asInt(Object? v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? 0;
    }

    return UnifiedPracticeTrendWindow(
      label: '${json['label'] ?? ''}',
      attempts: asInt(json['attempts']),
      correct: asInt(json['correct']),
      accuracy: asNullableDouble(json['accuracy']),
    );
  }
}

class UnifiedPracticeTrend {
  final UnifiedPracticeTrendWindow last7d;
  final UnifiedPracticeTrendWindow last30d;
  final double? deltaAccuracy;

  const UnifiedPracticeTrend({
    required this.last7d,
    required this.last30d,
    required this.deltaAccuracy,
  });

  factory UnifiedPracticeTrend.fromJson(Map<String, dynamic> json) {
    double? asNullableDouble(Object? v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    final raw7d = json['last7d'];
    final raw30d = json['last30d'];

    return UnifiedPracticeTrend(
      last7d: UnifiedPracticeTrendWindow.fromJson(
        raw7d is Map
            ? raw7d.map((k, v) => MapEntry(k.toString(), v))
            : <String, dynamic>{},
      ),
      last30d: UnifiedPracticeTrendWindow.fromJson(
        raw30d is Map
            ? raw30d.map((k, v) => MapEntry(k.toString(), v))
            : <String, dynamic>{},
      ),
      deltaAccuracy: asNullableDouble(json['deltaAccuracy']),
    );
  }
}
