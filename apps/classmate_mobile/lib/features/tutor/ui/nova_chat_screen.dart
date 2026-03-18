import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../insights/providers/insights_providers.dart';
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

  String get _headerTitle {
    final title = (widget.initialTitle ?? '').trim();
    return title.isEmpty ? 'NOVA' : title;
  }

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
          const _Msg(
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
        if (direct is List) return direct;

        final session = json['session'];
        if (session is Map<String, dynamic> && session['messages'] is List) {
          return session['messages'] as List<dynamic>;
        }

        return <dynamic>[];
      }();

      final next = <_Msg>[];
      for (final item in rawMessages) {
        if (item is! Map) continue;
        final map = item.map((k, v) => MapEntry(k.toString(), v));
        final roleRaw = (map['role'] ?? '').toString().toUpperCase();
        final role = roleRaw == 'USER' ? 'user' : 'assistant';
        final content = (map['content'] ?? '').toString();
        if (content.trim().isEmpty) continue;
        next.add(_Msg(role: role, content: content));
      }

      if (!mounted) return;

      setState(() {
        _sessionId = sessionId;
        _messages
          ..clear()
          ..addAll(
            next.isEmpty
                ? const <_Msg>[
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
      if (!mounted) return;

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
    if (_sessionId != null && _sessionId!.trim().isNotEmpty) return;

    final repo = ref.read(tutorRepositoryProvider);
    final created = await repo.createSession(
      title: _headerTitle == 'NOVA' ? null : _headerTitle,
    );
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
    if (text.isEmpty || _sending) return;

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
        _messages.add(const _Msg(role: 'assistant', content: 'Thinking…'));
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
                if (delta.isNotEmpty) buffer.write(delta);

                if (!mounted) return;

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

                if (!mounted) return;

                setState(() {
                  if (assistantIndex < _messages.length) {
                    _messages[assistantIndex] = _Msg(
                      role: 'assistant',
                      content: content.trim().isEmpty ? 'Done.' : content,
                    );
                  }
                  _sending = false;
                });
                _scrollToBottom();
                ref.invalidate(tutorSessionsProvider);
                return;
              }

              if (type == 'error') {
                if (!mounted) return;

                setState(() {
                  if (assistantIndex < _messages.length) {
                    _messages[assistantIndex] = _Msg(
                      role: 'assistant',
                      content:
                          '⚠️ ${(ev['message'] ?? 'Failed to stream reply').toString()}',
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
                _messages.add(
                  _Msg(role: 'assistant', content: '⚠️ Stream failed: $e'),
                );
                _sending = false;
              });
              _scrollToBottom();
            },
            onDone: () {
              if (!mounted) return;
              if (_sending) {
                setState(() {
                  _sending = false;
                });
              }
            },
          );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _Msg(role: 'assistant', content: '⚠️ Failed to send: $e'),
        );
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    if (_sending) return;

    setState(() {
      _messages.add(
        const _Msg(
          role: 'assistant',
          content:
              'Photo input UI is ready. Backend image understanding is the next wired step.',
        ),
      );
    });
    _scrollToBottom();
  }

  Future<void> _recordVoice() async {
    if (_sending) return;

    setState(() {
      _messages.add(
        const _Msg(
          role: 'assistant',
          content:
              'Voice message UI is ready. Recorder/transcription wiring is the next step.',
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final pos = _scroll.position.maxScrollExtent;
      if (jump) {
        _scroll.jumpTo(pos);
      } else {
        _scroll.animateTo(
          pos,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _academicBadge() {
    final async = ref.watch(unifiedStudentInsightsProvider);

    return async.maybeWhen(
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        final bits = <String>[
          if (data.practice.weakTopics.isNotEmpty)
            'Focus: ${data.practice.weakTopics.first.topicLabel}',
          if ((data.grades.weakestSubject ?? '').trim().isNotEmpty)
            'Weakest subject: ${data.grades.weakestSubject}',
          if (data.attendance.attendanceRate != null)
            'Attendance ${data.attendance.attendanceRate!.toStringAsFixed(1)}%',
        ];

        if (bits.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.65),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology_alt_rounded, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NOVA knows your performance • ${bits.join(' • ')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _starterChips() {
    final async = ref.watch(unifiedStudentInsightsProvider);

    return async.maybeWhen(
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        final chips = <String>[
          if (data.practice.weakTopics.isNotEmpty)
            'Help me with ${data.practice.weakTopics.first.topicLabel}',
          if ((data.grades.weakestSubject ?? '').trim().isNotEmpty)
            'Why am I weak in ${data.grades.weakestSubject}?',
          if (data.practice.trend?.deltaAccuracy != null)
            'Analyze my last 7d vs 30d progress',
          if ((data.grades.bestSubject ?? '').trim().isNotEmpty)
            'Push me harder in ${data.grades.bestSubject}',
        ];

        final uniq = <String>[];
        for (final chip in chips) {
          if (chip.trim().isEmpty) continue;
          if (!uniq.contains(chip)) uniq.add(chip);
        }

        if (uniq.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chip in uniq.take(4))
                ActionChip(
                  label: Text(chip),
                  onPressed: _sending
                      ? null
                      : () async {
                          _controller.text = chip;
                          await _onSend();
                        },
                ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildBubble(_Msg msg) {
    final isUser = msg.role == 'user';
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? cs.primaryContainer.withValues(alpha: 0.90)
              : cs.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
        ),
        child: SelectableText(
          msg.content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
          ),
          padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 6,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _onSend(),
                  decoration: const InputDecoration(
                    hintText: 'Ask NOVA anything…',
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              IconButton(
                onPressed: _sending ? null : _pickImage,
                icon: const Icon(Icons.photo_outlined),
              ),
              IconButton(
                onPressed: _sending ? null : _recordVoice,
                icon: const Icon(Icons.mic_none_rounded),
              ),
              IconButton(
                onPressed: _sending ? null : _onSend,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_headerTitle),
            Text(
              _sending ? 'Thinking…' : 'Ready',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          if (_sessionId != null && _sessionId!.isNotEmpty)
            IconButton(
              tooltip: 'Copy session id',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _sessionId!));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session id copied')),
                );
              },
              icon: const Icon(Icons.link_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          _academicBadge(),
          _starterChips(),
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildBubble(_messages[index]);
                    },
                  ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }
}

class _Msg {
  const _Msg({required this.role, required this.content});

  final String role;
  final String content;
}
