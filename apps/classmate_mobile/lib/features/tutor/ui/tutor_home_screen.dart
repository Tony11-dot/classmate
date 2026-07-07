import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/tutor_providers.dart';
import '../providers/tutor_repository_provider.dart';
import 'nova_chat_screen.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/glass_search_field.dart';
import '../../../ui/widgets/nova_avatar.dart';

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
  static const _defaultNovaTitle = 'NOVA';

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
    final l = AppLocalizations.of(context)!;
    final repo = ref.read(tutorRepositoryProvider);

    try {
      // Do NOT seed the prompt as a message (no `initialMessage`). Seeding it
      // created a phantom "already sent" user bubble with no reply, and since
      // we also prefill the composer, sending produced a duplicate. We only
      // open a fresh session and prefill the composer — the user sends it.
      final created = await repo.createSession(
        subject: (subject ?? '').trim().isEmpty ? null : subject,
        title: (title ?? '').trim().isEmpty ? _defaultNovaTitle : title,
        topic: (subject ?? '').trim().isEmpty ? null : subject,
      );

      final session = (created['session'] is Map<String, dynamic>)
          ? created['session'] as Map<String, dynamic>
          : created;

      final sessionId = (session['id'] ?? '').toString();
      final effectivePrompt = prompt.trim();

      ref.invalidate(tutorSessionsProvider);

      if (!mounted || sessionId.isEmpty) {
        return;
      }

      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => NovaChatScreen(
            sessionId: sessionId,
            initialTitle:
                (title ?? '').trim().isEmpty ? _defaultNovaTitle : title,
            initialPrompt: effectivePrompt.isEmpty ? null : effectivePrompt,
          ),
        ),
      );

      ref.invalidate(tutorSessionsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(l.tutorFailedToOpenSeededChat(e.toString()))),
      );
    }
  }

  Future<void> _createFreshChat() async {
    final l = AppLocalizations.of(context)!;
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
          builder: (_) => NovaChatScreen(
            sessionId: sessionId,
            initialTitle: l.tutorNewChat,
          ),
        ),
      );

      ref.invalidate(tutorSessionsProvider);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(l.tutorFailedToCreateChat(e.toString()))),
      );
    }
  }

  Future<void> _openSession(Map<String, dynamic> session) async {
    final sessionId = (session['id'] ?? '').toString();
    if (sessionId.isEmpty) {
      return;
    }

    final title = _displayTitle(context, session);

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

    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: _displayTitle(context, session),
    );

    final next = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l.tutorRenameChatTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l.tutorChatNameHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.tutorCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l.profileSave),
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

  Future<void> _deleteSessionPermanently(Map<String, dynamic> session) async {
    final id = (session['id'] ?? '').toString();
    if (id.isEmpty) return;

    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(ctx)!.tutorDeleteConversationTitle),
            content: Text(AppLocalizations.of(ctx)!.tutorDeleteConversationWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l.tutorCancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: cs.error),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(AppLocalizations.of(ctx)!.tutorDeleteConversationButton),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    try {
      await ref.read(tutorRepositoryProvider).deleteSession(id);
      // Remove from the local hidden set too (clean up any old hide state).
      setState(() => _hiddenSessions.remove(id));
      await _persistPrefs();
      // Refresh the session list.
      ref.invalidate(tutorSessionsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.tutorDeleteFailed(e.toString()))),
      );
    }
  }

  Future<void> _showSessionActions(Map<String, dynamic> session) async {
    final l = AppLocalizations.of(context)!;
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
                title: Text(l.tutorRenameChatTitle),
                onTap: () => Navigator.of(context).pop('rename'),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.error),
                title: Text(AppLocalizations.of(context)!.tutorDeleteMenuTitle),
                subtitle: Text(AppLocalizations.of(context)!.tutorDeleteMenuSubtitle),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
            ],
          ),
        );
      },
    );

    if (action == 'rename') {
      await _renameSession(session);
    } else if (action == 'delete') {
      await _deleteSessionPermanently(session);
    }
  }

  String _displayTitle(BuildContext context, Map<String, dynamic> s) {
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
    return AppLocalizations.of(context)!.tutorUntitledChat;
  }

  String _subtitleFor(BuildContext context, Map<String, dynamic> s) {
    final subject = (s['subject'] ?? '').toString().trim();
    final topic = (s['topic'] ?? '').toString().trim();

    if (subject.isNotEmpty) {
      return subject;
    }
    if (topic.isNotEmpty) {
      return topic;
    }
    return AppLocalizations.of(context)!.tutorTapToOpenHistory;
  }

  String _sessionInitial(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return 'N';
    }
    return trimmed.characters.first.toUpperCase();
  }

  List<Map<String, dynamic>> _normalizedSessions(List<dynamic> raw) {
    final items = raw
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .where((e) => !_hiddenSessions.contains((e['id'] ?? '').toString()))
        .toList();

    items.sort((a, b) {
      final aDt =
          DateTime.tryParse((a['updatedAt'] ?? a['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDt =
          DateTime.tryParse((b['updatedAt'] ?? b['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDt.compareTo(aDt);
    });

    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      return items;
    }

    return items.where((s) {
      final hay = [
        _displayTitle(context, s),
        _subtitleFor(context, s),
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
    final l = AppLocalizations.of(context)!;

    Widget topSection() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const NovaAvatar(size: 56),
                    const SizedBox(height: 12),
                    Text(
                      'NOVA',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        l.tutorEmptyStateTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                              height: 0.96,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        l.tutorTapToOpenHistory,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: _createFreshChat,
                          icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                          label: Text(l.tutorStartFreshConversation),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            minimumSize: const Size(0, 42),
                            visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        OutlinedButton.icon(
                          // go (not push): /plans lives in the same ShellRoute,
                          // so push would keep the shell's location on /tutor —
                          // pill/bottom-nav/drawer wouldn't update. go re-resolves
                          // the shell to /plans (NOVA Plans pill, no bottom nav).
                          onPressed: () => context.go('/plans'),
                          icon: const Icon(Icons.workspace_premium_rounded, size: 16),
                          label: Text(l.tutorYourNovaPlanTitle),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            minimumSize: const Size(0, 42),
                            visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GlassSearchField(
              hintText: l.tutorSearchHistoryHint,
              controller: _searchController,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: !_prefsLoaded
          ? const Center(child: CmLoading())
          : sessions.when(
              loading: () => ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  0,
                  MediaQuery.paddingOf(context).top,
                  0,
                  120,
                ),
                children: [
                  topSection(),
                  const SizedBox(height: 24),
                  const Center(child: CmLoading()),
                ],
              ),
              error: (e, _) => ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  0,
                  MediaQuery.paddingOf(context).top,
                  0,
                  120,
                ),
                children: [
                  topSection(),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          l.tutorFailedToLoadChats,
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
                          onPressed: () => ref.invalidate(tutorSessionsProvider),
                          child: Text(l.retry),
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
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                  0,
                  MediaQuery.paddingOf(context).top,
                  0,
                  120,
                ),
                    children: [
                      topSection(),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: cs.outlineVariant,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: cs.outlineVariant,
                                      ),
                                    ),
                                    child: Icon(
                                      _searchController.text.trim().isEmpty
                                          ? Icons.forum_rounded
                                          : Icons.search_off_rounded,
                                      size: 22,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchController.text.trim().isEmpty
                                        ? l.tutorNoChatsYet
                                        : l.tutorNoChatsMatchSearch,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  if (_searchController.text.trim().isEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      l.tutorEmptyStateBody,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                            height: 1.25,
                                          ),
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  FilledButton.icon(
                                    onPressed: _createFreshChat,
                                    icon: const Icon(Icons.add_comment_rounded, size: 16),
                                    label: Text(l.tutorCreateFirstChat),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(0, 40),
                                      visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ...List.generate(items.length, (index) {
                          final session = items[index];
                          final title = _displayTitle(context, session);
                          final subtitle = _subtitleFor(context, session);
                          final timeLabel = _sessionTimeLabel(context, session);
                          return Padding(
                            padding: EdgeInsets.fromLTRB(16, index == 0 ? 4 : 0, 16, 6),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _openSession(session),
                              onLongPress: () => _showSessionActions(session),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: cs.outlineVariant,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: cs.outlineVariant,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _sessionInitial(title),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: cs.onSurface,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          fontWeight: FontWeight.w800,
                                                          letterSpacing: -0.1,
                                                        ),
                                                  ),
                                                ),
                                                if (timeLabel.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    timeLabel,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: cs.onSurfaceVariant,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              subtitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: cs.onSurfaceVariant,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.15,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        tooltip: l.menu,
                                        constraints: const BoxConstraints.tightFor(
                                          width: 32,
                                          height: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                        splashRadius: 18,
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        onPressed: () => _showSessionActions(session),
                                        icon: Icon(
                                          Icons.more_horiz_rounded,
                                          size: 20,
                                          color: cs.onSurfaceVariant,
                                        ),
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

String _sessionTimeLabel(BuildContext context, Map<String, dynamic> session) {
  final raw = session['updatedAt'] ?? session['createdAt'];
  if (raw == null) return '';

  try {
    final dt = DateTime.parse(raw.toString()).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    final l = AppLocalizations.of(context)!;
    final material = MaterialLocalizations.of(context);

    if (diff.inMinutes < 60) return l.tutorTimeMinutesShort(diff.inMinutes);
    if (diff.inHours < 24) return l.tutorTimeHoursShort(diff.inHours);
    return material.formatCompactDate(dt);
  } catch (_) {
    return '';
  }
}
