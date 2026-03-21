// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import '../../chat_core/utils/chat_reply_codec.dart';
import '../../chat_core/ui/chat_message_bubble.dart';

import '../data/dm_repository.dart';
import '../domain/dm_models.dart';
import '../providers/dm_providers.dart';

class DmThreadScreen extends ConsumerStatefulWidget {
  const DmThreadScreen({super.key, required this.threadId});
  final String threadId;

  @override
  ConsumerState<DmThreadScreen> createState() => _DmThreadScreenState();
}

class _DmThreadScreenState extends ConsumerState<DmThreadScreen> {
  final _imagePicker = ImagePicker();
  final composer = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _draftVoicePlayer = AudioPlayer();

  bool _sending = false;
  bool _recording = false;
  String? _draftVoicePath;
  String? _draftVoiceName;
  bool _draftVoicePlaying = false;
  double _draftVoiceSpeed = 1.0;
  final List<Map<String, String>> _draftAttachments = <Map<String, String>>[];

  DmMessage? replyingTo;
  final Map<String, String> _localEdits = <String, String>{};
  final Set<String> _localDeleted = <String>{};
  final Map<String, String> _localReactions = <String, String>{};
  final Map<String, double> _swipeDxByMessage = <String, double>{};
  final ScrollController _chatScrollCtl = ScrollController();
  final ValueNotifier<bool> _showDmScrollToBottom = ValueNotifier<bool>(false);
  int _lastVisibleCount = -1;

  Future<DmMediaMode?> _pickMode(BuildContext context) async {
    return DmMediaMode.keep;
  }

  String _uploadsBaseUrl() {
    final raw = const String.fromEnvironment(
      'CM_API_BASE_URL',
      defaultValue: 'http://127.0.0.1:3001/api',
    ).trim();
    final noSlash = raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
    return noSlash.endsWith('/api')
        ? noSlash.substring(0, noSlash.length - 4)
        : noSlash;
  }

  void _handleDmScroll() {
    if (!_chatScrollCtl.hasClients) {
      return;
    }
    final pos = _chatScrollCtl.position;
    final distance = pos.maxScrollExtent - pos.pixels;
    _showDmScrollToBottom.value = distance > 120;
  }

  void _pinDmToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_chatScrollCtl.hasClients) {
        return;
      }

      double target() {
        if (!_chatScrollCtl.hasClients) return 0;
        return _chatScrollCtl.position.maxScrollExtent;
      }

      try {
        if (jump) {
          _chatScrollCtl.jumpTo(target());
        } else {
          await _chatScrollCtl.animateTo(
            target(),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      } catch (_) {}

      for (final delay in const [16, 32, 64]) {
        if (!mounted || !_chatScrollCtl.hasClients) {
          return;
        }
        await Future<void>.delayed(Duration(milliseconds: delay));
        if (!mounted || !_chatScrollCtl.hasClients) {
          return;
        }
        final exact = target();
        final current = _chatScrollCtl.offset;
        if ((exact - current).abs() > 0.5) {
          try {
            _chatScrollCtl.jumpTo(exact);
          } catch (_) {}
        }
      }
    });
  }

  void _openThreadProfile({required DmThread meta}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(meta.isGroup ? 'Group info' : 'Profile')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ChatAvatar(name: meta.title, size: 84),
                      const SizedBox(height: 16),
                      Text(
                        meta.title.trim().isEmpty
                            ? (meta.isGroup ? 'Group' : 'Student')
                            : meta.title.trim(),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meta.isGroup ? 'Group chat' : 'Direct chat',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _absoluteMediaUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '';
    if (value.startsWith('file:///uploads/')) {
      final repaired = value.replaceFirst('file://', '');
      final base = _uploadsBaseUrl();
      return repaired.startsWith('/') ? '$base$repaired' : '$base/$repaired';
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final base = _uploadsBaseUrl();
    return value.startsWith('/') ? '$base$value' : '$base/$value';
  }

  Future<void> _showImageSourceSheet(DmRepository repo) async {
    final mode = await _pickMode(context);
    if (mode == null) {
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(
                context,
                !kIsWeb && (Platform.isAndroid || Platform.isIOS)
                    ? 'camera'
                    : 'gallery',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (action == null) {
      return;
    }

    String? path;
    if (action == 'camera') {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      path = picked?.path;
    } else {
      final picked = await FilePicker.platform.pickFiles(type: FileType.image);
      path = picked?.files.single.path;
    }

    if (path == null || path.trim().isEmpty) return;

    final safePath = path;
    if (!mounted) {
      return;
    }
    setState(() {
      _draftAttachments.add(<String, String>{
        'kind': 'IMAGE',
        'path': safePath,
        'name': safePath.split('/').last,
      });
    });
  }

  Future<void> _pickFile(DmRepository repo) async {
    final mode = await _pickMode(context);
    if (mode == null) {
      return;
    }

    final picked = await FilePicker.platform.pickFiles(type: FileType.any);
    final path = picked?.files.single.path;
    if (path == null || path.trim().isEmpty) return;

    final safePath = path;
    if (!mounted) {
      return;
    }
    setState(() {
      _draftAttachments.add(<String, String>{
        'kind': 'FILE',
        'path': safePath,
        'name': safePath.split('/').last,
      });
    });
  }

  Future<void> _toggleMic(DmRepository repo) async {
    if (_sending) {
      return;
    }

    if (_recording) {
      final path = await _recorder.stop();
      if (!mounted) {
        return;
      }
      setState(() => _recording = false);

      if (path == null || path.trim().isEmpty) return;

      setState(() {
        _draftVoicePath = path;
        _draftVoiceName = path.split('/').last;
      });
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    final dir = Directory.systemTemp;
    final filePath =
        '${dir.path}/dm-voice-${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: filePath,
    );

    if (!mounted) {
      return;
    }
    setState(() => _recording = true);
  }

  Widget _dmDraftChip(Map<String, String> a) {
    final path = (a['path'] ?? '').trim();
    final name = (a['name'] ?? 'file').trim();
    final kind = (a['kind'] ?? '').trim().toUpperCase();
    final isImage = kind == 'IMAGE';

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161C23),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(path),
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.insert_drive_file_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => setState(() => _draftAttachments.remove(a)),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleDraftVoicePlayback() async {
    final path = (_draftVoicePath ?? '').trim();
    if (path.isEmpty) {
      return;
    }

    try {
      if (_draftVoicePlaying) {
        await _draftVoicePlayer.stop();
        if (mounted) {
          setState(() => _draftVoicePlaying = false);
        }
        return;
      }

      await _draftVoicePlayer.stop();
      await _draftVoicePlayer.setFilePath(path);
      await _draftVoicePlayer.setSpeed(_draftVoiceSpeed);
      await _draftVoicePlayer.play();

      if (mounted) {
        setState(() => _draftVoicePlaying = true);
      }
    } catch (_) {}
  }

  Future<void> _cycleDraftVoiceSpeed() async {
    final next = _draftVoiceSpeed == 1.0
        ? 1.5
        : _draftVoiceSpeed == 1.5
        ? 2.0
        : 1.0;

    if (mounted) {
      setState(() => _draftVoiceSpeed = next);
    }

    if (_draftVoicePlaying) {
      try {
        await _draftVoicePlayer.setSpeed(_draftVoiceSpeed);
      } catch (_) {}
    }
  }

  Widget _dmVoiceDraftChip() {
    final name = (_draftVoiceName ?? 'Voice note').trim();
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161C23),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggleDraftVoicePlayback,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                _draftVoicePlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _cycleDraftVoiceSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _draftVoiceSpeed == 1.0
                    ? '1x'
                    : _draftVoiceSpeed == 1.5
                    ? '1.5x'
                    : '2x',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () async {
              await _draftVoicePlayer.stop();
              if (!mounted) {
                return;
              }
              setState(() {
                _draftVoicePlaying = false;
                _draftVoicePath = null;
                _draftVoiceName = null;
              });
            },
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendText(DmRepository repo) async {
    final text = composer.text.trim();
    final composedText = replyingTo != null
        ? '↪ ${replyingTo!.senderName.trim()}: ${replyPreviewText(replyingTo!.text)} — $text'
              .trim()
        : text;

    if ((text.isEmpty &&
            _draftAttachments.isEmpty &&
            (_draftVoicePath ?? '').trim().isEmpty) ||
        _sending) {
      return;
    }

    setState(() => _sending = true);
    try {
      for (final a in List<Map<String, String>>.from(_draftAttachments)) {
        final path = (a['path'] ?? '').trim();
        final kind = (a['kind'] ?? '').trim().toUpperCase();
        if (path.isEmpty) continue;
        if (kind == 'IMAGE') {
          await repo.sendImage(widget.threadId, path, DmMediaMode.keep);
        } else {
          await repo.sendFile(widget.threadId, path, DmMediaMode.keep);
        }
      }

      final voicePath = (_draftVoicePath ?? '').trim();
      if (voicePath.isNotEmpty) {
        await _draftVoicePlayer.stop();
        await repo.sendVoice(widget.threadId, voicePath, DmMediaMode.keep);
      }

      if (text.isNotEmpty) {
        await repo.sendText(widget.threadId, composedText);
      }

      composer.clear();
      setState(() {
        replyingTo = null;
        _draftAttachments.clear();
        _draftVoicePath = null;
        _draftVoiceName = null;
      });
      ref.invalidate(dmMessagesProvider(widget.threadId));
      ref.invalidate(dmThreadsProvider);
      _pinDmToBottom(jump: true);
      _pinDmToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _editMessage(DmMessage message) async {
    final ctl = TextEditingController(
      text: editableBodyText(_localEdits[message.id] ?? message.text),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: ctl,
          minLines: 1,
          maxLines: 6,
          decoration: const InputDecoration(hintText: 'Edit message...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) {
      return;
    }

    final finalText = preserveReplyOnEdit(
      originalRaw: message.text,
      updatedBody: ctl.text.trim(),
    );

    setState(() {
      _localEdits[message.id] = finalText;
    });

    ref.invalidate(dmMessagesProvider(widget.threadId));
    ref.invalidate(dmThreadsProvider);
  }

  Future<void> _pickReaction(DmRepository repo, DmMessage message) async {
    final emoji = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            for (final e in const ['❤️', '👍', '😂', '😮', '😢', '🔥'])
              ListTile(
                title: Text(e, style: const TextStyle(fontSize: 26)),
                onTap: () => Navigator.pop(context, e),
              ),
          ],
        ),
      ),
    );

    if (emoji == null) {
      return;
    }

    setState(() {
      _localReactions[message.id] = emoji;
    });

    try {
      await repo.react(message.id, emoji);
      ref.invalidate(dmMessagesProvider(widget.threadId));
    } catch (_) {}
  }

  Future<void> _openBubbleMenu(DmRepository repo, DmMessage message) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Reply'),
              onTap: () => Navigator.pop(context, 'reply'),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions_outlined),
              title: const Text('React'),
              onTap: () => Navigator.pop(context, 'react'),
            ),
            if (message.isMine)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
            if (message.isMine)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Delete'),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );

    if (action == 'reply') {
      setState(() => replyingTo = message);
      return;
    }
    if (action == 'react') {
      await _pickReaction(repo, message);
      return;
    }
    if (action == 'edit') {
      await _editMessage(message);
      return;
    }
    if (action == 'delete') {
      setState(() => _localDeleted.add(message.id));
      return;
    }
  }

  Widget _composerBar(DmThread meta, DmRepository repo) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2129).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, 12),
                color: Colors.black.withValues(alpha: 0.28),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyingTo != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Replying to ${replyingTo!.senderName}: ${replyPreviewText(replyingTo!.text)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => replyingTo = null),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_draftAttachments.isNotEmpty ||
                  (_draftVoicePath ?? '').trim().isNotEmpty)
                SizedBox(
                  height: 68,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._draftAttachments.map(_dmDraftChip),
                      if ((_draftVoicePath ?? '').trim().isNotEmpty)
                        _dmVoiceDraftChip(),
                    ],
                  ),
                ),
              if (_draftAttachments.isNotEmpty ||
                  (_draftVoicePath ?? '').trim().isNotEmpty)
                const SizedBox(height: 8),
              Row(
                children: [
                  _ComposerButton(
                    icon: Icons.camera_alt_rounded,
                    onTap: _sending || _recording
                        ? null
                        : () => _showImageSourceSheet(repo),
                  ),
                  const SizedBox(width: 8),
                  _ComposerButton(
                    icon: Icons.attach_file_rounded,
                    onTap: _sending || _recording
                        ? null
                        : () => _pickFile(repo),
                  ),
                  const SizedBox(width: 8),
                  _ComposerButton(
                    icon: _recording
                        ? Icons.stop_rounded
                        : Icons.mic_none_rounded,
                    onTap: _sending ? null : () => _toggleMic(repo),
                    fill: _recording
                        ? const Color(0xFF8E2E2E)
                        : const Color(0xFF1C232B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 46),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F141A).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Center(
                        child: TextField(
                          controller: composer,
                          minLines: 1,
                          maxLines: 6,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: meta.isGroup
                                ? 'Message group'
                                : 'Message',
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendText(repo),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ComposerButton(
                    icon: Icons.send_rounded,
                    onTap: _sending || _recording
                        ? null
                        : () => _sendText(repo),
                    fill: const Color(0xFF143B5C),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _chatScrollCtl.addListener(_handleDmScroll);
  }

  @override
  void dispose() {
    _chatScrollCtl.removeListener(_handleDmScroll);
    _chatScrollCtl.dispose();
    _showDmScrollToBottom.dispose();
    composer.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threadsAsync = ref.watch(dmThreadsProvider);
    final messagesAsync = ref.watch(dmMessagesProvider(widget.threadId));
    final repo = ref.read(dmRepositoryProvider);

    return threadsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (threads) {
        final meta = threads.firstWhere(
          (e) => e.id == widget.threadId,
          orElse: () => threads.first,
        );

        if (meta.requestState == DmRequestState.pendingIncoming) {
          return Scaffold(
            appBar: AppBar(title: Text(meta.title)),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message request',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${meta.title} wants to start a chat with you.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/profile'),
                        icon: const Icon(Icons.person_outline_rounded),
                        label: const Text('Open profile'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await repo.blockUser(widget.threadId);
                                ref.invalidate(dmThreadsProvider);
                              },
                              icon: const Icon(Icons.block_rounded),
                              label: const Text('Block'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                await repo.acceptRequest(widget.threadId);
                                ref.invalidate(dmThreadsProvider);
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openThreadProfile(meta: meta),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ChatAvatar(name: meta.title, size: 32),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      meta.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  if (meta.isBlocked) {
                    await repo.unblockUser(widget.threadId);
                  } else {
                    await repo.blockUser(widget.threadId);
                  }
                  ref.invalidate(dmThreadsProvider);
                },
                icon: Icon(
                  meta.isBlocked
                      ? Icons.lock_open_rounded
                      : Icons.block_rounded,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (messages) {
                    final visible = messages
                        .where((m) => !_localDeleted.contains(m.id))
                        .toList();

                    if (visible.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 28,
                                    spreadRadius: -8,
                                    color: Colors.black.withValues(alpha: 0.24),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Start the conversation',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Send a message, photo, file, or voice note.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.56),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (_lastVisibleCount != visible.length) {
                      _lastVisibleCount = visible.length;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _pinDmToBottom(jump: true);
                      });
                    }

                    return ValueListenableBuilder<bool>(
                      valueListenable: _showDmScrollToBottom,
                      builder: (_, showScroll, child) {
                        return Stack(
                          children: [
                            NotificationListener<ScrollNotification>(
                              onNotification: (_) {
                                _handleDmScroll();
                                return false;
                              },
                              child: ListView.builder(
                                controller: _chatScrollCtl,
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  18,
                                  14,
                                  8,
                                ),
                                itemCount: visible.length,
                                itemBuilder: (context, i) {
                                  final message = visible[i];
                                  final isMine =
                                      message.isMine ||
                                      message.senderName.trim().toLowerCase() ==
                                          'you';
                                  final previous = i > 0
                                      ? visible[i - 1]
                                      : null;
                                  final groupedWithPrevious =
                                      previous != null &&
                                      (previous.isMine ||
                                              previous.senderName
                                                      .trim()
                                                      .toLowerCase() ==
                                                  'you') ==
                                          isMine &&
                                      previous.senderName.trim() ==
                                          message.senderName.trim();
                                  final showAvatar = !groupedWithPrevious;
                                  final showName = !groupedWithPrevious;
                                  final swipeDx =
                                      _swipeDxByMessage[message.id] ?? 0.0;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: showAvatar ? 12 : 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: isMine
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (!isMine)
                                          SizedBox(
                                            width: 40,
                                            child: showAvatar
                                                ? _ChatAvatar(
                                                    name: message.senderName,
                                                  )
                                                : null,
                                          ),
                                        if (!isMine) const SizedBox(width: 10),
                                        Flexible(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onHorizontalDragUpdate: (details) {
                                              final next =
                                                  (swipeDx + details.delta.dx)
                                                      .clamp(0.0, 84.0);
                                              setState(() {
                                                _swipeDxByMessage[message.id] =
                                                    next;
                                              });
                                            },
                                            onHorizontalDragEnd: (_) {
                                              final current =
                                                  _swipeDxByMessage[message
                                                      .id] ??
                                                  0.0;
                                              if (current >= 44) {
                                                setState(
                                                  () => replyingTo = message,
                                                );
                                              }
                                              setState(() {
                                                _swipeDxByMessage.remove(
                                                  message.id,
                                                );
                                              });
                                            },
                                            onHorizontalDragCancel: () {
                                              setState(() {
                                                _swipeDxByMessage.remove(
                                                  message.id,
                                                );
                                              });
                                            },
                                            onLongPress: () =>
                                                _openBubbleMenu(repo, message),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                if (swipeDx.abs() > 8)
                                                  Positioned(
                                                    right: 0,
                                                    top: 28,
                                                    child: Opacity(
                                                      opacity:
                                                          (swipeDx.abs() / 72)
                                                              .clamp(0.0, 1.0),
                                                      child: Container(
                                                        width: 28,
                                                        height: 28,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withValues(
                                                                    alpha: 0.08,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Icon(
                                                          Icons.reply_rounded,
                                                          size: 16,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                Transform.translate(
                                                  offset: Offset(swipeDx, 0),
                                                  child: ChatMessageBubble(
                                                    contextForNavigation:
                                                        context,
                                                    rawText:
                                                        _localEdits[message
                                                            .id] ??
                                                        message.text,
                                                    mediaUrl: _absoluteMediaUrl(
                                                      message.mediaUrl,
                                                    ),
                                                    isMine: isMine,
                                                    showName: showName,
                                                    senderLabel: isMine
                                                        ? 'You'
                                                        : message.senderName,
                                                    timeLabel: _timeLabel(
                                                      message.createdAt,
                                                    ),
                                                    edited: _localEdits
                                                        .containsKey(
                                                          message.id,
                                                        ),
                                                    reaction:
                                                        _localReactions[message
                                                            .id],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isMine) const SizedBox(width: 10),
                                        if (isMine)
                                          SizedBox(
                                            width: 40,
                                            child: showAvatar
                                                ? _ChatAvatar(name: 'You')
                                                : null,
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: showScroll
                                  ? FloatingActionButton.small(
                                      heroTag: 'dm-scroll-bottom',
                                      backgroundColor: const Color(0xFF0A84FF),
                                      foregroundColor: Colors.white,
                                      onPressed: () =>
                                          _pinDmToBottom(jump: true),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              _composerBar(meta, repo),
            ],
          ),
        );
      },
    );
  }
}

String _timeLabel(DateTime dt) {
  final local = dt.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.name, this.size = 36});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

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
    final bg = palette[seed % palette.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ComposerButton extends StatelessWidget {
  const _ComposerButton({
    required this.icon,
    required this.onTap,
    this.fill = const Color(0xFF1C232B),
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFF121820) : fill,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: 0.22),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
