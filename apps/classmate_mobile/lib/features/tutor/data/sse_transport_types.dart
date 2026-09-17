import 'dart:async';

/// A platform-neutral view of an open SSE HTTP response: the status code, the
/// raw byte stream of the body (delivered incrementally as it arrives), and a
/// close hook to tear down the underlying connection/reader.
///
/// The mobile (`dart:io`) and web (Fetch) transports each build one of these;
/// [SseClient] does the SSE framing on top so the parsing stays shared.
class SseTransportResponse {
  SseTransportResponse({
    required this.statusCode,
    required this.body,
    required this.close,
  });

  final int statusCode;
  final Stream<List<int>> body;
  final Future<void> Function() close;
}
