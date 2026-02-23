class ParentChild {
  const ParentChild({
    required this.id,
    required this.fullName,
    this.grade,
    this.className,
  });

  final String id;
  final String fullName;
  final String? grade;
  final String? className;

  static ParentChild fromJson(Map<String, dynamic> j) {
    return ParentChild(
      id: (j['id'] ?? j['studentId'] ?? j['sub'] ?? '').toString(),
      fullName: (j['fullName'] ?? j['name'] ?? j['displayName'] ?? 'Student')
          .toString(),
      grade: j['grade']?.toString(),
      className: (j['className'] ?? j['class'] ?? j['homeroom'])?.toString(),
    );
  }
}

class OverviewKpis {
  const OverviewKpis({
    this.attendancePct,
    this.avgGrade,
    this.missingAssignments,
    this.alerts,
  });

  final double? attendancePct;
  final double? avgGrade;
  final int? missingAssignments;
  final int? alerts;

  static OverviewKpis fromJson(Map<String, dynamic> j) {
    double? _d(dynamic v) => v == null ? null : double.tryParse(v.toString());
    int? _i(dynamic v) => v == null ? null : int.tryParse(v.toString());
    return OverviewKpis(
      attendancePct: _d(j['attendancePct'] ?? j['attendance']),
      avgGrade: _d(j['avgGrade'] ?? j['average']),
      missingAssignments: _i(j['missingAssignments'] ?? j['missing']),
      alerts: _i(j['alerts'] ?? j['notifications'] ?? j['flags']),
    );
  }
}
