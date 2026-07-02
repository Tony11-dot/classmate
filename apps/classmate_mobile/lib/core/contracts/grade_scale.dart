/// A custom (non-numeric) grading scale, e.g. letter grades A / A+ / B, defined
/// by an admin and applied to a set of grade levels. Shared by the admin
/// management screen and the teacher grading UI.
class GradeScaleLabel {
  const GradeScaleLabel({required this.label, this.value, this.i18n = const {}});

  /// The base label (e.g. "A+"). Language-neutral fallback.
  final String label;

  /// Numeric equivalent (0..100) used for subject averages. Null = excluded.
  final int? value;

  /// Optional per-locale text, keyed by locale code (en, ar, he, ru, fr, ps).
  final Map<String, String> i18n;

  /// The label in the given [locale], falling back to the base label.
  String localized(String locale) {
    final v = i18n[locale];
    if (v != null && v.trim().isNotEmpty) return v;
    return label;
  }

  factory GradeScaleLabel.fromJson(Map<String, dynamic> json) {
    final rawI18n = json['i18n'];
    final i18n = <String, String>{};
    if (rawI18n is Map) {
      rawI18n.forEach((k, v) {
        final s = '${v ?? ''}'.trim();
        if (s.isNotEmpty) i18n['$k'] = s;
      });
    }
    return GradeScaleLabel(
      label: '${json['label'] ?? ''}',
      value: json['value'] == null
          ? null
          : (json['value'] is int ? json['value'] as int : int.tryParse('${json['value']}')),
      i18n: i18n,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        if (value != null) 'value': value,
        if (i18n.isNotEmpty) 'i18n': i18n,
      };
}

class CustomGradeScale {
  const CustomGradeScale({
    required this.id,
    required this.name,
    required this.gradeLevels,
    required this.labels,
  });

  final String id;
  final String name;
  final List<int> gradeLevels;
  final List<GradeScaleLabel> labels;

  /// Whether this scale applies to a student in [gradeLevel]. An empty
  /// gradeLevels list means "all grade levels".
  bool appliesTo(int? gradeLevel) {
    if (gradeLevels.isEmpty) return true;
    if (gradeLevel == null) return false;
    return gradeLevels.contains(gradeLevel);
  }

  factory CustomGradeScale.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'];
    final labels = <GradeScaleLabel>[];
    if (rawLabels is List) {
      for (final e in rawLabels) {
        if (e is Map) labels.add(GradeScaleLabel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    final rawLevels = json['gradeLevels'];
    final levels = <int>[];
    if (rawLevels is List) {
      for (final e in rawLevels) {
        final n = e is int ? e : int.tryParse('$e');
        if (n != null) levels.add(n);
      }
    }
    return CustomGradeScale(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      gradeLevels: levels,
      labels: labels,
    );
  }
}
