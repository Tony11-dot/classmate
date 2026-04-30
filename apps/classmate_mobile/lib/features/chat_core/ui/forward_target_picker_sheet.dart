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

/// Shows the forward-target picker bottom sheet.
///
/// Returns the list of [ForwardTarget]s the user selected, or `null` if the
/// picker was dismissed/cancelled. An empty list will not be returned —
/// the picker disables the confirm button until at least one target is picked.
Future<List<ForwardTarget>?> showForwardTargetPicker(
  BuildContext context,
  WidgetRef ref, {
  required ChatThreadType sourceThreadType,
  required String sourceThreadId,
}) async {
  final inbox = await ref.read(messagesInboxProvider.future);
  if (!context.mounted) return null;

  final hasApprovedDm = inbox.any(
    (item) =>
        !(sourceThreadType == ChatThreadType.direct && item.id == sourceThreadId) &&
        _isApprovedForwardTarget(item),
  );
  final hasClassrooms =
      (ref.read(orderedStudentClassroomsProvider).asData?.value ?? const [])
          .any((c) {
        final id = (c['id'] ?? '').toString().trim();
        return !(sourceThreadType == ChatThreadType.classroom &&
                id == sourceThreadId) &&
            id.isNotEmpty;
      });

  if (!hasApprovedDm && !hasClassrooms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No approved chats available')),
    );
    return null;
  }

  return showModalBottomSheet<List<ForwardTarget>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _ForwardTargetPickerSheet(
      sourceThreadType: sourceThreadType,
      sourceThreadId: sourceThreadId,
    ),
  );
}

bool _isApprovedForwardTarget(MessageThreadSummary item) {
  return item.requestState != ChatRequestState.pendingIncoming &&
      item.requestState != ChatRequestState.pendingOutgoing &&
      item.requestState != ChatRequestState.blocked;
}

class _ForwardTargetPickerSheet extends ConsumerStatefulWidget {
  const _ForwardTargetPickerSheet({
    required this.sourceThreadType,
    required this.sourceThreadId,
  });

  final ChatThreadType sourceThreadType;
  final String sourceThreadId;

  @override
  ConsumerState<_ForwardTargetPickerSheet> createState() =>
      _ForwardTargetPickerSheetState();
}

class _ForwardTargetPickerSheetState
    extends ConsumerState<_ForwardTargetPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  // Selection key is "dm:<id>" or "classroom:<id>" so DM/classroom IDs can't collide.
  final Set<String> _selected = <String>{};
  bool _submitting = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _key(MessageThreadSummary item) =>
      '${item.type == ChatThreadType.classroom ? 'classroom' : 'dm'}:${item.id}';

  ForwardTarget _toTarget(MessageThreadSummary item) =>
      item.type == ChatThreadType.classroom
          ? ForwardTargetClassroom(item.id)
          : ForwardTargetDm(item.id);

  MessageThreadSummary _classroomMapToSummary(Map<String, dynamic> map) {
    final l = AppLocalizations.of(context)!;
    final id = (map['id'] ?? '').toString().trim();
    final name = (map['name'] ?? map['title'] ?? '').toString().trim();
    final subject = (map['subject'] ?? '').toString().trim();
    final teacher =
        (map['teacherName'] ?? map['teacher'] ?? '').toString().trim();
    final displayTitle = name.isNotEmpty
        ? name
        : (subject.isNotEmpty ? subject : l.classroomsThreadTypeClassroom);
    final initials = displayTitle.trim().split(RegExp(r'\s+')).take(2).map(
      (w) => w.isNotEmpty ? w[0].toUpperCase() : '',
    ).join();
    return MessageThreadSummary(
      id: id,
      type: ChatThreadType.classroom,
      title: displayTitle,
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

  bool _isClassroomThread(MessageThreadSummary item) =>
      item.type == ChatThreadType.classroom;

  bool _excludeSource(MessageThreadSummary item) {
    if (widget.sourceThreadType == ChatThreadType.classroom &&
        _isClassroomThread(item)) {
      return item.id != widget.sourceThreadId;
    }
    if (widget.sourceThreadType == ChatThreadType.direct &&
        !_isClassroomThread(item)) {
      return item.id != widget.sourceThreadId;
    }
    return true;
  }

  List<MessageThreadSummary> _filtered(List<MessageThreadSummary> items) {
    final q = _query.trim().toLowerCase();
    return items
        .where(_excludeSource)
        .where(_isApprovedForwardTarget)
        .where((item) {
          if (q.isEmpty) return true;
          return item.title.toLowerCase().contains(q) ||
              item.subtitle.toLowerCase().contains(q);
        })
        .toList();
  }

  List<MessageThreadSummary> _sortTargets(List<MessageThreadSummary> items) {
    final sorted = List<MessageThreadSummary>.from(items);
    sorted.sort((a, b) {
      final aDate = a.lastMessageDate;
      final bDate = b.lastMessageDate;
      if (aDate != null && bDate != null) {
        final byRecent = bDate.compareTo(aDate);
        if (byRecent != 0) return byRecent;
      } else if (aDate != null) {
        return -1;
      } else if (bDate != null) {
        return 1;
      }
      final byTitle = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (byTitle != 0) return byTitle;
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  void _toggle(String key) {
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
  }

  Widget _pickerSection(
    BuildContext context, {
    required String title,
    required List<MessageThreadSummary> items,
  }) {
    final l = AppLocalizations.of(context)!;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        ...items.map((item) {
          final key = _key(item);
          final selected = _selected.contains(key);
          final subtitle = item.subtitle.trim().isEmpty
              ? (_isClassroomThread(item)
                  ? l.classroomsThreadTypeClassroom
                  : (item.isGroup
                      ? l.classroomsThreadTypeGroup
                      : l.classroomsThreadTypeDirectMessage))
              : item.subtitle.trim();

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _submitting ? null : () => _toggle(key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.10)
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.28)
                        : Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(child: Text(item.initials)),
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
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              _typeBadge(context, item, l),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _typeBadge(
    BuildContext context,
    MessageThreadSummary item,
    AppLocalizations l,
  ) {
    final label = _isClassroomThread(item)
        ? l.classroomsThreadTypeClassroom
        : (item.isGroup
            ? l.classroomsThreadTypeGroup
            : l.classroomsThreadTypeDirectMessageShort);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final inbox = ref.watch(messagesInboxProvider);
    final classroomsAsync = ref.watch(orderedStudentClassroomsProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 120), () {
                  if (!mounted) return;
                  setState(() => _query = value);
                });
              },
              decoration: InputDecoration(
                hintText: l.classroomsForwardSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _submitting
                    ? null
                    : () async {
                        final nav = Navigator.of(context);
                        final threadId = await nav.push<String>(
                          MaterialPageRoute<String>(
                            builder: (_) => const NewChatScreen(),
                          ),
                        );
                        if (threadId != null && threadId.trim().isNotEmpty) {
                          nav.pop(<ForwardTarget>[
                            ForwardTargetDm(threadId.trim()),
                          ]);
                        }
                      },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(l.classroomsForwardNewChat),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: inbox.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    l.classroomsForwardLoadError(error.toString()),
                  ),
                ),
                data: (inboxItems) {
                  final classrooms = _filtered(
                    (classroomsAsync.asData?.value ?? const [])
                        .map(_classroomMapToSummary)
                        .toList(),
                  );
                  final directMessages = _sortTargets(
                    _filtered(
                      inboxItems
                          .where((i) => !_isClassroomThread(i))
                          .toList(),
                    ),
                  );

                  if (classrooms.isEmpty && directMessages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(l.classroomsForwardNoChatsFound),
                      ),
                    );
                  }

                  return ListView(
                    shrinkWrap: true,
                    children: [
                      _pickerSection(
                        context,
                        title: l.classroomsForwardSectionClassrooms,
                        items: classrooms,
                      ),
                      _pickerSection(
                        context,
                        title: l.classroomsForwardSectionDirectMessages,
                        items: directMessages,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(l.classroomsForwardCancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting || _selected.isEmpty
                        ? null
                        : () async {
                            setState(() => _submitting = true);
                            final allItems = <MessageThreadSummary>[
                              ...((ref
                                          .read(orderedStudentClassroomsProvider)
                                          .asData
                                          ?.value ??
                                      const [])
                                  .map(_classroomMapToSummary)),
                              ...((ref
                                          .read(messagesInboxProvider)
                                          .asData
                                          ?.value ??
                                      const <MessageThreadSummary>[])
                                  .where((i) => !_isClassroomThread(i))),
                            ];
                            final targets = <ForwardTarget>[];
                            for (final item in allItems) {
                              if (_selected.contains(_key(item))) {
                                targets.add(_toTarget(item));
                              }
                            }
                            if (!mounted) return;
                            Navigator.of(context).pop(targets);
                          },
                    child: Text(
                      _selected.isEmpty
                          ? l.classroomsForwardAction
                          : l.classroomsForwardCount(_selected.length),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
