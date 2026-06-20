import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../config/env.dart';

/// Event types emitted by the server over SSE.
class RealtimeEvent {
  const RealtimeEvent({
    required this.type,
    this.classroomId,
    this.threadId,
    this.studentId,
    this.targetUserIds,
  });
  final String type;
  final String? classroomId;
  final String? threadId;
  final String? studentId;
  final List<String>? targetUserIds;

  factory RealtimeEvent.fromJson(Map<String, dynamic> j) => RealtimeEvent(
    type: (j['type'] ?? '').toString(),
    classroomId: j['classroomId']?.toString(),
    threadId: j['threadId']?.toString(),
    studentId: j['studentId']?.toString(),
    targetUserIds: j['targetUserIds'] is List
        ? List<String>.from((j['targetUserIds'] as List).map((e) => e.toString()))
        : null,
  );
}

/// Singleton SSE client.  Call [connect] after login, [dispose] on logout.
/// Subscribe to [events] stream to get push events; invalidate providers there.
class RealtimeService {
  RealtimeService._();
  static final instance = RealtimeService._();

  final _controller = StreamController<RealtimeEvent>.broadcast();
  Stream<RealtimeEvent> get events => _controller.stream;

  String _token = '';
  StreamSubscription<String>? _lineSub;
  Timer? _reconnect;
  bool _disposed = false;
  // Start reconnect attempts fast (1s) so a dropped stream re-establishes
  // near-instantly — a slow re-attach was the main cause of messages/
  // notifications feeling "a minute late". Backs off to 30s on repeated fails.
  int _retryDelay = 1;

  // Second SSE connection for parents: /parent/notifications/stream
  // fires alongside the main /realtime/stream so a logged-in parent
  // gets both their child-realtime events AND parent-specific
  // notification pings.
  StreamSubscription<String>? _parentLineSub;
  Timer? _parentReconnect;
  int _parentRetryDelay = 1;
  bool _parentEnabled = false;

  // On web, package:http's BrowserClient buffers the whole response instead of
  // streaming, so SSE never delivers incremental events. Fall back to periodic
  // polling so web data stays fresh like the phone.
  Timer? _webPoll;
  static const _webPollInterval = Duration(seconds: 20);

  void connect(String token) {
    _token = token;
    _disposed = false;
    _retryDelay = 1;
    if (kIsWeb) {
      _startWebPolling();
      return;
    }
    _doConnect();
    if (_parentEnabled) _doConnectParent();
  }

  void _startWebPolling() {
    _webPoll?.cancel();
    if (_token.isEmpty) return;
    // Emit one immediate refresh, then poll on an interval.
    _controller.add(const RealtimeEvent(type: 'poll'));
    _webPoll = Timer.periodic(_webPollInterval, (_) {
      if (_disposed || _token.isEmpty) return;
      _controller.add(const RealtimeEvent(type: 'poll'));
    });
  }

  /// Opt the current connection into the parent SSE stream. Called
  /// from the main wireup when the logged-in user is a PARENT.
  void enableParentStream() {
    _parentEnabled = true;
    if (!_disposed && _token.isNotEmpty) _doConnectParent();
  }

  void _doConnect() {
    if (_disposed || _token.isEmpty) return;
    _lineSub?.cancel();

    final base = Env.apiBaseUrl
        .replaceAll(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/+$'), '');
    // Pass the token as a query param too (mirrors the parent stream) so the
    // server's SSE guard can authenticate even where the Authorization header
    // isn't honored.
    final uri = Uri.parse('$base/realtime/stream?token=$_token');

    final client = http.Client();
    final request = http.Request('GET', uri)
      ..headers['Authorization'] = 'Bearer $_token'
      ..headers['Accept'] = 'text/event-stream'
      ..headers['Cache-Control'] = 'no-cache';

    client.send(request).then((response) {
      if (_disposed) { client.close(); return; }
      if (response.statusCode != 200) { client.close(); _scheduleReconnect(); return; }
      _retryDelay = 1;

      _lineSub = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _onLine,
            onDone:  () { client.close(); _scheduleReconnect(); },
            onError: (_) { client.close(); _scheduleReconnect(); },
          );
    }).catchError((_) { _scheduleReconnect(); });
  }

  void _onLine(String line) {
    if (!line.startsWith('data:')) return;
    final jsonStr = line.substring(5).trim();
    if (jsonStr.isEmpty) return;
    try {
      final j = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (j['type'] == 'ping' || j['type'] == 'connected') return;
      _controller.add(RealtimeEvent.fromJson(j));
    } catch (_) {}
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnect?.cancel();
    _reconnect = Timer(Duration(seconds: _retryDelay), () {
      _retryDelay = (_retryDelay * 2).clamp(1, 30);
      _doConnect();
    });
  }

  void _doConnectParent() {
    if (_disposed || _token.isEmpty) return;
    _parentLineSub?.cancel();

    final base = Env.apiBaseUrl
        .replaceAll(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/+$'), '');
    // SseJwtGuard on the parent stream reads the JWT from a query
    // param (the SSE polyfill on web can't set Authorization headers).
    final uri = Uri.parse('$base/parent/notifications/stream?token=$_token');

    final client = http.Client();
    final request = http.Request('GET', uri)
      ..headers['Authorization'] = 'Bearer $_token'
      ..headers['Accept'] = 'text/event-stream'
      ..headers['Cache-Control'] = 'no-cache';

    client.send(request).then((response) {
      if (_disposed) { client.close(); return; }
      if (response.statusCode != 200) { client.close(); _scheduleParentReconnect(); return; }
      _parentRetryDelay = 1;

      _parentLineSub = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _onParentLine,
            onDone:  () { client.close(); _scheduleParentReconnect(); },
            onError: (_) { client.close(); _scheduleParentReconnect(); },
          );
    }).catchError((_) { _scheduleParentReconnect(); });
  }

  void _onParentLine(String line) {
    if (!line.startsWith('data:')) return;
    final jsonStr = line.substring(5).trim();
    if (jsonStr.isEmpty) return;
    try {
      final j = jsonDecode(jsonStr) as Map<String, dynamic>;
      final t = j['type']?.toString() ?? '';
      if (t == 'ping' || t == 'hello') return;
      // Bridge the parent-specific events into the SHARED event
      // stream as plain 'notification' so the existing app-shell
      // listener picks them up uniformly. The shell handler
      // invalidates parentNotificationsProvider on 'notification'.
      if (t == 'notification.created') {
        _controller.add(const RealtimeEvent(type: 'notification'));
      }
    } catch (_) {}
  }

  void _scheduleParentReconnect() {
    if (_disposed) return;
    _parentReconnect?.cancel();
    _parentReconnect = Timer(Duration(seconds: _parentRetryDelay), () {
      _parentRetryDelay = (_parentRetryDelay * 2).clamp(1, 30);
      _doConnectParent();
    });
  }

  void disconnect() {
    _disposed = true;
    _lineSub?.cancel();
    _parentLineSub?.cancel();
    _reconnect?.cancel();
    _parentReconnect?.cancel();
    _webPoll?.cancel();
    _token = '';
  }
}
