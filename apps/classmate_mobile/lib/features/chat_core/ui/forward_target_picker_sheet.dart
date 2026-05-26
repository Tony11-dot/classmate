import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../classrooms/providers/classrooms_providers.dart';
import '../../messages/domain/message_thread_models.dart';
import '../../messages/providers/messages_repository_provider.dart';
import '../../messages/ui/new_chat_screen.dart';
import '../domain/chat_request_state.dart';
import '../domain/chat_thread_type.dart';
import '../domain/forward_target.dart';
import '../../../ui/widgets/cm_loading.dart';

/// Opens the forward-target picker.
/// Returns selected [ForwardTarget]s, or null if cancelled.
Future<List<ForwardTarget>?> showForwardTargetPicker(
  BuildContext context,
  WidgetRef ref, {
  required ChatThreadType sourceThreadType,
  required String sourceThreadId,
}) async {
  if (!context.mounted) return null;
  return showModalBottomSheet<List<ForwardTarget>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ForwardPickerSheet(
      sourceThreadType: sourceThreadType,
      sourceThreadId: sourceThreadId,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _ForwardPickerSheet extends ConsumerStatefulWidget {
  const _ForwardPickerSheet({
    required this.sourceThreadType,
    required this.sourceThreadId,
  });
  final ChatThreadType sourceThreadType;
  final String sourceThreadId;

  @override
  ConsumerState<_ForwardPickerSheet> createState() => _ForwardPickerSheetState();
}

class _ForwardPickerSheetState extends ConsumerState<_ForwardPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  final Set<String> _selected = {};
  bool _submitting = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _key(MessageThreadSummary item) =>
      '${item.type == ChatThreadType.classroom ? 'classroom' : 'dm'}:${item.id}';

  ForwardTarget _toTarget(MessageThreadSummary item) =>
      item.type == ChatThreadType.classroom
          ? ForwardTargetClassroom(item.id)
          : ForwardTargetDm(item.id);

  bool _isClassroom(MessageThreadSummary item) =>
      item.type == ChatThreadType.classroom;

  bool _notSource(MessageThreadSummary item) {
    if (widget.sourceThreadType == ChatThreadType.classroom && _isClassroom(item)) {
      return item.id != widget.sourceThreadId;
    }
    if (widget.sourceThreadType == ChatThreadType.direct && !_isClassroom(item)) {
      return item.id != widget.sourceThreadId;
    }
    return true;
  }

  bool _notBlocked(MessageThreadSummary item) =>
      item.requestState != ChatRequestState.blocked;

  List<MessageThreadSummary> _filter(List<MessageThreadSummary> items) {
    final q = _query.trim().toLowerCase();
    return items.where(_notSource).where(_notBlocked).where((i) {
      if (q.isEmpty) return true;
      return i.title.toLowerCase().contains(q) ||
          i.subtitle.toLowerCase().contains(q);
    }).toList();
  }

  MessageThreadSummary _classroomToSummary(Map<String, dynamic> map) {
    final l = AppLocalizations.of(context)!;
    final id = (map['id'] ?? '').toString().trim();
    final name = (map['name'] ?? map['title'] ?? '').toString().trim();
    final subject = (map['subject'] ?? '').toString().trim();
    final teacher = (map['teacherName'] ?? '').toString().trim();
    final title = name.isNotEmpty ? name : (subject.isNotEmpty ? subject : l.classroomsThreadTypeClassroom);
    final initials = title.split(RegExp(r'\s+')).take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    return MessageThreadSummary(
      id: id,
      type: ChatThreadType.classroom,
      title: title,
      subtitle: [subject, teacher].where((s) => s.isNotEmpty).join(' · '),
      isGroup: false,
      isUnread: false,
      unreadCount: 0,
      lastMessageAt: '',
      lastMessageAtRaw: '',
      requestState: ChatRequestState.approved,
      initials: initials.isEmpty ? 'C' : initials,
    );
  }

  void _toggle(String key) => setState(() {
    if (_selected.contains(key)) {
      _selected.remove(key);
    } else {
      _selected.add(key);
    }
  });

  void _submit(List<MessageThreadSummary> allItems) {
    setState(() => _submitting = true);
    final targets = <ForwardTarget>[];
    for (final item in allItems) {
      if (_selected.contains(_key(item))) targets.add(_toTarget(item));
    }
    Navigator.of(context).pop(targets.isEmpty ? null : targets);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final inbox = ref.watch(messagesInboxProvider);
    final classroomsAsync = ref.watch(orderedStudentClassroomsProvider);

    final allClassrooms = _filter(
      (classroomsAsync.asData?.value ?? const []).map(_classroomToSummary).toList(),
    );

    final allDms = inbox.asData?.value
            .where((i) => !_isClassroom(i))
            .toList() ??
        const <MessageThreadSummary>[];

    // WhatsApp-style sections:
    // 1. Classrooms
    // 2. Recent chats (DMs with at least 1 message, sorted by recency)
    // 3. Other chats (DMs with no messages yet)
    final recent = _filter(
      allDms.where((i) => i.lastMessageAt.trim().isNotEmpty).toList()
        ..sort((a, b) {
          final ad = a.lastMessageDate, bd = b.lastMessageDate;
          if (ad != null && bd != null) return bd.compareTo(ad);
          if (ad != null) return -1;
          if (bd != null) return 1;
          return 0;
        }),
    );
    final otherChats = _filter(
      allDms.where((i) => i.lastMessageAt.trim().isEmpty).toList(),
    );

    final allItems = [
      ...allClassrooms,
      ...recent,
      ...otherChats,
    ];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => Column(
        children: [
          // ── Search ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 120), () {
                  if (mounted) setState(() => _query = v);
                });
              },
              decoration: InputDecoration(
                hintText: 'Search chats and classrooms…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); },
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),

          // ── New chat button ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _submitting ? null : () async {
                  final rootNav = Navigator.of(context, rootNavigator: true);
                  final threadId = await rootNav.push<String>(
                    MaterialPageRoute<String>(builder: (_) => const NewChatScreen()),
                  );
                  if (threadId != null && threadId.trim().isNotEmpty && context.mounted) {
                    Navigator.of(context).pop(<ForwardTarget>[ForwardTargetDm(threadId.trim())]);
                  }
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(l.classroomsForwardNewChat),
              ),
            ),
          ),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: inbox.when(
              loading: () => const Center(child: CmLoading()),
              error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.forwardCouldNotLoadChats(e))),
              data: (_) {
                if (allItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 36, color: cs.onSurfaceVariant),
                        const SizedBox(height: 10),
                        Text(AppLocalizations.of(context)!.forwardNoChats, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  );
                }

                return ListView(
                  controller: scroll,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    if (allClassrooms.isNotEmpty) ...[
                      _sectionHeader(context, l.classroomsForwardSectionClassrooms),
                      ...allClassrooms.map((item) => _itemTile(context, item, cs, theme)),
                      const SizedBox(height: 8),
                    ],
                    if (recent.isNotEmpty) ...[
                      _sectionHeader(context, 'Recent chats'),
                      ...recent.map((item) => _itemTile(context, item, cs, theme)),
                      const SizedBox(height: 8),
                    ],
                    if (otherChats.isNotEmpty) ...[
                      _sectionHeader(context, 'Other chats'),
                      ...otherChats.map((item) => _itemTile(context, item, cs, theme)),
                    ],
                  ],
                );
              },
            ),
          ),

          // ── Bottom action bar ────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                      child: Text(l.classroomsForwardCancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submitting
                          ? null
                          : _selected.isEmpty
                              ? () => Navigator.of(context).pop() // 0 selected = cancel
                              : () => _submit(allItems),
                      child: Text(
                        _selected.isEmpty
                            ? l.classroomsForwardCancel
                            : l.classroomsForwardCount(_selected.length),
                      ),
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

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _itemTile(
    BuildContext context,
    MessageThreadSummary item,
    ColorScheme cs,
    ThemeData theme,
  ) {
    final key = _key(item);
    final selected = _selected.contains(key);
    final l = AppLocalizations.of(context)!;
    final subtitle = item.subtitle.trim().isEmpty
        ? (_isClassroom(item)
            ? l.classroomsThreadTypeClassroom
            : (item.isGroup ? l.classroomsThreadTypeGroup : l.classroomsThreadTypeDirectMessage))
        : item.subtitle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _submitting ? null : () => _toggle(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.10)
                : cs.surfaceContainerHighest.withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.30)
                  : cs.outlineVariant.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: selected ? cs.primaryContainer : cs.surfaceContainerHigh,
                child: Text(
                  item.initials,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? cs.onPrimaryContainer : cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: selected
                    ? Icon(Icons.check_circle_rounded, key: const ValueKey('c'), color: cs.primary)
                    : Icon(Icons.circle_outlined, key: const ValueKey('u'), color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
