import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/sse_client.dart';
import 'chatgpt_chat_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';

class NovaChatScreen extends StatefulWidget {
  const NovaChatScreen({super.key});

  @override
  State<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends State<NovaChatScreen> {
  void _log(String msg) {}
  static const String _devToken = String.fromEnvironment(
    'CM_DEV_TOKEN',
    defaultValue: '',
  );

  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final SseClient _sse = SseClient();

  final List<_Msg> _messages = <_Msg>[
    _Msg(role: 'assistant', content: 'Hi! I’m NOVA inside ClassMate.'),
  ];

  bool _sending = false;
  String? _sessionId;
  StreamSubscription<Map<String, dynamic>>? _sseSub;

  Uri _u(String path) => Uri.parse('${Env.apiBaseUrl}$path');

  Future<String> _getToken() async => _devToken.trim();

  // TODO: wire to Settings screen (per-user) like GPT custom instructions.
  String _novaSettings() {
    return [
      'tone: friendly',
      'verbosity: concise',
      'quizFrequency: low',
      'humor: light',
      'addressUserByName: firstNameOnly',
      'neverCallUserTony: true',
    ].join('\n');
  }

  @override
  void initState() {
    super.initState();
    unawaited(_ensureSession());
  }

  Future<void> _ensureSession() async {
    if (_sessionId != null && _sessionId!.isNotEmpty) return;

    try {
      final token0 = (await _getToken()).trim();
      final token = (token0 == 'SIM_TOKEN') ? '' : token0;
      final req = await HttpClient().postUrl(_u('/api/tutor/sessions'));
      req.headers.set('Accept', 'application/json');
      req.headers.set('Content-Type', 'application/json');
      if (token.isNotEmpty) {
        /* removed empty bearer */
      } else {
        req.headers.set('x-dev-role', 'STUDENT');
        req.headers.set('x-dev-user-id', 'dev-student');
        req.headers.set('x-dev-grade', '10');
        req.headers.set('x-dev-school-id', 'test-school');

        // NOVA customization headers (optional)        // ignore: avoid_print
        // ignore: avoid_print
        // ignore: avoid_print
      }

      // backend accepts empty body
      req.add(const <int>[]);

      final res = await req.close();
      _log('http response received');
      final body = await res.transform(const Utf8Decoder()).join();
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('createSession HTTP ${res.statusCode}: $body');
      }

      final decoded = jsonDecode(body);
      final sid = (decoded is Map<String, dynamic>)
          ? ((decoded['session']?['id'] ?? decoded['id'] ?? '') as String)
          : '';

      if (sid.isEmpty) throw Exception('Missing session id');
      if (!mounted) return;
      setState(() => _sessionId = sid);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _Msg(role: 'assistant', content: '⚠️ Failed to start session: $e'),
        );
      });
    }
  }

  Future<void> _resetSession() async {
    await _sseSub?.cancel();
    _sseSub = null;
    if (!mounted) return;
    setState(() {
      _sessionId = null;
      _sending = false;
      _messages.clear();
      _messages.add(
        _Msg(role: 'assistant', content: 'Hi! I’m NOVA inside ClassMate.'),
      );
    });
    await _ensureSession();
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 250,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onSend() async {
    final dn = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(authSessionProvider).displayName;

    final t = _controller.text.trim();
    // ignore: prefer_interpolation_to_compose_strings
    _log('send: $t');
    if (t.isEmpty) return;

    setState(() {
      _messages.add(_Msg(role: 'user', content: t));
      _controller.clear();
      _sending = true;
    });
    _scrollToBottom();

    await _ensureSession();
    final sid = _sessionId;
    if (sid == null || sid.isEmpty) {
      if (!mounted) return;
      setState(() => _sending = false);
      return;
    }

    // Insert placeholder assistant message we will stream into.
    final assistantIndex = _messages.length;
    setState(() => _messages.add(_Msg(role: 'assistant', content: '')));
    _scrollToBottom();

    try {
      // 1) POST user message
      final token0 = (await _getToken()).trim();
      final token = (token0 == 'SIM_TOKEN') ? '' : token0;
      final req = await HttpClient().postUrl(
        _u('/api/tutor/sessions/$sid/messages'),
      );
      req.headers.set('Accept', 'application/json');
      req.headers.set('Content-Type', 'application/json');
      if (token.isNotEmpty) {
        /* removed empty bearer */
      } else {
        req.headers.set('x-dev-role', 'STUDENT');
        req.headers.set('x-dev-user-id', 'dev-student');
        req.headers.set('x-dev-grade', '10');
        req.headers.set('x-dev-school-id', 'test-school');

        // NOVA customization headers (optional)        // ignore: avoid_print
        // ignore: avoid_print
        // ignore: avoid_print
      }
      req.add(
        utf8.encode(
          jsonEncode(<String, dynamic>{
            'role': 'USER',
            'content': t,
            'displayName': dn,
            'novaSettings': _novaSettings(),
          }),
        ),
      );

      final res = await req.close();
      final body = await res.transform(const Utf8Decoder()).join();
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('postMessage HTTP ${res.statusCode}: $body');
      }

      // 2) SSE reply stream

      await _sseSub?.cancel();
      _sseSub = null;

      final stream = _sse.connect(
        _u(
          '/api/tutor/sessions/$sid/reply/stream?displayName=${Uri.encodeQueryComponent(dn)}&novaSettings=${Uri.encodeQueryComponent(_novaSettings())}',
        ),
        getToken: _getToken,
      );

      final buf = StringBuffer();

      _sseSub = stream.listen(
        (ev) {
          final type = (ev['type'] ?? '').toString();

          if (type == 'chunk') {
            final delta = (ev['delta'] ?? '').toString();
            if (delta.isNotEmpty) buf.write(delta);

            if (!mounted) return;
            setState(() {
              if (assistantIndex < _messages.length) {
                _messages[assistantIndex] = _Msg(
                  role: 'assistant',
                  content: buf.toString(),
                );
              }
            });
            _scrollToBottom();
            return;
          }

          if (type == 'done') {
            final am = ev['assistantMessage'];
            final content = (am is Map<String, dynamic>)
                ? (am['content'] ?? buf.toString()).toString()
                : buf.toString();

            if (!mounted) return;
            setState(() {
              if (assistantIndex < _messages.length) {
                _messages[assistantIndex] = _Msg(
                  role: 'assistant',
                  content: content,
                );
              }
              _sending = false;
            });
            _scrollToBottom();
          }
        },
        onError: (e) {
          if (!mounted) return;
          setState(() {
            if (assistantIndex < _messages.length) {
              _messages[assistantIndex] = _Msg(
                role: 'assistant',
                content: '⚠️ Stream error: $e',
              );
            } else {
              _messages.add(
                _Msg(role: 'assistant', content: '⚠️ Stream error: $e'),
              );
            }
            _sending = false;
          });
          _scrollToBottom();
        },
        onDone: () {
          if (!mounted) return;
          setState(() => _sending = false);
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (assistantIndex < _messages.length) {
          _messages[assistantIndex] = _Msg(role: 'assistant', content: '⚠️ $e');
        } else {
          _messages.add(_Msg(role: 'assistant', content: '⚠️ $e'));
        }
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    _controller.dispose();
    _scroll.dispose();
    _sse.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatGptLayout(
      title: 'NOVA',
      trailing: IconButton(
        icon: const Icon(Icons.refresh_rounded),
        onPressed: _resetSession,
      ),
      body: ChatGptMessageList(
        controller: _scroll,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final m = _messages[index];
          final isUser = m.role == 'user';
          return ChatGptBubble(isUser: isUser, text: m.content);
        },
      ),
      composer: ChatGptComposer(
        controller: _controller,
        onSend: () => unawaited(_onSend()),
        isSending: _sending,
      ),
    );
  }
}

class _Msg {
  _Msg({required this.role, required this.content});
  final String role;
  final String content;
}
