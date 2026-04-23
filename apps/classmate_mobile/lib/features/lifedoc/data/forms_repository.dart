import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';
import '../domain/form_models.dart';

const _formsCacheTtl = Duration(minutes: 2);
DateTime? _formsCachedAt;
List<StudentFormItem>? _formsCachedItems;
Future<List<StudentFormItem>>? _formsInflight;

final formsRepositoryProvider = Provider<StudentFormsRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return StudentFormsRepository(token: token);
});

final formsLiveProvider = FutureProvider<List<StudentFormItem>>((
  ref,
) async {
  final now = DateTime.now();
  final cachedAt = _formsCachedAt;
  final cachedItems = _formsCachedItems;
  if (cachedAt != null &&
      cachedItems != null &&
      now.difference(cachedAt) < _formsCacheTtl) {
    return cachedItems;
  }

  final inflight = _formsInflight;
  if (inflight != null) {
    return inflight;
  }

  final future = ref.read(formsRepositoryProvider).list().then((items) {
    _formsCachedItems = items;
    _formsCachedAt = DateTime.now();
    return items;
  });

  _formsInflight = future;
  try {
    return await future;
  } finally {
    _formsInflight = null;
  }
});

class StudentFormsRepository {
  StudentFormsRepository({this.token = ''});

  final String token;
  List<StudentFormItem> _cache = const <StudentFormItem>[];

  CMApi get _api => CMApi(token: token);

  Future<List<StudentFormItem>> list() async {
    final raw = await _api.getJson('/forms/live');
    final list = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : const <dynamic>[];

    _cache = list
        .whereType<Map>()
        .map((item) => _mapToFormItem(item.map((k, v) => MapEntry(k.toString(), v))))
        .toList(growable: false);
    return _cache;
  }

  StudentFormItem? byId(String id) {
    for (final form in _cache) {
      if (form.id == id) return form;
    }
    return null;
  }
}

StudentFormItem _mapToFormItem(Map<String, dynamic> json) {
  String str(List<String> keys, [String fallback = '']) {
    for (final key in keys) {
      final value = (json[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  bool boolValue(List<String> keys, [bool fallback = false]) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      final text = (value ?? '').toString().trim().toLowerCase();
      if (text == 'true') return true;
      if (text == 'false') return false;
    }
    return fallback;
  }

  int intValue(Map<String, dynamic> source, List<String> keys, [int fallback = 0]) {
    for (final key in keys) {
      final value = source[key];
      if (value is int) return value;
      final parsed = int.tryParse((value ?? '').toString().trim());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  double doubleValue(Map<String, dynamic> source, List<String> keys, [double fallback = 0]) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) return value.toDouble();
      final parsed = double.tryParse((value ?? '').toString().trim());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  final summary = json['summary'] is Map<String, dynamic>
      ? json['summary'] as Map<String, dynamic>
      : json['summary'] is Map
      ? Map<String, dynamic>.from(json['summary'] as Map)
      : <String, dynamic>{};

  final rawQuestions = json['questions'] is List ? json['questions'] as List : const <dynamic>[];

  return StudentFormItem(
    id: str(['id'], 'form-${json.hashCode}'),
    subject: str(['subject'], 'Form'),
    title: str(['title', 'name'], 'Untitled form'),
    description: str(['description', 'body']),
    teacher: str(['teacher', 'teacherName'], 'School'),
    audienceLabel: str(['audienceLabel', 'audience'], 'School audience'),
    acceptingResponses: boolValue(['acceptingResponses'], true),
    allowMultipleResponses: boolValue(['allowMultipleResponses']),
    published: boolValue(['published'], true),
    summary: StudentFormSummary(
      responsesCount: intValue(summary, ['responsesCount']),
      pendingCount: intValue(summary, ['pendingCount']),
      completionRate: doubleValue(summary, ['completionRate']),
      averageDurationLabel: (summary['averageDurationLabel'] ?? '').toString().trim(),
      publishedLabel: (summary['publishedLabel'] ?? '').toString().trim(),
    ),
    questions: rawQuestions
        .whereType<Map>()
        .map((item) => _mapQuestion(Map<String, dynamic>.from(item)))
        .toList(growable: false),
  );
}

StudentFormQuestion _mapQuestion(Map<String, dynamic> json) {
  final typeRaw = (json['type'] ?? '').toString().trim().toLowerCase();
  final type = switch (typeRaw) {
    'paragraph' => StudentFormQuestionType.paragraph,
    'multiplechoice' => StudentFormQuestionType.multipleChoice,
    'checkboxes' => StudentFormQuestionType.checkboxes,
    'dropdown' => StudentFormQuestionType.dropdown,
    'linearscale' => StudentFormQuestionType.linearScale,
    _ => StudentFormQuestionType.shortAnswer,
  };

  final statsMap = json['stats'] is Map<String, dynamic>
      ? json['stats'] as Map<String, dynamic>
      : json['stats'] is Map
      ? Map<String, dynamic>.from(json['stats'] as Map)
      : <String, dynamic>{};

  final rawChoiceStats = statsMap['choiceStats'] is List
      ? statsMap['choiceStats'] as List
      : const <dynamic>[];
  final rawTextSamples = statsMap['textSamples'] is List
      ? statsMap['textSamples'] as List
      : const <dynamic>[];

  return StudentFormQuestion(
    id: (json['id'] ?? '').toString().trim(),
    title: (json['title'] ?? '').toString().trim(),
    description: (json['description'] ?? '').toString().trim().isEmpty
        ? null
        : (json['description'] ?? '').toString().trim(),
    type: type,
    required: json['required'] == true,
    options: (json['options'] is List ? json['options'] as List : const <dynamic>[])
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false),
    minScale: int.tryParse((json['minScale'] ?? '').toString()) ?? 1,
    maxScale: int.tryParse((json['maxScale'] ?? '').toString()) ?? 5,
    stats: StudentFormQuestionStats(
      choiceStats: rawChoiceStats
          .whereType<Map>()
          .map(
            (item) => StudentFormChoiceStat(
              label: (item['label'] ?? '').toString().trim(),
              count: int.tryParse((item['count'] ?? '').toString()) ?? 0,
              fraction: double.tryParse((item['fraction'] ?? '').toString()) ?? 0,
            ),
          )
          .toList(growable: false),
      textSamples: rawTextSamples
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      averageScale: statsMap['averageScale'] == null
          ? null
          : double.tryParse((statsMap['averageScale'] ?? '').toString()),
    ),
  );
}
