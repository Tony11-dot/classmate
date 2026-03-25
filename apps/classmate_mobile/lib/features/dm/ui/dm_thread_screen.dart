// ignore_for_file: use_build_context_synchronously, unused_element
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../chat_core/ui/chat_composer.dart';
import '../../chat_core/ui/chat_media_preview_screen.dart';
import '../../chat_core/ui/chat_camera_capture_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final composer = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _draftVoicePlayer = AudioPlayer();

  bool _sending = false;
  bool _recording = false;
  bool _voiceLocked = false;
  bool _voicePaused = false;
  bool _voiceCancelled = false;
  double _holdDx = 0;
  double _holdDy = 0;
  String? _draftVoicePath;
  bool _draftVoicePlaying = false;
  double _draftVoiceSpeed = 1.0;
  Duration _draftVoicePosition = Duration.zero;
  Duration _draftVoiceDuration = Duration.zero;
  bool _draftVoiceReady = false;
  final List<Map<String, String>> _draftAttachments = <Map<String, String>>[];

  DmMessage? replyingTo;
  final Map<String, String> _localEdits = <String, String>{};
  final Set<String> _localDeleted = <String>{};
  final Set<String> _selectedMessageIds = <String>{};
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
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ChatAvatar(
                        name: meta.title,
                        size: 84,
                        avatarUrl: _absoluteThreadAvatarUrl(meta.avatarUrl),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        meta.title.trim().isEmpty
                            ? (meta.isGroup ? 'Group' : 'Student')
                            : meta.title.trim(),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
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

  String _absoluteThreadAvatarUrl(String? raw) {
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
              title: Text(
                !kIsWeb && (Platform.isAndroid || Platform.isIOS)
                    ? 'Take photo'
                    : 'Choose image',
              ),
              onTap: () => Navigator.pop(
                context,
                !kIsWeb && (Platform.isAndroid || Platform.isIOS)
                    ? 'camera'
                    : 'camera_unavailable',
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
    if (action == 'camera_unavailable') {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera capture is available on mobile builds. On macOS this button cannot open a real camera yet.',
          ),
        ),
      );
      return;
    } else if (action == 'camera') {
      if (!mounted) return;
      final camera = await Navigator.of(context).push<ChatCameraCaptureResult>(
        MaterialPageRoute(
          builder: (_) => const ChatCameraCaptureScreen(title: 'Camera'),
        ),
      );
      if (camera == null || camera.paths.isEmpty) return;
      path = camera.paths.first;
    } else {
      final picked = await FilePicker.platform.pickFiles(type: FileType.image);
      path = picked?.files.single.path;
    }

    if (path == null || path.trim().isEmpty || !mounted) return;

    final safePath = path;
    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) =>
            ChatMediaPreviewScreen(initialPaths: [safePath], title: 'Preview'),
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _sending = true);
    try {
      for (final safePath in result.paths) {
        await repo.sendImage(widget.threadId, safePath, DmMediaMode.keep);
      }
      if (result.caption.trim().isNotEmpty) {
        await repo.sendText(widget.threadId, result.caption.trim());
      }
      ref.invalidate(dmMessagesProvider(widget.threadId));
      ref.invalidate(dmThreadsProvider);
      _pinDmToBottom(jump: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickFile(DmRepository repo) async {
    final mode = await _pickMode(context);
    if (mode == null) {
      return;
    }

    final picked = await FilePicker.platform.pickFiles(type: FileType.any);
    final path = picked?.files.single.path;
    if (path == null || path.trim().isEmpty || !mounted) return;

    final safePath = path;
    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) =>
            ChatMediaPreviewScreen(initialPaths: [safePath], title: 'Preview'),
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _sending = true);
    try {
      for (final pth in result.paths) {
        await repo.sendFile(widget.threadId, pth, DmMediaMode.keep);
      }
      if (result.caption.trim().isNotEmpty) {
        await repo.sendText(widget.threadId, result.caption.trim());
      }
      ref.invalidate(dmMessagesProvider(widget.threadId));
      ref.invalidate(dmThreadsProvider);
      _pinDmToBottom(jump: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openDirectCamera() async {
    if (!mounted) return;

    final camera = await Navigator.of(context).push<ChatCameraCaptureResult>(
      MaterialPageRoute(
        builder: (_) => const ChatCameraCaptureScreen(title: 'Camera'),
      ),
    );
    if (camera == null || camera.paths.isEmpty || !mounted) return;

    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) => ChatMediaPreviewScreen(
          initialPaths: camera.paths,
          title: 'Preview',
        ),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      for (final path in result.paths) {
        _draftAttachments.add(<String, String>{
          'path': path,
          'name': path.split('/').last,
          'kind': 'FILE',
        });
      }
      if (result.caption.trim().isNotEmpty) {
        final current = composer.text.trim();
        composer.text = current.isEmpty
            ? result.caption.trim()
            : '$current\n${result.caption.trim()}';
        composer.selection = TextSelection.fromPosition(
          TextPosition(offset: composer.text.length),
        );
      }
    });
  }

  Future<void> _forwardMessageLocal(DmMessage message) async {
    final text = editableBodyText(message.text).trim();
    if (text.isEmpty) return;

    final payload = 'Forwarded message\n$text';
    final current = composer.text.trim();
    composer.text = current.isEmpty ? payload : '$current\n\n$payload';
    composer.selection = TextSelection.fromPosition(
      TextPosition(offset: composer.text.length),
    );

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Forwarded to composer')));
  }

  Future<void> _micHoldStart(LongPressStartDetails d) async {
    if (_sending || _recording) return;
    _holdDx = 0;
    _holdDy = 0;
    _voiceLocked = false;
    _voiceCancelled = false;
    await _toggleMic(ref.read(dmRepositoryProvider));
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
    await _toggleMic(ref.read(dmRepositoryProvider));
  }

  Future<void> _micHoldCancel() async {
    if (!_recording) return;
    if (_voiceLocked) return;
    await _cancelVoiceDraft();
  }

  Future<void> _pauseVoiceRecord() async {
    if (!_recording || !_voiceLocked) return;
    try {
      await _recorder.pause();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _voicePaused = true);
  }

  Future<void> _resumeVoiceRecord() async {
    if (!_recording || !_voiceLocked) return;
    try {
      await _recorder.resume();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _voicePaused = false);
  }

  Future<void> _cancelVoiceDraft() async {
    try {
      await _recorder.stop();
    } catch (_) {}
    try {
      final p = (_draftVoicePath ?? '').trim();
      if (p.isNotEmpty) {
        final f = File(p);
        if (await f.exists()) {
          await f.delete();
        }
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _recording = false;
      _voiceLocked = false;
      _voicePaused = false;
      _voiceCancelled = false;
      _holdDx = 0;
      _holdDy = 0;
      _draftVoicePath = null;
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
                        ? 'Recording locked • tap mic/stop to finish'
                        : 'Hold to record • slide left to cancel • slide up to lock'),
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
        _draftVoicePlaying = false;
        _draftVoiceReady = false;
        _draftVoicePosition = Duration.zero;
        _draftVoiceDuration = Duration.zero;
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

  Future<void> _toggleDraftVoicePlayback() async {
    final path = (_draftVoicePath ?? '').trim();
    if (path.isEmpty) {
      return;
    }

    try {
      if (_draftVoicePlaying) {
        await _draftVoicePlayer.pause();
        if (mounted) {
          setState(() => _draftVoicePlaying = false);
        }
        return;
      }

      if (!_draftVoiceReady) {
        await _draftVoicePlayer.setFilePath(path);
        _draftVoiceReady = true;
      }

      await _draftVoicePlayer.setSpeed(_draftVoiceSpeed);

      if (_draftVoiceDuration > Duration.zero &&
          _draftVoicePosition >= _draftVoiceDuration) {
        await _draftVoicePlayer.seek(Duration.zero);
        if (mounted) {
          setState(() => _draftVoicePosition = Duration.zero);
        }
      }

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

  Future<void> _seekDraftVoiceToRatio(double ratio) async {
    final totalMs = _draftVoiceDuration.inMilliseconds <= 0
        ? 1
        : _draftVoiceDuration.inMilliseconds;
    final target = Duration(
      milliseconds: (totalMs * ratio.clamp(0.0, 1.0)).round(),
    );

    try {
      if (!_draftVoiceReady) {
        final path = (_draftVoicePath ?? '').trim();
        if (path.isEmpty) {
          return;
        }
        await _draftVoicePlayer.setFilePath(path);
        _draftVoiceReady = true;
        await _draftVoicePlayer.setSpeed(_draftVoiceSpeed);
      }
      await _draftVoicePlayer.seek(target);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _draftVoicePosition = target;
      });
    }
  }

  String _fmtDuration(Duration d) {
    final total = d.inSeconds;
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _seekDraftVoice(double value) async {
    if (!_draftVoiceReady || _draftVoiceDuration == Duration.zero) return;
    final ms = (_draftVoiceDuration.inMilliseconds * value).round();
    await _draftVoicePlayer.seek(Duration(milliseconds: ms));
    if (!mounted) return;
    setState(() {
      _draftVoicePosition = Duration(milliseconds: ms);
    });
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

    HapticFeedback.lightImpact();
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
          decoration: const InputDecoration(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) Navigator.pop(context, true);
            },
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

  Future<void> _confirmBlockToggle(DmRepository repo, bool blocked) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(blocked ? 'Unblock user?' : 'Block user?'),
        content: Text(
          blocked
              ? 'They will be able to message you again.'
              : 'You will stop receiving messages from this user.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) Navigator.pop(context, true);
            },
            child: Text(blocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    if (blocked) {
      await repo.unblockUser(widget.threadId);
    } else {
      await repo.blockUser(widget.threadId);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(blocked ? 'User unblocked' : 'User blocked')),
    );
    ref.invalidate(dmThreadsProvider);
  }

  Future<void> _openWhatsAppStyleMenu(
    DmRepository repo,
    DmMessage message,
  ) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in const ['❤️', '👍', '😂', '😮', '😢', '🙏'])
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => Navigator.pop(context, 'react:$e'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Text(e, style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _waAction(
                      Icons.reply_rounded,
                      'Reply',
                      () => Navigator.pop(context, 'reply'),
                    ),
                    _waAction(
                      Icons.copy_rounded,
                      'Copy',
                      () => Navigator.pop(context, 'copy'),
                    ),
                    if (message.isMine)
                      _waAction(
                        Icons.edit_outlined,
                        'Edit',
                        () => Navigator.pop(context, 'edit'),
                      ),
                    if (message.isMine)
                      _waAction(
                        Icons.delete_outline_rounded,
                        'Delete',
                        () => Navigator.pop(context, 'delete'),
                      ),
                    _waAction(
                      Icons.forward_to_inbox_rounded,
                      'Forward',
                      () => Navigator.pop(context, 'forward'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (chosen == null) return;
    if (chosen.startsWith('react:')) {
      await _pickReaction(repo, message);
      return;
    }
    switch (chosen) {
      case 'reply':
        setState(() => replyingTo = message);
        return;
      case 'copy':
        await Clipboard.setData(
          ClipboardData(text: editableBodyText(message.text)),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Copied')));
        return;
      case 'edit':
        await _editMessage(message);
        return;
      case 'delete':
        setState(() => _localDeleted.add(message.id));
        return;
      case 'forward':
        await _forwardMessageLocal(message);
        return;
    }
  }

  Widget _waAction(IconData icon, String label, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }

  IconData _statusIconForMessage(DmMessage message) {
    final t = (message.text).toLowerCase();
    if (t.contains('[failed]')) return Icons.error_outline_rounded;
    if (t.contains('[read]')) return Icons.done_all_rounded;
    if (t.contains('[delivered]')) return Icons.done_all_rounded;
    return Icons.done_rounded;
  }

  Color _statusColorForMessage(BuildContext context, DmMessage message) {
    final t = (message.text).toLowerCase();
    if (t.contains('[failed]')) return Theme.of(context).colorScheme.error;
    if (t.contains('[read]')) return const Color(0xFF34B7F1);
    if (t.contains('[delivered]')) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Future<void> _showWaMessageActionsAt(
    DmRepository repo,
    DmMessage message,
    Offset globalPosition,
  ) async {
    final overlay = Overlay.of(context);
    final box = overlay.context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalPosition);

    const menuWidth = 188.0;
    const menuHeight = 354.0;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final left = local.dx.clamp(10.0, box.size.width - menuWidth - 10.0);
        double top = local.dy + 26;
        if (top > box.size.height - menuHeight - 10) {
          top = local.dy - menuHeight - 14;
        }
        top = top.clamp(10.0, box.size.height - menuHeight - 10.0);

        return Material(
          color: Colors.black.withValues(alpha: 0.12),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => entry.remove(),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                left: left,
                top: top,
                child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(width: menuWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 2,
                          runSpacing: 2,
                          children: [
                            for (final e in const [
                              '❤️',
                              '👍',
                              '😂',
                              '😮',
                              '😢',
                              '🙏',
                            ])
                              InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () async {
                                  entry.remove();
                                  setState(
                                    () => _localReactions[message.id] = e,
                                  );
                                  try {
                                    await repo.react(message.id, e);
                                    ref.invalidate(
                                      dmMessagesProvider(widget.threadId),
                                    );
                                    ref.invalidate(dmThreadsProvider);
                                  } catch (_) {}
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 5,
                                  ),
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _waMenuTile(
                              context,
                              icon: Icons.reply_rounded,
                              label: 'Reply',
                              onTap: () {
                                entry.remove();
                                setState(() => replyingTo = message);
                              },
                            ),
                            _waMenuTile(
                              context,
                              icon: Icons.copy_rounded,
                              label: 'Copy',
                              onTap: () async {
                                entry.remove();
                                await Clipboard.setData(
                                  ClipboardData(
                                    text: editableBodyText(message.text),
                                  ),
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied')),
                                );
                              },
                            ),
                            if (message.isMine)
                              _waMenuTile(
                                context,
                                icon: Icons.edit_rounded,
                                label: 'Edit',
                                onTap: () async {
                                  entry.remove();
                                  await _editMessage(message);
                                },
                              ),
                            _waMenuTile(
                              context,
                              icon: Icons.forward_rounded,
                              label: 'Forward',
                              onTap: () async {
                                entry.remove();
                                await _forwardMessageLocal(message);
                              },
                            ),
                            _waMenuTile(
                              context,
                              icon: Icons.checklist_rounded,
                              label: _selectedMessageIds.contains(message.id)
                                  ? 'Unselect'
                                  : 'Select',
                              onTap: () {
                                entry.remove();
                                setState(() {
                                  if (_selectedMessageIds.contains(
                                    message.id,
                                  )) {
                                    _selectedMessageIds.remove(message.id);
                                  } else {
                                    _selectedMessageIds.add(message.id);
                                  }
                                });
                              },
                            ),
                            if (message.isMine)
                              _waMenuTile(
                                context,
                                icon: Icons.delete_outline_rounded,
                                label: 'Delete',
                                onTap: () {
                                  entry.remove();
                                  setState(() => _localDeleted.add(message.id));
                                  ref.invalidate(
                                    dmMessagesProvider(widget.threadId),
                                  );
                                  ref.invalidate(dmThreadsProvider);
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    overlay.insert(entry);
  }

  Future<void> _showWaMessageActionsLegacy(
    DmRepository repo,
    DmMessage message,
    Offset globalPosition,
  ) async {
    final overlay = Overlay.of(context);
    final box = overlay.context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalPosition);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.22),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => entry.remove(),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: (local.dx - 150).clamp(12, box.size.width - 312),
              top: (local.dy - 118).clamp(18, box.size.height - 190),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final e in const [
                            '❤️',
                            '👍',
                            '😂',
                            '😮',
                            '😢',
                            '🙏',
                          ])
                            InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () async {
                                entry.remove();
                                setState(() => _localReactions[message.id] = e);
                                try {
                                  await repo.react(message.id, e);
                                  ref.invalidate(
                                    dmMessagesProvider(widget.threadId),
                                  );
                                  ref.invalidate(dmThreadsProvider);
                                } catch (_) {}
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Text(
                                  e,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _waTopAction(
                            context,
                            icon: Icons.reply_rounded,
                            label: 'Reply',
                            onTap: () {
                              entry.remove();
                              setState(() => replyingTo = message);
                            },
                          ),
                          _waTopAction(
                            context,
                            icon: Icons.copy_rounded,
                            label: 'Copy',
                            onTap: () async {
                              entry.remove();
                              await Clipboard.setData(
                                ClipboardData(
                                  text: editableBodyText(message.text),
                                ),
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied')),
                              );
                            },
                          ),
                          if (message.isMine)
                            _waTopAction(
                              context,
                              icon: Icons.edit_rounded,
                              label: 'Edit',
                              onTap: () async {
                                entry.remove();
                                await _editMessage(message);
                              },
                            ),
                          if (message.isMine)
                            _waTopAction(
                              context,
                              icon: Icons.delete_outline_rounded,
                              label: 'Delete',
                              onTap: () {
                                entry.remove();
                                setState(() => _localDeleted.add(message.id));
                                ref.invalidate(
                                  dmMessagesProvider(widget.threadId),
                                );
                                ref.invalidate(dmThreadsProvider);
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    overlay.insert(entry);
  }

  Widget _waMenuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waTopAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
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

    if (emoji == null) return;

    setState(() {
      _localReactions[message.id] = emoji;
    });

    try {
      await repo.react(message.id, emoji);
      ref.invalidate(dmMessagesProvider(widget.threadId));
      ref.invalidate(dmThreadsProvider);
    } catch (_) {}
  }

  Widget _dmVoiceDraftChip() {
    Widget seekBar() {
      final totalMs = _draftVoiceDuration.inMilliseconds;
      final posMs = _draftVoicePosition.inMilliseconds.clamp(
        0,
        totalMs <= 0 ? 0 : totalMs,
      );
      final ratio = totalMs <= 0 ? 0.0 : posMs / totalMs.toDouble();

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) async {
          if (!_draftVoiceReady || _draftVoiceDuration == Duration.zero) return;
          final box = context.findRenderObject();
          if (box is! RenderBox) return;
          final local = box.globalToLocal(details.globalPosition);
          final width = box.size.width <= 0 ? 1.0 : box.size.width;
          final next = (local.dx / width).clamp(0.0, 1.0);
          await _seekDraftVoiceToRatio(next);
        },
        child: SizedBox(
          height: 22,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(-1 + (ratio * 2), 0),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF171D24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggleDraftVoicePlayback,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                _draftVoicePlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 120, maxWidth: 158),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                seekBar(),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _fmtDuration(_draftVoicePosition),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cycleDraftVoiceSpeed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _draftVoiceSpeed == 1.0
                              ? '1x'
                              : _draftVoiceSpeed == 1.5
                              ? '1.5x'
                              : '2x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => setState(() {
              _draftVoicePath = null;
              _draftVoiceReady = false;
              _draftVoicePlaying = false;
              _draftVoiceDuration = Duration.zero;
              _draftVoicePosition = Duration.zero;
            }),
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dmAttachmentChip(Map<String, String> a) {
    final kind = (a['kind'] ?? '').trim().toUpperCase();
    final name = (a['name'] ?? a['path'] ?? 'Attachment').trim();
    final isImage = kind == 'IMAGE';

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF171D24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              isImage ? Icons.image_outlined : Icons.insert_drive_file_outlined,
              size: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => setState(() => _draftAttachments.remove(a)),
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close_rounded, size: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dmDraftBar() {
    if (_draftAttachments.isEmpty && (_draftVoicePath ?? '').trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final a in _draftAttachments) _dmAttachmentChip(a),
            if ((_draftVoicePath ?? '').trim().isNotEmpty) _dmVoiceDraftChip(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _draftVoicePlayer.positionStream.listen((value) {
      if (!mounted || false) {
        return;
      }
      setState(() {
        _draftVoicePosition = value;
      });
    });
    _draftVoicePlayer.durationStream.listen((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _draftVoiceDuration = value ?? Duration.zero;
      });
    });
    _draftVoicePlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        try {
          await _draftVoicePlayer.pause();
          await _draftVoicePlayer.seek(Duration.zero);
        } catch (_) {}
        if (!mounted) {
          return;
        }
        setState(() {
          _draftVoicePlaying = false;
          _draftVoicePosition = Duration.zero;
        });
        return;
      }
      if (!mounted) {
        return;
      }
      if (_draftVoicePlaying != _draftVoicePlayer.playing) {
        setState(() {
          _draftVoicePlaying = _draftVoicePlayer.playing;
        });
      }
    });
    _draftVoicePlayer.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      final playingNow = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _draftVoicePlayer.seek(Duration.zero);
      }
      if (_draftVoicePlaying != playingNow) {
        setState(() => _draftVoicePlaying = playingNow);
      }
    });
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
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Message request',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${meta.title} wants to start a chat with you.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 3),
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
                          const SizedBox(width: 3),
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
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openThreadProfile(meta: meta),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ChatAvatar(
                    name: meta.title,
                    size: 22,
                    avatarUrl: _absoluteThreadAvatarUrl(meta.avatarUrl),
                  ),
                  const SizedBox(width: 3),
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
                  await _confirmBlockToggle(repo, meta.isBlocked);
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
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Start the conversation',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
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
                                cacheExtent: 900,
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: true,
                                padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
                                itemCount: visible.length,
                                itemBuilder: (context, i) {
                                  final message = visible[i];
                                  final isMine =
                                      message.isMine ||
                                      message.senderName.trim().toLowerCase() ==
                                          'you';
                                  final swipeDx =
                                      _swipeDxByMessage[message.id] ?? 0.0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: Row(
                                      mainAxisAlignment: isMine
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
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
                                            onLongPressStart: (d) =>
                                                _showWaMessageActionsAt(
                                                  repo,
                                                  message,
                                                  d.globalPosition,
                                                ),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                if (_selectedMessageIds
                                                    .isNotEmpty)
                                                  Positioned(
                                                    left: -28,
                                                    right: null,
                                                    top: 10,
                                                    child: Icon(
                                                      _selectedMessageIds
                                                              .contains(
                                                                message.id,
                                                              )
                                                          ? Icons
                                                                .check_circle_rounded
                                                          : Icons
                                                                .radio_button_unchecked_rounded,
                                                      size: 22,
                                                      color:
                                                          _selectedMessageIds
                                                              .contains(
                                                                message.id,
                                                              )
                                                          ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .outline,
                                                    ),
                                                  ),
                                                if (swipeDx.abs() > 10)
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
                                                    showName: false,
                                                    senderLabel: isMine
                                                        ? ''
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
                                        if (isMine) const SizedBox(width: 3),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: showScroll
                                  ? FloatingActionButton.small(
                                      heroTag: 'dm-scroll-bottom',
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dmDraftBar(),
                  ChatComposer(
                    controller: composer,
                    onSend: () {
                      if (_sending || _recording) return;
                      _sendText(repo);
                    },
                    onAttach: () {
                      if (_sending || _recording) return;
                      _pickFile(repo);
                    },
                    onCamera: _openDirectCamera,
                    onMic: () {
                      if (_sending) return;
                      if (_recording && _voiceLocked) {
                        _toggleMic(repo);
                        return;
                      }
                      _toggleMic(repo);
                    },
                    onMicHoldStart: _micHoldStart,
                    onMicHoldMove: _micHoldMove,
                    onMicHoldEnd: _micHoldEnd,
                    onMicHoldCancel: _micHoldCancel,
                    isRecording: _recording,
                    isVoiceLocked: _voiceLocked,
                    isVoicePaused: _voicePaused,
                    onTrashRecording: _cancelVoiceDraft,
                    onPauseRecording: _pauseVoiceRecord,
                    onResumeRecording: _resumeVoiceRecord,
                  ),
                ],
              ),
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
  const _ChatAvatar({required this.name, this.size = 40, this.avatarUrl});

  final String name;
  final double size;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final text = parts.isEmpty
        ? 'DM'
        : parts.length == 1
        ? parts.first
              .substring(0, parts.first.length >= 2 ? 2 : 1)
              .toUpperCase()
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();

    final safeAvatar = (avatarUrl ?? '').trim();

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.white.withValues(alpha: 0.10),
      backgroundImage: safeAvatar.isNotEmpty ? NetworkImage(safeAvatar) : null,
      child: safeAvatar.isNotEmpty
          ? null
          : Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: size * 0.28,
              ),
            ),
    );
  }
}
