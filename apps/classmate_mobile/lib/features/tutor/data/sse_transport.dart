/// Picks the SSE byte-stream transport per platform: the `dart:io` streaming
/// client on mobile/desktop, the Fetch `ReadableStream` reader on web (where
/// XHR can't stream). Both expose the same `openSseStream()` + working
/// `SseTransportResponse`.
library;

export 'sse_transport_io.dart'
    if (dart.library.js_interop) 'sse_transport_web.dart';
