import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/tutor_providers.dart';
import '../providers/tutor_repository_provider.dart';
import 'nova_chat_screen.dart';

class TutorHomeScreen extends ConsumerStatefulWidget {
  const TutorHomeScreen({
    super.key,
    this.initialPrompt,
    this.initialSubject,
    this.initialTitle,
  });

  final String? initialPrompt;
  final String? initialSubject;
  final String? initialTitle;

  @override
  ConsumerState<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends ConsumerState<TutorHomeScreen> {
  static const _renameKey = 'nova_local_session_titles_v1';
  static const _hiddenKey = 'nova_hidden_sessions_v1';

  final TextEditingController _searchController = TextEditingController();

  Map<String, String> _localTitles = <String, String>{};
  Set<String> _hiddenSessions = <String>{};
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final prompt = (widget.initialPrompt ?? '').trim();
      if (prompt.isEmpty) return;
      _openSeededChat(
        prompt: prompt,
        title: widget.initialTitle,
        subject: widget.initialSubject,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final rawTitles = prefs.getString(_renameKey);
    Map<String, String> titles = <String, String>{};
    if (rawTitles != null && rawTitles.trim().isNotEmpty) {
      final decoded = jsonDecode(rawTitles);
      if (decoded is Map) {
        titles = decoded.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    }

    final hidden = prefs.getStringList(_hiddenKey) ?? <String>[];

    if (!mounted) {
      return;
    }

    setState(() {
      _localTitles = titles;
      _hiddenSessions = hidden.toSet();
      _prefsLoaded = true;
    });
  }

  Future<void> _persistPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_renameKey, jsonEncode(_localTitles));
    await prefs.setStringList(_hiddenKey, _hiddenSessions.toList());
  }

  Future<void> _openSeededChat({
    required String prompt,
    String? title,
    String? subject,
  }) async {
    final repo = ref.read(tutorRepositoryProvider);

    try {
      final created = await repo.createSession(
        subject: (subject ?? '').trim().isEmpty ? null : subject,
        title: (title ?? '').trim().isEmpty ? 'NOVA' : title,
        topic: (subject ?? '').trim().isEmpty ? null : subject,
        initialMessage: prompt.trim().isEmpty ? null : prompt.trim(),
      );

      final session = (created['session'] is Map<String, dynamic>)
          ? created['session'] as Map<String, dynamic>
          : created;

      final sessionId = (session['id'] ?? '').toString();
      final seededPrompt = (created['seededPrompt'] ?? '').toString();
      final effectivePrompt = seededPrompt.trim().isNotEmpty
          ? seededPrompt
          : prompt.trim();

      ref.invalidate(tutorSessionsProvider);

      if (!mounted || sessionId.isEmpty) {
        return;
      }

      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => NovaChatScreen(
            sessionId: sessionId,
            initialTitle: (title ?? '').trim().isEmpty ? 'NOVA' : title,
            initialPrompt: effectivePrompt.isEmpty ? null : effectivePrompt,
          ),
        ),
      );

      ref.invalidate(tutorSessionsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open seeded chat: $e')));
    }
  }

  Future<void> _createFreshChat() async {
    final repo = ref.read(tutorRepositoryProvider);

    try {
      final created = await repo.createSession();
      final session = (created['session'] is Map<String, dynamic>)
          ? created['session'] as Map<String, dynamic>
          : created;
      final sessionId = (session['id'] ?? '').toString();

      ref.invalidate(tutorSessionsProvider);

      if (!mounted || sessionId.isEmpty) {
        return;
      }

      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) =>
              NovaChatScreen(sessionId: sessionId, initialTitle: 'New chat'),
        ),
      );

      ref.invalidate(tutorSessionsProvider);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create chat: $e')));
    }
  }

  Future<void> _openSession(Map<String, dynamic> session) async {
    final sessionId = (session['id'] ?? '').toString();
    if (sessionId.isEmpty) {
      return;
    }

    final title = _displayTitle(session);

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) =>
            NovaChatScreen(sessionId: sessionId, initialTitle: title),
      ),
    );

    if (!mounted) {
      return;
    }

    ref.invalidate(tutorSessionsProvider);
  }

  Future<void> _renameSession(Map<String, dynamic> session) async {
    final id = (session['id'] ?? '').toString();
    if (id.isEmpty) {
      return;
    }

    final controller = TextEditingController(text: _displayTitle(session));

    final next = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename chat'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Chat name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (next == null) {
      return;
    }

    setState(() {
      if (next.isEmpty) {
        _localTitles.remove(id);
      } else {
        _localTitles[id] = next;
      }
    });

    await _persistPrefs();
  }

  Future<void> _deleteSessionLocally(Map<String, dynamic> session) async {
    final id = (session['id'] ?? '').toString();
    if (id.isEmpty) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Hide chat?'),
              content: const Text(
                'This hides the chat from the list on this device. The session stays on the backend.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Hide'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    setState(() {
      _hiddenSessions.add(id);
    });

    await _persistPrefs();
  }

  Future<void> _showSessionActions(Map<String, dynamic> session) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline_rounded),
                title: const Text('Rename chat'),
                onTap: () => Navigator.of(context).pop('rename'),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_rounded),
                title: const Text('Hide chat'),
                subtitle: const Text('Local-only for now'),
                onTap: () => Navigator.of(context).pop('hide'),
              ),
            ],
          ),
        );
      },
    );

    if (action == 'rename') {
      await _renameSession(session);
    } else if (action == 'hide') {
      await _deleteSessionLocally(session);
    }
  }

  String _displayTitle(Map<String, dynamic> s) {
    final id = (s['id'] ?? '').toString();
    final local = _localTitles[id];
    if (local != null && local.trim().isNotEmpty) {
      return local.trim();
    }

    final title = (s['title'] ?? '').toString().trim();
    final topic = (s['topic'] ?? '').toString().trim();
    final subject = (s['subject'] ?? '').toString().trim();

    if (title.isNotEmpty) {
      return title;
    }
    if (topic.isNotEmpty) {
      return topic;
    }
    if (subject.isNotEmpty) {
      return subject;
    }
    return 'Untitled chat';
  }

  String _subtitleFor(Map<String, dynamic> s) {
    final parts = <String>[];
    final subject = (s['subject'] ?? '').toString().trim();
    final updatedAt = (s['updatedAt'] ?? s['createdAt'] ?? '')
        .toString()
        .trim();

    if (subject.isNotEmpty) {
      parts.add(subject);
    }
    if (updatedAt.isNotEmpty) {
      parts.add(updatedAt.replaceFirst('T', ' ').split('.').first);
    }

    return parts.isEmpty ? 'Tap to open history' : parts.join(' • ');
  }

  List<Map<String, dynamic>> _normalizedSessions(List<dynamic> raw) {
    final items = raw
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .where((e) => !_hiddenSessions.contains((e['id'] ?? '').toString()))
        .toList();

    items.sort((a, b) {
      final aDt =
          DateTime.tryParse(
            (a['updatedAt'] ?? a['createdAt'] ?? '').toString(),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDt =
          DateTime.tryParse(
            (b['updatedAt'] ?? b['createdAt'] ?? '').toString(),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDt.compareTo(aDt);
    });

    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      return items;
    }

    return items.where((s) {
      final hay = [
        _displayTitle(s),
        _subtitleFor(s),
        (s['subject'] ?? '').toString(),
        (s['topic'] ?? '').toString(),
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(tutorSessionsProvider);
    final cs = Theme.of(context).colorScheme;

    Widget topSection() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withValues(alpha: 0.22),
                    cs.secondary.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.10),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surface.withValues(alpha: 0.42),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.28),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'N',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'NOVA',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your AI tutor',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.76),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Real chat history, cleaner threads, faster access.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.72),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _createFreshChat,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Start a fresh conversation'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: 'Search chat history',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          FocusScope.of(context).unfocus();
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: cs.primary.withValues(alpha: 0.85),
                    width: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 44,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFreshChat,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New chat'),
      ),
      body: !_prefsLoaded
          ? const Center(child: CircularProgressIndicator())
          : sessions.when(
              loading: () => ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                children: [
                  topSection(),
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                ],
              ),
              error: (e, _) => ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                children: [
                  topSection(),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load chats',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$e',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () =>
                              ref.invalidate(tutorSessionsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              data: (raw) {
                final items = _normalizedSessions(raw);

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(tutorSessionsProvider);
                  },
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                    children: [
                      topSection(),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.forum_rounded, size: 42),
                              const SizedBox(height: 12),
                              Text(
                                _searchController.text.trim().isEmpty
                                    ? 'No chats yet'
                                    : 'No chats match your search',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _createFreshChat,
                                icon: const Icon(Icons.add_comment_rounded),
                                label: const Text('Create first chat'),
                              ),
                            ],
                          ),
                        )
                      else
                        ...List.generate(items.length, (index) {
                          final session = items[index];
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              index == 0 ? 4 : 0,
                              16,
                              10,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => _openSession(session),
                              onLongPress: () => _showSessionActions(session),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    14,
                                    10,
                                    14,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: cs.primary.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome_rounded,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _displayTitle(session),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _subtitleFor(session),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: cs.onSurfaceVariant,
                                                    height: 1.3,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _sessionTimeLabel(session),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                ),
                                          ),
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () =>
                                                _showSessionActions(session),
                                            icon: const Icon(
                                              Icons.more_horiz_rounded,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

String _sessionTimeLabel(Map<String, dynamic> session) {
  final raw = session['updatedAt'] ?? session['createdAt'];
  if (raw == null) return '';

  try {
    final dt = DateTime.parse(raw.toString()).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.day}/${dt.month}/${dt.year}';
  } catch (_) {
    return '';
  }
}
