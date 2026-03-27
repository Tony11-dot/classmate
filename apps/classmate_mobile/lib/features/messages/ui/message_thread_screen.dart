import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
import '../../chat_core/ui/chat_message_info_sheet.dart';
import '../../chat_core/utils/chat_reply_codec.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import 'components/message_reply_preview.dart';
import 'components/message_reaction_bar.dart';

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
  final Map<String, String> _reactionByMessageId = <String, String>{};
  final Set<String> _pinnedMessageIds = <String>{};
  final AudioRecorder _recorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();

  int? _replyIndex;
  bool _sending = false;
  bool _recording = false;
  bool _voiceLocked = false;
  bool _voicePaused = false;
  bool _voiceCancelled = false;
  double _holdDx = 0;
  double _holdDy = 0;
  String? _recordingPath;

  Future<void> _refreshThread() async {
    ref.invalidate(messageThreadProvider(widget.threadId));
    ref.invalidate(messagesInboxProvider);
  }

  Future<void> _showMessageInfo(MessageItem row) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ChatMessageInfoSheet(
        info: ChatMessageInfo(
          title: 'Message info',
          sentAt: row.timeLabel,
          deliveredAt: row.timeLabel,
          seenAt: row.isMine ? row.timeLabel : '',
          edited: row.edited,
          forwarded: row.forwarded,
          deleteState: row.deleteState,
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

  Future<List<String>?> _showForwardPicker(
    List<MessageThreadSummary> targets,
  ) async {
    final searchController = TextEditingController();
    final selected = <String>{};

    try {
      return await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          var query = '';

          return StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              final filtered = targets.where((t) {
                final q = query.trim().toLowerCase();
                if (q.isEmpty) return true;
                return t.title.toLowerCase().contains(q) ||
                    t.subtitle.toLowerCase().contains(q);
              }).toList();

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                  ),
                  child: SizedBox(
                    height: 520,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Forward to',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (selected.isNotEmpty)
                              FilledButton(
                                onPressed: () => Navigator.of(
                                  sheetContext,
                                ).pop(selected.toList()),
                                child: Text('Send (${selected.length})'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setSheetState(() {
                              query = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search chats',
                            prefixIcon: Icon(Icons.search_rounded),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: filtered.isEmpty
                              ? const Center(
                                  child: Text('No chats match your search'),
                                )
                              : ListView.separated(
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 4),
                                  itemBuilder: (context, index) {
                                    final item = filtered[index];
                                    final checked = selected.contains(item.id);

                                    return CheckboxListTile(
                                      value: checked,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      secondary: CircleAvatar(
                                        child: Text(
                                          item.initials.isEmpty
                                              ? '?'
                                              : item.initials,
                                        ),
                                      ),
                                      title: Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        item.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onChanged: (_) {
                                        setSheetState(() {
                                          if (checked) {
                                            selected.remove(item.id);
                                          } else {
                                            selected.add(item.id);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      searchController.dispose();
    }
  }

  Future<void> _forwardStub(MessageItem row) async {
    final repo = ref.read(messagesRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    final inbox = await repo.fetchInbox();
    if (!mounted) return;

    final targets = inbox.where((t) => t.id != widget.threadId).toList();

    if (targets.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No other chats to forward to yet')),
      );
      return;
    }

    final selectedIds = await _showForwardPicker(targets);
    if (!mounted || selectedIds == null || selectedIds.isEmpty) return;

    await repo.forwardMessage(
      fromThreadId: widget.threadId,
      messageId: row.id,
      targetThreadIds: selectedIds,
    );

    if (!mounted) return;
    await _refreshThread();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          selectedIds.length == 1
              ? 'Message forwarded'
              : 'Message forwarded to ${selectedIds.length} chats',
        ),
      ),
    );
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
      await _forwardStub(row);
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

    final shot = await _imagePicker.pickImage(source: ImageSource.camera);
    if (!mounted || shot == null || shot.path.trim().isEmpty) return;

    final preview = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) => ChatMediaPreviewScreen(
          initialPaths: <String>[shot.path],
          title: 'Send photo',
        ),
      ),
    );

    if (!mounted || preview == null || preview.paths.isEmpty) return;

    for (final path in preview.paths) {
      final mime = lookupMimeType(path) ?? 'image/jpeg';
      await _sendMediaFile(
        detail,
        path,
        kind: 'IMAGE',
        caption: preview.caption,
        fileName: path.split('/').last,
        mimeType: mime,
      );
    }
  }

  Future<void> _micHoldStart(LongPressStartDetails d) async {
    if (_sending || _recording) return;
    _holdDx = 0;
    _holdDy = 0;
    _voiceLocked = false;
    _voicePaused = false;
    _voiceCancelled = false;
    await _toggleMic(null);
  }

  void _micHoldMove(LongPressMoveUpdateDetails d) {
    if (!_recording) return;
    setState(() {
      _holdDx = d.offsetFromOrigin.dx;
      _holdDy = d.offsetFromOrigin.dy;
      if (_holdDx < -88) _voiceCancelled = true;
      if (_holdDy < -88) _voiceLocked = true;
    });
  }

  Future<void> _micHoldEnd(LongPressEndDetails d) async {
    if (!_recording) return;
    if (_voiceCancelled) {
      await _cancelVoiceDraft();
      return;
    }
    if (_voiceLocked) {
      if (mounted) setState(() {});
      return;
    }
    await _toggleMic(null);
  }

  Future<void> _micHoldCancel() async {
    if (!_recording || _voiceLocked) return;
    await _cancelVoiceDraft();
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

    if (!mounted) return;
    setState(() {
      _recording = false;
      _voiceLocked = false;
      _voicePaused = false;
      _voiceCancelled = false;
      _holdDx = 0;
      _holdDy = 0;
      _recordingPath = null;
    });
  }

  Widget _recordHud() {
    if (!_recording) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final locked = _voiceLocked;
    final cancelling = _voiceCancelled;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(
            cancelling
                ? Icons.delete_outline_rounded
                : (locked ? Icons.lock_rounded : Icons.mic_rounded),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cancelling
                  ? 'Release to cancel'
                  : (locked
                        ? (_voicePaused
                              ? 'Recording paused • tap mic to send'
                              : 'Recording locked • tap mic to send')
                        : 'Hold to record • slide left to cancel • slide up to lock'),
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMic(MessageThreadDetail? detail) async {
    if (_sending) return;

    if (_recording) {
      final stoppedPath = await _recorder.stop();

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

    if (!mounted) return;
    setState(() {
      _recording = true;
      _recordingPath = path;
      _voicePaused = false;
      _voiceCancelled = false;
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
    await showModalBottomSheet<void>(
      context: modalContext,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Message info')),
            ListTile(title: const Text('Sent'), subtitle: Text(row.timeLabel)),
            ListTile(
              title: const Text('Delivered'),
              subtitle: Text(row.timeLabel),
            ),
            ListTile(
              title: const Text('Seen'),
              subtitle: Text(row.isMine ? row.timeLabel : '—'),
            ),
            ListTile(title: const Text('Type'), subtitle: Text(row.kind)),
          ],
        ),
      ),
    );
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(messagesRepositoryProvider)
                  .markThreadRead(threadId: widget.threadId);
              ref.invalidate(messagesInboxProvider);
            });

            final rows = detail.messages;
            _lastRows = rows;
            final replyingText = _replyIndex == null
                ? ''
                : rows[_replyIndex!].text;

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
                      CircleAvatar(child: Text(_avatarText(detail))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          detail.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!detail.canSend ||
                    detail.requestState == ChatRequestState.pendingOutgoing ||
                    detail.requestState == ChatRequestState.pendingIncoming)
                  _pendingBanner(context, detail),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final startsGroup = _startsGroup(rows, index);
                      final endsGroup = _endsGroup(rows, index);

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
                            onHorizontalDragEnd: (_) {
                              setState(() => _replyIndex = index);
                            },
                            onLongPress: () async {
                              final navigator = Navigator.of(context);
                              final selected =
                                  await showModalBottomSheet<String>(
                                    context: navigator.context,
                                    showDragHandle: true,
                                    builder: (sheetContext) => SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MessageReactionBar(
                                            onReact: (reaction) {
                                              Navigator.of(
                                                sheetContext,
                                              ).pop('react:$reaction');
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.reply_rounded,
                                            ),
                                            title: const Text('Reply'),
                                            onTap: () => Navigator.of(
                                              sheetContext,
                                            ).pop('reply'),
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.info_outline_rounded,
                                            ),
                                            title: const Text('Message info'),
                                            onTap: () => Navigator.of(
                                              sheetContext,
                                            ).pop('info'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );

                              if (!mounted || selected == null) return;

                              if (selected == 'reply') {
                                setState(() => _replyIndex = index);
                                return;
                              }

                              if (selected.startsWith('react:')) {
                                final reaction = selected
                                    .substring('react:'.length)
                                    .trim();
                                if (reaction.isEmpty) return;
                                setState(() {
                                  _reactionByMessageId[row.id] = reaction;
                                });
                                return;
                              }

                              if (selected == 'info') {
                                await _openMessageInfoSheet(
                                  navigator.context,
                                  row,
                                );
                              }
                            },
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
                                      bottom: 4,
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.push_pin_rounded,
                                          size: 12,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pinned',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                  reaction:
                                      _reactionByMessageId[row.id] ??
                                      row.reaction,
                                  replySender: row.replyPreview?.senderName,
                                  replySnippet: row.replyPreview?.text,
                                  maxWidth: 340,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_replyIndex != null)
                  MessageReplyPreview(
                    sender: rows[_replyIndex!].isMine
                        ? 'You'
                        : rows[_replyIndex!].senderName,
                    text: replyingText,
                    onCancel: () {
                      setState(() => _replyIndex = null);
                    },
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
                    if (_recording && _voiceLocked) {
                      await _toggleMic(detail);
                      return;
                    }
                    await _toggleMic(detail);
                  },
                  onMicHoldStart: _micHoldStart,
                  onMicHoldMove: _micHoldMove,
                  onMicHoldEnd: _micHoldEnd,
                  onMicHoldCancel: _micHoldCancel,
                  onTrashRecording: _cancelVoiceDraft,
                  onPauseRecording: _pauseVoiceRecord,
                  onResumeRecording: _resumeVoiceRecord,
                  enabled: detail.canSend && !_sending,
                  isRecording: _recording,
                  isVoiceLocked: _voiceLocked,
                  isVoicePaused: _voicePaused,
                  hintText: detail.canSend
                      ? (_sending ? 'Sending…' : 'Message')
                      : 'Waiting for approval',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
