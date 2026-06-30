import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class AvgCohort {
  const AvgCohort({required this.id, required this.name, required this.grade});
  final String id;
  final String name;
  final int? grade;
  factory AvgCohort.fromJson(Map<String, dynamic> j) => AvgCohort(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        grade: j['grade'] is int ? j['grade'] as int : int.tryParse('${j['grade']}'),
      );
}

class AvgSubject {
  const AvgSubject({required this.value, required this.display, this.i18n});
  final String value; // raw subject (matches Assessment.subject)
  final String display;
  final Map<String, dynamic>? i18n;
  factory AvgSubject.fromJson(Map<String, dynamic> j) => AvgSubject(
        value: (j['value'] ?? '').toString(),
        display: (j['display'] ?? j['value'] ?? '').toString(),
        i18n: j['i18n'] is Map ? Map<String, dynamic>.from(j['i18n'] as Map) : null,
      );
}

class AvgAssessment {
  const AvgAssessment({required this.id, required this.title, this.date, this.maxGrade});
  final String id;
  final String title;
  final DateTime? date;
  final int? maxGrade;
  factory AvgAssessment.fromJson(Map<String, dynamic> j) => AvgAssessment(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        date: j['date'] != null ? DateTime.tryParse('${j['date']}') : null,
        maxGrade: j['maxGrade'] is int ? j['maxGrade'] as int : int.tryParse('${j['maxGrade']}'),
      );
}

class AvgComponent {
  AvgComponent({required this.assessmentId, required this.weight});
  String assessmentId;
  int weight;
  Map<String, dynamic> toJson() => {'assessmentId': assessmentId, 'weight': weight};
  factory AvgComponent.fromJson(Map<String, dynamic> j) => AvgComponent(
        assessmentId: (j['assessmentId'] ?? '').toString(),
        weight: j['weight'] is int ? j['weight'] as int : int.tryParse('${j['weight']}') ?? 0,
      );
}

class AvgVariant {
  AvgVariant({this.label, this.components = const []});
  String? label;
  List<AvgComponent> components;
  Map<String, dynamic> toJson() => {
        if (label != null && label!.isNotEmpty) 'label': label,
        'components': components.map((c) => c.toJson()).toList(),
      };
  factory AvgVariant.fromJson(Map<String, dynamic> j) => AvgVariant(
        label: j['label']?.toString(),
        components: (j['components'] as List? ?? [])
            .map((c) => AvgComponent.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList(),
      );
}

class AvgFormula {
  AvgFormula({
    required this.id,
    required this.title,
    required this.cohortId,
    required this.subject,
    required this.units,
    required this.variants,
  });
  final String id;
  final String title;
  final String cohortId;
  final String subject;
  final int units;
  final List<AvgVariant> variants;
  factory AvgFormula.fromJson(Map<String, dynamic> j) => AvgFormula(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        cohortId: (j['cohortId'] ?? '').toString(),
        subject: (j['subject'] ?? '').toString(),
        units: j['units'] is int ? j['units'] as int : int.tryParse('${j['units']}') ?? 0,
        variants: (j['variants'] as List? ?? [])
            .map((v) => AvgVariant.fromJson(Map<String, dynamic>.from(v as Map)))
            .toList(),
      );
}

// ── Repository ────────────────────────────────────────────────────────────────

final averagesRepositoryProvider = Provider<AveragesRepository>((ref) {
  final token = (ref.watch(authSessionProvider).token ?? '').trim();
  return AveragesRepository(token: token);
});

class AveragesRepository {
  AveragesRepository({required this.token});
  final String token;
  CMApi get _api => CMApi(token: token);

  Map<String, dynamic> _m(dynamic raw) => raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  List<dynamic> _l(dynamic raw) => raw is List ? raw : const [];

  Future<List<AvgCohort>> cohorts() async {
    final raw = await _api.getJson('/averages/cohorts');
    return _l(_m(raw)['cohorts']).map((e) => AvgCohort.fromJson(_m(e))).toList();
  }

  Future<List<AvgSubject>> options(String cohortId) async {
    final raw = await _api.getJson('/averages/options', query: {'cohortId': cohortId});
    return _l(_m(raw)['subjects']).map((e) => AvgSubject.fromJson(_m(e))).toList();
  }

  Future<List<AvgAssessment>> grades(String cohortId, String subject, {int? semester}) async {
    final raw = await _api.getJson('/averages/grades', query: {
      'cohortId': cohortId,
      'subject': subject,
      if (semester != null) 'semester': '$semester',
    });
    return _l(_m(raw)['grades']).map((e) => AvgAssessment.fromJson(_m(e))).toList();
  }

  Future<List<AvgFormula>> list(String cohortId, String subject) async {
    final raw = await _api.getJson('/averages', query: {'cohortId': cohortId, 'subject': subject});
    return _l(_m(raw)['formulas']).map((e) => AvgFormula.fromJson(_m(e))).toList();
  }

  Future<void> create({
    required String title,
    required String cohortId,
    required String subject,
    required int units,
    required List<AvgVariant> variants,
  }) async {
    await _api.postJson('/averages', body: {
      'title': title,
      'cohortId': cohortId,
      'subject': subject,
      'units': units,
      'variants': variants.map((v) => v.toJson()).toList(),
    });
  }

  Future<void> update(String id, {String? title, int? units, List<AvgVariant>? variants}) async {
    await _api.patchJson('/averages/$id', body: {
      'title': ?title,
      'units': ?units,
      if (variants != null) 'variants': variants.map((v) => v.toJson()).toList(),
    });
  }

  Future<void> delete(String id) async {
    await _api.deleteJson('/averages/$id');
  }
}
