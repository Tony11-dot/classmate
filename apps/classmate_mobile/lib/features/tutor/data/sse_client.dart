import 'dart:async';
import 'dart:convert';

import '../../../core/http/cm_api.dart';
import 'sse_transport.dart';

class SseClient {
  SseClient();

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
    // The transport is picked per platform: `dart:io` streaming on mobile,
    // Fetch `ReadableStream` on web (XHR can't stream, which is what left NOVA
    // spinning on the browser). Both keep the token in the Authorization
    // header, never the URL.
    final res = await openSseStream(uri, <String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      if (hasToken) 'Authorization': 'Bearer $token',
      ...headers,
    });
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = await res.body.transform(utf8.decoder).join();
      // Sanitized toString — never leak the raw response body to the UI.
      await res.close();
      throw CMApiException(statusCode: res.statusCode, uri: uri, body: body);
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
    // Every add below checks isClosed first. The consumer cancelling the
    // outer `yield*` (user leaves the screen mid-stream) races the network
    // callbacks here — an event that slips through after the finally's
    // close() would throw the fatal "Cannot add new events after calling
    // close" instead of being harmlessly dropped.
    void safeAdd(Map<String, dynamic> ev) {
      if (!out.isClosed) out.add(ev);
    }

    final sub = res.body
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
                safeAdd(ev);
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
          onError: (Object e, StackTrace st) {
            if (!out.isClosed) out.addError(e, st);
          },
          onDone: () {
            if (dataBuf.isNotEmpty) {
              final ev = parseEvent(dataBuf.toString());
              dataBuf.clear();
              if (curId != null && curId!.isNotEmpty && !ev.containsKey('id')) {
                ev['id'] = curId;
              }
              safeAdd(ev);
            }
            if (!out.isClosed) out.close();
          },
        );

    try {
      yield* out.stream;
    } finally {
      await sub.cancel();
      await res.close();
      if (!out.isClosed) await out.close();
    }
  }
}
