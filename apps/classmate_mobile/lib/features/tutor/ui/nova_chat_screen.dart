import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/media/image_viewer_screen.dart';
import '../../common/media/pdf_viewer_screen.dart';

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
  final AudioRecorder _recorder = AudioRecorder();

  final List<_Msg> _messages = <_Msg>[];
  final List<_DraftAttachment> _draftAttachments = <_DraftAttachment>[];

  String? _sessionId;
  String _headerTitle = 'Untitled chat';
  bool _loadingHistory = false;
  bool _sending = false;
  bool _recording = false;
  String? _recordingPath;
  StreamSubscription<Map<String, dynamic>>? _replySub;

  TutorRepository get _repo => ref.read(tutorRepositoryProvider);

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickCameraOrUploadImage() async {
    if (_sending || _recording) return;

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
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Upload photo'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (action == null) return;

    if (action == 'camera') {
      if (!(Platform.isAndroid || Platform.isIOS)) {
        await _pickImages();
        return;
      }
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      final path = picked?.path;
      if (path == null || path.trim().isEmpty) return;
      setState(() {
        _draftAttachments.add(
          _DraftAttachment(
            path: path,
            name: path.split('/').last,
            kind: 'IMAGE',
          ),
        );
      });
      return;
    }

    await _pickImages();
  }

  Future<void> _pickImages() async {
    if (_sending || _recording) return;
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (picked == null) return;

    setState(() {
      for (final f in picked.files) {
        if ((f.path ?? '').trim().isEmpty) continue;
        _draftAttachments.add(
          _DraftAttachment(path: f.path!, name: f.name, kind: 'IMAGE'),
        );
      }
    });
  }

  Future<void> _pickFiles() async {
    if (_sending || _recording) return;
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (picked == null) return;

    setState(() {
      for (final f in picked.files) {
        if ((f.path ?? '').trim().isEmpty) continue;
        _draftAttachments.add(
          _DraftAttachment(path: f.path!, name: f.name, kind: 'FILE'),
        );
      }
    });
  }

  Future<void> _toggleMic() async {
    if (_sending) return;

    if (_recording) {
      final stoppedPath = await _recorder.stop();
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
          setState(() => _sending = false);
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

    if (!mounted) return;
    setState(() {
      _recording = true;
      _recordingPath = path;
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
          curve: Curves.easeOut,
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
            : 'Voice message';
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
    final accent = mine ? const Color(0xFF143B5C) : const Color(0xFF262D35);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _openAttachment(m),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(13),
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
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

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: mine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (hasPreview) preview,
              if (isFileLike) _fileAttachmentCard(m),
              if (hasPreview && hasText) const SizedBox(height: 2),
              if (isFileLike && hasText) const SizedBox(height: 2),
              if (hasText)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: mine
                        ? const Color(0xFF143B5C)
                        : const Color(0xFF262D35),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    m.content,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.45,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _composerButton({
    required IconData icon,
    required VoidCallback? onTap,
    Color fill = const Color(0xFF1C232B),
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFF121820) : fill,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: 0.22),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _draftChip(_DraftAttachment a) {
    final thumb = a.isImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(a.path),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2630),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: Colors.white70,
            ),
          );

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF171D24),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          thumb,
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              a.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => _removeDraftAttachment(a),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _composer() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
              if (_draftAttachments.isNotEmpty)
                SizedBox(
                  height: 72,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _draftAttachments.map(_draftChip).toList(),
                  ),
                ),
              if (_draftAttachments.isNotEmpty) const SizedBox(height: 2),
              Row(
                children: [
                  _composerButton(
                    icon: Icons.camera_alt_rounded,
                    onTap: _sending || _recording
                        ? null
                        : _pickCameraOrUploadImage,
                  ),
                  const SizedBox(width: 5),
                  _composerButton(
                    icon: Icons.attach_file_rounded,
                    onTap: _sending || _recording ? null : _pickFiles,
                  ),
                  const SizedBox(width: 5),
                  _composerButton(
                    icon: _recording
                        ? Icons.stop_rounded
                        : Icons.mic_none_rounded,
                    onTap: _sending ? null : _toggleMic,
                    fill: _recording
                        ? const Color(0xFF8E2E2E)
                        : const Color(0xFF1C232B),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 46),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F141A).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 6,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) =>
                              _sending || _recording ? null : _send(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ask NOVA anything...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  _composerButton(
                    icon: Icons.arrow_upward_rounded,
                    onTap: _sending || _recording ? null : _send,
                    fill: const Color(0xFF9EC8F0),
                    iconColor: const Color(0xFF0B2238),
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
  Widget build(BuildContext context) {
    final body = _loadingHistory
        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
        : ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _bubble(_messages[index]),
          );

    return Scaffold(
      backgroundColor: const Color(0xFF050A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A0F),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(_headerTitle),
            const SizedBox(height: 2),
            Text(
              _recording
                  ? 'Recording… tap mic again to transcribe'
                  : (_sending ? 'Working…' : 'Ready'),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
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
