class GradeRow {
  final String id;
  final String title;
  final num? score;
  final String subjectId;
  final String? teacherId;
  final String? studentUserId;
  final String? createdAt;

  GradeRow({
    required this.id,
    required this.title,
    required this.subjectId,
    this.score,
    this.teacherId,
    this.studentUserId,
    this.createdAt,
  });

  factory GradeRow.fromJson(Map<String, dynamic> j) => GradeRow(
    id: (j['id'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    score: j['score'] is num
        ? j['score'] as num
        : num.tryParse('${j['score']}'),
    subjectId: (j['subjectId'] ?? '').toString(),
    teacherId: j['teacherId']?.toString(),
    studentUserId: j['studentUserId']?.toString(),
    createdAt: j['createdAt']?.toString(),
  );
}

class GradeSubjectSummary {
  final String subjectId;
  final String? lastPostedAt;
  final num? lastScore;
  final num? minScore;
  final num? maxScore;
  final int count;

  GradeSubjectSummary({
    required this.subjectId,
    required this.count,
    this.lastPostedAt,
    this.lastScore,
    this.minScore,
    this.maxScore,
  });

  factory GradeSubjectSummary.fromJson(Map<String, dynamic> j) =>
      GradeSubjectSummary(
        subjectId: (j['subjectId'] ?? '').toString(),
        lastPostedAt: j['lastPostedAt']?.toString(),
        lastScore: j['lastScore'] is num
            ? j['lastScore'] as num
            : num.tryParse('${j['lastScore']}'),
        minScore: j['minScore'] is num
            ? j['minScore'] as num
            : num.tryParse('${j['minScore']}'),
        maxScore: j['maxScore'] is num
            ? j['maxScore'] as num
            : num.tryParse('${j['maxScore']}'),
        count: j['count'] is int
            ? j['count'] as int
            : int.tryParse('${j['count']}') ?? 0,
      );
}
