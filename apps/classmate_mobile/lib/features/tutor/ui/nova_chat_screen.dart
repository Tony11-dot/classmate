import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tutor_repository_provider.dart';
import '../providers/tutor_providers.dart';

class NovaChatScreen extends ConsumerStatefulWidget {
  const NovaChatScreen({
    super.key,
    required this.sessionId,
    required this.characterName,
    required this.subject,
  });

  final String sessionId;
  final String characterName;
  final String subject;

  @override
  ConsumerState<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends ConsumerState<NovaChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  late String _sessionId;
  late String _characterName;
  late String _subject;

  bool _sending = false;

  final List<_Msg> _msgs = [];

  @override
  void initState() {
    super.initState();
    _sessionId = widget.sessionId;
    _characterName = widget.characterName;
    _subject = widget.subject;

    // starter message (until Phase 2 wires real messages+reply)
    _msgs.add(
      _Msg.assistant(
        "You're chatting with $_characterName.\n(Session: $_sessionId)",
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _switchTutor() async {
    final subject = await _pickSubject();
    if (subject == null) return;

    final pick = await _pickCharacter(subject);
    if (pick == null) return;

    final repo = ref.read(tutorRepositoryProvider);

    setState(() => _sending = true);
    try {
      final res = await repo.createSession(
        characterId: pick.id,
        subject: subject == 'ALL' ? null : subject,
      );
      final newSessionId = (res['session']?['id'] ?? res['id'] ?? '') as String;
      if (newSessionId.isEmpty) throw Exception('Missing session id');

      // refresh chats list in background
      ref.invalidate(tutorSessionsProvider);

      setState(() {
        _sessionId = newSessionId;
        _characterName = pick.name;
        _subject = subject == 'ALL' ? 'GENERAL' : subject;
        _msgs.clear();
        _msgs.add(
          _Msg.assistant(
            "Switched to $_characterName.\n(New session: $_sessionId)",
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Switch failed: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _controller.clear();
      _msgs.add(_Msg.user(text));
      _sending = true;
    });

    // Phase 2 will call /api/tutor/sessions/:id/messages and /reply
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _msgs.add(_Msg.assistant("Phase 2 pending.\nYou said: \"$text\""));
      _sending = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_characterName),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: _Chip(text: _subject),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Switch tutor',
            onPressed: _sending ? null : _switchTutor,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemCount: _msgs.length,
              itemBuilder: (context, i) {
                final m = _msgs[i];
                final isUser = m.role == _Role.user;
                final bubble = isUser ? cs.primary : cs.surfaceContainerHighest;
                final textColor = isUser ? cs.onPrimary : cs.onSurface;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: const BoxConstraints(maxWidth: 560),
                    decoration: BoxDecoration(
                      color: bubble,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(color: textColor, height: 1.25),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 6,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Message NOVA…',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    width: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _sending ? null : _send,
                      child: _sending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_upward),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _pickSubject() async {
    final subjects = await ref
        .read(tutorStudentSubjectsProvider.future)
        .catchError((_) => <dynamic>[]);

    final set = <String>{};
    for (final x in subjects) {
      if (x is String) {
        set.add(x.toUpperCase());
      } else if (x is Map) {
        final v = (x['code'] ?? x['subject'] ?? x['name'] ?? x['id']);
        if (v is String && v.trim().isNotEmpty) set.add(v.toUpperCase());
      }
    }

    final items = <String>[
      'ALL',
      if (set.isEmpty) ...<String>[
        'GENERAL',
        'MATH',
        'PHYSICS',
        'CS',
        'ENGLISH',
      ] else
        ...set.toList()..sort(),
    ];

    return showModalBottomSheet<String>(
      // ignore: use_build_context_synchronously
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Switch tutor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('Pick a subject'),
              ),
              for (final s in items)
                ListTile(
                  title: Text(s),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(s),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<_CharPick?> _pickCharacter(String subject) async {
    List<dynamic> all = <dynamic>[];

    if (subject == 'ALL') {
      final subs = <String>['GENERAL', 'MATH', 'PHYSICS', 'CS', 'ENGLISH'];
      for (final s in subs) {
        final list = await ref
            .read(tutorCharactersProvider(s).future)
            .catchError((_) => <dynamic>[]);
        all.addAll(list);
      }
    } else {
      all = await ref
          .read(tutorCharactersProvider(subject).future)
          .catchError((_) => <dynamic>[]);
      if (all.isEmpty && subject != 'GENERAL') {
        final g = await ref
            .read(tutorCharactersProvider('GENERAL').future)
            .catchError((_) => <dynamic>[]);
        all = g;
      }
    }

    final seen = <String>{};
    final chars = <_CharPick>[];
    for (final x in all) {
      if (x is! Map) continue;
      final m = x.cast<String, dynamic>();
      final id = (m['id'] ?? '') as String;
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);

      final name = ((m['name'] ?? 'Tutor') as String);
      final sub = ((m['subject'] ?? 'GENERAL') as String);
      final tone = (m['tone'] as String?)?.trim();
      final style = (m['explainStyle'] as String?)?.trim();

      chars.add(
        _CharPick(
          id: id,
          name: name,
          subtitle: [
            sub,
            if (tone != null && tone.isNotEmpty) tone,
            if (style != null && style.isNotEmpty) style,
          ].join(' • '),
        ),
      );
    }

    if (chars.isEmpty) return null;

    // small shuffle so it doesn't feel “topic UI” deterministic
    chars.shuffle(Random());

    return showModalBottomSheet<_CharPick>(
      // ignore: use_build_context_synchronously
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Pick a tutor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              for (final c in chars)
                ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(c),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum _Role { user, assistant }

class _Msg {
  const _Msg(this.role, this.text);
  final _Role role;
  final String text;

  static _Msg user(String t) => _Msg(_Role.user, t);
  static _Msg assistant(String t) => _Msg(_Role.assistant, t);
}

class _CharPick {
  const _CharPick({
    required this.id,
    required this.name,
    required this.subtitle,
  });
  final String id;
  final String name;
  final String subtitle;
}
