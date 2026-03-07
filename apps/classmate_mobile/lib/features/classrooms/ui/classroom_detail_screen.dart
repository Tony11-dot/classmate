import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/auth_session.dart';
import '../providers/classrooms_providers.dart';
import '../providers/classrooms_repo_provider.dart';

class ClassroomDetailScreen extends ConsumerStatefulWidget {
  const ClassroomDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<ClassroomDetailScreen> createState() =>
      _ClassroomDetailScreenState();
}

String _classroomSeenKey(String courseId) => 'classroom_last_seen_$courseId';

class _ClassroomDetailScreenState extends ConsumerState<ClassroomDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);
  final TextEditingController _chatCtl = TextEditingController();
  final ScrollController _chatScrollCtl = ScrollController();

  bool _sending = false;

  void _goBackToClassrooms() {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/classrooms');
    }
  }

  Future<void> _markChatSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _classroomSeenKey(widget.courseId),
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  bool _typing = false;
  String? _replyToMessageId;
  String? _replyToSender;
  String? _replyToText;

  int _lastChatCount = -1;

  Map<String, String> _reactionByMessage = <String, String>{};
  Map<String, String> _editedTextByMessage = <String, String>{};
  Set<String> _deletedMessageIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(_markChatSeen);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging && _tabs.index == 0) {
        Future.microtask(_markChatSeen);
      }
    });
    _chatCtl.addListener(_onComposerChanged);
    _loadLocalChatState();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _chatCtl.removeListener(_onComposerChanged);
    _chatCtl.dispose();
    _chatScrollCtl.dispose();
    super.dispose();
  }

  void _onComposerChanged() {
    final next = _chatCtl.text.trim().isNotEmpty;
    if (next != _typing && mounted) {
      setState(() => _typing = next);
    }
  }

  String _key(String suffix) => 'classroom_chat:${widget.courseId}:$suffix';

  Future<void> _loadLocalChatState() async {
    final prefs = await SharedPreferences.getInstance();

    final reactionsRaw = prefs.getString(_key('reactions'));
    final editsRaw = prefs.getString(_key('edits'));
    final deletedRaw = prefs.getString(_key('deleted'));

    Map<String, String> reactions = <String, String>{};
    Map<String, String> edits = <String, String>{};
    Set<String> deleted = <String>{};

    if (reactionsRaw != null && reactionsRaw.trim().isNotEmpty) {
      final decoded = jsonDecode(reactionsRaw);
      if (decoded is Map) {
        reactions = decoded.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    }

    if (editsRaw != null && editsRaw.trim().isNotEmpty) {
      final decoded = jsonDecode(editsRaw);
      if (decoded is Map) {
        edits = decoded.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    }

    if (deletedRaw != null && deletedRaw.trim().isNotEmpty) {
      final decoded = jsonDecode(deletedRaw);
      if (decoded is List) {
        deleted = decoded.map((e) => e.toString()).toSet();
      }
    }

    if (!mounted) return;
    setState(() {
      _reactionByMessage = reactions;
      _editedTextByMessage = edits;
      _deletedMessageIds = deleted;
    });
  }

  Future<void> _persistLocalChatState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key('reactions'), jsonEncode(_reactionByMessage));
    await prefs.setString(_key('edits'), jsonEncode(_editedTextByMessage));
    await prefs.setString(
      _key('deleted'),
      jsonEncode(_deletedMessageIds.toList()..sort()),
    );
  }

  void _refreshAll() {
    ref.invalidate(classroomDetailProvider(widget.courseId));
    ref.invalidate(classroomPeopleProvider(widget.courseId));
    ref.invalidate(
      classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
    );
    ref.invalidate(classroomAssignmentsProvider(widget.courseId));
    ref.invalidate(classroomMaterialsProvider(widget.courseId));
    ref.invalidate(classroomMeetingsProvider(widget.courseId));
  }

  Future<void> _sendChat() async {
    final value = _chatCtl.text.trim();
    if (value.isEmpty || _sending) return;

    final senderPrefix = (_replyToSender ?? '').trim();
    final replyPrefix = (_replyToText ?? '').trim();
    final outbound = _replyToMessageId == null
        ? value
        : '↪ ${senderPrefix.isEmpty ? 'Reply' : senderPrefix}: '
              '${replyPrefix.isEmpty ? '' : '$replyPrefix — '}$value';

    setState(() => _sending = true);
    try {
      final repo = ref.read(classroomsRepoProvider);
      await repo.sendChatText(widget.courseId, outbound);
      _chatCtl.clear();
      _clearReply();
      await _markChatSeen();
      ref.invalidate(
        classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(jump: false);
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _scrollToBottom({required bool jump}) {
    if (!mounted) return;
    if (!_chatScrollCtl.hasClients) return;
    if (_chatScrollCtl.positions.length != 1) return;

    final target = _chatScrollCtl.position.maxScrollExtent;
    if (jump) {
      _chatScrollCtl.jumpTo(target);
      return;
    }

    _chatScrollCtl.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _clearReply() {
    if (!mounted) return;
    setState(() {
      _replyToMessageId = null;
      _replyToSender = null;
      _replyToText = null;
    });
  }

  Future<void> _setReaction(String messageId, String emoji) async {
    setState(() {
      if (_reactionByMessage[messageId] == emoji) {
        _reactionByMessage.remove(messageId);
      } else {
        _reactionByMessage[messageId] = emoji;
      }
    });
    await _persistLocalChatState();
  }

  Future<void> _deleteMessage(String messageId) async {
    setState(() {
      _deletedMessageIds.add(messageId);
      _reactionByMessage.remove(messageId);
      _editedTextByMessage.remove(messageId);
    });
    await _persistLocalChatState();
  }

  Future<void> _editMessage(
    BuildContext context, {
    required String messageId,
    required String currentText,
  }) async {
    final ctl = TextEditingController(text: currentText);
    final next = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
                autofocus: true,
                minLines: 2,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Edit your message...',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _goBackToClassrooms,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    label: const Text('Back'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(ctl.text.trim()),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (next == null || next.trim().isEmpty) return;

    setState(() {
      _editedTextByMessage[messageId] = next.trim();
    });
    await _persistLocalChatState();
  }

  void _replyTo({
    required String messageId,
    required String sender,
    required String text,
  }) {
    setState(() {
      _replyToMessageId = messageId;
      _replyToSender = sender;
      _replyToText = text;
    });
  }

  Future<void> _openBubbleMenu(
    BuildContext context, {
    required String messageId,
    required String text,
    required String senderLabel,
    required bool isMine,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final reaction = _reactionByMessage[messageId];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final emoji in const ['👍', '❤️', '🔥'])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () async {
                            Navigator.of(context).pop();
                            await _setReaction(messageId, emoji);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: reaction == emoji
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.reply_rounded),
                  title: const Text('Reply'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _replyTo(
                      messageId: messageId,
                      sender: senderLabel,
                      text: text,
                    );
                  },
                ),
                if (isMine)
                  ListTile(
                    leading: const Icon(Icons.edit_rounded),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _editMessage(
                        context,
                        messageId: messageId,
                        currentText: text,
                      );
                    },
                  ),
                if (isMine)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded),
                    title: const Text('Delete'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _deleteMessage(messageId);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _resolveMyUserId(Map<String, String> peopleMap) {
    final auth = ref.read(authSessionProvider);
    final displayName = auth.displayName.trim().toLowerCase();
    final rawToken = (auth.token ?? '').trim();

    final directUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );

    if (directUuid.hasMatch(rawToken)) {
      return rawToken;
    }

    final uuidInToken = RegExp(
      r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}',
    ).firstMatch(rawToken);
    if (uuidInToken != null) {
      return uuidInToken.group(0) ?? '';
    }

    if (displayName.isNotEmpty) {
      for (final entry in peopleMap.entries) {
        if (entry.value.trim().toLowerCase() == displayName) {
          return entry.key;
        }
      }
    }

    if (peopleMap.length == 1) {
      return peopleMap.keys.first;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(classroomDetailProvider(widget.courseId));
    final people = ref.watch(classroomPeopleProvider(widget.courseId));
    final chat = ref.watch(
      classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
    );
    final assignments = ref.watch(
      classroomAssignmentsProvider(widget.courseId),
    );
    final materials = ref.watch(classroomMaterialsProvider(widget.courseId));
    final meetings = ref.watch(classroomMeetingsProvider(widget.courseId));

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                detail.when(
                  loading: () => const _HeaderSkeleton(),
                  error: (e, st) => _TopHeader(
                    icon: Icons.book_rounded,
                    subject: 'Classroom',
                    subtitle: widget.courseId,
                    onRefresh: _refreshAll,
                    onBack: _goBackToClassrooms,
                  ),
                  data: (m) => _TopHeader(
                    icon: _subjectIcon((m['subject'] ?? '').toString()),
                    subject:
                        ((m['name'] ?? '').toString().trim().isNotEmpty
                                ? (m['name'] ?? '').toString()
                                : (m['subject'] ?? 'Classroom').toString())
                            .trim(),
                    subtitle:
                        ((m['subject'] ?? '').toString().trim().isNotEmpty
                                ? (m['subject'] ?? '').toString()
                                : widget.courseId)
                            .trim(),
                    onRefresh: _refreshAll,
                    onBack: _goBackToClassrooms,
                  ),
                ),
                const SizedBox(height: 8),
                _CenteredTabs(controller: _tabs),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _chatTab(chat, people),
                      _listTab(
                        value: assignments,
                        emptyTitle: 'No assignments yet',
                        emptySubtitle:
                            'This classroom has no assignments right now.',
                        itemBuilder: (item) => _SimpleCard(
                          title: _pick(item, 'title', fallback: 'Assignment'),
                          subtitle: _pick(item, 'body'),
                          trailing: _friendlyDateTime(_pick(item, 'dueAt')),
                        ),
                      ),
                      _listTab(
                        value: materials,
                        emptyTitle: 'No materials yet',
                        emptySubtitle:
                            'This classroom has no materials right now.',
                        itemBuilder: (item) => _SimpleCard(
                          title: _pick(item, 'title', fallback: 'Material'),
                          subtitle: _pick(item, 'description'),
                          trailing: _pick(item, 'mime'),
                        ),
                      ),
                      _listTab(
                        value: meetings,
                        emptyTitle: 'No meetings yet',
                        emptySubtitle:
                            'This classroom has no meetings right now.',
                        itemBuilder: (item) => _SimpleCard(
                          title: _pick(item, 'title', fallback: 'Meeting'),
                          subtitle: _pick(item, 'link'),
                          trailing: _friendlyDateTime(_pick(item, 'startsAt')),
                        ),
                      ),
                      _peopleTab(people),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 28,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  final v = details.primaryVelocity ?? 0;
                  if (v.abs() > 220) {
                    _goBackToClassrooms();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _peopleTab(AsyncValue<Map<String, dynamic>> people) {
    return people.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _CenteredState(
        icon: Icons.group_outlined,
        title: 'Could not load people',
        subtitle: '$e',
      ),
      data: (m) {
        final raw = (m['items'] is List) ? (m['items'] as List) : const [];
        if (raw.isEmpty) {
          return const _CenteredState(
            icon: Icons.group_outlined,
            title: 'No people yet',
            subtitle: 'Nobody is visible in this classroom yet.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: raw.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = raw[index];
            final name = _pick(item, 'name', fallback: 'Student');
            final email = _pick(item, 'email');
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: _panelDecoration(context),
              child: Row(
                children: [
                  _InitialsAvatar(name: name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        if (email.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _listTab({
    required AsyncValue<Map<String, dynamic>> value,
    required String emptyTitle,
    required String emptySubtitle,
    required Widget Function(dynamic item) itemBuilder,
  }) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _CenteredState(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load tab',
        subtitle: '$e',
      ),
      data: (m) {
        final raw = (m['items'] is List) ? (m['items'] as List) : const [];
        if (raw.isEmpty) {
          return _CenteredState(
            icon: Icons.inbox_outlined,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: raw.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => itemBuilder(raw[index]),
        );
      },
    );
  }

  Widget _chatTab(
    AsyncValue<Map<String, dynamic>> value,
    AsyncValue<Map<String, dynamic>> people,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: value.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => _CenteredState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Could not load chat',
              subtitle: '$e',
            ),
            data: (m) {
              final rawItems = (m['items'] is List)
                  ? (m['items'] as List)
                  : const [];

              final filtered =
                  rawItems
                      .where(
                        (item) =>
                            !_deletedMessageIds.contains(_pick(item, 'id')),
                      )
                      .toList()
                    ..sort((a, b) {
                      final da =
                          DateTime.tryParse(_pick(a, 'createdAt')) ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      final db =
                          DateTime.tryParse(_pick(b, 'createdAt')) ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      return da.compareTo(db);
                    });

              final peopleMap = people.maybeWhen(
                data: (pm) {
                  final raw = (pm['items'] is List)
                      ? (pm['items'] as List)
                      : const [];
                  return <String, String>{
                    for (final x in raw) _pick(x, 'id'): _pick(x, 'name'),
                  };
                },
                orElse: () => const <String, String>{},
              );

              final myUserId = _resolveMyUserId(peopleMap);

              if (_lastChatCount != filtered.length) {
                _lastChatCount = filtered.length;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom(jump: filtered.length <= 3);
                });
              }

              if (filtered.isEmpty) {
                return const _CenteredState(
                  icon: Icons.forum_outlined,
                  title: 'No messages yet',
                  subtitle: 'Start the classroom conversation.',
                );
              }

              return ListView.builder(
                controller: _chatScrollCtl,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final previous = index > 0 ? filtered[index - 1] : null;

                  final messageId = _pick(item, 'id');
                  final senderId = _pick(item, 'senderUserId');
                  final senderName =
                      (peopleMap[senderId] ?? _shortSender(senderId)).trim();
                  final createdRaw = _pick(item, 'createdAt');
                  final createdAt = DateTime.tryParse(createdRaw)?.toLocal();
                  final reaction = _reactionByMessage[messageId];

                  final originalText = _pick(item, 'text', fallback: '(empty)');
                  final text = (_editedTextByMessage[messageId] ?? originalText)
                      .trim();

                  final isMine =
                      myUserId.isNotEmpty && senderId.trim() == myUserId;

                  final previousSender = previous == null
                      ? ''
                      : _pick(previous, 'senderUserId');
                  final previousTime = previous == null
                      ? null
                      : DateTime.tryParse(
                          _pick(previous, 'createdAt'),
                        )?.toLocal();

                  final groupedWithPrevious =
                      previous != null &&
                      previousSender == senderId &&
                      createdAt != null &&
                      previousTime != null &&
                      createdAt.difference(previousTime).inMinutes.abs() <= 4;

                  final showAvatar = !isMine && !groupedWithPrevious;
                  final showName = !isMine && !groupedWithPrevious;

                  final bubble = GestureDetector(
                    onLongPress: () => _openBubbleMenu(
                      context,
                      messageId: messageId,
                      text: text,
                      senderLabel: isMine ? 'You' : senderName,
                      isMine: isMine,
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.96, end: 1),
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Column(
                        crossAxisAlignment: isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 290),
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                            decoration: BoxDecoration(
                              color: isMine ? cs.primaryContainer : cs.surface,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(isMine ? 18 : 6),
                                bottomRight: Radius.circular(isMine ? 6 : 18),
                              ),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showName)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      senderName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ),
                                Text(
                                  text.isEmpty ? '(empty)' : text,
                                  style: TextStyle(
                                    height: 1.25,
                                    color: isMine
                                        ? cs.onPrimaryContainer
                                        : cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_editedTextByMessage.containsKey(
                                      messageId,
                                    )) ...[
                                      Text(
                                        'edited',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              (isMine
                                                      ? cs.onPrimaryContainer
                                                      : cs.onSurfaceVariant)
                                                  .withValues(alpha: 0.72),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      _friendlyTime(createdRaw),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            (isMine
                                                    ? cs.onPrimaryContainer
                                                    : cs.onSurfaceVariant)
                                                .withValues(alpha: 0.82),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (reaction != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: cs.outlineVariant.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Text(reaction),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );

                  return Padding(
                    padding: EdgeInsets.only(
                      top: groupedWithPrevious ? 4 : 10,
                      bottom: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: isMine
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMine)
                          SizedBox(
                            width: 34,
                            child: showAvatar
                                ? _InitialsAvatar(name: senderName)
                                : const SizedBox.shrink(),
                          ),
                        if (!isMine) const SizedBox(width: 8),
                        Flexible(child: bubble),
                        if (isMine) const SizedBox(width: 8),
                        if (isMine) const SizedBox(width: 34),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (_typing && !_sending)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Typing…',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        if (_replyToMessageId != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${_replyToSender ?? 'message'}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (_replyToText ?? '').trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _clearReply,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatCtl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendChat(),
                  decoration: const InputDecoration(
                    hintText: 'Message classroom...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _sending ? null : _sendChat,
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.icon,
    required this.subject,
    required this.subtitle,
    required this.onRefresh,
    required this.onBack,
  });

  final IconData icon;
  final String subject;
  final String subtitle;
  final VoidCallback onRefresh;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              label: const Text('Back'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.trim().isEmpty ? 'Classroom' : subject.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.trim().isEmpty ? ' ' : subtitle.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SizedBox(height: 84, child: Card()),
    );
  }
}

class _CenteredTabs extends StatelessWidget {
  const _CenteredTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          labelColor: cs.onPrimaryContainer,
          unselectedLabelColor: cs.onSurfaceVariant,
          splashBorderRadius: BorderRadius.circular(16),
          tabs: const [
            Tab(child: _TabChipLabel(text: 'Chat')),
            Tab(child: _TabChipLabel(text: 'Assignments')),
            Tab(child: _TabChipLabel(text: 'Materials')),
            Tab(child: _TabChipLabel(text: 'Meetings')),
            Tab(child: _TabChipLabel(text: 'People')),
          ],
        ),
      ),
    );
  }
}

class _TabChipLabel extends StatelessWidget {
  const _TabChipLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.trim().isEmpty ? 'Untitled' : title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ],
            ),
          ),
          if (trailing.trim().isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              trailing,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 40, color: cs.onSurfaceVariant),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final bg = _avatarColorForName(context, name);
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initialsForName(name),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

BoxDecoration _panelDecoration(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: cs.surface,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
  );
}

String _pick(dynamic item, String key, {String fallback = ''}) {
  if (item is Map) {
    final value = item[key];
    return (value ?? fallback).toString();
  }
  return fallback;
}

String _friendlyTime(String raw) {
  if (raw.trim().isEmpty) return '';
  final dt = DateTime.tryParse(raw)?.toLocal();
  if (dt == null) return raw;
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _friendlyDateTime(String raw) {
  if (raw.trim().isEmpty) return '';
  final dt = DateTime.tryParse(raw)?.toLocal();
  if (dt == null) return raw;
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

String _shortSender(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return 'Unknown';
  if (value.length <= 12) return value;
  return '${value.substring(0, 8)}…';
}

IconData _subjectIcon(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('math')) return Icons.calculate_rounded;
  if (s.contains('physics')) return Icons.science_rounded;
  if (s.contains('chem')) return Icons.biotech_rounded;
  if (s.contains('bio')) return Icons.eco_rounded;
  if (s.contains('arabic') || s.contains('hebrew') || s.contains('english')) {
    return Icons.menu_book_rounded;
  }
  if (s.contains('history')) return Icons.history_edu_rounded;
  if (s.contains('geo')) return Icons.public_rounded;
  if (s.contains('cs') || s.contains('computer')) return Icons.memory_rounded;
  return Icons.book_rounded;
}

Color _avatarColorForName(BuildContext context, String name) {
  final palette = <Color>[
    const Color(0xFF9CCC65),
    const Color(0xFF4FC3F7),
    const Color(0xFFFFB74D),
    const Color(0xFFBA68C8),
    const Color(0xFFFF8A65),
    const Color(0xFF4DB6AC),
    const Color(0xFFA1887F),
    const Color(0xFF7986CB),
  ];
  final seed = name.trim().toLowerCase().runes.fold<int>(0, (a, b) => a + b);
  return palette[seed % palette.length];
}

String _initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final v = parts.first.trim();
    return v.length >= 2 ? v.substring(0, 2).toUpperCase() : v.toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
