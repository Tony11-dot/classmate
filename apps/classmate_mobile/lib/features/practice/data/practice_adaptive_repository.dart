import 'dart:convert';
import 'dart:io';

class PracticeAdaptiveProfileDto {
  final double theta;
  final double uncertainty;
  final int streak;
  final int totalSeen;
  final int totalCorrect;

  const PracticeAdaptiveProfileDto({
    required this.theta,
    required this.uncertainty,
    required this.streak,
    required this.totalSeen,
    required this.totalCorrect,
  });

  factory PracticeAdaptiveProfileDto.fromJson(Map<String, dynamic> json) {
    return PracticeAdaptiveProfileDto(
      theta: (json['theta'] as num?)?.toDouble() ?? 0,
      uncertainty: (json['uncertainty'] as num?)?.toDouble() ?? 1,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      totalSeen: (json['totalSeen'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['totalCorrect'] as num?)?.toInt() ?? 0,
    );
  }
}

class PracticeAdaptiveRepository {
  static const _apiBase = String.fromEnvironment(
    'CM_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3001',
  );

  static const _devToken = String.fromEnvironment('CM_DEV_TOKEN');

  Future<void> recordAttempt({
    required String subject,
    required String topicLabel,
    required String mode,
    required String difficulty,
    required String questionId,
    required String prompt,
    required int? selectedIndex,
    required int correctIndex,
    required bool isCorrect,
    required int? timeTakenMs,
    bool usedNova = false,
    String source = 'ai',
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);

    try {
      final uri = Uri.parse('$_apiBase/practice-adaptive/attempt');
      final req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (_devToken.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_devToken');
      }

      req.write(
        jsonEncode({
          'subject': subject,
          'topicLabel': topicLabel,
          'mode': mode,
          'difficulty': difficulty,
          'questionId': questionId,
          'prompt': prompt,
          'selectedIndex': selectedIndex,
          'correctIndex': correctIndex,
          'isCorrect': isCorrect,
          'timeTakenMs': timeTakenMs,
          'usedNova': usedNova,
          'source': source,
        }),
      );

      final res = await req.close();
      await utf8.decodeStream(res);
    } catch (_) {
    } finally {
      client.close(force: true);
    }
  }

  Future<PracticeAdaptiveProfileDto?> getProfile({
    required String subject,
    required String topicLabel,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);

    try {
      final uri = Uri.parse(
        '$_apiBase/practice-adaptive/profile?subject=${Uri.encodeQueryComponent(subject)}&topicLabel=${Uri.encodeQueryComponent(topicLabel)}',
      );
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (_devToken.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_devToken');
      }

      final res = await req.close();
      final body = await utf8.decodeStream(res);

      if (res.statusCode < 200 ||
          res.statusCode >= 300 ||
          body.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      return PracticeAdaptiveProfileDto.fromJson(decoded);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
