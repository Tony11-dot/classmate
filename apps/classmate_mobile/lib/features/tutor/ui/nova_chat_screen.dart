import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../chat_core/ui/chat_composer.dart';
import '../../chat_core/ui/chat_message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/media/image_viewer_screen.dart';
import '../../common/media/pdf_viewer_screen.dart';
import '../../chat_core/ui/chat_media_preview_screen.dart';
import '../../chat_core/ui/chat_camera_capture_screen.dart';
import '../../../common/widgets/cm_code_block.dart';
import '../../../ui/math/math_view.dart';
import 'chatgpt_chat_components.dart';

import '../data/tutor_repository.dart';
import '../providers/tutor_repository_provider.dart';

class _Msg {
  const _Msg({
    required this.role,
    required this.content,
    this.kind = 'TEXT',
    this.localPath,
    this.remoteUrl,
    this.fileName,
  });

  final String role;
  final String content;
  final String kind;
  final String? localPath;
  final String? remoteUrl;
  final String? fileName;

  bool get isUser => role.toLowerCase() == 'user';
  bool get isImage => kind.toUpperCase() == 'IMAGE';
  bool get isFileLike => !isImage && kind.toUpperCase() != 'TEXT';
}

class _DraftAttachment {
  const _DraftAttachment({
    required this.path,
    required this.name,
    required this.kind,
  });

  final String path;
  final String name;
  final String kind;

  bool get isImage => kind == 'IMAGE';
}

String _sourceValue(List<dynamic> sources, String prefix) {
  for (final raw in sources) {
    final s = raw.toString();
    if (s.startsWith(prefix)) return s.substring(prefix.length).trim();
  }
  return '';
}

_Msg _msgFromStored(Map<String, dynamic> mm) {
  final role = (mm['role'] ?? 'assistant').toString().toLowerCase();
  final content = (mm['content'] ?? '').toString();
  final sources = (mm['sources'] is List) ? mm['sources'] as List : const [];

  final kind = _sourceValue(sources, 'kind:').toUpperCase();
  final originalName = _sourceValue(sources, 'originalName:');
  final mimeType = _sourceValue(sources, 'mimeType:');
  final uploadedPath = _sourceValue(sources, 'uploadedPath:');

  String? remoteUrl;
  if (uploadedPath.isNotEmpty) {
    remoteUrl = uploadedPath.startsWith('/') ? uploadedPath : '/$uploadedPath';
  }

  if (role == 'user' && kind == 'IMAGE') {
    return _Msg(
      role: role,
      content: '',
      kind: 'IMAGE',
      remoteUrl: remoteUrl,
      fileName: originalName,
    );
  }

  if (role == 'user' && kind == 'VOICE') {
    return _Msg(
      role: role,
      content: originalName.isNotEmpty ? originalName : 'Voice message',
      kind: 'VOICE',
      remoteUrl: remoteUrl,
      fileName: originalName,
    );
  }

  if (role == 'user' && (kind == 'FILE' || kind == 'DOC' || kind == 'VIDEO')) {
    return _Msg(
      role: role,
      content: originalName.isNotEmpty ? originalName : 'File',
      kind: kind.isEmpty
          ? 'FILE'
          : (mimeType.toLowerCase() == 'application/pdf' ? 'PDF' : kind),
      remoteUrl: remoteUrl,
      fileName: originalName,
    );
  }

  return _Msg(role: role, content: content);
}

class NovaChatScreen extends ConsumerStatefulWidget {
  const NovaChatScreen({
    super.key,
    this.sessionId,
    this.initialTitle,
    this.initialPrompt,
  });

  final String? sessionId;
  final String? initialTitle;
  final String? initialPrompt;

  @override
  ConsumerState<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends ConsumerState<NovaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<bool> _showScrollToBottom = ValueNotifier(false);
  final AudioRecorder _recorder = AudioRecorder();

  final List<_Msg> _messages = <_Msg>[];
  final List<_DraftAttachment> _draftAttachments = <_DraftAttachment>[];

  String? _sessionId;
  String _headerTitle = 'Untitled chat';
  bool _loadingHistory = false;
  bool _sending = false;
  bool _recording = false;
  bool _voiceLocked = false;
  bool _voicePaused = false;
  bool _voiceCancelled = false;
  double _holdDx = 0;
  double _holdDy = 0;
  Offset? _holdOrigin;
  Duration _recordingElapsed = Duration.zero;
  String? _recordingPath;
  StreamSubscription<Map<String, dynamic>>? _replySub;
  Timer? _recordTicker;

  TutorRepository get _repo => ref.read(tutorRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      final show =
          _scroll.position.pixels < (_scroll.position.maxScrollExtent - 100);
      if (_showScrollToBottom.value != show) _showScrollToBottom.value = show;
    });
    _sessionId = widget.sessionId;
    _headerTitle = (widget.initialTitle ?? '').trim().isEmpty
        ? 'Untitled chat'
        : widget.initialTitle!.trim();

    final seed = (widget.initialPrompt ?? '').trim();
    if (seed.isNotEmpty) {
      _controller.text = seed;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitial();
    });
  }

  @override
  void dispose() {
    _replySub?.cancel();
    _recordTicker?.cancel();
    _controller.dispose();
    _scroll.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    if (_sessionId == null || _sessionId!.trim().isEmpty) return;

    setState(() => _loadingHistory = true);
    try {
      final json = await _repo.fetchSessionById(_sessionId!);

      final rawMessages = () {
        final direct = json['messages'];
        if (direct is List) return direct;

        final session = json['session'];
        if (session is Map<String, dynamic> && session['messages'] is List) {
          return session['messages'] as List<dynamic>;
        }

        return <dynamic>[];
      }();

      final next = <_Msg>[];
      for (final item in rawMessages) {
        if (item is! Map) continue;
        final mm = Map<String, dynamic>.from(
          item.map((k, v) => MapEntry(k.toString(), v)),
        );
        final msg = _msgFromStored(mm);
        if (msg.content.trim().isEmpty &&
            (msg.remoteUrl ?? '').trim().isEmpty) {
          continue;
        }
        next.add(msg);
      }

      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(next);
      });
      _scrollToBottom(jump: true);
    } finally {
      if (mounted) {
        setState(() => _loadingHistory = false);
      }
    }
  }

  Future<void> _ensureSession() async {
    if (_sessionId != null && _sessionId!.trim().isNotEmpty) return;

    final created = await _repo.createSession(
      title: _headerTitle == 'Untitled chat' ? null : _headerTitle,
    );
    final session = (created['session'] is Map)
        ? Map<String, dynamic>.from(created['session'] as Map)
        : created;
    final id = (session['id'] ?? '').toString().trim();
    if (id.isEmpty) throw Exception('Missing session id');
    _sessionId = id;
  }

  String _networkUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = _repo.baseUrl.endsWith('/')
        ? _repo.baseUrl.substring(0, _repo.baseUrl.length - 1)
        : _repo.baseUrl;
    return path.startsWith('/') ? '$base$path' : '$base/$path';
  }

  bool _isVideoPath(String path) {
    final v = path.trim().toLowerCase();
    return v.endsWith('.mp4') ||
        v.endsWith('.mov') ||
        v.endsWith('.mkv') ||
        v.endsWith('.webm') ||
        v.endsWith('.avi');
  }

  bool _isAudioPath(String path) {
    final v = path.trim().toLowerCase();
    return v.endsWith('.m4a') ||
        v.endsWith('.aac') ||
        v.endsWith('.mp3') ||
        v.endsWith('.wav') ||
        v.endsWith('.ogg');
  }

  String _draftKindForPath(String path) {
    final v = path.trim().toLowerCase();
    if (v.endsWith('.jpg') ||
        v.endsWith('.jpeg') ||
        v.endsWith('.png') ||
        v.endsWith('.webp') ||
        v.endsWith('.gif')) {
      return 'IMAGE';
    }
    if (v.endsWith('.pdf')) return 'PDF';
    return 'FILE';
  }

  List<_RichBlock> _richBlocks(String raw) {
    final text = raw.replaceAll('\r\n', '\n');
    final out = <_RichBlock>[];
    final fence = RegExp(r'```([\w+-]*)\n([\s\S]*?)```', multiLine: true);
    var last = 0;
    for (final m in fence.allMatches(text)) {
      if (m.start > last) {
        final plain = text.substring(last, m.start).trim();
        if (plain.isNotEmpty) out.add(_RichBlock.text(plain));
      }
      final lang = (m.group(1) ?? '').trim();
      final code = (m.group(2) ?? '').trimRight();
      out.add(_RichBlock.code(code, lang));
      last = m.end;
    }
    if (last < text.length) {
      final plain = text.substring(last).trim();
      if (plain.isNotEmpty) out.add(_RichBlock.text(plain));
    }
    if (out.isEmpty && text.trim().isNotEmpty) {
      out.add(_RichBlock.text(text.trim()));
    }
    return out;
  }

  Future<void> _showNovaMessageActions(_Msg m) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_all_rounded),
              title: const Text('Copy'),
              onTap: () => Navigator.of(sheetContext).pop('copy'),
            ),
            if (m.isUser && m.content.trim().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Edit message'),
                onTap: () => Navigator.of(sheetContext).pop('edit'),
              ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'copy') {
      final text = m.content.trim().isEmpty
          ? ((m.fileName ?? '').trim().isEmpty ? 'Attachment' : m.fileName!.trim())
          : m.content.trim();
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied')),
      );
      return;
    }

    if (action == 'edit') {
      final text = m.content.trim();
      if (text.isEmpty) return;
      _controller.text = text;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loaded into composer')),
      );
    }
  }

  Widget _assistantRichContent(String text) {
    final blocks = _richBlocks(text);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (blocks[i].isCode)
            CMCodeBlock(blocks[i].value)
          else
            MathView(
              blocks[i].value,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
            ),
          if (i != blocks.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }


  Future<void> _showCameraSheet() async {
    if (_sending || _recording) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Capture a photo'),
              onTap: () => Navigator.of(sheetContext).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Select from gallery'),
              onTap: () => Navigator.of(sheetContext).pop('gallery'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case 'camera':
        await _openDirectCamera();
        return;
      case 'gallery':
        final picked = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
        if (picked == null || !mounted) return;

        final initial = picked.files
            .map((f) => f.path ?? '')
            .where((p) => p.trim().isNotEmpty)
            .toList();
        if (initial.isEmpty) return;

        final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
          MaterialPageRoute(
            builder: (_) => ChatMediaPreviewScreen(
              initialPaths: initial,
              title: 'Preview',
            ),
          ),
        );
        if (result == null || !mounted) return;

        setState(() {
          for (final path in result.paths) {
            _draftAttachments.add(
              _DraftAttachment(
                path: path,
                name: path.split('/').last,
                kind: _draftKindForPath(path),
              ),
            );
          }
          if (result.caption.trim().isNotEmpty) {
            final current = _controller.text.trim();
            _controller.text = current.isEmpty
                ? result.caption.trim()
                : '$current\n${result.caption.trim()}';
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          }
        });
        return;
    }
  }


  Future<void> _regenerateFromAssistantRow(_Msg m) async {
    if (_sending) return;
    final sessionId = _sessionId;
    if (sessionId == null || sessionId.trim().isEmpty) return;

    final idx = _messages.indexOf(m);
    if (idx < 0) return;

    setState(() {
      while (_messages.length > idx) {
        _messages.removeLast();
      }
      _sending = true;
      _messages.add(const _Msg(role: 'assistant', content: 'Thinking…'));
    });
    _scrollToBottom();

    await _replySub?.cancel();
    final buffer = StringBuffer();

    _replySub = _repo.replyStream(sessionId: sessionId).listen(
      (ev) {
        if (!mounted) return;
        final type = (ev['type'] ?? '').toString();

        if (type == 'chunk') {
          buffer.write((ev['delta'] ?? '').toString());
          setState(() {
            if (_messages.isNotEmpty && _messages.last.role == 'assistant') {
              _messages[_messages.length - 1] = _Msg(
                role: 'assistant',
                content: buffer.isEmpty ? 'Thinking…' : buffer.toString(),
              );
            }
          });
          _scrollToBottom();
          return;
        }

        if (type == 'done') {
          final assistant = ev['assistantMessage'];
          final content = assistant is Map
              ? (assistant['content'] ?? '').toString()
              : buffer.toString();

          setState(() {
            if (_messages.isNotEmpty && _messages.last.role == 'assistant') {
              _messages[_messages.length - 1] = _Msg(
                role: 'assistant',
                content: content.trim().isEmpty ? 'Done.' : content,
              );
            }
            _sending = false;
          });
          _scrollToBottom();
          return;
        }

        if (type == 'error') {
          setState(() {
            if (_messages.isNotEmpty && _messages.last.role == 'assistant') {
              _messages[_messages.length - 1] = _Msg(
                role: 'assistant',
                content:
                    '⚠️ ${(ev['message'] ?? 'Failed to stream reply').toString()}',
              );
            }
            _sending = false;
          });
          _scrollToBottom();
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _sending = false);
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _sending = false);
      },
    );
  }

  Future<void> _pickFiles() async {
    if (_sending || _recording) return;
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (picked == null) return;

    final initial = picked.files
        .map((f) => f.path ?? '')
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (initial.isEmpty) return;

    final unsupported = initial.where((p) => _isVideoPath(p) || _isAudioPath(p)).toList();
    if (unsupported.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NOVA supports images, documents, and text. Video and audio files are not supported here.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) =>
            ChatMediaPreviewScreen(initialPaths: initial, title: 'Preview'),
      ),
    );
    if (result == null || !mounted) return;

    final sessionId = _sessionId;
    if (sessionId == null || sessionId.trim().isEmpty) return;

    setState(() => _sending = true);
    try {
      for (final p in result.paths) {
        await _repo.sendFile(sessionId: sessionId, path: p);
      }
      if (result.caption.trim().isNotEmpty) {
        _controller.text = result.caption.trim();
        await _send();
      }
      if (mounted) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scroll.hasClients) return;
          _scroll.animateTo(
            _scroll.position.maxScrollExtent + 120,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        });
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openDirectCamera() async {
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
        _draftAttachments.add(
          _DraftAttachment(
            path: path,
            name: path.split('/').last,
            kind: _draftKindForPath(path),
          ),
        );
      }
      if (result.caption.trim().isNotEmpty) {
        final current = _controller.text.trim();
        _controller.text = current.isEmpty
            ? result.caption.trim()
            : '$current\n${result.caption.trim()}';
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });
  }

  Future<void> _micHoldStart(LongPressStartDetails d) async {
    if (_sending || _recording) return;
    _holdOrigin = d.globalPosition;
    _holdDx = 0;
    _holdDy = 0;
    _voiceLocked = false;
    _voiceCancelled = false;
    await _toggleMic();
  }

  void _micHoldMove(LongPressMoveUpdateDetails d) {
    if (!_recording) return;
    final origin = _holdOrigin;
    if (origin == null) return;

    final dx = d.globalPosition.dx - origin.dx;
    final dy = d.globalPosition.dy - origin.dy;

    setState(() {
      _holdDx = dx;
      _holdDy = dy;
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
    await _toggleMic();
  }

  Future<void> _micHoldCancel() async {
    if (!_recording) return;
    if (_voiceLocked) return;
    await _cancelVoiceDraft();
  }

  void _activeHoldMove(Offset globalPosition) {
    if (!_recording) return;
    final origin = _holdOrigin;
    if (origin == null) return;

    final dx = globalPosition.dx - origin.dx;
    final dy = globalPosition.dy - origin.dy;

    setState(() {
      _holdDx = dx;
      _holdDy = dy;
      if (_holdDx < -88) _voiceCancelled = true;
      if (_holdDy < -88) _voiceLocked = true;
    });
  }

  Future<void> _activeHoldRelease() async {
    if (!_recording) return;
    if (_voiceCancelled) {
      await _cancelVoiceDraft();
      return;
    }
    if (_voiceLocked) {
      if (mounted) setState(() {});
      return;
    }
    await _toggleMic();
  }

  Future<void> _activeHoldCancel() async {
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
    _recordTicker?.cancel();
    setState(() {
      _recording = false;
      _voiceLocked = false;
      _voicePaused = false;
      _voiceCancelled = false;
      _holdOrigin = null;
      _holdDx = 0;
      _holdDy = 0;
      _recordingElapsed = Duration.zero;
    });
  }

  Widget _recordHud() => const SizedBox.shrink();

  void _startRecordTicker() {
    _recordTicker?.cancel();
    _recordingElapsed = Duration.zero;
    _recordTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_recording) return;
      setState(() {
        _recordingElapsed = _recordingElapsed + const Duration(seconds: 1);
      });
    });
  }

  Future<void> _toggleMic() async {
    if (_sending) return;

    if (_recording) {
      final stoppedPath = await _recorder.stop();
      _recordTicker?.cancel();
      _recordingPath = stoppedPath;

      if (!mounted) return;
      setState(() => _recording = false);

      final path = (stoppedPath ?? '').trim();
      if (path.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No audio captured.')));
        return;
      }

      setState(() => _sending = true);
      try {
        final transcript = await _repo.transcribeAudio(path: path);
        if (!mounted) return;

        final clean = transcript.trim();
        if (clean.isNotEmpty) {
          setState(() {
            final current = _controller.text.trim();
            _controller.text = current.isEmpty ? clean : '$current $clean';
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transcription failed. Please try again.'),
            ),
          );
        }
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transcription failed. Please try again.'),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _sending = false;
            _recordingElapsed = Duration.zero;
            _holdOrigin = null;
            _holdDx = 0;
            _holdDy = 0;
          });
        }
        if (_recordingPath != null && _recordingPath!.trim().isNotEmpty) {
          final f = File(_recordingPath!);
          if (await f.exists()) {
            try {
              await f.delete();
            } catch (_) {
              // best-effort cleanup
            }
          }
          _recordingPath = null;
        }
      }
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/nova-${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(const RecordConfig(), path: path);
    _startRecordTicker();

    if (!mounted) return;
    setState(() {
      _recording = true;
      _recordingPath = path;
      _recordingElapsed = Duration.zero;
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (_sending) return;
    if (text.isEmpty && _draftAttachments.isEmpty) return;

    await _ensureSession();
    final sessionId = _sessionId!;
    final attachments = List<_DraftAttachment>.from(_draftAttachments);

    setState(() {
      _sending = true;
      for (final a in attachments) {
        _messages.add(
          _Msg(
            role: 'user',
            content: a.kind.toUpperCase() == 'IMAGE' ? '' : a.name,
            kind: a.kind,
            localPath: a.path,
            fileName: a.name,
          ),
        );
      }
      if (text.isNotEmpty) {
        _messages.add(_Msg(role: 'user', content: text));
      }
      _draftAttachments.clear();
      _controller.clear();
    });
    _scrollToBottom();

    try {
      for (final a in attachments) {
        if (a.kind == 'IMAGE') {
          await _repo.sendImage(sessionId: sessionId, path: a.path);
        } else {
          await _repo.sendFile(sessionId: sessionId, path: a.path);
        }
      }

      if (text.isNotEmpty) {
        await _repo.sendMessage(sessionId: sessionId, text: text);
      }

      if (!mounted) return;
      setState(() {
        _messages.add(const _Msg(role: 'assistant', content: 'Thinking…'));
      });
      _scrollToBottom();

      await _replySub?.cancel();
      final buffer = StringBuffer();

      _replySub = _repo
          .replyStream(sessionId: sessionId)
          .listen(
            (ev) {
              if (!mounted) return;
              final type = (ev['type'] ?? '').toString();

              if (type == 'chunk') {
                buffer.write((ev['delta'] ?? '').toString());
                setState(() {
                  if (_messages.isNotEmpty &&
                      _messages.last.role == 'assistant') {
                    _messages[_messages.length - 1] = _Msg(
                      role: 'assistant',
                      content: buffer.isEmpty ? 'Thinking…' : buffer.toString(),
                    );
                  }
                });
                _scrollToBottom();
                return;
              }

              if (type == 'done') {
                final assistant = ev['assistantMessage'];
                final content = assistant is Map
                    ? (assistant['content'] ?? '').toString()
                    : buffer.toString();

                setState(() {
                  if (_messages.isNotEmpty &&
                      _messages.last.role == 'assistant') {
                    _messages[_messages.length - 1] = _Msg(
                      role: 'assistant',
                      content: content.trim().isEmpty ? 'Done.' : content,
                    );
                  }
                  _sending = false;
                });
                _scrollToBottom();
                return;
              }

              if (type == 'error') {
                setState(() {
                  if (_messages.isNotEmpty &&
                      _messages.last.role == 'assistant') {
                    _messages[_messages.length - 1] = _Msg(
                      role: 'assistant',
                      content:
                          '⚠️ ${(ev['message'] ?? 'Failed to stream reply').toString()}',
                    );
                  }
                  _sending = false;
                });
                _scrollToBottom();
              }
            },
            onError: (_) {
              if (!mounted) return;
              setState(() => _sending = false);
            },
            onDone: () {
              if (!mounted) return;
              setState(() => _sending = false);
            },
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Send failed.')));
    }
  }

  void _removeDraftAttachment(_DraftAttachment a) {
    setState(() {
      _draftAttachments.remove(a);
    });
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final pos = _scroll.position.maxScrollExtent;
      if (jump) {
        _scroll.jumpTo(pos);
      } else {
        _scroll.animateTo(
          pos,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _openAttachment(_Msg m) async {
    final local = (m.localPath ?? '').trim();
    final remote = _networkUrl(m.remoteUrl);
    final label = (m.fileName ?? m.content).trim().isEmpty
        ? 'file'
        : (m.fileName ?? m.content).trim();

    if (m.isImage && remote.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImageViewerScreen(url: remote, label: label),
        ),
      );
      return;
    }

    final isPdf =
        label.toLowerCase().endsWith('.pdf') || m.kind.toUpperCase() == 'PDF';

    if (isPdf && remote.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(url: remote, label: label),
        ),
      );
      return;
    }

    if (local.isNotEmpty) {
      final ok = await launchUrl(
        Uri.file(local),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open attachment.')),
        );
      }
      return;
    }

    if (remote.isNotEmpty) {
      final uri = Uri.tryParse(remote);
      if (uri != null) {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open attachment.')),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Attachment unavailable.')));
  }

  Widget _mediaPreviewFor(_Msg m) {
    if (!m.isImage) return const SizedBox.shrink();

    if (m.localPath != null && m.localPath!.trim().isNotEmpty) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openAttachment(m),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(m.localPath!),
            fit: BoxFit.cover,
            width: 270,
            height: 180,
          ),
        ),
      );
    }

    final url = _networkUrl(m.remoteUrl);
    if (url.isEmpty) return const SizedBox.shrink();

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openAttachment(m),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: 270,
          height: 180,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 270,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF1E242C),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Image unavailable',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }

  IconData _fileIconFor(_Msg m) {
    final name = (m.fileName ?? m.content).toLowerCase();
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (name.endsWith('.doc') || name.endsWith('.docx')) {
      return Icons.description_rounded;
    }
    if (name.endsWith('.ppt') || name.endsWith('.pptx')) {
      return Icons.slideshow_rounded;
    }
    if (name.endsWith('.xls') ||
        name.endsWith('.xlsx') ||
        name.endsWith('.csv')) {
      return Icons.table_chart_rounded;
    }
    if (name.endsWith('.zip') ||
        name.endsWith('.rar') ||
        name.endsWith('.7z')) {
      return Icons.folder_zip_rounded;
    }
    if (name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.mkv')) {
      return Icons.movie_creation_outlined;
    }
    if (name.endsWith('.mp3') ||
        name.endsWith('.m4a') ||
        name.endsWith('.wav')) {
      return Icons.audio_file_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  String _fileLabelFor(_Msg m) {
    final raw = (m.fileName ?? m.content).trim();
    if (raw.isNotEmpty &&
        !raw.startsWith('[FILE]') &&
        !raw.startsWith('[VIDEO]') &&
        !raw.startsWith('[Voice note attached.')) {
      return raw;
    }

    switch (m.kind.toUpperCase()) {
      case 'VOICE':
        return m.fileName?.trim().isNotEmpty == true
            ? m.fileName!.trim()
            : 'Audio file';
      case 'VIDEO':
        return m.fileName?.trim().isNotEmpty == true
            ? m.fileName!.trim()
            : 'Video file';
      default:
        return m.fileName?.trim().isNotEmpty == true
            ? m.fileName!.trim()
            : 'Attached file';
    }
  }

  Widget _fileAttachmentCard(_Msg m) {
    final mine = m.isUser;
    final label = _fileLabelFor(m);
    final accent = mine
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.22)
        : Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _openAttachment(m),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(_fileIconFor(m), color: Colors.white, size: 22),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      m.kind.toUpperCase() == 'PDF'
                          ? 'PDF'
                          : m.kind.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble(_Msg m) {
    final mine = m.isUser;
    final preview = _mediaPreviewFor(m);
    final hasPreview = m.isImage;
    final isFileLike = m.isFileLike;
    final hasText =
        m.content.trim().isNotEmpty &&
        !isFileLike &&
        !m.content.startsWith('[FILE]') &&
        !m.content.startsWith('[VIDEO]') &&
        !m.content.startsWith('[Voice note attached.');

    final body = Column(
      crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (hasPreview) preview,
        if (isFileLike) _fileAttachmentCard(m),
        if (hasPreview && hasText) const SizedBox(height: 10),
        if (isFileLike && hasText) const SizedBox(height: 10),
        if (hasText)
          mine
              ? ChatMessageBubble(
                  contextForNavigation: context,
                  rawText: m.content,
                  mediaUrl: '',
                  isMine: true,
                  showName: false,
                  senderLabel: 'You',
                  timeLabel: '',
                  edited: false,
                  reaction: null,
                  forwarded: false,
                  delivered: false,
                  seen: false,
                  deleteState: 'VISIBLE',
                  maxWidth: 340,
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _assistantRichContent(m.content),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: m.content),
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied')),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text('Copy'),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            onPressed: _sending
                                ? null
                                : () => _regenerateFromAssistantRow(m),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Regenerate'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      ],
    );

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onLongPress: () => _showNovaMessageActions(m),
            child: body,
          ),
        ),
      ),
    );
  }

  Widget _novaComposerTopContent() {
    if (_draftAttachments.isEmpty && !_recording) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_draftAttachments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
            child: SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _draftAttachments.map((a) => _draftChip(a)).toList(),
              ),
            ),
          ),
        if (_recording) _recordHud(),
      ],
    );
  }

  Widget _draftChip(_DraftAttachment a) {
    final isImage = a.isImage;
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
              a.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _removeDraftAttachment(a),
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

  Widget _composer() {
    return ChatComposer(
      controller: _controller,
      topContent: _novaComposerTopContent(),
      enabled: !_sending,
      isStreaming: false,
      isRecording: _recording,
      isVoiceLocked: _voiceLocked,
      isVoicePaused: _voicePaused,
      hintText: 'Message NOVA',
      onSend: _send,
      onAttach: _pickFiles,
      onCamera: _showCameraSheet,
      onMic: () async {
        if (_recording) {
          await _toggleMic();
          return;
        }
        setState(() {
          _voiceLocked = true;
          _voiceCancelled = false;
          _holdDx = 0;
          _holdDy = 0;
        });
        await _toggleMic();
      },
      onMicHoldStart: _micHoldStart,
      onMicHoldMove: _micHoldMove,
      onMicHoldEnd: _micHoldEnd,
      onMicHoldCancel: _micHoldCancel,
      onActiveHoldMove: _activeHoldMove,
      onActiveHoldRelease: _activeHoldRelease,
      onActiveHoldCancel: _activeHoldCancel,
      onTrashRecording: _cancelVoiceDraft,
      onPauseRecording: _pauseVoiceRecord,
      onResumeRecording: _resumeVoiceRecord,
      showCamera: true,
      showAttach: true,
      showMic: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _loadingHistory
        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
        : ValueListenableBuilder<bool>(
            valueListenable: _showScrollToBottom,
            builder: (context, showScroll, child) {
              return Stack(
                children: [
                  NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      return false;
                    },
                    child: ChatGptMessageList(
                      controller: _scroll,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => _bubble(_messages[index]),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: showScroll
                        ? FloatingActionButton.small(
                            heroTag: 'nova-scroll-bottom',
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            onPressed: () {
                              if (!_scroll.hasClients) return;
                              _scroll.animateTo(
                                _scroll.position.maxScrollExtent + 120,
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                              );
                            },
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(_headerTitle),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: body),
            _composer(),
          ],
        ),
      ),
    );
  }
}


class _RichBlock {
  const _RichBlock.text(this.value)
      : isCode = false,
        language = '';

  const _RichBlock.code(this.value, this.language) : isCode = true;

  final String value;
  final bool isCode;
  final String language;
}
