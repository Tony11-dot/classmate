// A first-class "subject average" (weighted grade formula) a teacher defines
// per (cohort, subject): one or more formats, each a set of {assessment,
// weight%} components whose weights sum to 100. Mirrors the backend
// GradeFormula / GradeFormulaVariant / GradeFormulaComponent models.

class AverageComponent {
  const AverageComponent({required this.assessmentId, required this.weight});
  final String assessmentId;
  final int weight;

  factory AverageComponent.fromJson(Map<String, dynamic> j) => AverageComponent(
        assessmentId: '${j['assessmentId'] ?? ''}',
        weight: j['weight'] is int ? j['weight'] as int : int.tryParse('${j['weight']}') ?? 0,
      );

  Map<String, dynamic> toJson() => {'assessmentId': assessmentId, 'weight': weight};
}

class AverageFormat {
  const AverageFormat({this.label, this.sortOrder = 0, required this.components});
  final String? label;
  final int sortOrder;
  final List<AverageComponent> components;

  int get total => components.fold(0, (s, c) => s + c.weight);

  factory AverageFormat.fromJson(Map<String, dynamic> j) => AverageFormat(
        label: (j['label'] == null || '${j['label']}'.trim().isEmpty) ? null : '${j['label']}',
        sortOrder: j['sortOrder'] is int ? j['sortOrder'] as int : int.tryParse('${j['sortOrder']}') ?? 0,
        components: (j['components'] as List? ?? [])
            .whereType<Map>()
            .map((e) => AverageComponent.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        if (label != null && label!.isNotEmpty) 'label': label,
        'components': components.map((c) => c.toJson()).toList(),
      };
}

class SubjectAverage {
  const SubjectAverage({
    required this.id,
    required this.cohortId,
    required this.subject,
    required this.title,
    this.units = 0,
    this.semester,
    required this.variants,
  });

  final String id;
  final String cohortId;
  final String subject;
  final String title;
  final int units;
  final int? semester;
  final List<AverageFormat> variants;

  factory SubjectAverage.fromJson(Map<String, dynamic> j) => SubjectAverage(
        id: '${j['id'] ?? ''}',
        cohortId: '${j['cohortId'] ?? ''}',
        subject: '${j['subject'] ?? ''}',
        title: '${j['title'] ?? ''}',
        units: j['units'] is int ? j['units'] as int : int.tryParse('${j['units']}') ?? 0,
        semester: j['semester'] == null ? null : (j['semester'] is int ? j['semester'] as int : int.tryParse('${j['semester']}')),
        variants: (j['variants'] as List? ?? [])
            .whereType<Map>()
            .map((e) => AverageFormat.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

/// One student's computed average for a formula (from the compute endpoint).
class ComputedStudentAverage {
  const ComputedStudentAverage({
    required this.studentId,
    required this.name,
    this.value,
    this.formatUsed,
  });
  final String studentId;
  final String name;
  final double? value;
  final int? formatUsed;

  factory ComputedStudentAverage.fromJson(Map<String, dynamic> j) => ComputedStudentAverage(
        studentId: '${j['studentId'] ?? ''}',
        name: '${j['name'] ?? ''}',
        value: j['value'] == null ? null : (j['value'] is num ? (j['value'] as num).toDouble() : double.tryParse('${j['value']}')),
        formatUsed: j['formatUsed'] == null ? null : (j['formatUsed'] is int ? j['formatUsed'] as int : int.tryParse('${j['formatUsed']}')),
      );
}
