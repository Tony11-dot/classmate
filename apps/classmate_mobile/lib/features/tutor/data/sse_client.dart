import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class SseClient {
  final http.Client _client;
  SseClient({http.Client? client}) : _client = client ?? http.Client();

  Stream<Map<String, dynamic>> connect(
    Uri uri, {
    required Future<String> Function() getToken,
    Map<String, String> headers = const {},
  }) async* {
    final token0 = (await getToken()).trim();
    final token = (token0 == 'SIM_TOKEN') ? '' : token0;
    final isJwtish = token.split('.').length >= 3;
    final isDevTok = token.startsWith('dev-token-');
    final hasToken = token.isNotEmpty && (isJwtish || isDevTok);
    final req = http.Request('GET', uri);
    req.headers.addAll(<String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      if (hasToken) 'Authorization': 'Bearer $token',
      ...headers,
    });
    final res = await _client.send(req);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = await res.stream.bytesToString();
      throw Exception('SSE HTTP ${res.statusCode}: $body');
    }

    String? curId;
    final dataBuf = StringBuffer();

    Map<String, dynamic> parseEvent(String raw) {
      final t = raw.trimRight();
      try {
        final decoded = jsonDecode(t);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'data': decoded};
      } catch (_) {
        return {'data': t};
      }
    }

    final out = StreamController<Map<String, dynamic>>();
    final sub = res.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (line.isEmpty) {
              if (dataBuf.isNotEmpty) {
                final ev = parseEvent(dataBuf.toString());
                dataBuf.clear();
                if (curId != null &&
                    curId!.isNotEmpty &&
                    !ev.containsKey('id')) {
                  ev['id'] = curId;
                }
                out.add(ev);
              }
              curId = null;
              return;
            }

            if (line.startsWith('id:')) {
              curId = line.substring(3).trim();
              return;
            }

            if (line.startsWith('data:')) {
              final part = line.substring(5);
              if (dataBuf.isNotEmpty) dataBuf.write('\n');
              dataBuf.write(part);
              return;
            }
          },
          onError: out.addError,
          onDone: () {
            if (dataBuf.isNotEmpty) {
              final ev = parseEvent(dataBuf.toString());
              dataBuf.clear();
              if (curId != null && curId!.isNotEmpty && !ev.containsKey('id')) {
                ev['id'] = curId;
              }
              out.add(ev);
            }
            out.close();
          },
        );

    try {
      yield* out.stream;
    } finally {
      await sub.cancel();
      await out.close();
    }
  }

  void close() => _client.close();
}
