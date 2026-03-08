import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tutor_providers.dart';
import '../providers/tutor_repository_provider.dart';

class NovaChatScreen extends ConsumerStatefulWidget {
  const NovaChatScreen({
    super.key,
    this.sessionId,
    this.initialPrompt,
    this.initialTitle,
  });

  final String? sessionId;
  final String? initialPrompt;
  final String? initialTitle;

  @override
  ConsumerState<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends ConsumerState<NovaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<_Msg> _messages = <_Msg>[];

  StreamSubscription<Map<String, dynamic>>? _sseSub;
  String? _sessionId;
  bool _sending = false;
  bool _loadingHistory = false;
  bool _bootedInitialPrompt = false;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.sessionId;
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    _controller.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (_sessionId != null && _sessionId!.isNotEmpty) {
      await _loadExistingSession(_sessionId!);
    } else if (_messages.isEmpty) {
      setState(() {
        _messages.add(
          _Msg(
            role: 'assistant',
            content:
                'Hi. I’m NOVA.\n\nAsk anything and I’ll help step by step.',
          ),
        );
      });
    }

    final seed = (widget.initialPrompt ?? '').trim();
    if (!_bootedInitialPrompt && seed.isNotEmpty) {
      _bootedInitialPrompt = true;
      _controller.text = seed;
      await _onSend();
    }
  }

  Future<void> _loadExistingSession(String sessionId) async {
    final repo = ref.read(tutorRepositoryProvider);

    setState(() {
      _loadingHistory = true;
    });

    try {
      final json = await repo.fetchSessionById(sessionId);

      final rawMessages = () {
        final direct = json['messages'];
        if (direct is List) {
          return direct;
        }

        final session = json['session'];
        if (session is Map<String, dynamic> && session['messages'] is List) {
          return session['messages'] as List<dynamic>;
        }

        return <dynamic>[];
      }();

      final next = <_Msg>[];
      for (final item in rawMessages) {
        if (item is! Map) {
          continue;
        }
        final map = item.map((k, v) => MapEntry(k.toString(), v));
        final roleRaw = (map['role'] ?? '').toString().toUpperCase();
        final role = roleRaw == 'USER' ? 'user' : 'assistant';
        final content = (map['content'] ?? '').toString();
        if (content.trim().isEmpty) {
          continue;
        }
        next.add(_Msg(role: role, content: content));
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _sessionId = sessionId;
        _messages
          ..clear()
          ..addAll(
            next.isEmpty
                ? <_Msg>[
                    _Msg(
                      role: 'assistant',
                      content:
                          'This chat is empty for now.\n\nSend a message to start.',
                    ),
                  ]
                : next,
          );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(jump: true);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages
          ..clear()
          ..add(
            _Msg(
              role: 'assistant',
              content: '⚠️ Failed to load chat history: $e',
            ),
          );
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingHistory = false;
        });
      }
    }
  }

  Future<void> _ensureSession() async {
    if (_sessionId != null && _sessionId!.trim().isNotEmpty) {
      return;
    }

    final repo = ref.read(tutorRepositoryProvider);
    final created = await repo.createSession();
    final session = (created['session'] is Map<String, dynamic>)
        ? created['session'] as Map<String, dynamic>
        : created;
    final id = (session['id'] ?? '').toString();

    if (id.trim().isEmpty) {
      throw Exception('Missing session id');
    }

    _sessionId = id;
    ref.invalidate(tutorSessionsProvider);
  }

  Future<void> _onSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }

    setState(() {
      _messages.add(_Msg(role: 'user', content: text));
      _controller.clear();
      _sending = true;
    });
    _scrollToBottom();

    try {
      await _ensureSession();
      final sessionId = _sessionId!;
      final repo = ref.read(tutorRepositoryProvider);

      await repo.postMessage(sessionId: sessionId, text: text);

      final assistantIndex = _messages.length;
      setState(() {
        _messages.add(_Msg(role: 'assistant', content: 'Thinking…'));
      });

      await _sseSub?.cancel();
      final buffer = StringBuffer();

      _sseSub = repo
          .replyStream(sessionId: sessionId)
          .listen(
            (ev) {
              final type = (ev['type'] ?? '').toString();

              if (type == 'chunk') {
                final delta = (ev['delta'] ?? '').toString();
                if (delta.isNotEmpty) {
                  buffer.write(delta);
                }

                if (!mounted) {
                  return;
                }

                setState(() {
                  if (assistantIndex < _messages.length) {
                    _messages[assistantIndex] = _Msg(
                      role: 'assistant',
                      content: buffer.isEmpty ? 'Thinking…' : buffer.toString(),
                    );
                  }
                });
                _scrollToBottom();
                return;
              }

              if (type == 'done') {
                final am = ev['assistantMessage'];
                final content = (am is Map<String, dynamic>)
                    ? (am['content'] ?? buffer.toString()).toString()
                    : buffer.toString();

                if (!mounted) {
                  return;
                }

                setState(() {
                  if (assistantIndex < _messages.length) {
                    _messages[assistantIndex] = _Msg(
                      role: 'assistant',
                      content: content.trim().isEmpty ? 'Done.' : content,
                    );
                  }
                  _sending = false;
                });

                ref.invalidate(tutorSessionsProvider);
                _scrollToBottom();
              }
            },
            onError: (e) {
              if (!mounted) {
                return;
              }

              setState(() {
                if (assistantIndex < _messages.length) {
                  _messages[assistantIndex] = _Msg(
                    role: 'assistant',
                    content: '⚠️ Reply failed: $e',
                  );
                }
                _sending = false;
              });
            },
            onDone: () {
              if (!mounted) {
                return;
              }
              setState(() {
                _sending = false;
              });
            },
          );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          _Msg(role: 'assistant', content: '⚠️ Failed to send: $e'),
        );
        _sending = false;
      });
    }
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }
      final target = _scroll.position.maxScrollExtent + 120;
      if (jump) {
        _scroll.jumpTo(target);
      } else {
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<_NovaBlock> _blocksFor(String text) {
    final parts = text.split('```');
    final blocks = <_NovaBlock>[];

    for (var i = 0; i < parts.length; i++) {
      final raw = parts[i];
      if (raw.trim().isEmpty) {
        continue;
      }

      if (i.isEven) {
        blocks.add(_NovaBlock(_NovaBlockKind.text, raw.trimRight()));
      } else {
        final lines = raw.split('\n');
        final maybeLang = lines.isNotEmpty ? lines.first.trim() : '';
        final body = lines.length > 1 ? lines.skip(1).join('\n') : raw;
        final code = maybeLang.contains(' ') ? raw : body;
        blocks.add(_NovaBlock(_NovaBlockKind.code, code.trimRight()));
      }
    }

    if (blocks.isEmpty) {
      blocks.add(_NovaBlock(_NovaBlockKind.text, text));
    }

    return blocks;
  }

  Widget _buildAssistantMessage(BuildContext context, String content) {
    final blocks = _blocksFor(content);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 12),
              child: _NovaAvatar(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'NOVA',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.35,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                  for (int i = 0; i < blocks.length; i++) ...[
                    if (blocks[i].kind == _NovaBlockKind.code)
                      _CodeBlock(code: blocks[i].text)
                    else
                      SelectableText(
                        blocks[i].text.trimRight(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.62,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    if (i != blocks.length - 1) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context, String content) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.28),
            ),
          ),
          child: SelectableText(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ),
    );
  }

  String get _screenTitle {
    final raw = (widget.initialTitle ?? '').trim();
    if (raw.isNotEmpty) {
      return raw;
    }
    return 'NOVA chat';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_screenTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              _sessionId == null ? 'New conversation' : 'Saved in history',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _createAnotherChatFromHere,
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'New chat',
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              Colors.transparent,
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _loadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 150),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final m = _messages[index];
                        final isUser = m.role == 'user';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 26),
                          child: isUser
                              ? _buildUserMessage(context, m.content)
                              : _buildAssistantMessage(context, m.content),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.10),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: KeyboardListener(
                              focusNode: _focusNode,
                              onKeyEvent: (event) {
                                if (event is KeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.enter &&
                                    !HardwareKeyboard.instance.isShiftPressed) {
                                  _onSend();
                                }
                              },
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 8,
                                textInputAction: TextInputAction.newline,
                                decoration: const InputDecoration(
                                  hintText: 'Message NOVA…',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: _sending ? null : _onSend,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(50, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _sending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_upward_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAnotherChatFromHere() async {
    final repo = ref.read(tutorRepositoryProvider);

    try {
      final created = await repo.createSession();
      final session = (created['session'] is Map<String, dynamic>)
          ? created['session'] as Map<String, dynamic>
          : created;
      final id = (session['id'] ?? '').toString();

      ref.invalidate(tutorSessionsProvider);

      if (!mounted || id.isEmpty) {
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              NovaChatScreen(sessionId: id, initialTitle: 'New chat'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create chat: $e')));
    }
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: SelectableText(
        code.trimRight(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          height: 1.5,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _NovaAvatar extends StatelessWidget {
  const _NovaAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.95),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'N',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

enum _NovaBlockKind { text, code }

class _NovaBlock {
  const _NovaBlock(this.kind, this.text);

  final _NovaBlockKind kind;
  final String text;
}

class _Msg {
  _Msg({required this.role, required this.content});

  final String role;
  final String content;
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: .3, end: 1.0).animate(_c),
      child: const Text("NOVA is thinking..."),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}
