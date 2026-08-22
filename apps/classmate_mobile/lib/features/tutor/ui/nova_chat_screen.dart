import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../chat_core/ui/chat_composer.dart';
import '../../chat_core/ui/chat_message_bubble.dart';
import '../../chat_core/ui/chat_recording_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmate_mobile/features/chat_core/ui/chat_scroll_to_bottom_fab.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/media/image_viewer_screen.dart';
import '../../common/media/pdf_viewer_screen.dart';
import '../../chat_core/ui/chat_media_preview_screen.dart';
import '../../../common/widgets/cm_ai_message.dart';
import '../../../common/widgets/typing_dots.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/ambient_background.dart';
import '../../../ui/widgets/nova_avatar.dart';
import 'chatgpt_chat_components.dart';

import '../../../ui/widgets/cm_loading.dart';
import '../data/nova_plan_models.dart';
import '../data/on_device_transcriber.dart';
import '../data/tutor_repository.dart';
import '../providers/nova_plan_provider.dart';
import '../providers/tutor_repository_provider.dart';
import '../../billing/data/billing_repository.dart';
import '../../billing/ui/plans_screen.dart';

class _Msg {
  const _Msg({
    required this.role,
    required this.content,
    this.kind = 'TEXT',
    this.localPath,
    this.remoteUrl,
    this.fileName,
    this.promptSuggestions = const <String>[],
  });

  final String role;
  final String content;
  final String kind;
  final String? localPath;
  final String? remoteUrl;
  final String? fileName;
  final List<String> promptSuggestions;

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

List<String> _promptSuggestionsFromSources(List<dynamic> sources) {
  return sources
      .map((raw) => raw.toString())
      .where((value) => value.startsWith('promptSuggestion:'))
      .map((value) => value.substring('promptSuggestion:'.length).trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

_Msg _msgFromStored(
  Map<String, dynamic> mm, {
  required String voiceFallback,
  required String fileFallback,
}) {
  final role = (mm['role'] ?? 'assistant').toString().toLowerCase();
  final content = (mm['content'] ?? '').toString();
  final sources = (mm['sources'] is List) ? mm['sources'] as List : const [];
  final promptSuggestions = _promptSuggestionsFromSources(sources);

  final kind = _sourceValue(sources, 'kind:').toUpperCase();
  final originalName = _sourceValue(sources, 'originalName:');
  final mimeType = _sourceValue(sources, 'mimeType:');
  final uploadedPath = _sourceValue(sources, 'uploadedPath:');

  String? remoteUrl;
  if (uploadedPath.isNotEmpty) {
    remoteUrl = uploadedPath.startsWith('/') ? uploadedPath : '/$uploadedPath';
  }

  if (kind == 'IMAGE') {
    return _Msg(
      role: role,
      content: '',
      kind: 'IMAGE',
      remoteUrl: remoteUrl,
      fileName: originalName,
      promptSuggestions: promptSuggestions,
    );
  }

  if (kind == 'VOICE') {
    return _Msg(
      role: role,
      content: originalName.isNotEmpty ? originalName : voiceFallback,
      kind: 'VOICE',
      remoteUrl: remoteUrl,
      fileName: originalName,
      promptSuggestions: promptSuggestions,
    );
  }

  if (kind == 'FILE' || kind == 'DOC' || kind == 'VIDEO' || kind == 'PDF') {
    return _Msg(
      role: role,
      content: originalName.isNotEmpty
          ? originalName
          : (content.trim().isNotEmpty ? content.trim() : fileFallback),
      kind: kind.isEmpty
          ? 'FILE'
          : (mimeType.toLowerCase() == 'application/pdf' ? 'PDF' : kind),
      remoteUrl: remoteUrl,
      fileName: originalName,
      promptSuggestions: promptSuggestions,
    );
  }

  return _Msg(
    role: role,
    content: content,
    promptSuggestions: promptSuggestions,
  );
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
  static const _untitledSentinel = '__untitled__';
  static const _thinkingSentinel = '__thinking__';

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<bool> _showScrollToBottom = ValueNotifier(false);
  final AudioRecorder _recorder = AudioRecorder();
  final OnDeviceTranscriber _transcriber = OnDeviceTranscriber();

  final List<_Msg> _messages = <_Msg>[];
  final List<_DraftAttachment> _draftAttachments = <_DraftAttachment>[];
  final ImagePicker _imagePicker = ImagePicker();

  String? _sessionId;
  String _headerTitle = _untitledSentinel;
  bool _loadingHistory = false;
  bool _sending = false;
  bool _recording = false;
  bool _voiceLocked = false;
  bool _voicePaused = false;
  bool _voiceCancelled = false;
  double _holdDx = 0;
  double _holdDy = 0;
  Offset? _holdOrigin;
  int _holdStartMs = 0;
  /// A press shorter than this with no drag is a tap → hands-free recording.
  static const int _kVoiceTapMaxMs = 320;
  Duration _recordingElapsed = Duration.zero;
  String _livePartial = '';
  StreamSubscription<Map<String, dynamic>>? _replySub;
  Timer? _recordTicker;

  // Dynamic follow-up suggestions fetched from ChatGPT
  List<String>? _dynamicSuggestions;
  _Msg? _suggestionTargetMsg;
  bool _suggestionsFetched = false;

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
      ? _untitledSentinel
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
    _transcriber.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    if (_sessionId == null || _sessionId!.trim().isEmpty) return;
    final l = AppLocalizations.of(context)!;

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
        // Skip system/meta messages — they're internal and not for display
        final rawRole = (mm['role'] ?? '').toString().toLowerCase();
        if (rawRole == 'system' || rawRole == 's') continue;

        final msg = _msgFromStored(
          mm,
          voiceFallback: l.tutorVoiceMessageFallback,
          fileFallback: l.tutorFileFallback,
        );
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
      // Fetch dynamic suggestions for the last assistant message from history
      final lastAssistant = _messages.lastWhere(
        (msg) => !msg.isUser && msg.content != _thinkingSentinel,
        orElse: () => const _Msg(role: 'user', content: ''),
      );
      if (!lastAssistant.isUser && lastAssistant.content.isNotEmpty) {
        setState(() {
          _suggestionTargetMsg = lastAssistant;
          _dynamicSuggestions = null;
        });
        _fetchDynamicSuggestions(lastAssistant);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingHistory = false);
      }
    }
  }

  Future<void> _ensureSession() async {
    if (_sessionId != null && _sessionId!.trim().isNotEmpty) return;

    final created = await _repo.createSession(
      title: _headerTitle == _untitledSentinel ? null : _headerTitle,
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
        v.endsWith('.gif') ||
        v.endsWith('.heic') ||
        v.endsWith('.heif')) {
      return 'IMAGE';
    }
    if (v.endsWith('.pdf')) return 'PDF';
    return 'FILE';
  }

  // _richBlocks removed — CMAiMessage handles all parsing internally.

  Future<void> _showNovaMessageActions(_Msg m) async {
    final l = AppLocalizations.of(context)!;
    final isTextOnlyMessage =
        !m.isImage &&
        (m.kind.trim().isEmpty || m.kind.toUpperCase() == 'TEXT') &&
        m.content.trim().isNotEmpty;

    if (!isTextOnlyMessage) return;

    final hasText = m.content.trim().isNotEmpty;
    final canCopy = hasText;
    final canEdit = m.isUser && hasText;

    if (!canCopy && !canEdit) return;

    final action = await _showGlassWindow<String>(
      maxWidth: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canCopy)
            _GlassMenuAction(
              icon: Icons.copy_all_rounded,
              label: l.tutorCopy,
              onTap: () => Navigator.of(context).pop('copy'),
            ),
          if (canEdit)
            _GlassMenuAction(
              icon: Icons.edit_rounded,
              label: l.tutorEditMessage,
              onTap: () => Navigator.of(context).pop('edit'),
            ),
        ],
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'copy') {
      await Clipboard.setData(ClipboardData(text: m.content.trim()));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.tutorCopied)));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.tutorLoadedIntoComposer)));
    }
  }

  Widget _assistantRichContent(String text, {bool isStreaming = false}) {
    // Append blinking cursor while streaming for a live-typing feel.
    final display = isStreaming ? '$text▋' : text;
    return CMAiMessage(
      display,
      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
    );
  }

  Future<void> _pickPhoto() async {
    if (_sending || _recording) return;
    final shot = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (!mounted || shot == null || shot.path.trim().isEmpty) return;
    await _previewAndSendMedia(<String>[shot.path]);
  }


  Future<void> _pickGalleryMedia() async {
    if (_sending || _recording) return;
    final picked = await _imagePicker.pickMultipleMedia(imageQuality: 92);
    if (!mounted || picked.isEmpty) return;
    // Filter out videos — Nova only accepts images.
    final initialPaths = picked
        .map((e) => e.path)
        .where((p) => p.trim().isNotEmpty && !_isVideoPath(p))
        .toList();
    if (initialPaths.isEmpty) return;
    await _previewAndSendMedia(initialPaths);
  }

  Future<void> _previewAndSendMedia(List<String> initialPaths) async {
    final l = AppLocalizations.of(context)!;
    final preview = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) => ChatMediaPreviewScreen(
          initialPaths: initialPaths,
          title: l.tutorPreviewTitle,
        ),
      ),
    );
    if (!mounted || preview == null) return;

    final paths = preview.paths.isNotEmpty ? preview.paths : initialPaths;
    if (paths.isEmpty) return;

    await _sendMediaPaths(paths, preview.caption);
  }

  /// Send media files immediately without showing draft chips.
  Future<void> _sendMediaPaths(List<String> paths, String caption) async {
    if (paths.isEmpty) return;
    // Add to drafts WITHOUT setState — chips never render.
    // _send() will snapshot + clear them atomically in its own setState.
    for (final path in paths) {
      _draftAttachments.add(_DraftAttachment(
        path: path,
        name: path.split('/').last,
        kind: _draftKindForPath(path),
      ));
    }
    if (caption.trim().isNotEmpty) {
      final current = _controller.text.trim();
      _controller.text = current.isEmpty
          ? caption.trim()
          : '$current\n${caption.trim()}';
    }
    await _send();
  }

  Future<void> _regenerateFromAssistantRow(_Msg m) async {
    if (_sending) return;
    final l = AppLocalizations.of(context)!;
    final sessionId = _sessionId;
    if (sessionId == null || sessionId.trim().isEmpty) return;

    final idx = _messages.indexOf(m);
    if (idx < 0) return;

    setState(() {
      while (_messages.length > idx) {
        _messages.removeLast();
      }
      _sending = true;
      _messages.add(const _Msg(role: 'assistant', content: _thinkingSentinel));
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
                    content: buffer.isEmpty ? _thinkingSentinel : buffer.toString(),
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
              final sources = assistant is Map && assistant['sources'] is List
                  ? assistant['sources'] as List
                  : const [];

              setState(() {
                if (_messages.isNotEmpty &&
                    _messages.last.role == 'assistant') {
                  _messages[_messages.length - 1] = _Msg(
                    role: 'assistant',
                    content: content.trim().isEmpty ? l.tutorDone : content,
                    promptSuggestions: _promptSuggestionsFromSources(sources),
                  );
                }
                _sending = false;
              });
              _scrollToBottom();
              return;
            }

            if (type == 'error') {
              final code = (ev['code'] ?? '').toString();
              setState(() {
                if (_messages.isNotEmpty &&
                    _messages.last.role == 'assistant') {
                  _messages.removeLast();
                }
                _sending = false;
              });
              if (code == 'OUT_OF_TOKENS') {
                _showOutOfTokensSnackbar();
              } else {
                setState(() {
                  _messages.add(_Msg(
                    role: 'assistant',
                    content: '⚠️ ${(ev['message'] ?? l.tutorFailedToStreamReply).toString()}',
                  ));
                });
              }
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

  /// Opens the plans/upgrade screen. NovaChatScreen is pushed on the ROOT
  /// navigator (see tutor_home_screen), so it sits above go_router's navigator.
  /// Using `context.push('/plans')` (go_router) would render the plans page
  /// *underneath* this chat — the user only saw it after navigating back (#8/#23).
  /// Pushing PlansScreen imperatively on the root navigator stacks it on top.
  void _openPlans() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const PlansScreen()),
    );
  }

  void _showOutOfTokensSnackbar() {
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.novaOutOfTokens),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: l.plansUpgrade,
          onPressed: _openPlans,
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    if (_sending || _recording) return;
    final l = AppLocalizations.of(context)!;
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

    final unsupported = initial
        .where((p) => _isVideoPath(p) || _isAudioPath(p))
        .toList();
    if (unsupported.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.tutorUnsupportedFilesMessage)),
      );
      return;
    }

    if (!mounted) return;
    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) =>
            ChatMediaPreviewScreen(initialPaths: initial, title: l.tutorPreviewTitle),
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

    await _send();
  }

  /// Finger down on the mic — recording starts on contact. See
  /// `_MicPressDetector` in chat_composer.dart for why there is no recognizer.
  Future<void> _micPressStart(Offset globalPosition) async {
    if (_sending || _recording) return;
    _holdOrigin = globalPosition;
    _holdStartMs = DateTime.now().millisecondsSinceEpoch;
    _holdDx = 0;
    _holdDy = 0;
    _voiceLocked = false;
    _voiceCancelled = false;
    await _toggleMic();
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
      _voiceCancelled = dx <= -chatRecordingCancelThreshold;
      _voiceLocked = dy <= -chatRecordingLockThreshold;
    });
  }

  Future<void> _activeHoldRelease() async {
    if (!_recording) return;
    if (_voiceCancelled) {
      await _cancelVoiceDraft();
      return;
    }
    // Quick tap with no real drag → hands-free (locked) recording, same as the
    // DM composer. Otherwise a release commits the take.
    final heldMs = DateTime.now().millisecondsSinceEpoch - _holdStartMs;
    final wasTap =
        heldMs <= _kVoiceTapMaxMs && _holdDx.abs() < 16 && _holdDy.abs() < 16;
    if (_voiceLocked || wasTap) {
      if (mounted) {
        setState(() {
          _voiceLocked = true;
          _holdDx = 0;
          _holdDy = 0;
        });
      }
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
    try {
      await _transcriber.cancel();
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
      _livePartial = '';
    });
  }

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
    final l = AppLocalizations.of(context)!;

    if (_recording) {
      // Stop on-device STT and collect the final transcript.
      final transcript = await _transcriber.stopListening();
      _recordTicker?.cancel();

      if (!mounted) return;
      setState(() {
        _recording = false;
        _livePartial = '';
      });

      if (transcript.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.tutorNoAudioCaptured)));
        // Still meter the elapsed seconds even when the result is empty.
        setState(() {
          _recordingElapsed = Duration.zero;
          _holdOrigin = null;
          _holdDx = 0;
          _holdDy = 0;
        });
        return;
      }

      setState(() => _sending = true);
      try {
        // Gate on voice-minutes plan allowance.
        if (!ref.read(novaPlanControllerProvider).canUseVoiceMinutes(
          _recordingElapsed.inSeconds,
        )) {
          await _showPlanLimitSheet(
            title: l.tutorVoiceLimitReachedTitle,
            message: l.tutorVoiceLimitReachedMessage,
          );
          return;
        }

        final clean = transcript.trim();
        if (clean.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.tutorTranscriptionFailed)),
          );
          return;
        }

        await ref
            .read(novaPlanControllerProvider)
            .recordVoiceUsage(_recordingElapsed.inSeconds);
        setState(() {
          final current = _controller.text.trim();
          _controller.text = current.isEmpty ? clean : '$current $clean';
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.tutorTranscriptionFailed)),
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
      }
      return;
    }

    // --- Start recording ---

    // Initialise on first use; bail with a snackbar if unavailable.
    final available = await _transcriber.initialize();
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.tutorTranscriptionFailed)),
      );
      return;
    }

    await _transcriber.startListening(
      onResult: (partial) {
        if (!mounted) return;
        setState(() => _livePartial = partial);
      },
    );

    _startRecordTicker();

    if (!mounted) return;
    setState(() {
      _recording = true;
      _recordingElapsed = Duration.zero;
      _livePartial = '';
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (_sending) return;
    if (text.isEmpty && _draftAttachments.isEmpty) return;
    final l = AppLocalizations.of(context)!;

    final attachments = List<_DraftAttachment>.from(_draftAttachments);
    final planController = ref.read(novaPlanControllerProvider);
    if (!planController.canSendPrompt(uploadCount: attachments.length)) {
      await _showPlanLimitSheet(
        title: l.tutorPlanLimitReachedTitle,
        message: l.tutorPlanLimitReachedMessage,
      );
      return;
    }

    await _ensureSession();
    final sessionId = _sessionId!;

    setState(() {
      _sending = true;
      _dynamicSuggestions = null;
      _suggestionTargetMsg = null;
      _suggestionsFetched = false;
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

      await ref
          .read(novaPlanControllerProvider)
          .recordPrompt(uploadCount: attachments.length);

      if (!mounted) return;
      setState(() {
        _messages.add(const _Msg(role: 'assistant', content: _thinkingSentinel));
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
                      content: buffer.isEmpty ? _thinkingSentinel : buffer.toString(),
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
                final sources = assistant is Map && assistant['sources'] is List
                    ? assistant['sources'] as List
                    : const [];

                setState(() {
                  if (_messages.isNotEmpty &&
                      _messages.last.role == 'assistant') {
                    _messages[_messages.length - 1] = _Msg(
                      role: 'assistant',
                      content: content.trim().isEmpty ? l.tutorDone : content,
                      promptSuggestions: _promptSuggestionsFromSources(sources),
                    );
                    // Set target synchronously so we return empty while loading
                    _suggestionTargetMsg = _messages.last;
                  }
                  _dynamicSuggestions = null;
                  _suggestionsFetched = false;
                  _sending = false;
                });
                _scrollToBottom();
                // Fetch dynamic follow-up suggestions from ChatGPT
                if (_messages.isNotEmpty && _messages.last.role == 'assistant') {
                  _fetchDynamicSuggestions(_messages.last);
                }
                return;
              }

              if (type == 'error') {
                final code = (ev['code'] ?? '').toString();
                setState(() {
                  if (_messages.isNotEmpty &&
                      _messages.last.role == 'assistant') {
                    _messages.removeLast();
                  }
                  _sending = false;
                });
                if (code == 'OUT_OF_TOKENS') {
                  _showOutOfTokensSnackbar();
                } else {
                  setState(() {
                    _messages.add(_Msg(
                      role: 'assistant',
                      content: '⚠️ ${(ev['message'] ?? l.tutorFailedToStreamReply).toString()}',
                    ));
                  });
                }
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
      ).showSnackBar(SnackBar(content: Text(l.tutorSendFailed)));
    }
  }

  Future<T?> _showGlassWindow<T>({
    required Widget child,
    double maxWidth = 420,
  }) {
    final mediaQuery = MediaQuery.of(context);
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      // Semi-transparent dim — using opaque Colors.black blanked out
      // the whole chat behind the card, which looked like a render bug.
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            14,
            mediaQuery.padding.top + 14,
            14,
            mediaQuery.padding.bottom + 14,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: LiquidGlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  borderRadius: BorderRadius.circular(28),
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPlanLimitSheet({
    required String title,
    required String message,
  }) async {
    final controller = ref.read(novaPlanControllerProvider);
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;

    await _showGlassWindow<void>(
      maxWidth: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 14),
          Text(
            l.tutorCurrentPlanUsageSummary(
              _localizedPlanName(l, controller.selectedPlan.id),
              controller.promptsRemaining,
              controller.uploadsRemaining,
              controller.voiceMinutesRemaining,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openPlans();
            },
            child: Text(l.plansUpgrade),
          ),
        ],
      ),
    );
  }

  void _removeDraftAttachment(_DraftAttachment a) {
    setState(() {
      _draftAttachments.remove(a);
    });
  }

  bool get _hasEnteredChat => _messages.isNotEmpty || _sending;

  List<String> _followUpPromptsFor(_Msg assistant, AppLocalizations l) {
    // Only show chips for the message currently being targeted by the GPT fetch
    if (_suggestionTargetMsg != assistant) return const [];

    // Still loading
    if (!_suggestionsFetched) return const [];

    // GPT suggestions
    if (_dynamicSuggestions != null && _dynamicSuggestions!.isNotEmpty) {
      return _dynamicSuggestions!
          .map(_cleanSuggestionLabel)
          .where((value) => value.isNotEmpty)
          .take(3)
          .toList(growable: false);
    }

    return const [];
  }

  String _lastUserQuestionBefore(_Msg assistant) {
    final assistantIndex = _messages.indexOf(assistant);
    for (var i = assistantIndex - 1; i >= 0; i--) {
      if (_messages[i].isUser) return _messages[i].content;
    }
    return '';
  }

  Future<void> _fetchDynamicSuggestions(_Msg assistantMsg) async {
    final sessionId = _sessionId;
    if (sessionId == null) return;
    final userMsg = _lastUserQuestionBefore(assistantMsg);
    if (userMsg.isEmpty && assistantMsg.content.isEmpty) return;

    final suggestions = await _repo.fetchFollowupSuggestions(
      sessionId: sessionId,
      userMessage: userMsg,
      assistantMessage: assistantMsg.content,
    );

    if (!mounted) return;
    // Only apply if this message is still the last assistant message
    final isStillLast = _messages.isNotEmpty && identical(_messages.last, assistantMsg);
    if (!isStillLast) return;

    setState(() {
      _dynamicSuggestions = suggestions.isEmpty ? null : suggestions;
      _suggestionTargetMsg = assistantMsg;
      _suggestionsFetched = true;
    });
  }

  String _cleanSuggestionLabel(String raw) {
    var value = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    value = value.replaceAll('->', ' to ');
    value = value.replaceAll('=>', ' to ');
    value = value.replaceFirst(RegExp(r'^[\u2022*\-\u2013\u2014>\s]+'), '');
    value = value.replaceFirst(RegExp(r'^\d+[\)\.\-\s]+'), '');
    value = value.replaceFirst(RegExp(r"^[Ii]['’]m ready\s*[:\-\u2013\u2014>]*\s*"), '');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    value = value.replaceAll(RegExp(r'[\s\-\u2013\u2014>]+$'), '').trim();
    return value;
  }

  Future<void> _sendQuickPrompt(String prompt) async {
    final clean = _cleanSuggestionLabel(prompt);
    if (clean.isEmpty || _sending) return;
    _controller.value = TextEditingValue(
      text: clean,
      selection: TextSelection.collapsed(offset: clean.length),
    );
    await _send();
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

    final imageUrl = remote.isNotEmpty
        ? remote
        : (local.isNotEmpty ? Uri.file(local).toString() : '');

    if (m.isImage && imageUrl.isNotEmpty) {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => ImageViewerScreen(url: imageUrl, label: label),
        ),
      );
      return;
    }

    final attachmentPath = remote.isNotEmpty ? remote : local;
    final isPdf =
      label.toLowerCase().endsWith('.pdf') ||
      attachmentPath.toLowerCase().endsWith('.pdf') ||
      m.kind.toUpperCase() == 'PDF';

    final pdfUrl = remote.isNotEmpty
        ? remote
        : (local.isNotEmpty ? Uri.file(local).toString() : '');

    if (isPdf && pdfUrl.isNotEmpty) {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(url: pdfUrl, label: label),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.tutorCouldNotOpenAttachment)),
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
            SnackBar(content: Text(AppLocalizations.of(context)!.tutorCouldNotOpenAttachment)),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.tutorAttachmentUnavailable)));
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
          errorBuilder: (context, error, stackTrace) => SizedBox(
            width: 270,
            height: 180,
            child: LiquidGlassCard(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF1E242C),
              border: Border.all(color: Colors.white12),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.tutorImageUnavailable,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
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

    final l = AppLocalizations.of(context)!;
    switch (m.kind.toUpperCase()) {
      case 'VOICE':
        return m.fileName?.trim().isNotEmpty == true
            ? m.fileName!.trim()
            : l.chatAudioFile;
      case 'VIDEO':
        return m.fileName?.trim().isNotEmpty == true
            ? m.fileName!.trim()
            : l.chatVideoFile;
      default:
        return m.fileName?.trim().isNotEmpty == true
            ? m.fileName!.trim()
            : l.chatAttachedFile;
    }
  }

  Widget _fileAttachmentCard(_Msg m) {
    final mine = m.isUser;
    final label = _fileLabelFor(m);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = mine
        ? cs.primaryContainer
        : cs.surfaceContainerHighest;
    final foreground = mine ? cs.onPrimaryContainer : cs.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _openAttachment(m),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: LiquidGlassCard(
          padding: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(13),
            color: accent,
            border: Border.all(color: cs.outlineVariant),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: LiquidGlassCard(
                  borderRadius: BorderRadius.circular(12),
                  color: cs.surfaceContainerLow,
                  child: Center(
                    child: Icon(_fileIconFor(m), color: foreground, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      m.kind.toUpperCase() == 'PDF'
                          ? 'PDF'
                          : m.kind.toUpperCase(),
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 10.5,
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
      ),
    );
  }

  Widget _bubble(_Msg m, int index) {
    final mine = m.isUser;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;

    // ── NOVA thinking: animated avatar + typing dots (Claude style) ──────────
    if (!mine && m.content == _thinkingSentinel) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 84, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _NovaAvatar(animating: true),
            const SizedBox(width: 10),
            TypingDots(
              color: cs.onSurfaceVariant,
              dotSize: 6,
              gap: 5,
            ),
          ],
        ),
      );
    }

    final preview = _mediaPreviewFor(m);
    final hasPreview = m.isImage;
    final isFileLike = m.isFileLike;
    final hasText =
        m.content.trim().isNotEmpty &&
        !isFileLike &&
        !m.content.startsWith('[FILE]') &&
        !m.content.startsWith('[VIDEO]') &&
        !m.content.startsWith('[Voice note attached.');
    final showFollowUpChips =
      !mine &&
      hasText &&
      index == _messages.lastIndexWhere(
        (msg) => !msg.isUser && msg.content != _thinkingSentinel,
      );

    final body = Column(
      crossAxisAlignment: mine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (hasPreview) preview,
        if (isFileLike) _fileAttachmentCard(m),
        if (hasPreview && hasText) const SizedBox(height: 8),
        if (isFileLike && hasText) const SizedBox(height: 8),
        if (hasText)
          mine
              ? ChatMessageBubble(
                  contextForNavigation: context,
                  rawText: m.content,
                  mediaUrl: '',
                  isMine: true,
                  showName: false,
                  senderLabel: l.tutorYou,
                  timeLabel: '',
                  edited: false,
                  reaction: null,
                  forwarded: false,
                  delivered: false,
                  seen: false,
                  showDeliveryStatus: false,
                  deleteState: 'VISIBLE',
                  maxWidth: 316,
                )
              // Claude-style: avatar + plain text, no bubble
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _NovaAvatar(animating: false),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _assistantRichContent(
                            m.content,
                            isStreaming: _sending &&
                                index == _messages.length - 1 &&
                                !m.isUser,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _AssistantActionChip(
                                icon: Icons.copy_rounded,
                                label: l.tutorCopy,
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: m.content),
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l.tutorCopied)),
                                  );
                                },
                              ),
                              _AssistantActionChip(
                                icon: Icons.refresh_rounded,
                                label: l.tutorRegenerate,
                                onTap: _sending
                                    ? null
                                    : () => _regenerateFromAssistantRow(m),
                              ),
                            ],
                          ),
                          if (showFollowUpChips) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 13,
                                  color: cs.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  l.chatFollowUp,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _followUpPromptsFor(m, l)
                                  .map(
                                    (prompt) => _PromptSuggestionChip(
                                      label: prompt,
                                      onTap: _sending
                                          ? null
                                          : () => _sendQuickPrompt(prompt),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
      ],
    );

    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
    // While recording, show live partial transcription above the HUD.
    if (_recording && _livePartial.isNotEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        child: Text(
          _livePartial,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 13,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
      );
    }

    if (_draftAttachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: SizedBox(
        height: 58,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _draftAttachments.map((a) => _draftChip(a)).toList(),
        ),
      ),
    );
  }

  Widget _draftChip(_DraftAttachment a) {
    final isImage = a.isImage;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerHigh,
        border: Border.all(color: cs.outlineVariant),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: LiquidGlassCard(
                borderRadius: BorderRadius.circular(7),
                color: cs.surfaceContainerLow,
                child: Center(
                  child: Icon(
                    isImage ? Icons.image_outlined : Icons.insert_drive_file_outlined,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 132),
              child: Text(
                a.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _removeDraftAttachment(a),
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close_rounded, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyStateCard() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;

    // Avatar + title + subtle AI disclaimer.
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _NovaAvatar(animating: false, size: 52),
            const SizedBox(height: 8),
            Text(
              l.tutorEmptyStateTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l.novaDisclaimer,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Gentle reminder that tokens are a study resource — use them well.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_outlined, size: 14, color: cs.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l.novaTokenTip,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composer() {
    final cs = Theme.of(context).colorScheme;
    return ChatComposer(
        controller: _controller,
        // Translucent so the full-screen aurora bleeds through the bottom bar
        // while keeping the input legible.
        backgroundColor: cs.surface.withValues(alpha: 0.78),
        topContent: _novaComposerTopContent(),
        enabled: !_sending,
        isStreaming: false,
        isRecording: _recording,
        isVoiceLocked: _voiceLocked,
        isVoicePaused: _voicePaused,
        recordingElapsed: _recordingElapsed,
        activeHoldDx: _holdDx,
        activeHoldDy: _holdDy,
        hintText: AppLocalizations.of(context)!.tutorMessageNovaHint,
        onSend: _send,
        onAttach: _pickFiles,
        onCamera: _pickPhoto,
        onVideo: null,
        onGallery: _pickGalleryMedia,
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
        onMicPressStart: _micPressStart,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final headerTitle =
      _headerTitle == _untitledSentinel ? l.tutorUntitledChat : _headerTitle;
    final showPlanButton = _hasEnteredChat;
    final body = _loadingHistory
        ? const Center(child: CmLoading())
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
                    child: _messages.isEmpty
                        ? _emptyStateCard()
                        : ChatGptMessageList(
                            controller: _scroll,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) =>
                                _bubble(_messages[index], index),
                          ),
                  ),
                ],
              );
            },
          );

    // Full-screen themed background behind the WHOLE chat — app bar, message
    // thread, and composer all sit on top of one continuous surface. Scaffold +
    // app bar are transparent so it reads as one smooth themed wash.
    return AmbientBackground(
      // Symbols stay quiet under the message thread — present, not shouting.
      symbolsSeed: 11,
      symbolsOpacity: 0.65,
      child: Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showScrollToBottom,
        builder: (context, showScroll, _) {
          return ChatScrollToBottomFab(
            heroTag: 'nova-scroll-bottom',
            show: showScroll,
            hasUnreadBelow: false,
            bottomInset: MediaQuery.of(context).viewInsets.bottom,
            onPressed: () {
              if (!mounted) return;
              _showScrollToBottom.value = false;
              _scrollToBottom();
            },
          );
        },
      ),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 48,
        centerTitle: true,
        title: Text(
          headerTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          // ⓘ — always visible; tapping shows the AI disclosure sheet.
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            tooltip: AppLocalizations.of(context)!.novaAbout,
            onPressed: () => _showNovaAboutSheet(context),
          ),
          if (showPlanButton)
            Consumer(builder: (context, ref, _) {
              final balanceAsync = ref.watch(tokenBalanceProvider);
              final balance = balanceAsync.asData?.value;
              final tier = balance?.activeTier ?? 'FREE';
              final remaining = balance?.totalRemaining;
              final label = _serverTierLabel(l, tier);
              final tokenText = remaining != null ? _formatTokens(remaining) : '—';
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: Center(
                  child: OutlinedButton(
                    // Root-push PlansScreen (not context.go) — this chat sits
                    // above go_router's navigator, so a route change would be
                    // hidden beneath it (#8/#23).
                    onPressed: _openPlans,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: BorderSide(color: cs.outlineVariant),
                      backgroundColor: cs.surfaceContainerLow,
                      foregroundColor: cs.onSurface,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded,
                            size: 14, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 1,
                          height: 12,
                          color: cs.outlineVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tokenText,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false, // composer's inner SafeArea handles the home-indicator gap
        child: Column(
          children: [
            Expanded(child: body),
            // ── Persistent AI disclaimer — always visible above the composer ──
            // Required for App Store compliance (AI-generated content disclosure).
            _PersistentDisclaimer(onInfo: () => _showNovaAboutSheet(context)),
            _composer(),
          ],
        ),
      ),
    ),
    );
  }

  void _showNovaAboutSheet(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // Keep the sheet clear of the status bar (top) and the system
      // navigation bar / home indicator (bottom) — #13.
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _NovaAvatar(animating: false, size: 36),
                  const SizedBox(width: 12),
                  Text(
                    l.titleNova,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _AboutRow(
                icon: Icons.psychology_rounded,
                title: l.novaChatScreenAboutAiPoweredTitle,
                body: l.novaChatScreenAboutAiPoweredBody,
              ),
              const SizedBox(height: 12),
              _AboutRow(
                icon: Icons.warning_amber_rounded,
                title: AppLocalizations.of(context)!.novaDisclaimerCanMakeMistakes,
                body: l.novaChatScreenAboutMistakesBody,
              ),
              const SizedBox(height: 12),
              _AboutRow(
                icon: Icons.school_rounded,
                title: AppLocalizations.of(context)!.novaDisclaimerEducationalUseOnly,
                body: l.novaChatScreenAboutEducationalBody,
              ),
              const SizedBox(height: 12),
              _AboutRow(
                icon: Icons.lock_outline_rounded,
                title: AppLocalizations.of(context)!.novaDisclaimerYourPrivacy,
                body: l.novaChatScreenAboutPrivacyBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _localizedPlanName(AppLocalizations l, NovaPlanId planId) {
  switch (planId) {
    case NovaPlanId.free:
      return l.tutorPlanStarterName;
    case NovaPlanId.plus:
      return l.tutorPlanPlusName;
    case NovaPlanId.pro:
      return l.tutorPlanProName;
    case NovaPlanId.school:
      return l.tutorPlanSchoolSeatName;
  }
}

/// Maps the server's tier string ('FREE' | 'BUDGET' | 'BALANCE' |
/// 'COMMITMENT') to the localized label rendered in the chat-header pill.
String _serverTierLabel(AppLocalizations l, String tier) {
  switch (tier) {
    case 'BUDGET':
      return l.planTierBudget;
    case 'BALANCE':
      return l.planTierBalance;
    case 'COMMITMENT':
      return l.planTierCommitment;
    case 'FREE':
    default:
      return l.plansFreePlan;
  }
}

/// Compact "tokens remaining" formatter — "12.4k", "847", "1.2M".
String _formatTokens(int n) {
  if (n >= 1_000_000) {
    final v = n / 1_000_000;
    return '${v.toStringAsFixed(v >= 10 ? 0 : 1)}M';
  }
  if (n >= 1000) {
    final v = n / 1000;
    return '${v.toStringAsFixed(v >= 10 ? 0 : 1)}k';
  }
  return n.toString();
}

class _AssistantActionChip extends StatelessWidget {
  const _AssistantActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassMenuAction extends StatelessWidget {
  const _GlassMenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: LiquidGlassCard(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(12),
                color: cs.primary,
                border: Border.all(
                  color: cs.outlineVariant,
                ),
                child: Center(
                  child: Icon(icon, size: 18, color: cs.onPrimary),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptSuggestionChip extends StatelessWidget {
  const _PromptSuggestionChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cleanLabel = label.replaceAll(RegExp(r'\s+'), ' ').trim();
    final isDisabled = onTap == null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: LiquidGlassCard(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
        borderRadius: BorderRadius.circular(16),
        color: isDisabled ? cs.surfaceContainerLow : cs.primaryContainer,
        border: Border.all(
          color: isDisabled ? cs.outlineVariant : cs.primary.withValues(alpha: 0.35),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 13,
                color: isDisabled ? cs.onSurfaceVariant : cs.primary,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                cleanLabel,
                softWrap: true,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDisabled ? cs.onSurfaceVariant : cs.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── NOVA animated avatar ──────────────────────────────────────────────────────

class _NovaAvatar extends StatefulWidget {
  const _NovaAvatar({this.animating = false, this.size = 28});

  final bool animating;
  final double size;

  @override
  State<_NovaAvatar> createState() => _NovaAvatarState();
}

class _NovaAvatarState extends State<_NovaAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.animating) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_NovaAvatar old) {
    super.didUpdateWidget(old);
    if (widget.animating && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.animating && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.animateTo(0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shared NOVA identity (gradient orb + sparkle) — the pulse wrapper here
    // just animates it while she's thinking.
    return ScaleTransition(
      scale: _pulse,
      child: NovaAvatar(size: widget.size),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
//  Persistent AI disclaimer — always shown below the composer
// ─────────────────────────────────────────────────────────────────────────────

class _PersistentDisclaimer extends StatelessWidget {
  const _PersistentDisclaimer({required this.onInfo});
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onInfo,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, size: 11, color: cs.onSurfaceVariant.withValues(alpha: 0.55)),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context)!.novaChatScreenDisclaimerTapToLearn,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  About-sheet row
// ─────────────────────────────────────────────────────────────────────────────

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: cs.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(body, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
