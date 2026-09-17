import 'dart:async';

import 'package:http/http.dart' as http;

import 'sse_transport_types.dart';

export 'sse_transport_types.dart';

/// Native/mobile/desktop transport. `package:http` on `dart:io` streams the
/// response body incrementally, which is exactly what SSE needs — this is the
/// long-standing, working path, kept unchanged.
Future<SseTransportResponse> openSseStream(
  Uri uri,
  Map<String, String> headers,
) async {
  final client = http.Client();
  final req = http.Request('GET', uri);
  req.headers.addAll(headers);
  final res = await client.send(req);
  return SseTransportResponse(
    statusCode: res.statusCode,
    body: res.stream,
    close: () async => client.close(),
  );
}
