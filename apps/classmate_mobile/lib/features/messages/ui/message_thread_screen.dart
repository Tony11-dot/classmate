import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/ui/chat_composer.dart';
import '../../chat_core/ui/chat_media_preview_screen.dart';
import '../../chat_core/ui/chat_message_bubble.dart';
import '../../chat_core/models/chat_message_info.dart';
import '../../chat_core/ui/chat_message_actions_sheet.dart';
import '../../chat_core/utils/chat_reply_codec.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import '../../chat_core/ui/chat_message_info_page.dart';

class _ForwardTargetPickerSheet extends ConsumerStatefulWidget {
  const _ForwardTargetPickerSheet({required this.currentThreadId});

  final String currentThreadId;

  @override
  ConsumerState<_ForwardTargetPickerSheet> createState() =>
      _ForwardTargetPickerSheetState();
}

class _ForwardTargetPickerSheetState
    extends ConsumerState<_ForwardTargetPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  final Set<String> _selected = <String>{};
  bool _submitting = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<MessageThreadSummary> _filtered(List<MessageThreadSummary> items) {
    final q = _query.trim().toLowerCase();
    final filtered = items
        .where((item) => item.id != widget.currentThreadId)
        .where((item) {
          if (q.isEmpty) return true;
          return item.title.toLowerCase().contains(q) ||
              item.subtitle.toLowerCase().contains(q);
        })
        .toList();

    filtered.sort((a, b) {
      final aPicked = _selected.contains(a.id) ? 1 : 0;
      final bPicked = _selected.contains(b.id) ? 1 : 0;
      if (aPicked != bPicked) return bPicked.compareTo(aPicked);
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return filtered;
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(messagesInboxProvider);

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
                hintText: 'Search chats',
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
            const SizedBox(height: 12),
            Flexible(
              child: inbox.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Failed to load chats: $error')),
                data: (items) {
                  final filtered = _filtered(items);

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No chats found'),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final selected = _selected.contains(item.id);

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _submitting ? null : () => _toggle(item.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.10)
                                : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.28)
                                  : Theme.of(context).colorScheme.outlineVariant
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
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        if (item.isGroup)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                            ),
                                            child: Text(
                                              'Group',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
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
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting || _selected.isEmpty
                        ? null
                        : () async {
                            setState(() => _submitting = true);
                            Navigator.of(context).pop(_selected.toList());
                          },
                    child: Text(
                      _selected.isEmpty
                          ? 'Forward'
                          : 'Forward (${_selected.length})',
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

class MessageThreadScreen extends ConsumerStatefulWidget {
  const MessageThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<MessageThreadScreen> createState() =>
      _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _pinnedMessageIds = <String>{};
  final Map<String, double> _swipeDxByMessage = <String, double>{};
  final AudioRecorder _recorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();

  int? _replyIndex;
  bool _sending = false;
  bool _recording = false;
  bool _voiceLocked = false;
  bool _voicePaused = false;
  bool _voiceCancelled = false;
  String? _recordingPath;
  Timer? _recordTicker;
  Duration _recordElapsed = Duration.zero;
  Offset? _holdStartGlobal;
  double _holdDx = 0;
  double _holdDy = 0;

  Future<void> _refreshThread() async {
    ref.invalidate(messageThreadProvider(widget.threadId));
    ref.invalidate(messagesInboxProvider);
  }

  String _kindInfoLabel(MessageItem row) {
    final kind = row.kind.trim().toUpperCase();
    switch (kind) {
      case 'IMAGE':
        return 'Photo';
      case 'VOICE':
        return 'Voice note';
      case 'VIDEO':
        return 'Video';
      case 'FILE':
        return 'File';
      case 'TEXT':
      default:
        return 'Message';
    }
  }

  String _fmtDuration(int seconds) {
    final total = seconds < 0 ? 0 : seconds;
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }


  Widget _threadMemberTile(BuildContext context, MessageParticipant p) {
    final school = p.schoolName.trim().isEmpty ? '—' : p.schoolName.trim();
    final grade = p.gradeLabel.trim().isEmpty ? '—' : p.gradeLabel.trim();

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(
        p.displayName.trim().isEmpty ? 'Student' : p.displayName.trim(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: Text(
        (school == '—' && grade == '—')
            ? 'Student info unavailable'
            : '$school • $grade',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      children: [
        _infoRow(context, 'School', school),
        _infoRow(context, 'Grade', grade),
      ],
    );
  }

  Future<void> _showThreadInfo(MessageThreadDetail detail) async {
    final participantCount = detail.participants.length;
    final subtitle = detail.subtitle.trim().isEmpty ? '—' : detail.subtitle.trim();

    String school = '—';
    String grade = '—';

    if (!detail.isGroup) {
      final parts = subtitle.split('/');
      if (parts.length >= 2) {
        school = parts.first.trim().isEmpty ? '—' : parts.first.trim();
        grade = parts.sublist(1).join('/').trim().isEmpty
            ? '—'
            : parts.sublist(1).join('/').trim();
      } else {
        school = subtitle;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: false,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 28,
                  child: Text(
                    _avatarText(detail),
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  detail.title.trim().isEmpty ? 'Conversation' : detail.title.trim(),
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (detail.isGroup) ...[
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Group',
                      style: Theme.of(sheetContext).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (!detail.isGroup) ...[
                _infoRow(sheetContext, 'School', school),
                _infoRow(sheetContext, 'Grade', grade),
              ] else ...[
                _infoRow(sheetContext, 'Participants', '$participantCount'),
                if (detail.participants.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Students',
                    style: Theme.of(sheetContext).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...detail.participants.map((p) => _threadMemberTile(sheetContext, p)),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final text = value.trim().isEmpty ? '—' : value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMessageInfo(MessageItem row) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ChatMessageInfoPage(
        info: ChatMessageInfo(
          title: 'Message info',
          sentAt: row.timeLabel,
          deliveredAt: row.isMine ? row.deliveredAt : '',
          seenAt: row.isMine ? row.seenAt : '',
          delivered: row.isMine ? row.delivered : false,
          seen: row.isMine ? row.seen : false,
          edited: row.edited,
          forwarded: row.forwarded,
          deleteState: row.deleteState,
          isMine: row.isMine,
          messageType: _kindInfoLabel(row),
          voiceDuration:
              row.kind.trim().toUpperCase() == 'VOICE' &&
                  row.voiceDurationSeconds != null &&
                  row.voiceDurationSeconds! > 0
              ? _fmtDuration(row.voiceDurationSeconds!)
              : '',
        ),
      ),
    );
  }

  Future<void> _editMessage(MessageItem row) async {
    final ctl = TextEditingController(text: row.text);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctl,
              minLines: 1,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Edit message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    await ref
        .read(messagesRepositoryProvider)
        .editMessage(
          threadId: widget.threadId,
          messageId: row.id,
          text: ctl.text.trim(),
        );
    await _refreshThread();
  }

  Future<void> _togglePin(MessageItem row) async {
    await ref
        .read(messagesRepositoryProvider)
        .togglePin(threadId: widget.threadId, messageId: row.id);
    await _refreshThread();
  }

  Future<void> _deleteForMe(MessageItem row) async {
    await ref
        .read(messagesRepositoryProvider)
        .deleteMessage(
          threadId: widget.threadId,
          messageId: row.id,
          mode: 'deleteForMe',
        );
    await _refreshThread();
  }

  Future<void> _deleteForEveryone(MessageItem row) async {
    await ref
        .read(messagesRepositoryProvider)
        .deleteMessage(
          threadId: widget.threadId,
          messageId: row.id,
          mode: 'deleteForEveryone',
        );
    await _refreshThread();
  }

  Future<void> _reactToMessage(MessageItem row, String? emoji) async {
    await ref
        .read(messagesRepositoryProvider)
        .reactMessage(
          threadId: widget.threadId,
          messageId: row.id,
          emoji: (emoji ?? '').trim().isEmpty ? null : emoji!.trim(),
        );
    await _refreshThread();
  }

  Future<void> _markVoicePlayed(MessageItem row) async {
    if (row.isMine || row.voicePlayed) return;
    await ref
        .read(messagesRepositoryProvider)
        .markThreadRead(threadId: widget.threadId).catchError((_) {});
      if (!mounted) return;
    await _refreshThread();
  }

  Future<String?> _showDeleteModeSheet() {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Delete for me'),
              onTap: () => Navigator.of(sheetContext).pop('me'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded),
              title: const Text('Delete for everyone'),
              onTap: () => Navigator.of(sheetContext).pop('everyone'),
            ),
          ],
        ),
      ),
    );
  }


  Future<List<String>?> _showForwardTargetPicker() async {
    final inbox = await ref.read(messagesInboxProvider.future);

    final candidates = inbox.where((item) {
      if (item.id == widget.threadId) return false;
      final state = item.requestState.name.toLowerCase();
      return !state.startsWith('pending');
    }).toList();

    if (!mounted) return null;

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No approved chats available')),
      );
      return null;
    }

    final selected = <String>{};

    return showModalBottomSheet<List<String>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Forward to',
                        style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: candidates.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 4),
                        itemBuilder: (_, index) {
                          final item = candidates[index];
                          final checked = selected.contains(item.id);

                          return CheckboxListTile(
                            value: checked,
                            onChanged: (value) {
                              setSheetState(() {
                                if (value == true) {
                                  selected.add(item.id);
                                } else {
                                  selected.remove(item.id);
                                }
                              });
                            },
                            secondary: CircleAvatar(
                              child: Text(item.initials),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.subtitle.trim().isEmpty
                                  ? (item.isGroup ? 'Group' : 'Direct message')
                                  : item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: selected.isEmpty
                            ? null
                            : () => Navigator.of(sheetContext).pop(selected.toList()),
                        child: Text(
                          selected.length == 1
                              ? 'Forward'
                              : 'Forward to ${selected.length} chats',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


  Future<void> _forwardMessage(MessageItem row) async {
    final targetThreadIds = await _showForwardTargetPicker();
    if (!mounted || targetThreadIds == null || targetThreadIds.isEmpty) return;

    try {
      await ref
          .read(messagesRepositoryProvider)
          .forwardMessage(
            fromThreadId: widget.threadId,
            messageId: row.id,
            targetThreadIds: targetThreadIds,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            targetThreadIds.length == 1
                ? 'Forwarded'
                : 'Forwarded to ${targetThreadIds.length} chats',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final text = e.toString();
      final message = text.contains('Cannot forward into a non-approved thread')
          ? 'Cannot forward into a request chat until it is approved'
          : 'Could not forward this message';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }


  // ignore: unused_element
  Future<void> _openBubbleMenu(MessageItem row, {required bool canPin}) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => ChatMessageActionsSheet(
        canEdit:
            row.isMine &&
            (row.mediaUrl == null || row.mediaUrl!.trim().isEmpty),
        canDelete: row.isMine,
        canViewInfo: true,
        canPin: canPin,
        canForward: true,
      ),
    );

    if (action == null || action.trim().isEmpty) return;

    if (action == 'reply') {
      setState(() => _replyIndex = rowIndexById(row.id));
      return;
    }

    if (action == 'info') {
      await _showMessageInfo(row);
      return;
    }

    if (action == 'pin') {
      await _togglePin(row);
      return;
    }

    if (action == 'forward') {
      await _forwardMessage(row);
      return;
    }

    if (action == 'edit') {
      await _editMessage(row);
      return;
    }

    if (action == 'delete') {
      final deleteForEveryone = await _showDeleteModeSheet();
      if (!mounted || deleteForEveryone == null) return;

      if (deleteForEveryone == 'everyone') {
        await _deleteForEveryone(row);
        return;
      }
      if (deleteForEveryone == 'me') {
        await _deleteForMe(row);
      }
    }
  }

  int rowIndexById(String id) => _lastRows.indexWhere((e) => e.id == id);

  List<MessageItem> _lastRows = const [];

  List<MessageItem> _pinnedRows(List<MessageItem> rows) {
    return rows
        .where(
          (row) =>
              row.deleteState.toUpperCase() != 'DELETED_FOR_ME' &&
              (row.isPinned || _pinnedMessageIds.contains(row.id)),
        )
        .toList();
  }

  void _jumpToMessage(String messageId) {
    final index = _lastRows.indexWhere((row) => row.id == messageId);
    if (index < 0) return;
    _pinToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _send(MessageThreadDetail detail) async {
    final text = _controller.text.trim();
    if (_sending || !detail.canSend) return;
    if (text.isEmpty) return;

    final rows = detail.messages;
    final replyToMessageId = _replyIndex == null ? null : rows[_replyIndex!].id;

    setState(() => _sending = true);
    try {
      await ref
          .read(messagesRepositoryProvider)
          .sendMessage(
            threadId: widget.threadId,
            text: text,
            replyToMessageId: replyToMessageId,
          );

      if (!mounted) return;

      _controller.clear();
      setState(() {
        _replyIndex = null;
      });

      ref.invalidate(messageThreadProvider(widget.threadId));
      ref.invalidate(messagesInboxProvider);
      _pinToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendMediaFile(
    MessageThreadDetail detail,
    String filePath, {
    required String kind,
    String? caption,
    String? fileName,
    String? mimeType,
  }) async {
    if (_sending || !detail.canSend) return;

    final rows = detail.messages;
    final replyToMessageId = _replyIndex == null ? null : rows[_replyIndex!].id;

    setState(() => _sending = true);
    try {
      final uploaded = await ref
          .read(messagesRepositoryProvider)
          .uploadDmMedia(filePath, fileName: fileName, mimeType: mimeType);

      final file = (uploaded['file'] is Map)
          ? Map<String, dynamic>.from(uploaded['file'] as Map)
          : <String, dynamic>{};

      final mediaUrl = (file['url'] ?? '').toString().trim();
      final resolvedMime = (file['mimeType'] ?? mimeType ?? '')
          .toString()
          .trim();

      if (mediaUrl.isEmpty) {
        throw Exception('DM upload returned empty media url');
      }

      await ref
          .read(messagesRepositoryProvider)
          .sendMessage(
            threadId: widget.threadId,
            text: (caption ?? '').trim(),
            kind: kind,
            mediaUrl: mediaUrl,
            mediaMimeType: resolvedMime,
            replyToMessageId: replyToMessageId,
          );

      if (!mounted) return;

      _controller.clear();
      setState(() {
        _replyIndex = null;
      });

      ref.invalidate(messageThreadProvider(widget.threadId));
      ref.invalidate(messagesInboxProvider);
      _pinToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _kindForPath(String path, {String? mimeType}) {
    final lower = path.toLowerCase();
    final mime = (mimeType ?? lookupMimeType(path) ?? '').toLowerCase();

    if (mime.startsWith('image/') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif')) {
      return 'IMAGE';
    }

    if (mime.startsWith('video/') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.webm')) {
      return 'VIDEO';
    }

    if (mime.startsWith('audio/') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.wav')) {
      return 'VOICE';
    }

    return 'FILE';
  }

  Future<void> _pickFiles(MessageThreadDetail detail) async {
    if (_sending || _recording || !detail.canSend) return;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final paths = result.files
        .map((e) => e.path ?? '')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    if (paths.isEmpty) return;

    final preview = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) =>
            ChatMediaPreviewScreen(initialPaths: paths, title: 'Send media'),
      ),
    );

    if (!mounted || preview == null || preview.paths.isEmpty) return;

    for (final path in preview.paths) {
      final mime = lookupMimeType(path);
      await _sendMediaFile(
        detail,
        path,
        kind: _kindForPath(path, mimeType: mime),
        caption: preview.caption,
        fileName: path.split('/').last,
        mimeType: mime,
      );
    }
  }

  Future<void> _openCamera(MessageThreadDetail detail) async {
    if (_sending || _recording || !detail.canSend) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_back_rounded),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(context).pop('photo'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_rounded),
              title: const Text('Record video'),
              onTap: () => Navigator.of(context).pop('video'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    List<String> initialPaths = <String>[];

    if (action == 'photo') {
      final shot = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (!mounted || shot == null || shot.path.trim().isEmpty) return;
      initialPaths = <String>[shot.path];
    } else if (action == 'video') {
      final shot = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: const Duration(minutes: 2),
      );
      if (!mounted || shot == null || shot.path.trim().isEmpty) return;
      initialPaths = <String>[shot.path];
    } else if (action == 'gallery') {
      final picked = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media,
      );
      if (!mounted || picked == null || picked.files.isEmpty) return;
      initialPaths = picked.files
          .map((e) => e.path ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList();
      if (initialPaths.isEmpty) return;
    } else {
      return;
    }

    final preview = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) => ChatMediaPreviewScreen(
          initialPaths: initialPaths,
          title: 'Preview',
        ),
      ),
    );

    if (!mounted || preview == null) return;

    final paths = preview.paths.isNotEmpty ? preview.paths : initialPaths;
    if (paths.isEmpty) return;

    for (final path in paths) {
      final mime = lookupMimeType(path) ??
          (path.toLowerCase().endsWith('.mp4') ||
                  path.toLowerCase().endsWith('.mov') ||
                  path.toLowerCase().endsWith('.m4v')
              ? 'video/mp4'
              : 'image/jpeg');

      await _sendMediaFile(
        detail,
        path,
        kind: _kindForPath(path, mimeType: mime),
        caption: preview.caption,
        fileName: path.split('/').last,
        mimeType: mime,
      );
    }
  }

  Future<void> _micHoldStart(
    MessageThreadDetail detail,
    LongPressStartDetails d,
  ) async {
    if (_sending || _recording) return;
    _holdStartGlobal = d.globalPosition;
    _holdDx = 0;
    _holdDy = 0;
    _voiceLocked = false;
    _voicePaused = false;
    _voiceCancelled = false;
    await _toggleMic(detail);
  }

  void _updateActiveHold(Offset globalPosition) {
    if (!_recording || _holdStartGlobal == null) return;

    final dx = globalPosition.dx - _holdStartGlobal!.dx;
    final dy = globalPosition.dy - _holdStartGlobal!.dy;

    final willCancel = dx <= -56;
    final willLock = dy <= -44;

    // 🔥 LIVE CANCEL (WHILE HOLDING)
    if (willCancel && !_voiceCancelled) {
      _voiceCancelled = true;
      _cancelVoiceDraft();
      return;
    }

    // 🔥 LIVE LOCK (WHILE HOLDING)
    if (willLock && !_voiceLocked) {
      setState(() {
        _voiceLocked = true;
        _voicePaused = false;
      });
      return;
    }

    setState(() {
      _holdDx = dx;
      _holdDy = dy;
    });
  }

  void _micHoldMove(LongPressMoveUpdateDetails d) {
    _updateActiveHold(d.globalPosition);
  }

  Future<void> _finishActiveHold(MessageThreadDetail detail) async {
    _holdStartGlobal = null;
    if (!_recording) return;

    if (_voiceCancelled) {
      await _cancelVoiceDraft();
      return;
    }

    if (_voiceLocked) {
      if (mounted) {
        setState(() {
          _voicePaused = false;
        });
      }
      return;
    }

    await _toggleMic(detail);
  }

  Future<void> _micHoldEnd(
    MessageThreadDetail detail,
    LongPressEndDetails d,
  ) async {
    await _finishActiveHold(detail);
  }

  Future<void> _micHoldCancel() async {
    _holdStartGlobal = null;
    if (!_recording || _voiceLocked) return;
    await _cancelVoiceDraft();
  }

  void _startRecordTicker() {
    _recordTicker?.cancel();
    _recordTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_recording || _voicePaused) return;
      setState(() {
        _recordElapsed = Duration(seconds: _recordElapsed.inSeconds + 1);
      });
    });
  }

  void _stopRecordTicker() {
    _recordTicker?.cancel();
    _recordTicker = null;
  }

  Future<void> _pauseVoiceRecord() async {
    if (!_recording || !_voiceLocked) return;
    try {
      await _recorder.pause();
    } catch (_) {}
    if (mounted) setState(() => _voicePaused = true);
  }

  Future<void> _resumeVoiceRecord() async {
    if (!_recording || !_voiceLocked) return;
    try {
      await _recorder.resume();
    } catch (_) {}
    if (mounted) setState(() => _voicePaused = false);
  }

  Future<void> _cancelVoiceDraft() async {
    try {
      await _recorder.stop();
    } catch (_) {}

    final path = (_recordingPath ?? '').trim();
    if (path.isNotEmpty) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    _stopRecordTicker();
    if (!mounted) return;
    setState(() {
      _recording = false;
      _voiceLocked = false;
      _voicePaused = false;
      _voiceCancelled = false;
      _holdStartGlobal = null;
      _holdDx = 0;
      _holdDy = 0;
      _recordingPath = null;
      _holdStartGlobal = null;
      _recordElapsed = Duration.zero;
    });
  }

  Widget _recordHud() => const SizedBox.shrink();

  Future<void> _toggleMic(MessageThreadDetail? detail) async {
    if (_sending) return;

    if (_recording) {
      final stoppedPath = await _recorder.stop();

      _stopRecordTicker();
      if (!mounted) return;
      setState(() {
        _recording = false;
      });

      final path = (stoppedPath ?? _recordingPath ?? '').trim();
      if (path.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No audio captured.')));
        return;
      }

      _recordingPath = path;

      if (detail != null) {
        await _sendMediaFile(
          detail,
          path,
          kind: 'VOICE',
          fileName: path.split('/').last,
          mimeType: lookupMimeType(path) ?? 'audio/mp4',
        );

        try {
          final f = File(path);
          if (await f.exists()) await f.delete();
        } catch (_) {}

        if (!mounted) return;
        setState(() {
          _voiceLocked = false;
          _voicePaused = false;
          _voiceCancelled = false;
          _holdDx = 0;
          _holdDy = 0;
          _recordingPath = null;
          _recordElapsed = Duration.zero;
        });
      }

      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/dm-voice-${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    _startRecordTicker();
    if (!mounted) return;
    setState(() {
      _recording = true;
      _recordingPath = path;
      _voicePaused = false;
      _voiceCancelled = false;
      _recordElapsed = Duration.zero;
    });
  }

  void _pinToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _openMessageInfoSheet(
    BuildContext modalContext,
    MessageItem row,
  ) async {
    Navigator.of(modalContext).pop();
    await _showMessageInfo(row);
  }

  String _avatarText(MessageThreadDetail detail) {
    if (detail.isGroup) {
      final parts = detail.title
          .split(' ')
          .where((v) => v.trim().isNotEmpty)
          .take(2)
          .map((e) => e[0].toUpperCase())
          .join();
      return parts.isEmpty ? 'G' : parts;
    }

    final others = detail.participants.where((p) {
      final lower = p.displayName.trim().toLowerCase();
      return lower != 'you';
    }).toList();

    if (others.isNotEmpty && others.first.initials.trim().isNotEmpty) {
      return others.first.initials.trim().toUpperCase();
    }

    return detail.title.isNotEmpty ? detail.title[0].toUpperCase() : '?';
  }

  Widget _pendingBanner(BuildContext context, MessageThreadDetail detail) {
    final scheme = Theme.of(context).colorScheme;
    final isOutgoing = detail.requestState == ChatRequestState.pendingOutgoing;
    final title = isOutgoing ? 'Waiting for approval' : 'Message request';
    final subtitle = isOutgoing
        ? 'You can send more once the other person approves this chat.'
        : 'Review the request to start chatting.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOutgoing
                ? Icons.hourglass_top_rounded
                : Icons.mark_chat_unread_rounded,
            color: scheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _startsGroup(List<MessageItem> rows, int index) {
    if (index == 0) return true;
    final prev = rows[index - 1];
    final cur = rows[index];
    return prev.senderId != cur.senderId;
  }

  bool _endsGroup(List<MessageItem> rows, int index) {
    if (index == rows.length - 1) return true;
    final next = rows[index + 1];
    final cur = rows[index];
    return next.senderId != cur.senderId;
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(messageThreadProvider(widget.threadId));

    return Scaffold(
      body: SafeArea(
        child: thread.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Failed to load thread: $error')),
          data: (detail) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                await ref
                    .read(messagesRepositoryProvider)
                    .markThreadRead(threadId: widget.threadId).catchError((_) {});
      if (!mounted) return;
              } catch (_) {}
              ref.invalidate(messagesInboxProvider);
            });

            final rows = detail.messages;
            _lastRows = rows;

            return Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showThreadInfo(detail),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                CircleAvatar(child: Text(_avatarText(detail))),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (detail.subtitle.trim().isNotEmpty)
                                        Text(
                                          detail.subtitle.trim(),
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!detail.canSend ||
                    detail.requestState == ChatRequestState.pendingOutgoing ||
                    detail.requestState == ChatRequestState.pendingIncoming)
                  _pendingBanner(context, detail),
                if (_pinnedRows(rows).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _pinnedRows(rows).map((pinned) {
                          final snippet =
                              (pinned.text.trim().isNotEmpty
                                      ? pinned.text.trim()
                                      : (pinned.kind == 'IMAGE'
                                            ? 'Photo'
                                            : pinned.kind == 'VOICE'
                                            ? 'Voice note'
                                            : pinned.kind == 'VIDEO'
                                            ? 'Video'
                                            : pinned.kind == 'FILE'
                                            ? 'File'
                                            : 'Message'))
                                  .replaceAll('\n', ' ');
                          return InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => _jumpToMessage(pinned.id),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 220),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.push_pin_rounded,
                                    size: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      snippet,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final startsGroup = _startsGroup(rows, index);
                      final endsGroup = _endsGroup(rows, index);
                      final swipeDx = _swipeDxByMessage[row.id] ?? 0.0;

                      return Align(
                        alignment: row.isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: startsGroup ? 8 : 2,
                            bottom: endsGroup ? 4 : 2,
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) {
                              final current = _swipeDxByMessage[row.id] ?? 0.0;
                              final next = (current + details.delta.dx).clamp(
                                -84.0,
                                84.0,
                              );
                              if ((_swipeDxByMessage[row.id] ?? 0.0) != next) {
                                setState(() {
                                  _swipeDxByMessage[row.id] = next;
                                });
                              }
                            },
                            onHorizontalDragEnd: (_) async {
                              final current = _swipeDxByMessage[row.id] ?? 0.0;

                              if (_swipeDxByMessage.containsKey(row.id)) {
                                setState(() {
                                  _swipeDxByMessage.remove(row.id);
                                });
                              }

                              if (current >= 44) {
                                setState(() => _replyIndex = index);
                                return;
                              }

                              if (current <= -44) {
                                await _openMessageInfoSheet(
                                  Navigator.of(context).context,
                                  row,
                                );
                                return;
                              }
                            },
                            onHorizontalDragCancel: () {
                              if (_swipeDxByMessage.containsKey(row.id)) {
                                setState(() {
                                  _swipeDxByMessage.remove(row.id);
                                });
                              }
                            },
                            onLongPress: () async {
                              final navigator = Navigator.of(context);
                              final selected =
                                  await showModalBottomSheet<String>(
                                    context: navigator.context,
                                    showDragHandle: true,
                                    builder: (_) => ChatMessageActionsSheet(
                                      canEdit:
                                          row.isMine &&
                                          (row.mediaUrl == null ||
                                              row.mediaUrl!.trim().isEmpty),
                                      canDelete: row.isMine,
                                      canViewInfo: true,
                                      canPin: detail.isGroup || row.isMine,
                                      canForward: true,
                                      canCopy: (row.mediaUrl == null ||
                                              row.mediaUrl!.trim().isEmpty) &&
                                          row.text.trim().isNotEmpty,
                                    ),
                                  );

                              if (!mounted || selected == null) return;

                              if (selected == 'reply') {
                                setState(() => _replyIndex = index);
                                return;
                              }

                              if (selected == 'copy') {
                                final text = row.text.trim();
                                if (text.isNotEmpty) {
                                  final messenger = ScaffoldMessenger.of(
                                    navigator.context,
                                  );
                                  await Clipboard.setData(
                                    ClipboardData(text: text),
                                  );
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Copied')),
                                  );
                                }
                                return;
                              }

                              if (selected == 'forward') {
                                await _forwardMessage(row);
                                return;
                              }

                              if (selected == 'pin') {
                                await _togglePin(row);
                                return;
                              }

                              if (selected == 'edit') {
                                await _editMessage(row);
                                return;
                              }

                              if (selected == 'delete') {
                                final deleteMode = await _showDeleteModeSheet();
                                if (!mounted || deleteMode == null) return;

                                if (deleteMode == 'everyone') {
                                  await _deleteForEveryone(row);
                                  return;
                                }
                                if (deleteMode == 'me') {
                                  await _deleteForMe(row);
                                  return;
                                }
                              }

                              if (selected.startsWith('react:')) {
                                final reaction = selected
                                    .substring('react:'.length)
                                    .trim();
                                await _reactToMessage(
                                  row,
                                  reaction.isEmpty ? null : reaction,
                                );
                                return;
                              }

                              if (selected == 'info') {
                                await _openMessageInfoSheet(
                                  navigator.context,
                                  row,
                                );
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOutCubic,
                              transform: Matrix4.translationValues(swipeDx, 0, 0),
                              child: Column(
                                crossAxisAlignment: row.isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                if (row.isPinned ||
                                    _pinnedMessageIds.contains(row.id))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 2,
                                      bottom: 6,
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.18),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.push_pin_rounded,
                                            size: 12,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Pinned',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (row.deleteState.toUpperCase() !=
                                    'DELETED_FOR_ME')
                                  ChatMessageBubble(
                                    contextForNavigation: context,
                                    rawText: row.text,
                                    mediaUrl: row.mediaUrl ?? '',
                                    isMine: row.isMine,
                                    showName:
                                        detail.isGroup &&
                                        startsGroup &&
                                        !row.isMine,
                                    senderLabel: row.senderName,
                                    timeLabel: row.timeLabel,
                                    edited: row.edited,
                                    reaction: row.reaction,
                                    forwarded: row.forwarded,
                                    delivered: row.delivered,
                                    seen: row.seen,
                                    deleteState: row.deleteState,
                                    voiceDurationSeconds:
                                        row.voiceDurationSeconds,
                                    voiceUnread:
                                        !row.isMine &&
                                        row.kind.toUpperCase() == 'VOICE' &&
                                        !row.voicePlayed,
                                    onVoicePlayed:
                                        row.kind.toUpperCase() == 'VOICE'
                                        ? () => _markVoicePlayed(row)
                                        : null,
                                    replySender: row.replyPreview?.senderName,
                                    replySnippet: row.replyPreview?.text,
                                    mediaMimeType: row.mediaMimeType,
                                    messageKind: row.kind,
                                    maxWidth: 280,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _recordHud(),
                ChatComposer(
                  controller: _controller,
                  replyingTo: _replyIndex == null
                      ? null
                      : (
                          senderName: rows[_replyIndex!].isMine
                              ? 'You'
                              : rows[_replyIndex!].senderName,
                          text: replyPreviewText(rows[_replyIndex!].text),
                        ),
                  onCancelReply: () {
                    setState(() => _replyIndex = null);
                  },
                  onSend: () => _send(detail),
                  onCamera: () => _openCamera(detail),
                  onAttach: () => _pickFiles(detail),
                  onMic: () async {
                    if (_recording) {
                      await _toggleMic(detail);
                      return;
                    }
                    setState(() {
                      _voiceLocked = true;
                      _voiceCancelled = false;
                      _holdDx = 0;
                      _holdDy = 0;
                    });
                    await _toggleMic(detail);
                  },
                  onMicHoldStart: (d) => _micHoldStart(detail, d),
                  onMicHoldMove: _micHoldMove,
                  onMicHoldEnd: (d) => _micHoldEnd(detail, d),
                  onMicHoldCancel: _micHoldCancel,
                  onActiveHoldMove: _updateActiveHold,
                  onActiveHoldRelease: () async => _finishActiveHold(detail),
                  onActiveHoldCancel: _micHoldCancel,
                  activeHoldDx: _holdDx,
                  activeHoldDy: _holdDy,
                  onTrashRecording: _cancelVoiceDraft,
                  onPauseRecording: _pauseVoiceRecord,
                  onResumeRecording: _resumeVoiceRecord,
                  enabled: detail.canSend && !_sending,
                  isRecording: _recording,
                  isVoiceLocked: _voiceLocked,
                  isVoicePaused: _voicePaused,
                  recordingElapsed: _recordElapsed,
                  hintText: detail.canSend
                      ? (_sending ? 'Sending…' : 'Message')
                      : 'Waiting for approval',
                  forceMicOnlyTap: false,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
