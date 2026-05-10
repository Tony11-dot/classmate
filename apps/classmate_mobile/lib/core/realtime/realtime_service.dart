import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';

/// Event types emitted by the server over SSE.
class RealtimeEvent {
  const RealtimeEvent({required this.type, this.classroomId, this.threadId, this.studentId});
  final String type;
  final String? classroomId;
  final String? threadId;
  final String? studentId;

  factory RealtimeEvent.fromJson(Map<String, dynamic> j) => RealtimeEvent(
    type: (j['type'] ?? '').toString(),
    classroomId: j['classroomId']?.toString(),
    threadId: j['threadId']?.toString(),
    studentId: j['studentId']?.toString(),
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
  int _retryDelay = 3;

  void connect(String token) {
    _token = token;
    _disposed = false;
    _retryDelay = 3;
    _doConnect();
  }

  void _doConnect() {
    if (_disposed || _token.isEmpty) return;
    _lineSub?.cancel();

    final base = Env.apiBaseUrl
        .replaceAll(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/realtime/stream');

    final client = http.Client();
    final request = http.Request('GET', uri)
      ..headers['Authorization'] = 'Bearer $_token'
      ..headers['Accept'] = 'text/event-stream'
      ..headers['Cache-Control'] = 'no-cache';

    client.send(request).then((response) {
      if (_disposed) { client.close(); return; }
      if (response.statusCode != 200) { client.close(); _scheduleReconnect(); return; }
      _retryDelay = 3;

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
      _retryDelay = (_retryDelay * 2).clamp(3, 60);
      _doConnect();
    });
  }

  void disconnect() {
    _disposed = true;
    _lineSub?.cancel();
    _reconnect?.cancel();
    _token = '';
  }
}
