/// Mirrors the server `/parent/*` shapes. Kept deliberately permissive
/// (`String? cohortName` not required, all numeric fields default-zero)
/// so a server change can't crash the screen — fields just render empty.

class ParentChild {
  final String studentId;
  final String name;
  final String? cohortName;
  final int? grade;

  const ParentChild({
    required this.studentId,
    required this.name,
    this.cohortName,
    this.grade,
  });

  factory ParentChild.fromJson(Map<String, dynamic> j) {
    final cohort = j['cohort'];
    return ParentChild(
      studentId: (j['studentId'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      cohortName: cohort is Map ? (cohort['name'] ?? '').toString() : null,
      grade: cohort is Map && cohort['grade'] is num
          ? (cohort['grade'] as num).toInt()
          : null,
    );
  }

  String get gradeLabel => grade != null ? 'Grade $grade' : '';
}

class ParentGrade {
  final String? subject;
  final String? title;
  final num? score;
  final num? maxScore;
  final String? createdAt;

  const ParentGrade({this.subject, this.title, this.score, this.maxScore, this.createdAt});

  factory ParentGrade.fromJson(Map<String, dynamic> j) => ParentGrade(
        subject: j['subject']?.toString(),
        title: j['title']?.toString(),
        score: j['score'] is num ? j['score'] as num : null,
        maxScore: j['maxScore'] is num ? j['maxScore'] as num : null,
        createdAt: j['createdAt']?.toString(),
      );

  String get scoreLabel {
    if (score == null) return '—';
    if (maxScore != null && maxScore! > 0) return '$score / $maxScore';
    return score.toString();
  }
}

class ParentScheduleSlot {
  final String? subject;
  final String? teacher;
  final String? dayOfWeek; // 'MON','TUE',… or '0'..'6'
  final String? startTime;
  final String? endTime;
  final String? room;

  const ParentScheduleSlot({
    this.subject,
    this.teacher,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.room,
  });

  factory ParentScheduleSlot.fromJson(Map<String, dynamic> j) => ParentScheduleSlot(
        subject: (j['subject'] ?? j['subjectName'] ?? '').toString(),
        teacher: (j['teacher'] ?? j['teacherName'] ?? '').toString(),
        dayOfWeek: (j['dayOfWeek'] ?? j['day'] ?? '').toString(),
        startTime: (j['startTime'] ?? j['start'] ?? '').toString(),
        endTime: (j['endTime'] ?? j['end'] ?? '').toString(),
        room: (j['room'] ?? '').toString(),
      );
}

class ParentAttendance {
  final String? date;
  final String status; // PRESENT | ABSENT | LATE | EXCUSED | UNKNOWN
  final String? subject;

  const ParentAttendance({this.date, this.status = 'UNKNOWN', this.subject});

  factory ParentAttendance.fromJson(Map<String, dynamic> j) => ParentAttendance(
        date: j['date']?.toString(),
        status: (j['status'] ?? 'UNKNOWN').toString().toUpperCase(),
        subject: j['subject']?.toString(),
      );
}

class ParentNotification {
  final String id;
  final String title;
  final String body;
  final String? createdAt;
  final bool seen;
  final String? studentName;

  const ParentNotification({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
    this.seen = false,
    this.studentName,
  });

  factory ParentNotification.fromJson(Map<String, dynamic> j) => ParentNotification(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        body: (j['body'] ?? j['message'] ?? '').toString(),
        createdAt: j['createdAt']?.toString(),
        seen: j['seen'] == true || j['readAt'] != null,
        studentName: (j['studentName'] ?? '').toString().isEmpty
            ? null
            : j['studentName'] as String,
      );
}
