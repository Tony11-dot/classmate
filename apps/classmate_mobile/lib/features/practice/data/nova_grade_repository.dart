import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class NovaGradeResultDto {
  final int score;
  final List<String> feedback;
  final List<Map<String, dynamic>> stepDetections;

  const NovaGradeResultDto({
    required this.score,
    required this.feedback,
    required this.stepDetections,
  });

  factory NovaGradeResultDto.fromJson(Map<String, dynamic> json) {
    return NovaGradeResultDto(
      score: (json['score'] as num?)?.toInt() ?? 0,
      feedback: (json['feedback'] as List<dynamic>? ?? const [])
          .map((e) => '$e')
          .toList(growable: false),
      stepDetections: (json['stepDetections'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry('$k', v)))
          .toList(growable: false),
    );
  }
}

class NovaGradeRepository {
  static const _apiBase = String.fromEnvironment(
    'CM_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3001',
  );

  static const _devToken = String.fromEnvironment('CM_DEV_TOKEN');

  final ImagePicker _picker = ImagePicker();

  Future<NovaGradeResultDto?> gradeFromCamera({
    List<String> steps = const [],
  }) async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return null;

    final bytes = await File(image.path).readAsBytes();
    final boundary = '----classmate-${DateTime.now().millisecondsSinceEpoch}';
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);

    try {
      final uri = Uri.parse('$_apiBase/nova/grade');
      final req = await client.postUrl(uri);

      req.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (_devToken.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_devToken');
      }

      void writeField(String name, String value) {
        req.write('--$boundary\r\n');
        req.write('Content-Disposition: form-data; name="$name"\r\n\r\n');
        req.write(value);
        req.write('\r\n');
      }

      writeField('steps', jsonEncode(steps));

      req.write('--$boundary\r\n');
      req.write(
        'Content-Disposition: form-data; name="image"; filename="solution.jpg"\r\n',
      );
      req.write('Content-Type: image/jpeg\r\n\r\n');
      req.add(bytes);
      req.write('\r\n--$boundary--\r\n');

      final res = await req.close();
      final body = await utf8.decodeStream(res);

      if (res.statusCode < 200 ||
          res.statusCode >= 300 ||
          body.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      return NovaGradeResultDto.fromJson(decoded);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
