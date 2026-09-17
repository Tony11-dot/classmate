import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'sse_transport_types.dart';

export 'sse_transport_types.dart';

/// Web transport. `package:http`'s browser client is XHR-based and does NOT
/// surface the response body until the request *completes*, so an open SSE
/// stream never delivers a chunk and NOVA spins forever (QA #36).
///
/// The Fetch API exposes the body as a `ReadableStream` that yields chunks the
/// moment they arrive — real incremental streaming — and, unlike `EventSource`,
/// still lets us send the `Authorization` header, so the token stays out of the
/// URL (no logging/referrer leak). This file is compiled only on web via the
/// conditional import in `sse_transport.dart`; it never touches mobile.
Future<SseTransportResponse> openSseStream(
  Uri uri,
  Map<String, String> headers,
) async {
  final h = web.Headers();
  headers.forEach((key, value) => h.append(key, value));
  final init = web.RequestInit(method: 'GET', headers: h);
  final res = await web.window.fetch(uri.toString().toJS, init).toDart;

  final controller = StreamController<List<int>>();
  final readable = res.body;

  if (readable == null) {
    // No streaming body handle (e.g. an error response) — read the whole
    // payload once so the caller can still surface the status/body.
    final text = (await res.text().toDart).toDart;
    if (text.isNotEmpty) controller.add(utf8.encode(text));
    unawaited(controller.close());
    return SseTransportResponse(
      statusCode: res.status,
      body: controller.stream,
      close: () async {},
    );
  }

  final reader = readable.getReader() as web.ReadableStreamDefaultReader;
  var cancelled = false;

  Future<void> pump() async {
    try {
      while (!cancelled) {
        final chunk = await reader.read().toDart;
        if (chunk.done) break;
        final value = chunk.value;
        if (value != null && !controller.isClosed) {
          controller.add((value as JSUint8Array).toDart);
        }
      }
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    } finally {
      if (!controller.isClosed) await controller.close();
    }
  }

  unawaited(pump());

  return SseTransportResponse(
    statusCode: res.status,
    body: controller.stream,
    close: () async {
      cancelled = true;
      try {
        await reader.cancel().toDart;
      } catch (_) {
        // Reader may already be released/errored — nothing to do.
      }
    },
  );
}
