import 'dart:convert';
import 'dart:io';

String _normalizeIncoming(String s) {
  return s
      .replaceAll(r'\(', '')
      .replaceAll(r'\)', '')
      .replaceAll(r'\[', '')
      .replaceAll(r'\]', '')
      .replaceAll(r'\\', r'\');
}

class BagrutQuestionDto {
  final String id;
  final String subject;
  final String topicLabel;
  final int year;
  final String season;
  final String examCode;
  final int questionIndex;
  final String promptLatex;
  final String solutionLatex;
  final String difficulty;
  final int points;

  const BagrutQuestionDto({
    required this.id,
    required this.subject,
    required this.topicLabel,
    required this.year,
    required this.season,
    required this.examCode,
    required this.questionIndex,
    required this.promptLatex,
    required this.solutionLatex,
    required this.difficulty,
    required this.points,
  });

  factory BagrutQuestionDto.fromJson(Map<String, dynamic> json) {
    return BagrutQuestionDto(
      id: '${json['id'] ?? ''}',
      subject: '${json['subject'] ?? ''}',
      topicLabel: '${json['topicLabel'] ?? ''}',
      year: (json['year'] as num?)?.toInt() ?? 0,
      season: '${json['season'] ?? ''}',
      examCode: '${json['examCode'] ?? ''}',
      questionIndex: (json['questionIndex'] as num?)?.toInt() ?? 0,
      promptLatex: _normalizeIncoming('${json['promptLatex'] ?? ''}'),
      solutionLatex: _normalizeIncoming('${json['solutionLatex'] ?? ''}'),
      difficulty: '${json['difficulty'] ?? ''}',
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }
}

class BagrutRepository {
  static const _apiBase = String.fromEnvironment(
    'CM_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3001',
  );

  static const _devToken = String.fromEnvironment('CM_DEV_TOKEN');

  Future<BagrutQuestionDto?> getQuestion({
    required String subject,
    required String topicLabel,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final uri = Uri.parse('$_apiBase/bagrut/question');
      final req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (_devToken.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_devToken');
      }

      req.write(jsonEncode({'subject': subject, 'topicLabel': topicLabel}));

      final res = await req.close();
      final body = await utf8.decodeStream(res);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        stderr.writeln('bagrut.question http ${res.statusCode}: $body');
        return null;
      }
      if (body.trim().isEmpty) {
        stderr.writeln(
          'bagrut.question empty body with status ${res.statusCode}',
        );
        return null;
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      return BagrutQuestionDto.fromJson(decoded);
    } catch (e, st) {
      stderr.writeln('bagrut.question failed: $e');
      stderr.writeln('$st');
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
