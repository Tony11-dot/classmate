import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';

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
  static const _devToken = String.fromEnvironment('CM_DEV_TOKEN');

  /// Signed-in user's JWT (set by the session controller). Same fix as
  /// PracticeGenerator — without it bagrut requests were unauthenticated.
  String? authToken;
  String get _bearer {
    final t = (authToken ?? '').trim();
    return t.isNotEmpty ? t : _devToken;
  }

  Future<BagrutQuestionDto?> getQuestion({
    required String subject,
    required String topicLabel,
  }) async {
    // Root base — no /api prefix on the server.
    final base = Env.stripApiSuffix(Env.apiBaseUrl);
    final uri = Uri.parse('$base/bagrut/question');
    final bearer = _bearer;
    final payloadJson = jsonEncode({'subject': subject, 'topicLabel': topicLabel});

    try {
      final int statusCode;
      final String body;
      if (kIsWeb) {
        // dart:io HttpClient / stderr don't exist on web — use package:http.
        final res = await http
            .post(
              uri,
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                if (bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
              },
              body: payloadJson,
            )
            .timeout(const Duration(seconds: 60));
        statusCode = res.statusCode;
        body = res.body;
      } else {
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 15);
        try {
          final req = await client.postUrl(uri);
          req.headers.contentType = ContentType.json;
          req.headers.set(HttpHeaders.acceptHeader, 'application/json');
          if (bearer.isNotEmpty) {
            req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
          }
          req.write(payloadJson);
          final res = await req.close();
          statusCode = res.statusCode;
          body = await utf8.decodeStream(res);
        } finally {
          client.close(force: true);
        }
      }

      if (statusCode < 200 || statusCode >= 300) {
        debugPrint('bagrut.question http $statusCode: $body');
        return null;
      }
      if (body.trim().isEmpty) {
        debugPrint('bagrut.question empty body with status $statusCode');
        return null;
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      return BagrutQuestionDto.fromJson(decoded);
    } catch (e, st) {
      debugPrint('bagrut.question failed: $e');
      debugPrint('$st');
      return null;
    }
  }
}
