// ignore_for_file: use_build_context_synchronously
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
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widgets/typing_dots.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/realtime/realtime_listener.dart';
import '../controllers/chat_thread_controller.dart';
import 'chat_load_error_view.dart';
import '../domain/chat_delete_mode.dart';
import '../domain/chat_message.dart';
import '../domain/chat_message_kind.dart';
import '../domain/chat_thread_type.dart';
import '../domain/forward_target.dart';
import '../../messages/data/messages_repository.dart';
import '../../messages/providers/messages_repository_provider.dart';
import '../models/chat_message_info.dart';
import '../policies/chat_action_policy.dart';
import '../utils/chat_reply_codec.dart';
import '../utils/chat_time.dart';
import 'chat_composer.dart';
import 'chat_context_overlay.dart';
import 'chat_media_preview_screen.dart';
import 'chat_message_bubble.dart';
import 'chat_message_info_page.dart';
import 'chat_reaction_details_sheet.dart';
import 'chat_recording_tokens.dart';
import 'chat_scroll_to_bottom_fab.dart';
import '../../../ui/widgets/cm_loading.dart';

/// Content string used for a reply preview. For text messages it's the text;
/// for media (which often has empty text) it's a wire marker the reply-preview
/// formatter turns into "🎤 Voice message", "🖼️ Photo", "📎 File", so the
/// reply chip shows the type + icon rather than nothing.
String _replyContentFor(ChatMessage m) {
  // Kind FIRST — a media message's `text` is usually its filename
  // ("chat-voice-123.m4a"), which must NOT be shown as the reply preview.
  switch (m.kind) {
    case ChatMessageKind.voice:
      final d = m.voiceDurationSeconds ?? 0;
      return d > 0 ? '[VOICE] [duration:$d]' : '[VOICE]';
    case ChatMessageKind.image:
      return '[IMAGE]';
    case ChatMessageKind.file:
      return '[FILE]';
    default:
      return m.text.trim();
  }
}

/// Snippet for the quoted reply shown inside a message bubble. Falls back to a
/// media marker derived from `replyToKind` when the replied-to message had no
/// text (so the quote reads "🎤 Voice message" / "🖼️ Photo" / "📎 File").
String? _replySnippetFor(ChatMessage m) {
  final t = (m.replyToText ?? '').trim();
  if (t.isNotEmpty) return t;
  switch ((m.replyToKind ?? '').toLowerCase()) {
    case 'voice':
      return '[VOICE]';
    case 'image':
    case 'photo':
      return '[IMAGE]';
    case 'file':
    case 'video':
      return '[FILE]';
    default:
      return m.replyToText;
  }
}

/// Shared chat thread surface used by both DM and Classroom screens.
class ChatThreadView extends ConsumerStatefulWidget {
  const ChatThreadView({
    super.key,
    required this.controller,
    required this.policy,
    this.headerSlot,
    this.bannerSlot,
    this.allowedEmojis = const ['❤️', '👍', '😂', '😮', '😢', '🙏'],
    this.canSend = true,
    this.onViewPublishedItem,
  });

  final ChatThreadController controller;
  final ChatActionPolicy policy;
  final Widget? headerSlot;
  final Widget? bannerSlot;
  final List<String> allowedEmojis;
  final bool canSend;

  /// Invoked when the user taps "View" on a published-item card (the
  /// server-posted "teacher just published X" message). The host screen —
  /// which owns the classroom's tab bar — decides where to go; DM threads
  /// leave this null and the card renders without the button.
  final void Function(String type, String id, String title)?
      onViewPublishedItem;

  @override
  ConsumerState<ChatThreadView> createState() => _ChatThreadViewState();
}

class _ChatThreadViewState extends ConsumerState<ChatThreadView>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _composerFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _recorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();

  // ─── voice-recording latency cache ───────────────────────────────────────
  // Starting the mic costs three platform round-trips (permission check, temp
  // dir, AVAudioSession activation). Doing them all inside the press handler
  // is what made the button feel dead for a second or two. These fields let
  // the HUD open on the press frame while the real recorder catches up:
  //   • the granted permission and the temp dir are resolved once, up front
  //   • _recorderStarting is the in-flight start, so stop/cancel can await it
  //     instead of racing a recorder that hasn't reached the platform yet
  bool _micPermissionGranted = false;
  Directory? _voiceTempDir;
  Future<bool>? _recorderStarting;
  bool _recorderActive = false;

  // Live input levels, newest last, each normalised to 0..1. The recording HUD
  // draws these instead of the canned bar heights it used to cycle through —
  // a waveform that doesn't move with your voice reads as a loading animation,
  // not as a microphone that's listening.
  final List<double> _voiceLevels = <double>[];
  StreamSubscription<Amplitude>? _amplitudeSub;
  static const int _kVoiceLevelWindow = 72;

  // Haptic edge-detection: fire once when a drag CROSSES a threshold, not on
  // every move event while it sits past it.
  bool _cancelHapticFired = false;

  // List rendering
  final Map<String, GlobalKey> _messageKeys = <String, GlobalKey>{};
  final Map<String, double> _swipeDxByMessage = <String, double>{};
  List<ChatMessage> _lastMessages = const <ChatMessage>[];
  List<ChatMessage> _lastKnownMessages = const <ChatMessage>[];

  // Scroll/jump
  bool _showScrollToBottom = false;
  bool _newMessagesBelow = false;
  int _knownMessageCount = 0;
  String? _knownLastMessageId;
  Timer? _highlightClearTimer;
  Timer? _highlightRestartTimer;
  Timer? _highlightFinalClearTimer;
  String? _highlightedMessageId;
  int _pulseGeneration = 0;

  // Reply
  String? _replyToMessageId;
  String? _replyToSenderName;
  String? _replyToText;

  // Edit
  String? _editingMessageId;
  String? _editingOriginalText;

  // Forward selection
  bool _isForwardSelectionMode = false;
  final Set<String> _forwardSelectedMessageIds = <String>{};

  // Delete selection
  bool _isDeleteSelectionMode = false;
  final Set<String> _deleteSelectedMessageIds = <String>{};

  // Voice recording
  bool _recording = false;
  bool _voiceLocked = false;
  bool _voicePaused = false;
  bool _voiceCancelled = false;
  Offset? _holdStartGlobal;
  double _holdDx = 0;
  double _holdDy = 0;
  Timer? _recordTicker;
  Duration _recordElapsed = Duration.zero;
  String? _recordingPath;
  // Monotonic id for the current take. Every async continuation captures the
  // value it started with and bails if it no longer matches, so a stop/cancel
  // can never be applied to the take that replaced it. This is what keeps the
  // two gesture paths (the mic's own pointer-down and the composer-level
  // Listener that takes over once the mic button unmounts) from both driving
  // the same take and leaving the HUD and the idle composer on screen at once.
  int _voiceSession = 0;
  // In-flight teardown of the PREVIOUS take (awaiting its start, stopping the
  // platform recorder). A new press does NOT wait for this to begin — the HUD
  // opens on the press frame — but the new take's bring-up awaits it before
  // touching the shared recorder, so rapid record→cancel→record never races
  // stop() against start() and never drops the press.
  Future<void>? _recorderTeardown;
  // Wall-clock of the press, used to tell a tap from a hold on release.
  int _holdStartMs = 0;
  // Precise elapsed accounting. The 1s ticker is only a repaint pulse; the
  // duration we display and attach to the sent clip comes from the clock, so
  // it matches the actual audio even if a tick is dropped under load.
  int _voicePausedAccumMs = 0;
  int _voiceResumedAtMs = 0;

  /// Real recorded length so far, excluding any paused stretches.
  Duration _liveRecordElapsed() {
    if (!_recorderActive) return Duration.zero;
    final running = _voicePaused
        ? 0
        : DateTime.now().millisecondsSinceEpoch - _voiceResumedAtMs;
    return Duration(milliseconds: _voicePausedAccumMs + running);
  }
  /// A press shorter than this with no meaningful drag is a *tap*, which starts
  /// hands-free (locked) recording — the same affordance WhatsApp gives.
  static const int _kVoiceTapMaxMs = 320;
  // Set in dispose() so async recorder work started before teardown never
  // touches the disposed platform recorder (would throw "Recorder has not
  // yet been created or has already been disposed" → fatal).
  bool _disposed = false;

  // Drafts
  final List<File> _draftAttachments = <File>[];

  bool _markedRead = false;

  // Foreground poll: SSE delivers messages in real-time, but the connection
  // can stall (mobile network handoff, proxy idle timeout, app resume). At
  // 1.5s this gives a WhatsApp-feel even when SSE is silent. Runs only
  // while the chat screen is the active route, so the cost is bounded to
  // one viewer at a time.
  Timer? _pollTimer;

  bool get _inSelectionMode => _isForwardSelectionMode || _isDeleteSelectionMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScroll);
    _textController.addListener(_handleTextChange);
    // SSE delivers messages in real-time; this poll is only a fallback for a
    // stalled connection. 1s was hammering the API (contributed to 429 rate-
    // limit errors during active use). 4s keeps a near-instant feel without
    // the request storm.
    _pollTimer = Timer.periodic(const Duration(milliseconds: 4000), (_) {
      if (!mounted) return;
      widget.controller.invalidate();
    });
    _prewarmVoiceRecording();
  }

  /// Resolves the temp directory (and the already-granted mic permission) off
  /// the press path, so holding the mic doesn't pay for them. Both are pure
  /// reads — neither prompts the user, so this is safe to run on open.
  Future<void> _prewarmVoiceRecording() async {
    try {
      final dir = await getTemporaryDirectory();
      if (_disposed) return;
      _voiceTempDir = dir;
      // Only cache a GRANTED result: caching a denial would keep the app
      // thinking the mic is off after the user flips it on in Settings.
      if (await _recorder.hasPermission() && !_disposed) {
        _micPermissionGranted = true;
      }
    } catch (_) {
      // Prewarm is best-effort — _startRecording still does the real work.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _textController.dispose();
    _composerFocus.dispose();
    _scrollController.dispose();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    _recordTicker?.cancel();
    _cancelPulseTimers();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // The keyboard opening/closing resizes the viewport. The message list is
    // not reversed, so without this the newest messages get hidden behind the
    // keyboard (#21). Re-pin to the bottom on the next frame — but only when
    // the user is already near the newest messages, so we never yank them down
    // while they're scrolled up reading older history.
    if (!mounted) return;
    if (!_nearBottom(280)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToBottom();
    });
  }

  // ─── scroll ──────────────────────────────────────────────────────────────

  bool _nearBottom([double threshold = 140]) {
    if (!_scrollController.hasClients) return true;
    final distance = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    return distance <= threshold;
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    // Near the top → page in older messages (upward infinite scroll). Fire-
    // and-forget; the controller guards against re-entry while loading.
    final pos = _scrollController.position;
    if (pos.pixels <= pos.minScrollExtent + 240 &&
        widget.controller.hasMoreOlder &&
        !widget.controller.isLoadingOlder) {
      widget.controller.loadOlder();
    }
    // Dismiss keyboard whenever the list scrolls (handles TabBarView contexts
    // where keyboardDismissBehavior.onDrag alone is insufficient).
    FocusManager.instance.primaryFocus?.unfocus();
    final nearBottom = _nearBottom(96);
    if (nearBottom && _newMessagesBelow) {
      if (!mounted) return;
      setState(() {
        _newMessagesBelow = false;
        _showScrollToBottom = false;
      });
      return;
    }
    final shouldShow = !_nearBottom(180) || _newMessagesBelow;
    if (shouldShow == _showScrollToBottom || !mounted) return;
    setState(() => _showScrollToBottom = shouldShow);
  }

  void _handleTextChange() {
    // Push a typing signal while the user actually has content in flight.
    // The controller throttles the network ping; DM-only (base is a no-op).
    if (_textController.text.trim().isNotEmpty) {
      widget.controller.notifyTyping();
    }
    setState(() {});
  }

  void _onMessagesRendered(List<ChatMessage> messages) {
    _lastMessages = messages;
    final previousCount = _knownMessageCount;
    final previousLastMessageId = _knownLastMessageId;
    final currentLastMessageId = messages.isEmpty ? null : messages.last.id;

    _knownMessageCount = messages.length;
    _knownLastMessageId = currentLastMessageId;

    if (previousCount == 0 || currentLastMessageId == null) return;
    if (currentLastMessageId == previousLastMessageId) return;

    final shouldStickToBottom = _nearBottom(180);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (shouldStickToBottom) {
        if (_newMessagesBelow || _showScrollToBottom) {
          setState(() {
            _newMessagesBelow = false;
            _showScrollToBottom = false;
          });
        }
        _scrollToBottom();
        return;
      }
      if (!_newMessagesBelow) {
        setState(() {
          _newMessagesBelow = true;
          _showScrollToBottom = true;
        });
      }
    });
  }

  void _scrollToBottom({bool jump = false}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position.maxScrollExtent;
    if (jump) {
      _scrollController.jumpTo(position);
    } else {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  GlobalKey _messageKeyFor(String messageId) =>
      _messageKeys.putIfAbsent(messageId, () => GlobalKey());

  void _cancelPulseTimers() {
    _highlightClearTimer?.cancel();
    _highlightRestartTimer?.cancel();
    _highlightFinalClearTimer?.cancel();
    _highlightClearTimer = null;
    _highlightRestartTimer = null;
    _highlightFinalClearTimer = null;
  }

  void _pulseMessage(String messageId) {
    // Cancel any in-flight pulse from a previous jump so its delayed timers
    // can't overwrite our highlight state.
    _cancelPulseTimers();
    final generation = ++_pulseGeneration;
    if (mounted) setState(() => _highlightedMessageId = messageId);
    _highlightClearTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || _pulseGeneration != generation) return;
      setState(() => _highlightedMessageId = null);
      _highlightRestartTimer = Timer(const Duration(milliseconds: 150), () {
        if (!mounted || _pulseGeneration != generation) return;
        setState(() => _highlightedMessageId = messageId);
        _highlightFinalClearTimer =
            Timer(const Duration(milliseconds: 800), () {
          if (!mounted || _pulseGeneration != generation) return;
          setState(() => _highlightedMessageId = null);
        });
      });
    });
  }

  void _jumpToMessage(String messageId) {
    // Recompute index every call — never trust state from a prior jump.
    final index = _lastMessages.indexWhere((m) => m.id == messageId);
    if (index < 0 || !_scrollController.hasClients) return;

    // Fresh pulse cancels any leftover timer pollution from a previous tap.
    _cancelPulseTimers();

    void scrollToContext(BuildContext ctx) {
      _pulseMessage(messageId);
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
    }

    final target = _messageKeyFor(messageId).currentContext;
    if (target != null) {
      scrollToContext(target);
      return;
    }

    // Target not currently mounted — estimate offset by position in the list,
    // animate there, then ensureVisible to nail the alignment once the
    // ListView has materialised the target.
    final total = _lastMessages.length;
    final fraction = total <= 1 ? 0.0 : index / (total - 1);
    final position = _scrollController.position;
    final estimated = (position.maxScrollExtent * fraction)
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    _scrollController
        .animateTo(
      estimated,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    )
        .then((_) async {
      // Give the ListView one frame + a tick to build the target widget.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      final ctx = _messageKeyFor(messageId).currentContext;
      if (ctx != null) scrollToContext(ctx);
    });
  }

  // ─── send / edit pipeline ────────────────────────────────────────────────

  Future<void> _sendCombined() async {
    // ── Confirm edit ────────────────────────────────────────────────────────
    if (_editingMessageId != null) {
      final editId = _editingMessageId!;
      final original = _editingOriginalText ?? '';
      final newText = _textController.text.trim();
      _cancelEdit();
      if (newText.isNotEmpty && newText != original) {
        widget.controller.editMessage(editId, newText)
            .then((_) => widget.controller.invalidate())
            .catchError((_) {});
      }
      return;
    }

    // ── Send media ──────────────────────────────────────────────────────────
    if (_draftAttachments.isNotEmpty) {
      final files = List<File>.from(_draftAttachments);
      final caption = _textController.text.trim();
      final replyId = _replyToMessageId;
      _textController.clear();
      _clearReply();
      setState(() => _draftAttachments.clear());
      _scrollToBottom(jump: true);
      widget.controller
          .sendMedia(files,
              caption: caption.isEmpty ? null : caption,
              replyToMessageId: replyId)
          .then((_) => widget.controller.invalidate())
          .catchError((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.chatCouldNotSendMedia)),
          );
        }
      });
      return;
    }

    // ── Send text (fire and forget) ─────────────────────────────────────────
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final replyId = _replyToMessageId;

    _textController.clear();
    _clearReply();
    _scrollToBottom(jump: true);

    widget.controller
        .sendText(text, replyToMessageId: replyId)
        .then((_) => widget.controller.invalidate())
        .catchError((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatCouldNotSendMessage)),
        );
      }
    });
  }

  void _clearReply() => setState(() {
        _replyToMessageId = null;
        _replyToSenderName = null;
        _replyToText = null;
      });

  // ─── edit ────────────────────────────────────────────────────────────────

  void _startEdit(ChatMessage message) {
    setState(() {
      _editingMessageId = message.id;
      _editingOriginalText = message.text;
      _replyToMessageId = null;
      _replyToSenderName = null;
      _replyToText = null;
    });
    _textController.text = message.text;
    _textController.selection = TextSelection.collapsed(
        offset: _textController.text.length);
  }

  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _editingOriginalText = null;
    });
    _textController.clear();
  }

  // ─── delete selection ────────────────────────────────────────────────────

  void _enterDeleteMode(String messageId) {
    setState(() {
      _isDeleteSelectionMode = true;
      _isForwardSelectionMode = false;
      _forwardSelectedMessageIds.clear();
      _deleteSelectedMessageIds
        ..clear()
        ..add(messageId);
    });
  }

  void _exitDeleteMode() => setState(() {
        _isDeleteSelectionMode = false;
        _deleteSelectedMessageIds.clear();
      });

  void _toggleDeleteSelection(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_deleteSelectedMessageIds.contains(id)) {
        _deleteSelectedMessageIds.remove(id);
      } else {
        _deleteSelectedMessageIds.add(id);
      }
    });
    if (_deleteSelectedMessageIds.isEmpty) _exitDeleteMode();
  }

  Future<void> _commitDelete() async {
    if (_deleteSelectedMessageIds.isEmpty) return;
    final ids = List<String>.from(_deleteSelectedMessageIds);

    // "Delete for everyone" is only offered when EITHER you can moderate
    // (teacher/admin deleting anyone's message) OR every selected message is
    // your own. A non-admin selecting someone else's message gets only
    // "delete for me" — no "delete for everyone" option.
    final selectedMsgs =
        _lastKnownMessages.where((m) => _deleteSelectedMessageIds.contains(m.id)).toList();
    final allOwn = selectedMsgs.isNotEmpty && selectedMsgs.every((m) => m.isOwn);
    final canEveryone = widget.policy.canModeratorDelete ||
        (widget.policy.canDeleteForEveryone && allOwn);

    ChatDeleteMode mode;
    if (canEveryone) {
      final picked = await showModalBottomSheet<ChatDeleteMode>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(AppLocalizations.of(ctx)!.chatDeleteForMe),
                onTap: () =>
                    Navigator.of(ctx).pop(ChatDeleteMode.deleteForMe),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded),
                title: Text(AppLocalizations.of(ctx)!.chatDeleteForEveryone),
                onTap: () =>
                    Navigator.of(ctx).pop(ChatDeleteMode.deleteForEveryone),
              ),
            ],
          ),
        ),
      );
      if (picked == null) return;
      mode = picked;
    } else {
      mode = ChatDeleteMode.deleteForMe;
    }

    for (final id in ids) {
      // Messages already deleted for everyone can only be hidden locally (delete for me).
      final msg = _lastKnownMessages.where((m) => m.id == id).firstOrNull;
      final effectiveMode =
          msg?.deletedForEveryone == true ? ChatDeleteMode.deleteForMe : mode;
      await widget.controller.deleteMessage(id, mode: effectiveMode);
    }
    widget.controller.invalidate();
    _exitDeleteMode();
  }

  // ─── forward selection ───────────────────────────────────────────────────

  void _enterForwardMode(String messageId) {
    setState(() {
      _isForwardSelectionMode = true;
      _isDeleteSelectionMode = false;
      _deleteSelectedMessageIds.clear();
      _forwardSelectedMessageIds
        ..clear()
        ..add(messageId);
    });
  }

  void _exitForwardMode() => setState(() {
        _isForwardSelectionMode = false;
        _forwardSelectedMessageIds.clear();
      });

  void _toggleForwardSelection(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_forwardSelectedMessageIds.contains(id)) {
        _forwardSelectedMessageIds.remove(id);
      } else {
        _forwardSelectedMessageIds.add(id);
      }
    });
    if (_forwardSelectedMessageIds.isEmpty) _exitForwardMode();
  }

  Future<void> _commitForward() async {
    if (_forwardSelectedMessageIds.isEmpty) return;
    final ids = List<String>.from(_forwardSelectedMessageIds);
    final targets = await widget.controller.showForwardPicker(context, ref);
    if (targets == null || targets.isEmpty) return;
    try {
      await widget.controller.forwardMessages(ids, targets);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.chatCouldNotForward)),
      );
      _exitForwardMode();
      return;
    }
    if (!mounted) return;
    final n = targets.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(AppLocalizations.of(context)!.chatForwardedCount(n))),
    );
    _exitForwardMode();
    // Invalidate source AND all target threads so the forwarded message appears.
    widget.controller.invalidate();
    for (final t in targets) {
      if (t is ForwardTargetDm) {
        ref.invalidate(messageThreadProvider(t.threadId));
      }
    }
    _openForwardedThreadIfSingle(targets);
  }

  void _openForwardedThreadIfSingle(List<ForwardTarget> targets) {
    if (targets.length != 1 || !mounted) return;
    widget.controller.openForwardedTarget(context, targets.first);
  }

  // ─── info sheet ──────────────────────────────────────────────────────────

  /// Fetches the live per-participant read/delivered state for a DM message.
  /// Recomputed from each participant's `lastSeenAt`/`lastDeliveredAt` vs the
  /// message time, so it stays accurate as people open the thread. Returns
  /// null for non-DM threads.
  Future<_ReadState?> _fetchReadState(ChatMessage message) async {
    if (widget.controller.threadType != ChatThreadType.direct) return null;
    final seenBy = <MessageReadParticipant>[];
    final deliveredTo = <MessageReadParticipant>[];
    final pendingFor = <MessageReadParticipant>[];
    DateTime? latestSeen;
    DateTime? latestDelivered;
    try {
      final repo = ref.read(messagesRepositoryProvider) as ApiMessagesRepository;
      final raw = await repo.fetchThreadInfo(threadId: widget.controller.threadId);
      final threadMap = raw['thread'] is Map
          ? Map<String, dynamic>.from(raw['thread'] as Map)
          : <String, dynamic>{};
      final members = threadMap['members'] is List
          ? (threadMap['members'] as List)
              .map((m) => Map<String, dynamic>.from(m is Map ? m : {}))
              .toList()
          : <Map<String, dynamic>>[];

      DateTime? parseUtc(dynamic v) {
        final s = (v ?? '').toString().trim();
        return s.isEmpty ? null : DateTime.tryParse(s)?.toLocal();
      }

      for (final m in members) {
        final userId = (m['userId'] ?? '').toString();
        if (userId == widget.controller.currentUserId) continue;
        final name = (m['name'] ?? '').toString();
        final lastSeenDt = parseUtc(m['lastSeenAt']);
        final lastDeliveredDt = parseUtc(m['lastDeliveredAt']);

        // Mirror the server's tick semantics exactly (deliveryStateForMessage):
        // SEEN — opened the thread at/after this message;
        // DELIVERED — either receipt is at/after it (reading implies arrival);
        // PENDING — no receipt reaches the message yet.
        final seenDt = lastSeenDt != null && !lastSeenDt.isBefore(message.createdAt)
            ? lastSeenDt
            : null;
        final receivedDt = [lastDeliveredDt, lastSeenDt]
            .whereType<DateTime>()
            .where((d) => !d.isBefore(message.createdAt))
            .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

        if (seenDt != null) {
          seenBy.add(MessageReadParticipant(name: name, time: _formatTime(seenDt)));
          if (latestSeen == null || seenDt.isAfter(latestSeen)) {
            latestSeen = seenDt;
          }
        } else if (receivedDt != null) {
          deliveredTo
              .add(MessageReadParticipant(name: name, time: _formatTime(receivedDt)));
          if (latestDelivered == null || receivedDt.isAfter(latestDelivered)) {
            latestDelivered = receivedDt;
          }
        } else {
          pendingFor.add(MessageReadParticipant(name: name));
        }
      }
    } catch (_) {
      return null;
    }

    // For the whole message: "seen" only when nobody is still pending/delivered,
    // "delivered" once everyone has at least opened the thread.
    final seen = pendingFor.isEmpty && deliveredTo.isEmpty && seenBy.isNotEmpty;
    final delivered =
        pendingFor.isEmpty && (seenBy.isNotEmpty || deliveredTo.isNotEmpty);
    return (
      seenBy: seenBy,
      deliveredTo: deliveredTo,
      pendingFor: pendingFor,
      seen: seen,
      delivered: delivered,
      seenAt: latestSeen == null ? '' : _formatTime(latestSeen),
      deliveredAt: latestDelivered == null ? '' : _formatTime(latestDelivered),
    );
  }

  Future<void> _openInfoPage(ChatMessage message) async {
    String fmtDt(DateTime? dt) => dt == null ? '' : _formatTime(dt);

    final baseInfo = ChatMessageInfo(
      title: message.senderName,
      isMine: message.isOwn,
      sentAt: _formatTime(message.createdAt),
      deliveredAt: fmtDt(message.deliveredAt),
      seenAt: fmtDt(message.seenAt),
      delivered: message.delivered,
      seen: message.seen,
      messageType: _kindToString(message.kind),
      voiceDuration: message.voiceDurationSeconds != null
          ? '${message.voiceDurationSeconds}s'
          : '',
      edited: message.editedAt != null,
      forwarded: message.forwarded,
      deleteState: message.deletedForEveryone
          ? 'DELETED_FOR_EVERYONE'
          : message.deletedForMe
              ? 'DELETED_FOR_ME'
              : 'VISIBLE',
    );

    // First fetch before opening so the page paints with fresh state.
    final initial = await _fetchReadState(message);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LiveMessageInfoPage(
          threadId: widget.controller.threadId,
          baseInfo: baseInfo,
          initial: initial,
          fetch: () => _fetchReadState(message),
          previewBubbleBuilder: (ctx) => _buildBubble(message, showName: true),
        ),
      ),
    );
  }

  // ─── reactions ───────────────────────────────────────────────────────────

  Future<void> _showReactionDetails(ChatMessage message) async {
    final result = await ChatReactionDetailsSheet.show(
      context,
      myReaction: _myReaction(message),
      reactionUsers: message.reactions,
      pickerAllowedEmojis: widget.allowedEmojis,
    );
    if (result == null || !mounted) return;
    if (result == '__remove__') {
      await widget.controller.react(message.id, null);
    } else {
      await widget.controller.react(message.id, result);
    }
    widget.controller.invalidate();
  }

  // ─── media picking ───────────────────────────────────────────────────────

  Future<void> _handleCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image == null || !mounted) return;
    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) =>
            ChatMediaPreviewScreen(initialPaths: [image.path], title: AppLocalizations.of(context)!.chatPhoto),
      ),
    );
    if (result == null || !mounted) return;
    _sendMediaResult(result);
  }

  Future<void> _handleVideo() async {
    final video = await _imagePicker.pickVideo(
      source: ImageSource.camera,
      // Bound the size: a 5-min clip easily exceeds the upload limit and the
      // request resets mid-upload. ~1 min keeps it well within bounds.
      maxDuration: const Duration(seconds: 60),
    );
    if (video == null || !mounted) return;
    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) =>
            ChatMediaPreviewScreen(initialPaths: [video.path], title: AppLocalizations.of(context)!.chatVideo),
      ),
    );
    if (result == null || !mounted) return;
    _sendMediaResult(result);
  }

  Future<void> _handleGallery() async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );
    if (picked == null || picked.files.isEmpty) return;
    final paths = picked.files
        .where((f) => (f.path ?? '').trim().isNotEmpty)
        .map((f) => f.path!)
        .toList();
    if (paths.isEmpty || !mounted) return;
    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) =>
            ChatMediaPreviewScreen(initialPaths: paths, title: AppLocalizations.of(context)!.chatMedia),
      ),
    );
    if (result == null || !mounted) return;
    _sendMediaResult(result);
  }

  Future<void> _handleFiles() async {
    final picked = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (picked == null || picked.files.isEmpty) return;
    final files = picked.files
        .where((f) => (f.path ?? '').trim().isNotEmpty)
        .map((f) => File(f.path!))
        .toList();
    if (files.isEmpty) return;
    setState(() => _draftAttachments.addAll(files));
    // Bring the keyboard up so the user can type a caption immediately — and
    // recover the input connection torn down by the file picker (QA #9).
    _focusComposer();
  }

  /// Re-establishes the platform keyboard connection for the composer after a
  /// round-trip through an external picker or a pushed media-preview route. On
  /// Android those tear down the input connection, leaving the field in a state
  /// where a plain tap won't reopen the keyboard (QA #7/#9). Unfocus first, then
  /// request focus on the next frame so a fresh connection is created.
  void _focusComposer() {
    if (!mounted) return;
    _composerFocus.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _composerFocus.requestFocus();
    });
  }

  void _sendMediaResult(ChatMediaPreviewResult result) {
    final files = result.paths
        .map((p) => File(p))
        .where((f) => f.existsSync())
        .toList();
    if (files.isEmpty) return;
    final caption =
        result.caption.trim().isEmpty ? null : result.caption.trim();
    _scrollToBottom(jump: true);
    // Recover the keyboard connection lost to the camera/gallery picker + the
    // pushed preview route, so the user can keep typing (QA #7).
    _focusComposer();
    widget.controller
        .sendMedia(files, caption: caption, replyToMessageId: _replyToMessageId)
        .then((_) {
      _clearReply();
      widget.controller.invalidate();
    }).catchError((Object e) {
      if (!mounted) return;
      // Surface the real reason — "Could not send media." was useless
      // when the actual failure was e.g. file too large, network error,
      // or a server validation message. Same pattern as the password
      // change error surfacing.
      final raw = e.toString();
      final m = RegExp(r'"message":"([^"]+)"').firstMatch(raw);
      final msg = m?.group(1) ?? raw.replaceFirst(RegExp(r'^Exception: '), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.commonCouldntSend(msg))),
      );
    });
  }

  void _removeDraftAttachment(int index) => setState(() {
        if (index >= 0 && index < _draftAttachments.length) {
          _draftAttachments.removeAt(index);
        }
      });

  // ─── voice recording ─────────────────────────────────────────────────────

  /// Opens the recording UI on the CURRENT frame and brings the platform
  /// recorder up behind it.
  ///
  /// The old version awaited hasPermission() → getTemporaryDirectory() →
  /// recorder.start() before flipping any state, so nothing at all happened on
  /// screen until all three channel calls returned — hundreds of ms, and worse
  /// on a cold audio session. Now the HUD is optimistic and `_recorderActive`
  /// tracks whether audio is genuinely flowing; the elapsed timer only starts
  /// once it is, so the displayed duration still matches the recorded file.
  Future<void> _startRecording({bool locked = false}) async {
    if (_recording || _disposed) return;

    final session = ++_voiceSession;
    setState(() {
      _recording = true;
      _recorderActive = false;
      _voicePaused = false;
      _voiceCancelled = false;
      _voiceLocked = locked;
      _recordElapsed = Duration.zero;
    });

    final start = _bringUpRecorder(session);
    _recorderStarting = start;
    await start;
  }

  /// Brings the platform recorder up for take [session]. Every await is
  /// followed by a session re-check: if the user released, cancelled, or
  /// started a new take while a channel call was in flight, this take is dead
  /// and must not touch shared state.
  Future<bool> _bringUpRecorder(int session) async {
    bool stale() => _disposed || _voiceSession != session || !_recording;

    // The previous take's stop() may still be in flight on the shared platform
    // recorder (rapid delete → re-hold). The press was NOT dropped — the HUD
    // is already up — we just queue behind the teardown before start().
    final pendingTeardown = _recorderTeardown;
    if (pendingTeardown != null) {
      await pendingTeardown;
      if (!mounted || stale()) return false;
    }

    // Permission: skip the round-trip once granted (see _micPermissionGranted).
    if (!_micPermissionGranted) {
      bool granted;
      try {
        granted = await _recorder.hasPermission();
      } catch (_) {
        // Recorder disposed mid-check (widget torn down) or platform denied.
        await _abortRecordingUi();
        return false;
      }
      if (_disposed) return false;
      if (!granted) {
        await _abortRecordingUi();
        if (!mounted) return false;
        await showDialog<void>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.chatMicNeeded),
            content: Text(AppLocalizations.of(context)!.chatMicNeededBody),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(AppLocalizations.of(context)!.actionCancel)),
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogCtx).pop();
                  await launchUrl(Uri.parse('app-settings:'));
                },
                child: Text(AppLocalizations.of(context)!.chatOpenSettings),
              ),
            ],
          ),
        );
        return false;
      }
      _micPermissionGranted = true;
    }

    final dir = _voiceTempDir ??= await getTemporaryDirectory();
    if (!mounted || stale()) return false;

    final path =
        '${dir.path}/chat-voice-${DateTime.now().millisecondsSinceEpoch}.m4a';
    try {
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path);
    } catch (_) {
      // Recorder was disposed (widget torn down) or the platform failed to
      // start — never surface this as a fatal unhandled error. Reset state.
      await _abortRecordingUi();
      return false;
    }

    if (!mounted || stale()) {
      // Released while start() was in flight — stop the mic we just opened and
      // bin the fragment, since whoever ended the take already gave up on it.
      try {
        await _recorder.stop();
      } catch (_) {}
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      return false;
    }

    _recordingPath = path;
    _recorderActive = true;
    _voicePausedAccumMs = 0;
    _voiceResumedAtMs = DateTime.now().millisecondsSinceEpoch;
    // Contact confirmation — the same "it heard you" tick the big apps give.
    unawaited(HapticFeedback.selectionClick());
    _listenToAmplitude();
    _recordTicker?.cancel();
    _recordTicker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || !_recording || _voicePaused) return;
      final next = _liveRecordElapsed();
      // Only repaint when the displayed second actually changes.
      if (next.inSeconds == _recordElapsed.inSeconds) return;
      setState(() => _recordElapsed = next);
    });
    return true;
  }

  /// Subscribes to the recorder's input level and keeps a rolling window of
  /// normalised samples for the HUD's waveform.
  void _listenToAmplitude() {
    _amplitudeSub?.cancel();
    _voiceLevels.clear();
    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 70))
        .listen((amp) {
      if (!mounted || !_recording || _voicePaused) return;
      // `current` is dBFS: 0 is clipping, silence is around -60 and can go
      // lower. Map the useful top ~50 dB onto 0..1 and floor the result so a
      // quiet room still shows a living baseline rather than a flat line.
      final db = amp.current;
      final normalised = ((db + 50) / 50).clamp(0.0, 1.0);
      // Light one-pole smoothing: raw dBFS jitters bar-to-bar; a 30% carry
      // from the previous sample keeps the trace lively but rounds off the
      // spikes so it scrolls the way Instagram's does.
      final prev = _voiceLevels.isEmpty ? normalised : _voiceLevels.last;
      final smoothed = prev * 0.3 + normalised * 0.7;
      setState(() {
        _voiceLevels.add(smoothed < 0.07 ? 0.07 : smoothed);
        if (_voiceLevels.length > _kVoiceLevelWindow) _voiceLevels.removeAt(0);
      });
    }, onError: (_) {
      // Amplitude reporting is optional — losing it must not affect the take.
    });
  }

  void _stopAmplitude() {
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    _voiceLevels.clear();
  }

  /// Tears the optimistic HUD back down when the recorder never came up.
  Future<void> _abortRecordingUi() async {
    _voiceSession++;
    _recordTicker?.cancel();
    _recordTicker = null;
    _stopAmplitude();
    _recorderActive = false;
    _recordingPath = null;
    void reset() {
      _recording = false;
      _voiceLocked = false;
      _voicePaused = false;
      _voiceCancelled = false;
      _holdStartGlobal = null;
      _holdDx = 0;
      _holdDy = 0;
      _recordElapsed = Duration.zero;
    }

    if (!mounted) {
      reset();
      return;
    }
    setState(reset);
  }

  /// Ends the current take *synchronously* — the HUD is gone on this frame and
  /// the take id is burned, so any in-flight start and any second release from
  /// the other gesture path both become no-ops. Returns the state the async
  /// teardown needs, or null if there was no live take to end.
  ({
    int session,
    bool wasActive,
    Duration elapsed,
    String? path,
    Future<bool>? starting,
  })? _endTake() {
    if (!_recording) return null;
    final snapshot = (
      session: _voiceSession,
      wasActive: _recorderActive,
      elapsed: _liveRecordElapsed(),
      path: _recordingPath,
      // This take's own in-flight start. Snapshotted (and cleared) HERE so the
      // async teardown never accidentally awaits — and then stops — a NEWER
      // take's recorder if the user has already pressed again.
      starting: _recorderStarting,
    );
    _recorderStarting = null;
    // Burn the id first: _bringUpRecorder() re-checks it after every await and
    // will now clean up after itself instead of adopting a dead take.
    _voiceSession++;
    _recorderActive = false;
    _recordingPath = null;
    _recordTicker?.cancel();
    _recordTicker = null;
    _stopAmplitude();
    void reset() {
      _recording = false;
      _voiceLocked = false;
      _voicePaused = false;
      _voiceCancelled = false;
      _holdStartGlobal = null;
      _holdDx = 0;
      _holdDy = 0;
      _recordElapsed = Duration.zero;
    }

    if (mounted) {
      setState(reset);
    } else {
      reset();
    }
    return snapshot;
  }

  Future<void> _stopRecordingAndSend() async {
    final take = _endTake();
    if (take == null) return;

    String? path;
    // A quick tap can land here before _bringUpRecorder() has reached the
    // platform. Let it settle so we never leave a mic running with no
    // owner — it sees the burned session id and tears itself down.
    Future<void> teardown() async {
      await take.starting;
      if (take.wasActive) {
        try {
          path = await _recorder.stop();
        } catch (_) {
          // Recorder disposed/failed — fall back to the tracked path below.
        }
      }
    }

    // Published so an immediate next press queues behind it instead of racing
    // the platform recorder (see _bringUpRecorder).
    final t = teardown();
    _recorderTeardown = t;
    try {
      await t;
    } finally {
      if (identical(_recorderTeardown, t)) _recorderTeardown = null;
    }

    final elapsed = take.elapsed;
    final resolved = (path ?? take.path ?? '').trim();
    if (resolved.isEmpty) return;
    final file = File(resolved);
    if (!await file.exists()) return;
    // Sub-second takes are almost always an accidental brush of the mic —
    // WhatsApp drops them rather than sending a blip. Bin the file too.
    if (elapsed.inMilliseconds < 700) {
      try {
        await file.delete();
      } catch (_) {}
      return;
    }

    // Do NOT delete the temp file here — the voice bubble's optimistic message
    // still references this local path.  The OS cleans up temp files automatically.
    // Deleting early caused "can't play" because the file was gone by the time
    // the user tapped play.
    widget.controller.sendVoice(file, elapsed, replyToMessageId: _replyToMessageId)
        .then((_) {
      _clearReply();
      widget.controller.invalidate();
      _scrollToBottom(jump: true);
    }).catchError((_) {});
  }

  Future<void> _cancelVoiceDraft() async {
    final take = _endTake();
    if (take == null) return;
    unawaited(HapticFeedback.mediumImpact());

    // Same race as _stopRecordingAndSend: a swipe-to-cancel can beat the
    // start. Published as _recorderTeardown so an instant re-press queues
    // behind the stop instead of being dropped.
    Future<void> teardown() async {
      await take.starting;
      if (take.wasActive) {
        try {
          await _recorder.stop();
        } catch (_) {}
      }
    }

    final t = teardown();
    _recorderTeardown = t;
    try {
      await t;
    } finally {
      if (identical(_recorderTeardown, t)) _recorderTeardown = null;
    }
    final path = (take.path ?? '').trim();
    if (path.isNotEmpty) {
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  /// Finger down on the mic. Recording begins on this frame — there is no
  /// recognition delay to wait out, because the press *is* the gesture: what
  /// the user does next (release quickly, hold, slide left, slide up) is
  /// resolved later from the same pointer stream.
  Future<void> _micPressStart(Offset globalPosition) async {
    if (_recording) return;
    _holdStartGlobal = globalPosition;
    _holdStartMs = DateTime.now().millisecondsSinceEpoch;
    _holdDx = 0;
    _holdDy = 0;
    _cancelHapticFired = false;
    await _startRecording();
  }

  void _updateActiveHold(Offset globalPosition) {
    if (!_recording || _voiceLocked || _holdStartGlobal == null) {
      return;
    }
    final dx = globalPosition.dx - _holdStartGlobal!.dx;
    final dy = globalPosition.dy - _holdStartGlobal!.dy;
    if (!mounted) return;

    // Cancel direction follows the trash icon: it sits at the pill's START
    // edge, so the drag is toward the physical left in LTR and toward the
    // physical right in RTL locales.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final toCancel = isRtl ? dx : -dx;
    final pastCancel = toCancel >= chatRecordingCancelThreshold;

    // Haptic on the EDGE, so the threshold ticks once as you cross it and
    // once more if you back off and cross again — the gesture stays legible
    // without looking at the screen.
    if (pastCancel != _cancelHapticFired) {
      _cancelHapticFired = pastCancel;
      unawaited(HapticFeedback.mediumImpact());
    }

    // NOTE: the lock does NOT latch mid-gesture. While the finger is down the
    // bubble just tracks it and shows "will lock" once it's high enough; the
    // actual lock/cancel/send decision is made ONLY on release, in
    // _finishActiveHold — per user spec: "until released nothing happens".
    setState(() {
      _holdDx = dx;
      _holdDy = dy;
      _voiceCancelled = pastCancel;
    });
  }

  /// Finger up. EVERYTHING resolves here — nothing latches mid-gesture.
  /// Priority order: cancel (released past the trash threshold), lock
  /// (released with the finger high enough — ANY horizontal position — or a
  /// quick tap), send (everything else).
  Future<void> _finishActiveHold() async {
    if (!_recording || _voiceLocked) return;
    final heldMs = DateTime.now().millisecondsSinceEpoch - _holdStartMs;
    final dx = _holdDx;
    final dy = _holdDy;
    _holdStartGlobal = null;

    if (_voiceCancelled) {
      await _cancelVoiceDraft();
      return;
    }

    void lockHandsFree() {
      if (!mounted) return;
      setState(() {
        _voiceLocked = true;
        _voicePaused = false;
        _voiceCancelled = false;
        _holdDx = 0;
        _holdDy = 0;
      });
      unawaited(HapticFeedback.selectionClick());
    }

    // Released with the finger raised past the lock height → hands-free.
    // The release point can be anywhere horizontally; only the lift matters.
    if (dy <= -chatRecordingLockThreshold) {
      lockHandsFree();
      return;
    }

    // A quick tap with no real drag also means hands-free: keep recording,
    // hand the user the locked HUD so they can put the phone down.
    final wasTap = heldMs <= _kVoiceTapMaxMs && dx.abs() < 16 && dy.abs() < 16;
    if (wasTap) {
      lockHandsFree();
      return;
    }
    await _stopRecordingAndSend();
  }

  /// Mic tap routed through onTap (locked-HUD send button, and tap-only
  /// fallback surfaces): sends the running take, or starts a hands-free one.
  Future<void> _toggleMicTap() async {
    if (_recording) {
      await _stopRecordingAndSend();
      return;
    }
    await _startRecording(locked: true);
  }

  Future<void> _pauseVoiceRecord() async {
    if (!_recording || !_voiceLocked || _voicePaused) return;
    // Bank the running stretch before the flag flips, or it is lost.
    _voicePausedAccumMs +=
        DateTime.now().millisecondsSinceEpoch - _voiceResumedAtMs;
    try {
      await _recorder.pause();
    } catch (_) {}
    if (mounted) setState(() => _voicePaused = true);
  }

  Future<void> _resumeVoiceRecord() async {
    if (!_recording || !_voiceLocked || !_voicePaused) return;
    _voiceResumedAtMs = DateTime.now().millisecondsSinceEpoch;
    try {
      await _recorder.resume();
    } catch (_) {}
    if (mounted) setState(() => _voicePaused = false);
  }

  // ─── long-press menu ─────────────────────────────────────────────────────

  Future<void> _handleLongPress(ChatMessage message) async {
    if (_inSelectionMode) {
      if (_isForwardSelectionMode) _toggleForwardSelection(message.id);
      if (_isDeleteSelectionMode) _toggleDeleteSelection(message.id);
      return;
    }

    final isPinned = message.pinned;
    final action = await ChatContextOverlay.show(
      context,
      messageBubble: _buildBubble(message, showName: false),
      isMine: message.isOwn,
      canReply: widget.policy.canReply && !message.deletedForEveryone,
      canEdit: message.isOwn &&
          widget.policy.canEditOwnText &&
          !message.deletedForEveryone &&
          message.kind == ChatMessageKind.text,
      canDelete: _canDelete(message),
      canCopy: !message.deletedForEveryone && message.text.isNotEmpty,
      canForward: widget.policy.canForward && !message.deletedForEveryone,
      canPin: widget.policy.canPin,
      canViewInfo: widget.policy.canViewInfo,
      // Report appears on messages from OTHER users — can't report your own.
      // Required by Google Play policy for any app with user messaging.
      canReport: !message.isOwn && !message.deletedForEveryone,
      pinLabel: isPinned ? AppLocalizations.of(context)!.chatUnpin : AppLocalizations.of(context)!.chatPin,
      pickerAllowedEmojis: widget.allowedEmojis,
    );

    if (action == null || action.isEmpty) return;

    switch (action) {
      case 'reply':
        setState(() {
          _replyToMessageId = message.id;
          _replyToSenderName = message.senderName;
          _replyToText = _replyContentFor(message);
        });
      case 'copy':
        await Clipboard.setData(ClipboardData(text: message.text));
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.chatCopied)));
      case 'pin':
        await widget.controller.togglePin(message.id);
        widget.controller.invalidate();
      case 'forward':
        _enterForwardMode(message.id);
      case 'edit':
        _startEdit(message);
      case 'delete':
        _enterDeleteMode(message.id);
      case 'report':
        await _reportMessage(message);
      case 'info':
        _openInfoPage(message);
      default:
        if (action.startsWith('react:')) {
          final emoji = action.substring('react:'.length).trim();
          await widget.controller
              .react(message.id, emoji.isEmpty ? null : emoji);
          widget.controller.invalidate();
        }
    }
  }

  Future<void> _reportMessage(ChatMessage message) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l.chatReportTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.chatReportFlagWarning,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 500,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.reportReasonOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l.chatReportButton),
            ),
          ],
        );
      },
    );
    if (reason == null) return; // user cancelled
    try {
      await widget.controller.reportMessage(message.id, reason: reason.isEmpty ? null : reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.chatReportSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.chatReportFailed(e.toString()))),
      );
    }
  }

  bool _canDelete(ChatMessage message) {
    if (message.deletedForMe) return false; // already hidden
    // "Delete for me" is allowed on ANY message in a context that supports
    // deletion (classroom + DM) — including other people's messages. The
    // stricter "delete for everyone" is gated separately in _commitDelete to
    // your own messages (or moderators). NOVA has all delete flags off, so it
    // still shows no delete action.
    return widget.policy.canDeleteOwn ||
        widget.policy.canDeleteOthers ||
        widget.policy.canModeratorDelete;
  }

  // ─── helpers ─────────────────────────────────────────────────────────────

  bool _sameMessageDay(ChatMessage a, ChatMessage b) =>
      sameLocalCalendarDay(a.createdAt, b.createdAt);

  String _daySeparatorLabel(AppLocalizations l, ChatMessage m) =>
      formatChatDayChipLabel(m.createdAt,
          includeYear: true,
          fallback: l.earlier,
          today: l.today,
          yesterday: l.yesterday);

  Widget _buildDaySeparatorChip(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: scheme.outlineVariant),
          ),
          child: Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  )),
        ),
      ),
    );
  }

  bool _startsGroup(List<ChatMessage> rows, int index) {
    if (index == 0) return true;
    final prev = rows[index - 1];
    final curr = rows[index];
    if (!_sameMessageDay(prev, curr)) return true;
    // Primary: compare by senderId (UUID) when both are available.
    if (prev.senderId.isNotEmpty && curr.senderId.isNotEmpty) {
      return prev.senderId != curr.senderId;
    }
    // Secondary: compare by senderName when IDs are missing (stale cache).
    if (prev.senderName.isNotEmpty && curr.senderName.isNotEmpty) {
      return prev.senderName != curr.senderName;
    }
    // Last resort: own vs other — works for 1:1 DMs.
    return prev.isOwn != curr.isOwn;
  }

  bool _endsGroup(List<ChatMessage> rows, int index) {
    if (index == rows.length - 1) return true;
    return rows[index + 1].senderId != rows[index].senderId ||
        !_sameMessageDay(rows[index], rows[index + 1]);
  }

  Widget _senderAvatar(String senderName) {
    const colors = <Color>[
      Color(0xFF9CCC65), Color(0xFF4FC3F7), Color(0xFFFFB74D),
      Color(0xFFBA68C8), Color(0xFFFF8A65), Color(0xFF4DB6AC),
      Color(0xFFA1887F), Color(0xFF7986CB),
    ];
    final seed =
        senderName.trim().toLowerCase().runes.fold<int>(0, (a, b) => a + b);
    final bg = colors[seed % colors.length];
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final parts = senderName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? '?'
        : parts.length == 1
            ? (parts.first.length >= 2
                ? parts.first.substring(0, 2).toUpperCase()
                : parts.first.toUpperCase())
            : (parts.first[0] + parts.last[0]).toUpperCase();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }

  String _formatTime(DateTime dt) {
    final hh = (dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString();
    final mm = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hh:$mm $suffix';
  }

  String _kindToString(ChatMessageKind kind) {
    switch (kind) {
      case ChatMessageKind.image: return 'IMAGE';
      case ChatMessageKind.file: return 'FILE';
      case ChatMessageKind.voice: return 'VOICE';
      case ChatMessageKind.poll: return 'POLL';
      case ChatMessageKind.event: return 'EVENT';
      case ChatMessageKind.system: return 'SYSTEM';
      default: return 'TEXT';
    }
  }

  Widget _buildBubble(
    ChatMessage message, {
    required bool showName,
    bool tail = false,
  }) {
    return ChatMessageBubble(
      tail: tail,
      contextForNavigation: context,
      rawText: message.text,
      mediaUrl: message.mediaUrl ?? '',
      mediaMimeType: message.mediaMimeType,
      isMine: message.isOwn,
      showName: showName && !message.isOwn,
      senderLabel: message.senderName,
      timeLabel: _formatTime(message.createdAt),
      edited: message.editedAt != null,
      reaction: _myReaction(message),
      reactions: message.reactions,
      forwarded: message.forwarded,
      delivered: message.delivered,
      seen: message.seen,
      deleteState: message.deletedForEveryone
          ? 'DELETED_FOR_EVERYONE'
          : message.deletedForMe
              ? 'DELETED_FOR_ME'
              : 'VISIBLE',
      voiceDurationSeconds: message.voiceDurationSeconds,
      voiceUnread: !message.isOwn &&
          message.kind == ChatMessageKind.voice &&
          !message.voicePlayed,
      onVoicePlayed: message.kind == ChatMessageKind.voice
          ? () => widget.controller.markVoicePlayed(message.id)
          : null,
      replySender: message.replyToSenderName,
      replySnippet: _replySnippetFor(message),
      onReplyTap: message.replyToMessageId == null
          ? null
          : () => _jumpToMessage(message.replyToMessageId!),
      onReactionTap: message.reactions.isNotEmpty || _myReaction(message) != null
          ? () => _showReactionDetails(message)
          : null,
      messageKind: _kindToString(message.kind),
      pinned: message.pinned,
      maxWidth: 280,
      onViewPublished: widget.onViewPublishedItem,
    );
  }

  String? _myReaction(ChatMessage m) {
    for (final entry in m.reactions.entries) {
      if (entry.value.contains('me') ||
          entry.value.contains(widget.controller.currentUserId)) {
        return entry.key;
      }
    }
    return null;
  }

  // ─── pinned strip ────────────────────────────────────────────────────────

  Widget _buildPinnedStrip(List<ChatMessage> messages, AppLocalizations l) {
    final pinned = messages
        .where((m) => m.pinned && !m.deletedForEveryone && !m.deletedForMe)
        .toList();
    if (pinned.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pinned.map((p) {
            final snippet = (p.text.trim().isNotEmpty
                    ? p.text.trim()
                    : _kindToString(p.kind).toLowerCase())
                .replaceAll('\n', ' ');
            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => _jumpToMessage(p.id),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
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
                    Icon(Icons.push_pin_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        snippet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
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
    );
  }

  // ─── draft attachments ───────────────────────────────────────────────────

  Widget _buildDraftAttachmentsPreview() {
    if (_draftAttachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _draftAttachments.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final file = _draftAttachments[index];
            final mime = lookupMimeType(file.path) ?? '';
            final isImage = mime.startsWith('image/') ||
                file.path.toLowerCase().endsWith('.jpg') ||
                file.path.toLowerCase().endsWith('.jpeg') ||
                file.path.toLowerCase().endsWith('.png') ||
                file.path.toLowerCase().endsWith('.webp');
            return Stack(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.32),
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: isImage
                      ? Image.file(file, fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            mime.startsWith('video/')
                                ? Icons.videocam_rounded
                                : Icons.insert_drive_file_rounded,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: InkWell(
                    onTap: () => _removeDraftAttachment(index),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.40),
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── selection action bars ───────────────────────────────────────────────

  void _selectAllForForward() {
    final all = _lastKnownMessages
        .where((m) => !m.deletedForEveryone && !m.deletedForMe)
        .map((m) => m.id)
        .toSet();
    setState(() => _forwardSelectedMessageIds
      ..clear()
      ..addAll(all));
  }

  void _selectAllForDelete() {
    // Include deletedForEveryone messages — users can select them to delete for me
    // (hides the "This message was deleted" stamp from their view).
    final all = _lastKnownMessages
        .where((m) => !m.deletedForMe)
        .map((m) => m.id)
        .toSet();
    setState(() => _deleteSelectedMessageIds
      ..clear()
      ..addAll(all));
  }

  Widget _buildForwardActionBar() {
    final l = AppLocalizations.of(context)!;
    final count = _forwardSelectedMessageIds.length;
    final total = _lastKnownMessages
        .where((m) => !m.deletedForEveryone && !m.deletedForMe)
        .length;
    final allSelected = count == total && total > 0;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: l.chatCancelTooltip,
                onPressed: _exitForwardMode,
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(
                child: Text(l.chatSelectedCount(count.toString()),
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              IconButton(
                tooltip: allSelected ? l.chatDeselectAll : l.chatSelectAll,
                onPressed: allSelected
                    ? () => setState(() => _forwardSelectedMessageIds.clear())
                    : _selectAllForForward,
                icon: Icon(allSelected
                    ? Icons.deselect_rounded
                    : Icons.select_all_rounded),
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: count == 0 ? null : _commitForward,
                icon: const Icon(Icons.forward_rounded),
                label: Text(l.chatForwardLabel(count.toString())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteActionBar() {
    final l = AppLocalizations.of(context)!;
    final count = _deleteSelectedMessageIds.length;
    final total = _lastKnownMessages
        .where((m) => !m.deletedForEveryone && !m.deletedForMe)
        .length;
    final allSelected = count == total && total > 0;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: l.chatCancelTooltip,
                onPressed: _exitDeleteMode,
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(
                child: Text(l.chatSelectedCount(count.toString()),
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              IconButton(
                tooltip: allSelected ? l.chatDeselectAll : l.chatSelectAll,
                onPressed: allSelected
                    ? () => setState(() => _deleteSelectedMessageIds.clear())
                    : _selectAllForDelete,
                icon: Icon(allSelected
                    ? Icons.deselect_rounded
                    : Icons.select_all_rounded),
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                onPressed: count == 0 ? null : _commitDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l.chatDeleteLabel(count.toString())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── editing banner ──────────────────────────────────────────────────────

  Widget _buildEditingBanner() {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: scheme.primary),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_rounded, size: 14, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.chatEditingMessage,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Semantics(
            button: true,
            label: l.a11yCancel,
            child: GestureDetector(
              onTap: _cancelEdit,
              child: Icon(Icons.close_rounded, size: 16, color: scheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // Real-time push: invalidate when SSE fires a relevant event.
    ref.listen(realtimeEventProvider, (_, event) {
      if (event == null) return;
      final tid = widget.controller.threadId;
      final isIncomingHere =
          (event.type == 'classroom_message' && event.classroomId == tid) ||
              (event.type == 'dm_message' && event.threadId == tid) ||
              // A new message can also surface as a generic `notification` push
              // (no threadId). Since the user is actively looking at THIS
              // thread, refetch and advance the read cursor anyway — otherwise
              // the message lands late and the sender's ticks never flip to
              // read (QA #1/#4).
              (event.type == 'notification');
      if (isIncomingHere) {
        widget.controller.invalidate();
        // The user is LOOKING at this thread, so the arriving message is seen
        // the moment it renders — advance my read cursor immediately. This is
        // what makes the sender's ticks flip to blue in real time (the server
        // pushes them a `dm_read` in response). Without it, lastSeenAt only
        // moved on thread ENTRY, so ticks froze while both sides sat in chat.
        widget.controller.markRead().catchError((_) {});
      }
      // The other side received (grey ✓✓) or read (blue ✓✓) the thread →
      // refetch so my ticks advance live rather than on the next poll.
      if ((event.type == 'dm_read' || event.type == 'dm_delivered') &&
          event.threadId == tid) {
        widget.controller.invalidate();
      }
    });

    final messagesAsync = widget.controller.watchMessages(ref);
    final typingAsync = widget.controller.watchTyping(ref);
    final isPeerTyping =
        typingAsync.maybeWhen(data: (v) => v, orElse: () => false);

    // Cache the most recent valid message list to avoid loading-spinner
    // flicker. Important: never SHRINK to empty mid-session — if the
    // controller briefly emits AsyncValue.data([]) during an invalidate
    // cycle (e.g. server returned nothing, dedup wiped everything), we
    // keep the prior list visible instead of blanking the chat. This is
    // the "all disappears after pressing send" symptom from the user.
    if (messagesAsync.hasValue) {
      final next = messagesAsync.requireValue;
      if (next.isNotEmpty || _lastKnownMessages.isEmpty) {
        _lastKnownMessages = next;
      }
    }

    Widget buildBody(List<ChatMessage> allMessages) {
      // Pre-filter invisible messages (system, [SYSTEM] text) once, up-front.
      // All downstream consumers — _onMessagesRendered, _buildPinnedStrip,
      // _buildMessageList — see the same consistent visible-only list so that
      // grouping, date separators, and jump-to-message all work correctly.
      final messages = allMessages
          .where((m) => !_isInvisible(m))
          .toList(growable: false);

      _onMessagesRendered(messages);

      if (!_markedRead && messages.isNotEmpty) {
        _markedRead = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await widget.controller.markRead();
            // Invalidate the inbox provider so the unread badge decrements immediately
            if (mounted) ref.invalidate(messagesInboxProvider);
          } catch (_) {
            // Reset so we retry on next render
            _markedRead = false;
          }
        });
      }

      return Column(
        children: [
          _buildPinnedStrip(messages, l),
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(child: _ChatDoodleBackground()),
                _buildMessageList(messages, l, isPeerTyping),
                // Top spinner while paging in older messages.
                if (widget.controller.isLoadingOlder)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const CmLoading(size: 18),
                      ),
                    ),
                  ),
                if (_showScrollToBottom)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: Center(child: ChatScrollToBottomFab(
                      show: _showScrollToBottom,
                      hasUnreadBelow: _newMessagesBelow,
                      bottomInset: 0,
                      heroTag: 'chat-scroll-fab-${widget.controller.threadId}',
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _newMessagesBelow = false;
                          _showScrollToBottom = false;
                        });
                        _scrollToBottom();
                      },
                    )),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (widget.bannerSlot != null) widget.bannerSlot!,
        if (widget.headerSlot != null) widget.headerSlot!,
        Expanded(
          child: messagesAsync.when(
            data: buildBody,
            loading: () => _lastKnownMessages.isNotEmpty
                ? buildBody(_lastKnownMessages)
                : const Center(child: CmLoading()),
            // First-open failure (nothing cached yet): show a friendly,
            // localized state with a Retry button. NEVER render the raw
            // error — it used to leak the backend path/status/exception
            // payload straight into the chat area (tester-reported).
            error: (err, _) => _lastKnownMessages.isNotEmpty
                ? buildBody(_lastKnownMessages)
                : ChatLoadErrorView(
                    error: err,
                    onRetry: () => widget.controller.retryInitialLoad(),
                  ),
          ),
        ),
        if (_isForwardSelectionMode)
          _buildForwardActionBar()
        else if (_isDeleteSelectionMode)
          _buildDeleteActionBar()
        else ...[
          _buildDraftAttachmentsPreview(),
          ChatComposer(
                controller: _textController,
                focusNode: _composerFocus,
                enabled: widget.canSend,
                isRecording: _recording,
                isVoiceLocked: _voiceLocked,
                isVoicePaused: _voicePaused,
                recordingElapsed: _recordElapsed,
                voiceLevels: _voiceLevels,
                activeHoldDx: _holdDx,
                activeHoldDy: _holdDy,
                hasDraft: _draftAttachments.isNotEmpty,
                onSend: _sendCombined,
                onCamera: _handleCamera,
                onAttach: _handleFiles,
                onVideo: _handleVideo,
                onGallery: _handleGallery,
                onMic: _toggleMicTap,
                onMicPressStart: _micPressStart,
                onActiveHoldMove: _updateActiveHold,
                onActiveHoldRelease: () async => _finishActiveHold(),
                onActiveHoldCancel: () async => _cancelVoiceDraft(),
                onTrashRecording: _cancelVoiceDraft,
                onPauseRecording: _pauseVoiceRecord,
                onResumeRecording: _resumeVoiceRecord,
                hintText: _editingMessageId != null
                    ? l.chatEditPlaceholder
                    : widget.canSend
                        ? l.chatComposerDefaultHint
                        : l.messagesThreadWaitingForApproval,
                replyingTo: _replyToMessageId == null
                    ? null
                    : (
                        senderName: _replyToSenderName ?? '',
                        text: replyPreviewText(_replyToText ?? ''),
                      ),
                onCancelReply: _clearReply,
                onTapReplyPreview: _replyToMessageId == null
                    ? null
                    : () => _jumpToMessage(_replyToMessageId!),
                topContent: _editingMessageId != null
                    ? _buildEditingBanner()
                    : null,
              ),
        ],
      ],
    );
  }

  // Returns true for messages that must be completely excluded from the UI —
  // no avatar placeholder, no date separator, no row height.
  //
  // • kind=system          → internal markers (typing, read-receipts, etc.)
  // • [SYSTEM] text prefix → server-generated housekeeping ("user started chat")
  // • deletedForMe         → user explicitly hid this message; omit entirely so
  //                          no 36 px avatar placeholder floats without a bubble
  //   (deletedForEveryone is intentionally NOT hidden — it shows the
  //    "This message was deleted" stamp, which is useful context)
  static bool _isInvisible(ChatMessage m) =>
      m.kind == ChatMessageKind.system ||
      m.text.startsWith('[SYSTEM]') ||
      m.text.startsWith('[system]') ||
      (m.deletedForMe && !m.deletedForEveryone);

  Widget _buildMessageList(
    List<ChatMessage> messages,
    AppLocalizations l,
    bool peerTyping,
  ) {
    // Caller (buildBody) already pre-filtered invisible messages.
    // Use the list directly — no further filtering needed here.
    return ListView.builder(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // Always scrollable so a near-empty thread can still be dragged to
      // dismiss the keyboard (onDrag needs a scrollable that accepts drags).
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 24),
      itemCount: messages.length + (peerTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (peerTyping && index == messages.length) {
          final peers = messages.where((m) => !m.isOwn);
          final peerName = peers.isEmpty ? null : peers.last.senderName;
          return Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width: 36, child: _senderAvatar(peerName ?? '')),
                const SizedBox(width: 6),
                const TypingBubble(),
              ],
            ),
          );
        }

        final row = messages[index];
        final showDaySeparator =
            index == 0 || !_sameMessageDay(messages[index - 1], row);
        final startsGroup = _startsGroup(messages, index);
        final endsGroup = _endsGroup(messages, index);

        final swipeDx = _swipeDxByMessage[row.id] ?? 0.0;
        final isHighlighted = _highlightedMessageId == row.id;
        final isSelected = _isForwardSelectionMode
            ? _forwardSelectedMessageIds.contains(row.id)
            : _isDeleteSelectionMode
                ? _deleteSelectedMessageIds.contains(row.id)
                : false;

        return KeyedSubtree(
          key: _messageKeyFor(row.id),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDaySeparator)
                _buildDaySeparatorChip(context, _daySeparatorLabel(l, row)),
              Padding(
                padding: EdgeInsets.only(
                  top: startsGroup ? 8 : 2,
                  bottom: endsGroup ? 4 : 2,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Selection circle, pinned to the row's LEADING edge for
                    // every row (own and incoming alike) — WhatsApp's layout.
                    // It used to sit inline next to each bubble, which put it
                    // in a different place on every row and read as clutter.
                    // AnimatedSize slides the whole thread aside smoothly as
                    // the mode toggles instead of snapping.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment: AlignmentDirectional.centerStart,
                      child: _inSelectionMode
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (_isForwardSelectionMode) {
                                  _toggleForwardSelection(row.id);
                                } else {
                                  _toggleDeleteSelection(row.id);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 2, end: 10),
                                child: _SelectionCheck(selected: isSelected),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: Row(
                  mainAxisAlignment: row.isOwn
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Reply icon — only occupies space when actively swiping
                    if (swipeDx > 0)
                      Opacity(
                        opacity: (swipeDx / 44).clamp(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 4),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.reply_rounded,
                                size: 15,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    if (!row.isOwn) ...[
                      SizedBox(
                        width: 36,
                        child: startsGroup
                            ? _senderAvatar(row.senderName)
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _inSelectionMode
                            ? () {
                                if (_isForwardSelectionMode) {
                                  _toggleForwardSelection(row.id);
                                } else {
                                  _toggleDeleteSelection(row.id);
                                }
                              }
                            : null,
                        onHorizontalDragUpdate: _inSelectionMode
                            ? null
                            : (details) {
                                final cur = _swipeDxByMessage[row.id] ?? 0.0;
                                final next = (cur + details.delta.dx)
                                    .clamp(-84.0, 84.0);
                                if ((_swipeDxByMessage[row.id] ?? 0.0) !=
                                    next) {
                                  setState(() =>
                                      _swipeDxByMessage[row.id] = next);
                                }
                              },
                        onHorizontalDragEnd: _inSelectionMode
                            ? null
                            : (_) async {
                                final cur = _swipeDxByMessage[row.id] ?? 0.0;
                                if (_swipeDxByMessage.containsKey(row.id)) {
                                  setState(
                                      () => _swipeDxByMessage.remove(row.id));
                                }
                                if (cur >= 44) {
                                  // Right swipe → reply
                                  setState(() {
                                    _replyToMessageId = row.id;
                                    _replyToSenderName = row.senderName;
                                    _replyToText = _replyContentFor(row);
                                  });
                                } else if (cur <= -44 &&
                                    widget.policy.canViewInfo) {
                                  // Left swipe → info
                                  _openInfoPage(row);
                                }
                              },
                        onHorizontalDragCancel: () {
                          if (_swipeDxByMessage.containsKey(row.id)) {
                            setState(() => _swipeDxByMessage.remove(row.id));
                          }
                        },
                        onLongPress: () => _handleLongPress(row),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOutCubic,
                          transform: Matrix4.translationValues(swipeDx, 0, 0),
                          padding: EdgeInsets.symmetric(
                            horizontal: isHighlighted ? 4 : 0,
                            vertical: isHighlighted ? 2 : 0,
                          ),
                          // Selection state lives ONLY in the leading circle —
                          // no frame or tint hugging the bubble; the old
                          // border+fill treatment read as a clunky box around
                          // the message. The jump-to-message pulse keeps its
                          // highlight because that one must draw the eye.
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.48)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: row.isOwn
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (!row.deletedForMe)
                                _buildBubble(
                                  row,
                                  showName: startsGroup,
                                  // Only the run's first bubble points
                                  // at its sender; the rest tuck in.
                                  tail: startsGroup,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (row.isOwn) const SizedBox(width: 6),
                  ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// WhatsApp-style faint doodle wallpaper behind the message list. A scattered,
/// low-opacity tile of school-relevant glyphs that fills dead space without
/// disrupting reading (bubbles are opaque and sit on top). Pure CustomPaint —
/// no image asset, and it tints itself from the active color scheme so it
/// works in light and dark.
class _ChatDoodleBackground extends StatelessWidget {
  const _ChatDoodleBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface
        .withValues(alpha: theme.brightness == Brightness.dark ? 0.05 : 0.04);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ChatDoodlePainter(color: color),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ChatDoodlePainter extends CustomPainter {
  _ChatDoodlePainter({required this.color});

  final Color color;

  static const List<IconData> _icons = <IconData>[
    Icons.menu_book_rounded,
    Icons.edit_rounded,
    Icons.school_rounded,
    Icons.calculate_rounded,
    Icons.science_rounded,
    Icons.lightbulb_rounded,
    Icons.functions_rounded,
    Icons.public_rounded,
    Icons.brush_rounded,
    Icons.music_note_rounded,
    Icons.sports_basketball_rounded,
    Icons.palette_rounded,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const double cell = 92.0; // grid spacing
    const double iconSize = 30.0;
    final int cols = (size.width / cell).ceil() + 1;
    final int rows = (size.height / cell).ceil() + 1;
    int i = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final IconData icon = _icons[(r * 3 + c * 5 + i) % _icons.length];
        i++;
        // Brick-offset alternate rows + a tiny deterministic jitter so it
        // reads as hand-scattered, never a rigid grid.
        final double dx =
            c * cell + (r.isEven ? 0.0 : cell / 2) + ((c * 7 + r * 3) % 11) - 5;
        final double dy = r * cell + ((r * 5 + c * 13) % 9) - 4;
        final double angle = (((r * c + c) % 7) - 3) * 0.12; // ~±0.36 rad
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              fontSize: iconSize,
              color: color,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.save();
        canvas.translate(dx + iconSize / 2, dy + iconSize / 2);
        canvas.rotate(angle);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ChatDoodlePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Live per-participant read/delivered state for the message-info page.
typedef _ReadState = ({
  List<MessageReadParticipant> seenBy,
  List<MessageReadParticipant> deliveredTo,
  List<MessageReadParticipant> pendingFor,
  bool seen,
  bool delivered,
  String seenAt,
  String deliveredAt,
});

/// Wraps [ChatMessageInfoPage] and keeps its Seen/Delivered state live: it
/// re-fetches whenever a realtime read/message event arrives for this thread,
/// so the WhatsApp-style "Read by" list updates in real time and stays accurate.
class _LiveMessageInfoPage extends ConsumerStatefulWidget {
  const _LiveMessageInfoPage({
    required this.threadId,
    required this.baseInfo,
    required this.initial,
    required this.fetch,
    required this.previewBubbleBuilder,
  });

  final String threadId;
  final ChatMessageInfo baseInfo;
  final _ReadState? initial;
  final Future<_ReadState?> Function() fetch;
  final WidgetBuilder previewBubbleBuilder;

  @override
  ConsumerState<_LiveMessageInfoPage> createState() =>
      _LiveMessageInfoPageState();
}

class _LiveMessageInfoPageState extends ConsumerState<_LiveMessageInfoPage> {
  _ReadState? _state;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _state = widget.initial;
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final s = await widget.fetch();
      if (mounted && s != null) setState(() => _state = s);
    } finally {
      _refreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to realtime read receipts / new messages for THIS thread. A read
    // receipt (`dm_read`) is emitted by the server when the other side opens the
    // thread, so an open info page flips Delivered → Seen without a manual refresh.
    ref.listen<RealtimeEvent?>(realtimeEventProvider, (prev, next) {
      if (next == null) return;
      final t = next.type;
      final matches = t == 'poll' ||
          ((t == 'dm_read' || t == 'dm_delivered' || t == 'dm_message') &&
              next.threadId == widget.threadId);
      if (matches) _refresh();
    });

    final s = _state;
    final info = s == null
        ? widget.baseInfo
        : ChatMessageInfo(
            title: widget.baseInfo.title,
            isMine: widget.baseInfo.isMine,
            sentAt: widget.baseInfo.sentAt,
            deliveredAt: s.deliveredAt.isNotEmpty
                ? s.deliveredAt
                : widget.baseInfo.deliveredAt,
            seenAt: s.seenAt.isNotEmpty ? s.seenAt : widget.baseInfo.seenAt,
            delivered: s.delivered || widget.baseInfo.delivered,
            seen: s.seen,
            messageType: widget.baseInfo.messageType,
            voiceDuration: widget.baseInfo.voiceDuration,
            edited: widget.baseInfo.edited,
            forwarded: widget.baseInfo.forwarded,
            deleteState: widget.baseInfo.deleteState,
          );

    return ChatMessageInfoPage(
      info: info,
      previewBubbleBuilder: widget.previewBubbleBuilder,
      seenBy: s?.seenBy ?? const <MessageReadParticipant>[],
      deliveredTo: s?.deliveredTo ?? const <MessageReadParticipant>[],
      pendingFor: s?.pendingFor ?? const <MessageReadParticipant>[],
    );
  }
}

/// The per-row selection indicator shown while a forward/delete selection is
/// in progress. Empty ring when unselected, filled check when selected —
/// the same read as WhatsApp's, and legible without relying on the row tint
/// (which washes out against coloured own-bubbles on some of the nine themes).
/// WhatsApp-style selection circle: a quiet outline ring that fills with the
/// accent and pops a tick when selected. The tick scales in with a small
/// overshoot so toggling feels alive rather than binary.
class _SelectionCheck extends StatelessWidget {
  const _SelectionCheck({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? scheme.primary : Colors.transparent,
        border: Border.all(
          // Unselected is a hint, not a statement — half-strength outline.
          color: selected
              ? scheme.primary
              : scheme.outline.withValues(alpha: 0.55),
          width: selected ? 1.6 : 1.4,
        ),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        scale: selected ? 1.0 : 0.0,
        child: Icon(Icons.check_rounded, size: 15, color: scheme.onPrimary),
      ),
    );
  }
}
