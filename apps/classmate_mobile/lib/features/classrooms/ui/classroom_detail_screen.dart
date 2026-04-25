import 'dart:async';
// ignore_for_file: unused_element, unused_local_variable, use_build_context_synchronously, annotate_overrides, unnecessary_import
import 'dart:convert';
import '../../../ui/glass/native_glass_view.dart';
import 'package:classmate_mobile/features/classrooms/data/classrooms_repository.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmate_mobile/features/chat_core/ui/chat_scroll_to_bottom_fab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/media/image_viewer_screen.dart';
import '../../common/media/pdf_viewer_screen.dart';
import '../../../common/widgets/typing_dots.dart';
import '../../chat_core/utils/chat_reply_codec.dart';
import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/domain/chat_thread_type.dart';
import '../../messages/domain/message_thread_models.dart';
import '../../messages/providers/messages_repository_provider.dart';
import '../../chat_core/ui/chat_message_bubble.dart';
import '../../chat_core/ui/chat_context_overlay.dart';
import '../../chat_core/ui/chat_reaction_details_sheet.dart';
import '../../chat_core/ui/chat_media_preview_screen.dart';
import '../../chat_core/ui/chat_composer.dart';
import '../../chat_core/models/chat_message_info.dart';
import '../../chat_core/ui/chat_message_info_page.dart';
import '../../chat_core/ui/chat_recording_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/auth/auth_session.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../providers/classrooms_providers.dart';
import '../providers/classrooms_repo_provider.dart';
import '../../messages/ui/new_chat_screen.dart';

class _ClassroomForwardTargetPickerSheet extends ConsumerStatefulWidget {
  const _ClassroomForwardTargetPickerSheet({required this.currentThreadId});

  final String currentThreadId;

  @override
  ConsumerState<_ClassroomForwardTargetPickerSheet> createState() =>
      _ClassroomForwardTargetPickerSheetState();
}

class _ClassroomForwardTargetPickerSheetState
    extends ConsumerState<_ClassroomForwardTargetPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  final Set<String> _selected = <String>{};
  bool _submitting = false;
  bool _isApprovedForwardTarget(MessageThreadSummary item) {
    return item.requestState != ChatRequestState.pendingIncoming &&
        item.requestState != ChatRequestState.pendingOutgoing &&
        item.requestState != ChatRequestState.blocked;
  }

  bool _isClassroomThread(MessageThreadSummary item) {
    return item.type == ChatThreadType.classroom;
  }

  List<MessageThreadSummary> _filtered(List<MessageThreadSummary> items) {
    final q = _query.trim().toLowerCase();

    return items
        .where((item) => item.id != widget.currentThreadId)
        .where(_isApprovedForwardTarget)
        .where((item) {
          if (q.isEmpty) return true;
          return item.title.toLowerCase().contains(q) ||
              item.subtitle.toLowerCase().contains(q);
        })
        .toList();
  }

  // Sort DMs by recency (matching DM picker behaviour).
  List<MessageThreadSummary> _sortDmTargets(List<MessageThreadSummary> items) {
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

  MessageThreadSummary _classroomMapToSummary(Map<String, dynamic> map) {
    final id = (map['id'] ?? '').toString().trim();
    final name = (map['name'] ?? map['title'] ?? '').toString().trim();
    final subject = (map['subject'] ?? '').toString().trim();
    final teacher = (map['teacherName'] ?? map['teacher'] ?? '').toString().trim();
    final displayTitle = name.isNotEmpty
        ? name
        : (subject.isNotEmpty
              ? subject
              : AppLocalizations.of(context)!.classroomsClassroomLabel);
    final initials = displayTitle.trim().split(RegExp(r'\s+')).take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
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

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
          final selected = _selected.contains(item.id);
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
              onTap: _submitting ? null : () => _toggle(item.id),
              child: LiquidGlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                borderRadius: BorderRadius.circular(16),
                blurSigma: 10,
                color: selected
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.10)
                    : Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.55),
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
                              if (_isClassroomThread(item))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.92),
                                        Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withValues(alpha: 0.58),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                          .withValues(alpha: 0.14),
                                    ),
                                  ),
                                  child: Text(
                                    l.classroomsThreadTypeClassroom,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                )
                              else if (item.isGroup)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.92),
                                        Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withValues(alpha: 0.58),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                          .withValues(alpha: 0.14),
                                    ),
                                  ),
                                  child: Text(
                                    l.classroomsThreadTypeGroup,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.92),
                                        Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withValues(alpha: 0.58),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                          .withValues(alpha: 0.14),
                                    ),
                                  ),
                                  child: Text(
                                    l.classroomsThreadTypeDirectMessageShort,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
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
                          nav.pop([threadId.trim()]);
                        }
                      },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(l.classroomsForwardNewChat),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: inbox.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(l.classroomsForwardLoadError(error.toString())),
                ),
                data: (inboxItems) {
                  final classrooms = _filtered(
                    (classroomsAsync.asData?.value ?? const [])
                        .map(_classroomMapToSummary)
                        .toList(),
                  );
                  final directMessages = _sortDmTargets(
                    _filtered(
                      inboxItems.where((i) => !_isClassroomThread(i)).toList(),
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
                            Navigator.of(context).pop(_selected.toList());
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

class ClassroomDetailScreen extends ConsumerStatefulWidget {
  const ClassroomDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<ClassroomDetailScreen> createState() =>
      _ClassroomDetailScreenState();
}

String _classroomSeenKey(String courseId) => 'classroom_last_seen_$courseId';

class _ClassroomDetailScreenState extends ConsumerState<ClassroomDetailScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> classroomAllowedEmojis = <String>['❤️', '👍', '😂', '😮', '😢', '🙏'];
  double lastClassroomInsetsBottom = 0;

  ({String replyPrefix, String bodyText}) _splitReplyRaw(String raw) {
    final v = raw.trim();
    if (!v.startsWith('↪ ')) {
      return (replyPrefix: '', bodyText: v);
    }
    final dash = v.lastIndexOf(' — ');
    if (dash == -1) {
      return (replyPrefix: '', bodyText: v);
    }
    return (
      replyPrefix: v.substring(0, dash + 3).trimRight(),
      bodyText: v.substring(dash + 3).trim(),
    );
  }

  String _editableBodyText(String raw) {
    final body = _splitReplyRaw(raw).bodyText;
    if (body.startsWith('Forwarded\n')) return body.substring('Forwarded\n'.length);
    if (body.startsWith('Forwarded\r\n')) return body.substring('Forwarded\r\n'.length);
    final legacyMatch = RegExp(r'^↪ Forwarded[：:]\s*').firstMatch(body);
    if (legacyMatch != null) return body.substring(legacyMatch.end);
    if (body == 'Forwarded') return '';
    return body;
  }

  String _replyPreviewText(String raw) {
    var v = _editableBodyText(raw);

    v = v.replaceFirst(RegExp(r'^\[IMAGE\]\s*', caseSensitive: false), '');
    v = v.replaceFirst(RegExp(r'^\[FILE\]\s*', caseSensitive: false), '');
    v = v.replaceFirst(RegExp(r'^\[VIDEO\]\s*', caseSensitive: false), '');
    v = v.replaceFirst(RegExp(r'^\[VOICE\]\s*', caseSensitive: false), '');

    if (RegExp(
      r'\.(jpg|jpeg|png|webp|gif)$',
      caseSensitive: false,
    ).hasMatch(v)) {
      return _classroomKindLabel('IMAGE');
    }
    if (RegExp(r'\.(m4a|aac|mp3|wav)$', caseSensitive: false).hasMatch(v)) {
      return _classroomKindLabel('VOICE');
    }
    if (v.isEmpty) return AppLocalizations.of(context)!.classroomsMessageFallback;
    return v;
  }

  String _classroomKindLabel(String kind) {
    final l = AppLocalizations.of(context)!;
    switch (kind.trim().toUpperCase()) {
      case 'IMAGE':
        return l.classroomDetailPhoto;
      case 'VOICE':
        return l.classroomDetailVoiceNote;
      case 'VIDEO':
        return l.classroomDetailVideo;
      case 'DOC':
      case 'FILE':
      case 'PDF':
        return l.classroomDetailFile;
      case 'TEXT':
      default:
        return l.classroomsMessageFallback;
    }
  }

  String _classroomEmptyPreviewLabel(String kind) {
    final l = AppLocalizations.of(context)!;
    switch (kind.trim().toUpperCase()) {
      case 'IMAGE':
        return l.classroomDetailPhoto;
      case 'VIDEO':
        return l.classroomDetailVideo;
      case 'VOICE':
        return l.classroomDetailVoiceNote;
      case 'FILE':
      case 'DOC':
      case 'PDF':
        return l.classroomDetailFile;
      default:
        return l.classroomDetailEmptyValue;
    }
  }

  String _classroomSenderLabel(bool isMine, String senderLabel) {
    return isMine ? AppLocalizations.of(context)!.tutorYou : senderLabel;
  }

  String _classroomPreviewBody(String text, String kind) {
    final body = _editableBodyText(text).trim();
    return body.isEmpty ? _classroomEmptyPreviewLabel(kind) : _editableBodyText(text);
  }

  final _imagePicker = ImagePicker();
  late final TabController _tabs = TabController(length: 5, vsync: this);
  final TextEditingController _chatCtl = TextEditingController();
  final ScrollController _chatScrollCtl = ScrollController();
  final ValueNotifier<bool> _showClassroomScrollToBottom = ValueNotifier<bool>(
    false,
  );
  final Map<String, double> _swipeDxByMessage = <String, double>{};
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _draftVoicePlayer = AudioPlayer();
  final List<Map<String, String>> _draftAttachments = <Map<String, String>>[];
  final Set<String> _recentOwnMessageTexts = <String>{};
  // Optimistic messages appended immediately after send, cleared on re-fetch.
  final List<Map<String, dynamic>> _optimisticMessages = <Map<String, dynamic>>[];
  final Set<String> _pinnedMessageIds = <String>{};
  final Set<String> _deleteSelection = <String>{};
  final Set<String> _forwardSelectedMessageIds = <String>{};
  bool _isForwardSelectionMode = false;

  String get _classroomPinnedPrefsKey => 'classroom_pinned_ids_${widget.courseId}';
  String get _classroomTabsCollapsedPrefsKey =>
      'classroom_tabs_collapsed_${widget.courseId}';

  Future<void> _loadPinnedClassroomIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_classroomPinnedPrefsKey) ?? const <String>[];
      if (!mounted) return;
      setState(() {
        _pinnedMessageIds
          ..clear()
          ..addAll(
            saved
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty),
          );
      });
    } catch (_) {}
  }

  Future<void> _persistPinnedClassroomIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _classroomPinnedPrefsKey,
        _pinnedMessageIds
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
          ..sort(),
      );
    } catch (_) {}
  }

  Future<void> _loadClassroomTabsCollapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_classroomTabsCollapsedPrefsKey) ?? false;
      if (!mounted) return;
      setState(() {
        _classroomTabsCollapsed = saved;
      });
    } catch (_) {}
  }

  Future<void> _persistClassroomTabsCollapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        _classroomTabsCollapsedPrefsKey,
        _classroomTabsCollapsed,
      );
    } catch (_) {}
  }

  final Map<String, GlobalKey> _messageKeys = <String, GlobalKey>{};
  final List<Map<String, dynamic>> _lastVisibleClassroomRows =
      <Map<String, dynamic>>[];
  final List<String> _lastVisibleClassroomMessageIds = <String>[];
  Timer? _highlightClearTimer;
  String? _highlightedMessageId;
  String? _draftVoicePath;
  Timer? _recordTicker;
  Duration _recordElapsed = Duration.zero;
  Offset? _holdStartGlobal;
  double _holdDx = 0;
  double _holdDy = 0;
  bool _draftVoicePlaying = false;
  double _draftVoiceSpeed = 1.0;
  Duration _draftVoicePosition = Duration.zero;
  Duration _draftVoiceDuration = Duration.zero;
  bool _draftVoiceReady = false;

  bool _sending = false;
  bool _classroomNearBottom([double threshold = 140]) {
    if (!_chatScrollCtl.hasClients) return true;
    final distance =
        _chatScrollCtl.position.maxScrollExtent - _chatScrollCtl.position.pixels;
    return distance <= threshold;
  }

  void _onClassroomRowsRendered(List<Map<String, dynamic>> rows) {
    final previousCount = _lastChatCount;
    final previousLastMessageId = _knownLastClassroomMessageId;
    final currentLastMessageId = rows.isEmpty ? null : _pick(rows.last, 'id');

    _lastChatCount = rows.length;
    _knownLastClassroomMessageId = currentLastMessageId;

    if (previousCount <= 0 || currentLastMessageId == null) return;
    if (currentLastMessageId == previousLastMessageId) return;

    final shouldStickToBottom = _classroomNearBottom(180);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (shouldStickToBottom) {
        _classroomNewMessagesBelow = false;
        _showClassroomScrollToBottom.value = false;
        _pinClassroomToBottom();
        return;
      }

      _classroomNewMessagesBelow = true;
      _showClassroomScrollToBottom.value = true;
    });
  }

  void _handleClassroomScroll() {
    if (!_chatScrollCtl.hasClients) return;

    final nearBottom = _classroomNearBottom(96);
    if (nearBottom && _classroomNewMessagesBelow) {
      _classroomNewMessagesBelow = false;
      _showClassroomScrollToBottom.value = false;
      return;
    }

    _showClassroomScrollToBottom.value =
        !_classroomNearBottom(180) || _classroomNewMessagesBelow;
  }

  void _pinClassroomToBottom({bool jump = false}) {
    if (!_chatScrollCtl.hasClients) return;
    final offset = _chatScrollCtl.position.maxScrollExtent;
    if (jump) {
      _chatScrollCtl.jumpTo(offset);
      return;
    }
    _chatScrollCtl.animateTo(
      offset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  GlobalKey _keyForClassroomMessage(String messageId) {
    return _messageKeys.putIfAbsent(messageId, () => GlobalKey());
  }

  void _pulseClassroomMessage(String messageId) {
    _highlightClearTimer?.cancel();
    if (!mounted) return;
    // Triple-flash: on → off → on → fade
    setState(() => _highlightedMessageId = messageId);
    _highlightClearTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || _highlightedMessageId != messageId) return;
      setState(() => _highlightedMessageId = null);
      Timer(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() => _highlightedMessageId = messageId);
        Timer(const Duration(milliseconds: 800), () {
          if (!mounted || _highlightedMessageId != messageId) return;
          setState(() => _highlightedMessageId = null);
        });
      });
    });
  }

  String? _resolveClassroomReplyJumpTarget(
    Map<String, dynamic> item,
    List<Map<String, dynamic>> rows,
  ) {
    final direct = [
      _pick(item, 'replyToMessageId'),
      _pick(item, 'replyToId'),
      _pick(item, 'quotedMessageId'),
      _pick(item, 'parentMessageId'),
    ].firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');
    if (direct.isNotEmpty && rows.any((row) => _pick(row, 'id') == direct)) {
      return direct;
    }

    final selfId = _pick(item, 'id');
    final rawText = (_editedTextByMessage[selfId] ?? _pick(item, 'text')).trim();
    if (!rawText.startsWith('↪ ')) return null;

    final afterArrow = rawText.substring(2).trim();
    final colon = afterArrow.indexOf(':');
    if (colon == -1) return null;

    final replySender = afterArrow.substring(0, colon).trim().toLowerCase();
    final rest = afterArrow.substring(colon + 1).trim();
    final dash = rest.lastIndexOf(' — ');
    final replySnippet = (dash == -1 ? rest : rest.substring(0, dash)).trim();
    if (replySnippet.isEmpty) return null;

    String normalize(String v) => v.trim().toLowerCase();

    for (var i = rows.length - 1; i >= 0; i--) {
      final row = rows[i];
      final rowId = _pick(row, 'id');
      if (rowId.isEmpty || rowId == selfId) continue;

      final candidateSender = [
        _pick(row, 'senderName').trim(),
        _pick(row, 'authorName').trim(),
        _pick(row, 'createdByName').trim(),
      ].firstWhere((e) => e.isNotEmpty, orElse: () => '').toLowerCase();

      final candidateRaw =
          (_editedTextByMessage[rowId] ?? _pick(row, 'text')).trim();
      final candidatePreview = _replyPreviewText(candidateRaw).trim();
      final candidateBody = _editableBodyText(candidateRaw).trim();

      final senderOk =
          replySender.isEmpty ||
          candidateSender == replySender ||
          candidateSender.isEmpty;

      final snippetOk =
          normalize(candidatePreview) == normalize(replySnippet) ||
          normalize(candidateBody) == normalize(replySnippet) ||
          normalize(candidatePreview).startsWith(normalize(replySnippet)) ||
          normalize(replySnippet).startsWith(normalize(candidatePreview)) ||
          normalize(candidateBody).startsWith(normalize(replySnippet)) ||
          normalize(replySnippet).startsWith(normalize(candidateBody));

      if (senderOk && snippetOk) {
        return rowId;
      }
    }

    return null;
  }

  void _jumpToClassroomMessage(String messageId) {
    final index = _lastVisibleClassroomMessageIds.indexOf(messageId);
    if (index < 0 || !_chatScrollCtl.hasClients) return;

    void ensureAfterScroll() {
      Future<void>.delayed(const Duration(milliseconds: 40), () {
        if (!mounted) return;
        final ctx = _keyForClassroomMessage(messageId).currentContext;
        if (ctx == null) return;
        _pulseClassroomMessage(messageId);
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: 0.18,
        );
      });
    }

    final target = _keyForClassroomMessage(messageId).currentContext;
    if (target != null) {
      _pulseClassroomMessage(messageId);
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
      return;
    }

    final total = _lastVisibleClassroomMessageIds.length;
    final fraction = total <= 1 ? 0.0 : index / (total - 1);
    final estimatedOffset =
        (_chatScrollCtl.position.maxScrollExtent * fraction).clamp(
          _chatScrollCtl.position.minScrollExtent,
          _chatScrollCtl.position.maxScrollExtent,
        );

    _chatScrollCtl
        .animateTo(
          estimatedOffset,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        )
        .then((_) {
          ensureAfterScroll();
        });
  }

  bool _recording = false;
  bool _voiceLocked = false;
  bool _voicePaused = false;
  bool _voiceCancelled = false;
  String? replyToId;

  void _goBackToClassrooms() {
    if (!mounted) {
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/classrooms');
    }
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

  String _absoluteMediaUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final base = _uploadsBaseUrl();
    return value.startsWith('/') ? '$base$value' : '$base/$value';
  }

  Future<void> _openAttachmentUrl({
    required String raw,
    required String label,
    required String kind,
  }) async {
    final l = AppLocalizations.of(context)!;
    final absolute = _absoluteMediaUrl(raw);
    if (absolute.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(l.classroomDetailAttachmentUnavailable)),
      );
      return;
    }

    final upperKind = kind.trim().toUpperCase();
    final lowerLabel = label.trim().toLowerCase();
    final isImage = upperKind == 'IMAGE';
    final isPdf = lowerLabel.endsWith('.pdf') || upperKind == 'PDF';
    final isAudio =
        upperKind == 'VOICE' ||
        lowerLabel.endsWith('.m4a') ||
        lowerLabel.endsWith('.aac') ||
        lowerLabel.endsWith('.mp3') ||
        lowerLabel.endsWith('.wav');

    if (isImage) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImageViewerScreen(url: absolute, label: label),
        ),
      );
      return;
    }

    if (isAudio) {
      final uri = Uri.tryParse(absolute);
      if (uri == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text(l.classroomDetailAudioUnavailable)),
        );
        return;
      }

      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      return;
    }

    if (isAudio) {
      return;
    }

    if (isPdf) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(url: absolute, label: label),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(absolute);
    if (uri == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(l.classroomDetailAttachmentUnavailable)),
      );
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.classroomDetailCouldNotOpenAttachment)),
      );
    }
  }

  bool _isImageKind(String kind) => kind == 'IMAGE';

  bool _isFileLikeKind(String kind) =>
      kind == 'DOC' || kind == 'FILE' || kind == 'VIDEO' || kind == 'VOICE';

  IconData _fileIconForKind(String kind, String text) {
    final name = text.toLowerCase();
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
    if (kind == 'VIDEO' ||
        name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.mkv')) {
      return Icons.movie_creation_outlined;
    }
    if (kind == 'VOICE' ||
        name.endsWith('.mp3') ||
        name.endsWith('.m4a') ||
        name.endsWith('.wav')) {
      return Icons.audio_file_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  String _fileLabelFromMessageText(String text, String kind) {
    final l = AppLocalizations.of(context)!;
    final v = text.trim();
    if (v.startsWith('[IMAGE] ')) return v.substring(8).trim();
    if (v.startsWith('[VOICE] ')) return v.substring(8).trim();
    if (v.startsWith('[VIDEO] ')) return v.substring(8).trim();
    if (v.startsWith('[FILE] ')) return v.substring(7).trim();

    if (v.isNotEmpty && v != '(empty)') return v;

    switch (kind) {
      case 'VOICE':
        return l.classroomDetailVoiceMessage;
      case 'VIDEO':
        return l.classroomDetailVideoFile;
      case 'DOC':
      case 'FILE':
        return l.classroomDetailAttachedFile;
      default:
        return l.classroomDetailAttachment;
    }
  }

  String _classroomKindInfoLabel(String kind) {
    return _classroomKindLabel(kind);
  }

  String _fmtInfoDurationSeconds(int? seconds) {
    final value = seconds ?? 0;
    if (value <= 0) return '';
    final mm = (value ~/ 60).toString().padLeft(2, '0');
    final ss = (value % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _showClassroomMessageInfo({
    required String sentAt,
    required bool isMine,
    required bool edited,
    required bool forwarded,
    required String deleteState,
    required String kind,
    required String previewTitle,
    required String previewBody,
    String previewMeta = '',
    String previewMediaUrl = '',
    WidgetBuilder? previewBubbleBuilder,
    int? voiceDurationSeconds,
  }) async {
    if (!mounted) return;
    final nav = Navigator.of(context);

    await nav.push(
      CupertinoPageRoute<void>(
        builder: (_) => ChatMessageInfoPage(
          info: ChatMessageInfo(
            title: AppLocalizations.of(context)!.classroomDetailMessageInfoTitle,
            sentAt: sentAt,
            deliveredAt: '',
            seenAt: '',
            delivered: false,
            seen: false,
            edited: edited,
            forwarded: forwarded,
            deleteState: deleteState,
            isMine: isMine,
            messageType: _classroomKindInfoLabel(kind),
            voiceDuration: _fmtInfoDurationSeconds(voiceDurationSeconds),
          ),
          previewTitle: previewTitle,
          previewBody: previewBody,
          previewMeta: previewMeta,
          previewBubbleBuilder: previewBubbleBuilder,
          seenByNames: const <String>[],
          deliveredToNames: const <String>[],
        ),
      ),
    );
  }

  String _fmtDuration(Duration d) {
    final total = d.inSeconds;
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _markChatSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _classroomSeenKey(widget.courseId),
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  bool _typing = false;
  bool _classroomTabsCollapsed = false;
  int _activeClassroomTabIndex = 0;
  String? _replyToMessageId;
  String? _replyToSender;
  String? _replyToText;
  String? _editingMessageId;
  String? _editingOriginalText;

  int _lastChatCount = -1;
  String? _knownLastClassroomMessageId;
  bool _classroomNewMessagesBelow = false;

  Map<String, String> _reactionByMessage = <String, String>{};
  Map<String, String> _editedTextByMessage = <String, String>{};
  Set<String> _deletedMessageIds = <String>{};
  final Set<String> _deletedForEveryoneMessageIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadPinnedClassroomIds();
    _loadClassroomTabsCollapsed();
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
    Future.microtask(_markChatSeen);
    _tabs.addListener(() {
      if (!mounted) {
        return;
      }
      if (!_tabs.indexIsChanging && _activeClassroomTabIndex != _tabs.index) {
        setState(() {
          _activeClassroomTabIndex = _tabs.index;
        });
      }
      if (!_tabs.indexIsChanging && _tabs.index == 0) {
        Future.microtask(_markChatSeen);
      }
    });
    _chatCtl.addListener(_onComposerChanged);
    _loadLocalChatState();
    _loadPinnedClassroomIds();
  }

  @override
  void dispose() {
    _highlightClearTimer?.cancel();
    _draftVoicePlayer.stop();
    _draftVoicePlayer.dispose();
    _tabs.dispose();
    _chatCtl.removeListener(_onComposerChanged);
    _chatCtl.dispose();
    _chatScrollCtl.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _onComposerChanged() {
    final next = _chatCtl.text.trim().isNotEmpty;
    if (next != _typing && mounted) {
      setState(() => _typing = next);
    }
  }

  String _key(String suffix) => 'classroom_chat:${widget.courseId}:$suffix';

    Future<void> _loadLocalChatState() async {
    final prefs = await SharedPreferences.getInstance();

    final reactionsRaw = prefs.getString(_key('reactions'));
    final editsRaw = prefs.getString(_key('edits'));
    final deletedRaw = prefs.getString(_key('deleted'));
    final deletedForEveryoneRaw = prefs.getString(_key('deleted_for_everyone'));


    Map<String, String> reactions = <String, String>{};
    Map<String, String> edits = <String, String>{};
    Set<String> deleted = <String>{};
    Set<String> deletedForEveryone = <String>{};

    if (reactionsRaw != null && reactionsRaw.trim().isNotEmpty) {
      final decoded = jsonDecode(reactionsRaw);
      if (decoded is Map) {
        reactions = decoded.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    }

    if (editsRaw != null && editsRaw.trim().isNotEmpty) {
      final decoded = jsonDecode(editsRaw);
      if (decoded is Map) {
        edits = decoded.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    }

    if (deletedRaw != null && deletedRaw.trim().isNotEmpty) {
      final decoded = jsonDecode(deletedRaw);
      if (decoded is List) {
        deleted = decoded.map((e) => e.toString()).toSet();
      }
    }

    if (deletedForEveryoneRaw != null &&
        deletedForEveryoneRaw.trim().isNotEmpty) {
      final decoded = jsonDecode(deletedForEveryoneRaw);
      if (decoded is List) {
        deletedForEveryone = decoded.map((e) => e.toString()).toSet();
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _reactionByMessage = reactions;
      _editedTextByMessage = edits;
      _deletedMessageIds = deleted;
      _deletedForEveryoneMessageIds
        ..clear()
        ..addAll(deletedForEveryone);
    });

  }

    Future<void> _persistLocalChatState() async {
    final prefs = await SharedPreferences.getInstance();
    final reactionsJson = jsonEncode(_reactionByMessage);
    final editsJson = jsonEncode(_editedTextByMessage);
    final deletedJson = jsonEncode(_deletedMessageIds.toList()..sort());
    final deletedForEveryoneJson = jsonEncode(_deletedForEveryoneMessageIds.toList()..sort());

    debugPrint('[CLASSROOM_PERSIST] course=${widget.courseId} deleted=${_deletedMessageIds.toList()..sort()} deletedForEveryone=${_deletedForEveryoneMessageIds.toList()..sort()}');

    await prefs.setString(_key('reactions'), reactionsJson);
    await prefs.setString(_key('edits'), editsJson);
    await prefs.setString(_key('deleted'), deletedJson);
    await prefs.setString(_key('deleted_for_everyone'), deletedForEveryoneJson);

    debugPrint('[CLASSROOM_PERSIST_DONE] course=${widget.courseId} deletedRaw=${prefs.getString(_key('deleted')) ?? 'null'} deletedForEveryoneRaw=${prefs.getString(_key('deleted_for_everyone')) ?? 'null'}');
  }

  void _refreshAll() {
    ref.invalidate(classroomDetailProvider(widget.courseId));
    ref.invalidate(classroomPeopleProvider(widget.courseId));
    ref.invalidate(
      classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
    );
    ref.invalidate(classroomAssignmentsProvider(widget.courseId));
    ref.invalidate(classroomMaterialsProvider(widget.courseId));
    ref.invalidate(classroomMeetingsProvider(widget.courseId));
  }

  void _scrollToBottom({required bool jump}) {
    if (!mounted) {
      return;
    }
    if (!_chatScrollCtl.hasClients) {
      return;
    }
    if (_chatScrollCtl.positions.length != 1) {
      return;
    }

    final target = _chatScrollCtl.position.maxScrollExtent;
    if (jump) {
      _chatScrollCtl.jumpTo(target);
      return;
    }

    if (jump) {
      _chatScrollCtl.jumpTo(_chatScrollCtl.position.maxScrollExtent);
      return;
    }
    _chatScrollCtl.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutQuart,
    );
  }

  void _clearReply() {
    if (!mounted) {
      return;
    }
    setState(() {
      _replyToMessageId = null;
      _replyToSender = null;
      _replyToText = null;
    });
  }

  void _clearClassroomEdit() {
    _editingMessageId = null;
    _editingOriginalText = null;
  }

  String _resolveMyUserId(Map<String, String> peopleMap) {
    final session = ref.read(authSessionProvider);
    final display = session.displayName.trim().toLowerCase();
    final token = (session.token ?? '').trim().toLowerCase();
    final tokenLocal = token.contains('@')
        ? token.split('@').first.trim().toLowerCase()
        : token;
    final tokenLocalClean = tokenLocal.replaceFirst(
      RegExp(r'^dev-token-'),
      '',
    );

    for (final entry in peopleMap.entries) {
      final id = entry.key.trim();
      final name = entry.value.trim().toLowerCase();
      final idLower = id.toLowerCase();

      if (display.isNotEmpty &&
          (name == display || name.contains(display) || display.contains(name))) {
        return id;
      }
      if (token.isNotEmpty && idLower == token) {
        return id;
      }
      if (tokenLocalClean.isNotEmpty &&
          (name == tokenLocalClean || name.contains(tokenLocalClean))) {
        return id;
      }
    }

    return '';
  }

  Future<void> _setReaction(String messageId, String emoji) async {
    setState(() {
      if (_reactionByMessage[messageId] == emoji) {
        _reactionByMessage.remove(messageId);
      } else {
        _reactionByMessage[messageId] = emoji;
      }
    });
    await _persistLocalChatState();
  }

  Future<void> _openClassroomReactionDetails(String messageId) async {
    final picked = await ChatReactionDetailsSheet.show(
      context,
      myReaction: _reactionByMessage[messageId],
      reactionUsers:
          (_reactionByMessage[messageId] ?? '').trim().isEmpty
              ? const <String, List<String>>{}
              : <String, List<String>>{
                  _reactionByMessage[messageId]!.trim(): const <String>['me'],
                },
      pickerAllowedEmojis: classroomAllowedEmojis,
    );
    if (!mounted || (picked ?? '').trim().isEmpty) return;
    if (picked == '__remove__') {
      setState(() {
        _reactionByMessage.remove(messageId);
      });
      await _persistLocalChatState();
      return;
    }
    await _setReaction(messageId, picked!.trim());
  }

  Future<void> _togglePinMessage(String messageId) async {
    setState(() {
      if (_pinnedMessageIds.contains(messageId)) {
        _pinnedMessageIds.remove(messageId);
      } else {
        _pinnedMessageIds.add(messageId);
      }
    });
    await _persistPinnedClassroomIds();
  }

  Future<List<String>?> _showClassroomForwardTargetPicker() {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ClassroomForwardTargetPickerSheet(
        currentThreadId: widget.courseId,
      ),
    );
  }

  void _enterForwardSelectionMode(String messageId) {
    if (!mounted) return;
    setState(() {
      _isForwardSelectionMode = true;
      _forwardSelectedMessageIds
        ..clear()
        ..add(messageId);
      _deleteSelection.clear();
      _clearClassroomEdit();
    });
  }

  void _exitForwardSelectionMode() {
    if (!mounted) return;
    setState(() {
      _isForwardSelectionMode = false;
      _forwardSelectedMessageIds.clear();
    });
  }

  void _openForwardedIfSingle(List<String> targetThreadIds) {
    if (targetThreadIds.length != 1 || !mounted) return;
    final targetId = targetThreadIds.first;
    final knownClassrooms =
        ref.read(orderedStudentClassroomsProvider).asData?.value ?? const [];
    final isClassroom = knownClassrooms.any(
      (c) => (c['id'] ?? '').toString().trim() == targetId,
    );
    if (isClassroom) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ClassroomDetailScreen(courseId: targetId),
        ),
      );
    } else {
      context.push('/messages/$targetId');
    }
  }

  Future<void> _forwardSelectedClassroomMessages() async {
    if (_forwardSelectedMessageIds.isEmpty) return;
    final l = AppLocalizations.of(context)!;

    final targetThreadIds = await _showClassroomForwardTargetPicker();
    if (!mounted || targetThreadIds == null || targetThreadIds.isEmpty) {
      return;
    }

    final selectedRows = _lastVisibleClassroomRows
        .where((row) => _forwardSelectedMessageIds.contains(_pick(row, 'id')))
        .toList(growable: false);

    try {
      for (final row in selectedRows) {
        final id = _pick(row, 'id');
        await ref.read(classroomsRepoProvider).forwardChatMessage(
              widget.courseId,
              messageId: id,
              targetThreadIds: targetThreadIds,
            );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _forwardSelectedMessageIds.length == 1
                ? l.classroomDetailForwardedSingle
                : l.classroomDetailForwardedMultiple(
                    _forwardSelectedMessageIds.length,
                  ),
          ),
        ),
      );
      _openForwardedIfSingle(targetThreadIds);
    } catch (e) {
      if (!mounted) return;
      final text = e.toString();
      final message = text.contains('Cannot forward into a non-approved thread')
          ? l.classroomDetailCannotForwardPending
          : l.classroomDetailCouldNotForwardSelected;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isForwardSelectionMode = false;
          _forwardSelectedMessageIds.clear();
        });
      }
    }
  }

  Widget _buildForwardModeHeader() {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        borderRadius: BorderRadius.circular(16),
        blurSigma: 14,
        color: cs.surface.withValues(alpha: 0.88),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.22),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _exitForwardSelectionMode,
              icon: const Icon(Icons.close_rounded),
              tooltip: AppLocalizations.of(context)!.classroomsForwardCancel,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.classroomsForwardCount(
                  _forwardSelectedMessageIds.length,
                ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: _forwardSelectedMessageIds.isEmpty
                  ? null
                  : _forwardSelectedClassroomMessages,
              icon: const Icon(Icons.forward_rounded),
              tooltip: 'Forward selected',
            ),
          ],
        ),
      ),
    );
  }

  bool _isClassroomForwardedText(String text) {
    final normalized = text.trimLeft();
    return normalized.startsWith('Forwarded\n') ||
        normalized.startsWith('Forwarded\r\n') ||
        normalized.startsWith('↪ Forwarded:') ||
        normalized.startsWith('↪ Forwarded：') ||
        normalized == 'Forwarded';
  }

  bool _isTruthyForwardedValue(String raw) {
    final v = raw.trim().toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }

  bool _isClassroomMessageForwarded(
    dynamic item, {
    required String text,
    required String originalText,
  }) {
    final metadataCandidates = <String>[
      _pick(item, 'forwarded'),
      _pick(item, 'isForwarded'),
      _pick(item, 'forwardedFlag'),
    ];

    for (final candidate in metadataCandidates) {
      if (_isTruthyForwardedValue(candidate)) return true;
    }

    return _isClassroomForwardedText(text) ||
        _isClassroomForwardedText(originalText);
  }

  Future<void> _forwardPlaceholder({
    required String messageId,
    required String text,
    required String mediaUrl,
  }) async {
    final l = AppLocalizations.of(context)!;
    final label = _editableBodyText(text).trim().isNotEmpty
        ? _editableBodyText(text).trim()
        : (mediaUrl.trim().isNotEmpty
              ? mediaUrl.split('/').last
              : l.classroomsMessageFallback);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.classroomDetailForwardTargetNext(label))),
    );
  }

    Future<void> _deleteMessage(String messageId) async {
    setState(() {
      _deletedMessageIds.add(messageId);
      _deletedForEveryoneMessageIds.remove(messageId);
      _reactionByMessage.remove(messageId);
      _editedTextByMessage.remove(messageId);
    });
    await _persistLocalChatState();
  }

  Future<void> _editMessage(
    BuildContext context, {
    required String messageId,
    required String currentText,
  }) async {
    final l = AppLocalizations.of(context)!;
    final ctl = TextEditingController(text: _editableBodyText(currentText));
    final next = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.classroomDetailEditMessageTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: ctl,
                autofocus: true,
                minLines: 2,
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  hintText: l.classroomDetailEditMessageHint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.classroomsForwardCancel),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    fit: FlexFit.loose,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, ctl.text.trim()),
                      child: Text(l.profileSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (next == null || next.trim().isEmpty) return;

    final finalText = preserveReplyOnEdit(
      originalRaw: currentText,
      updatedBody: next.trim(),
    );

    setState(() {
      _editedTextByMessage[messageId] = finalText;
    });
    await _persistLocalChatState();
  }

  Future<void> _showMessageInfo({
    required String title,
    required bool edited,
    bool forwarded = false,
    String sentAt = '',
    String deliveredAt = '',
    String seenAt = '',
    String deleteState = '',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      builder: (_) => ChatMessageInfoPage(
        info: ChatMessageInfo(
          title: title,
          sentAt: sentAt,
          deliveredAt: deliveredAt,
          seenAt: seenAt,
          edited: edited,
          forwarded: forwarded,
          deleteState: deleteState,
        ),
      ),
    );
  }

  void _replyTo({
    required String messageId,
    required String sender,
    required String text,
  }) {
    setState(() {
      _replyToMessageId = messageId;
      _replyToSender = sender;
      _replyToText = _replyPreviewText(text);
    });
  }

  bool _classroomCanEditMessage({
    required String messageId,
    required String text,
    required String mediaUrl,
    required String kind,
  }) {
    final raw = (_editedTextByMessage[messageId] ?? text).trim().toLowerCase();
    final media = mediaUrl.trim().toLowerCase();
    final type = kind.trim().toUpperCase();

    final isImage =
        type == 'IMAGE' ||
        raw.startsWith('[image]') ||
        media.endsWith('.jpg') ||
        media.endsWith('.jpeg') ||
        media.endsWith('.png') ||
        media.endsWith('.webp') ||
        media.endsWith('.gif');

    final isVoice =
        type == 'VOICE' ||
        raw.startsWith('[voice]') ||
        media.endsWith('.m4a') ||
        media.endsWith('.aac') ||
        media.endsWith('.mp3') ||
        media.endsWith('.wav');

    final isVideo = type == 'VIDEO' || raw.startsWith('[video]');

    final isFileLike =
        type == 'FILE' ||
        type == 'DOC' ||
        type == 'PDF' ||
        raw.startsWith('[file]') ||
        media.endsWith('.pdf');

    if (isImage || isVoice || isVideo || isFileLike) {
      return false;
    }

    return _editableBodyText(raw).trim().isNotEmpty;
  }

  String _pickKindFromRaw(String text, String mediaUrl) {
    final raw = text.trim().toLowerCase();
    final media = mediaUrl.trim().toLowerCase();

    if (raw.startsWith('[image]') ||
        media.endsWith('.jpg') ||
        media.endsWith('.jpeg') ||
        media.endsWith('.png') ||
        media.endsWith('.webp') ||
        media.endsWith('.gif')) {
      return 'IMAGE';
    }

    if (raw.startsWith('[voice]') ||
        media.endsWith('.m4a') ||
        media.endsWith('.aac') ||
        media.endsWith('.mp3') ||
        media.endsWith('.wav')) {
      return 'VOICE';
    }

    if (raw.startsWith('[video]')) return 'VIDEO';
    if (raw.startsWith('[file]') || media.endsWith('.pdf')) return 'FILE';
    return 'TEXT';
  }

  Future<void> _openBubbleMenu(
    BuildContext context, {
    required String messageId,
    required String text,
    required String mediaUrl,
    required String kind,
    required String senderLabel,
    required bool isMine,
    required bool edited,
    required bool forwarded,
    required String timeLabel,
    int? voiceDurationSeconds,
  }) async {
    final action = await ChatContextOverlay.show(
      context,
      isMine: isMine,
      canReply: true,
      canEdit: isMine &&
          _classroomCanEditMessage(
            messageId: messageId,
            text: text,
            mediaUrl: mediaUrl,
            kind: kind,
          ),
      canDelete: isMine,
      canViewInfo: isMine,
      canPin: true,
        pinLabel: _pinnedMessageIds.contains(messageId)
          ? AppLocalizations.of(context)!.classroomDetailUnpinAction
          : AppLocalizations.of(context)!.classroomDetailPinAction,
      canForward: true,
      canCopy: false,
      messageBubble: ChatMessageBubble(
        contextForNavigation: context,
        rawText: text,
        mediaUrl: mediaUrl,
        isMine: isMine,
        showName: false,
        senderLabel: senderLabel,
        timeLabel: timeLabel,
        edited: edited,
        reaction: _reactionByMessage[messageId],
        forwarded: forwarded,
        delivered: false,
        seen: false,
        deleteState: 'VISIBLE',
        voiceDurationSeconds: voiceDurationSeconds,
        voiceUnread: false,
        onVoicePlayed: null,
        replySender: null,
        replySnippet: null,
        mediaMimeType: null,
        messageKind: kind,
        maxWidth: 260,
      ),
    );

    if (action == null || action.trim().isEmpty) return;

    if (action == 'info') {
      setState(() {
        _deleteSelection.clear();
        _clearClassroomEdit();
      });
      await _showClassroomMessageInfo(
        sentAt: timeLabel,
        isMine: isMine,
        edited: edited,
        forwarded: forwarded,
        deleteState: 'VISIBLE',
        kind: kind,
        previewTitle: _classroomSenderLabel(isMine, senderLabel),
        previewBody: _classroomPreviewBody(text, kind),
        previewMeta: timeLabel,
        previewMediaUrl: mediaUrl,
        previewBubbleBuilder: (infoContext) => ChatMessageBubble(
          contextForNavigation: context,
          rawText: text,
          mediaUrl: mediaUrl,
          isMine: isMine,
          showName: false,
          senderLabel: senderLabel,
          timeLabel: timeLabel,
          edited: edited,
          reaction: _reactionByMessage[messageId],
          forwarded: forwarded,
          delivered: false,
          seen: false,
          deleteState: 'VISIBLE',
          voiceDurationSeconds: voiceDurationSeconds,
          voiceUnread: false,
          onVoicePlayed: null,
          replySender: _splitReplyRaw(text).replyPrefix.trim(),
          replySnippet: _replyPreviewText(text),
          mediaMimeType: null,
          messageKind: kind,
          maxWidth: 280,
        ),
      );
      return;
    }

    if (action == 'reply') {
      setState(() {
        _deleteSelection.clear();
        _clearClassroomEdit();
      });
      _replyTo(
        messageId: messageId,
        sender: senderLabel,
        text: _editableBodyText(text),
      );
      return;
    }

    if (action == 'pin') {
      setState(() {
        _deleteSelection.clear();
        _clearClassroomEdit();
      });
      await _togglePinMessage(messageId);
      return;
    }

    if (action == 'forward') {
      setState(() {
        _deleteSelection.clear();
        _clearClassroomEdit();
      });
      _enterForwardSelectionMode(messageId);
      return;
    }

    if (action.startsWith('react:')) {
      final emoji = action.substring('react:'.length).trim();
      if (emoji.isEmpty) {
        return;
      }
      await _setReaction(messageId, emoji);
      return;
    }

    if (action == 'edit') {
      setState(() {
        _deleteSelection.clear();
        _editingMessageId = messageId;
        _editingOriginalText = _editableBodyText(text);
        _chatCtl.value = TextEditingValue(
          text: _editableBodyText(text),
          selection: TextSelection.collapsed(
            offset: _editableBodyText(text).length,
          ),
        );
      });
      return;
    }

    if (action == 'delete') {
      setState(() {
        _clearClassroomEdit();
        _deleteSelection
          ..clear()
          ..add(messageId);
      });
      return;
    }
  }

  Future<void> _beginInlineEditClassroom({
    required String messageId,
    required String text,
    required String mediaUrl,
    required String kind,
  }) async {
    if (!_classroomCanEditMessage(
      messageId: messageId,
      text: text,
      mediaUrl: mediaUrl,
      kind: kind,
    )) {
      return;
    }

    final original = _editableBodyText(text).trimRight();

    setState(() {
      _clearReply();
      _editingMessageId = messageId;
      _editingOriginalText = original;
      _chatCtl.value = TextEditingValue(
        text: original,
        selection: TextSelection.collapsed(offset: original.length),
      );
    });
  }

  Future<void> _leaveClassroom() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.classroomDetailLeaveClassroomTitle),
        content: Text(l.classroomDetailLeaveClassroomBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomsForwardCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.classroomDetailLeaveAction),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await ClassroomsRepository().leaveClassroom(widget.courseId);
    ref.invalidate(classroomDetailProvider(widget.courseId));
    ref.invalidate(classroomPeopleProvider(widget.courseId));
    ref.invalidate(
      classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }


  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final detail = ref.watch(classroomDetailProvider(widget.courseId));
    final people = ref.watch(classroomPeopleProvider(widget.courseId));
    final chat = ref.watch(
      classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
    );
    final assignments = ref.watch(
      classroomAssignmentsProvider(widget.courseId),
    );
    final materials = ref.watch(classroomMaterialsProvider(widget.courseId));
    final meetings = ref.watch(classroomMeetingsProvider(widget.courseId));

    final classroomInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    if (classroomInsetsBottom != lastClassroomInsetsBottom) {
      lastClassroomInsetsBottom = classroomInsetsBottom;
      if (classroomInsetsBottom > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _scrollToBottom(jump: false);
        });
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showClassroomScrollToBottom,
        builder: (context, showScroll, _) {
          return ChatScrollToBottomFab(
            heroTag: 'classroom-scroll-bottom',
            show: showScroll,
            hasUnreadBelow: _classroomNewMessagesBelow,
            bottomInset: MediaQuery.of(context).viewInsets.bottom,
            onPressed: () {
              if (!mounted) return;
              _classroomNewMessagesBelow = false;
              _showClassroomScrollToBottom.value = false;
              _pinClassroomToBottom();
            },
          );
        },
      ),
      bottomNavigationBar: _activeClassroomTabIndex == 0
          ? AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [_classroomComposer()],
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (_isForwardSelectionMode)
              _buildForwardModeHeader()
            else
              detail.when(
                loading: () => const _HeaderSkeleton(),
                error: (e, st) => _TopHeader(
                icon: Icons.book_rounded,
                subject: l.classroomsClassroomLabel,
                subtitle: widget.courseId,
                onRefresh: () async {
                  _refreshAll();
                },
                onBack: _goBackToClassrooms,
                tabsCollapsed: _classroomTabsCollapsed,
                onToggleTabs: () async {
                  setState(() {
                    _classroomTabsCollapsed = !_classroomTabsCollapsed;
                  });
                  await _persistClassroomTabsCollapsed();
                },
                onLeave: _leaveClassroom,
              ),
              data: (m) => _TopHeader(
                icon: _subjectIcon((m['subject'] ?? '').toString()),
                subject:
                    ((m['name'] ?? '').toString().trim().isNotEmpty
                            ? (m['name'] ?? '').toString()
                      : (m['subject'] ?? l.classroomsClassroomLabel)
                        .toString())
                        .trim(),
                subtitle:
                    ((m['subject'] ?? '').toString().trim().isNotEmpty
                            ? (m['subject'] ?? '').toString()
                            : widget.courseId)
                        .trim(),
                onRefresh: () async {
                  _refreshAll();
                },
                onBack: _goBackToClassrooms,
                tabsCollapsed: _classroomTabsCollapsed,
                onToggleTabs: () async {
                  setState(() {
                    _classroomTabsCollapsed = !_classroomTabsCollapsed;
                  });
                  await _persistClassroomTabsCollapsed();
                },
                onLeave: _leaveClassroom,
              ),
            ),
            const SizedBox(height: 0),
            if (!_classroomTabsCollapsed)
              _CenteredTabs(controller: _tabs),
            if (_activeClassroomTabIndex == 0)
              _PinnedMessagesStrip(
                rows: _pinnedClassroomRows(_lastVisibleClassroomRows),
                onTapMessage: _jumpToClassroomMessage,
                titleForMessage: (item) {
                  final senderId =
                      [
                        _pick(item, 'senderUserId'),
                        _pick(item, 'senderId'),
                        _pick(item, 'userId'),
                        _pick(item, 'authorId'),
                        _pick(item, 'createdByUserId'),
                      ].firstWhere(
                        (e) => e.trim().isNotEmpty,
                        orElse: () => '',
                      );

                  final senderName = [
                    _pick(item, 'senderName').trim(),
                    _pick(item, 'authorName').trim(),
                    _pick(item, 'createdByName').trim(),
                    _shortSender(senderId).trim(),
                  ].firstWhere((e) => e.isNotEmpty, orElse: () => 'Message');

                  final raw =
                      (_editedTextByMessage[_pick(item, 'id')] ??
                              _pick(item, 'text'))
                          .trim();

                  final body = _editableBodyText(raw).trim();
                  final kind = _pick(item, 'kind').trim().toUpperCase();

                  final title = body.isNotEmpty
                      ? body
                      : (kind == 'IMAGE'
                        ? l.classroomDetailPhoto
                            : kind == 'VIDEO'
                        ? l.classroomDetailVideo
                            : kind == 'VOICE'
                        ? l.classroomDetailVoiceNote
                            : kind == 'FILE'
                        ? l.classroomDetailFile
                            : senderName);

                  return title;
                },
              ),
            const SizedBox(height: 2),
            Flexible(
              fit: FlexFit.loose,
              child: TabBarView(
                controller: _tabs,
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      _refreshAll();
                    },
                    child: _chatTab(chat, people),
                  ),
                  _listTab(
                    value: assignments,
                    emptyTitle: l.classroomDetailNoAssignmentsTitle,
                    emptySubtitle: l.classroomDetailNoAssignmentsSubtitle,
                    itemBuilder: (item) => _SimpleCard(
                      title: _pick(
                        item,
                        'title',
                        fallback: l.classroomDetailAssignmentFallback,
                      ),
                      subtitle: _pick(item, 'body'),
                      trailing: _friendlyDateTime(_pick(item, 'dueAt')),
                    ),
                  ),
                  _listTab(
                    value: materials,
                    emptyTitle: l.classroomDetailNoMaterialsTitle,
                    emptySubtitle: l.classroomDetailNoMaterialsSubtitle,
                    itemBuilder: (item) => _SimpleCard(
                      title: _pick(
                        item,
                        'title',
                        fallback: l.classroomDetailMaterialFallback,
                      ),
                      subtitle: _pick(item, 'description'),
                      trailing: _pick(item, 'mime'),
                    ),
                  ),
                  _listTab(
                    value: meetings,
                    emptyTitle: l.classroomDetailNoMeetingsTitle,
                    emptySubtitle: l.classroomDetailNoMeetingsSubtitle,
                    itemBuilder: (item) => _SimpleCard(
                      title: _pick(
                        item,
                        'title',
                        fallback: l.classroomDetailMeetingFallback,
                      ),
                      subtitle: _pick(item, 'agenda'),
                      trailing: _friendlyDateTime(_pick(item, 'startsAt')),
                    ),
                  ),
                  _peopleTab(people),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _peopleTab(AsyncValue<Map<String, dynamic>> people) {
    final l = AppLocalizations.of(context)!;
    return people.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _CenteredState(
        icon: Icons.group_outlined,
        title: l.classroomDetailCouldNotLoadPeople,
        subtitle: '$e',
      ),
      data: (m) {
        final items = (m['items'] is Map)
            ? Map<String, dynamic>.from(m['items'] as Map)
            : <String, dynamic>{};

        final raw = <Map<String, dynamic>>[];

        final teacher = items['teacher'];
        final teacherUserId = (items['teacherUserId'] ?? '').toString().trim();
        if (teacher is Map) {
          raw.add(<String, dynamic>{
            'id': teacherUserId,
            'name': (teacher['name'] ?? teacher['email'] ?? l.roleTeacher)
                .toString(),
            'email': (teacher['email'] ?? '').toString(),
          });
        }

        final students = (items['students'] is List)
            ? (items['students'] as List)
            : const <dynamic>[];

        for (final student in students) {
          if (student is Map) {
            raw.add(Map<String, dynamic>.from(student));
          }
        }

        if (raw.isEmpty) {
          return _CenteredState(
            icon: Icons.group_outlined,
            title: l.classroomDetailNoPeopleTitle,
            subtitle: l.classroomDetailNoPeopleSubtitle,
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            12,
            8,
            12,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          itemCount: raw.length,
          separatorBuilder: (_, _) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final item = raw[index];
            final name = _pick(item, 'name', fallback: l.student);
            final email = _pick(item, 'email');
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: _panelDecoration(context),
              child: Row(
                children: [
                  _InitialsAvatar(name: name),
                  const SizedBox(width: 2),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        if (email.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _listTab({
    required AsyncValue<Map<String, dynamic>> value,
    required String emptyTitle,
    required String emptySubtitle,
    required Widget Function(dynamic item) itemBuilder,
  }) {
    final l = AppLocalizations.of(context)!;
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _CenteredState(
        icon: Icons.cloud_off_rounded,
        title: l.classroomDetailCouldNotLoadTab,
        subtitle: '$e',
      ),
      data: (m) {
        final raw = (m['items'] is List) ? (m['items'] as List) : const [];
        if (raw.isEmpty) {
          return _CenteredState(
            icon: Icons.inbox_outlined,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            12,
            8,
            12,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          itemCount: raw.length,
          separatorBuilder: (_, _) => const SizedBox(height: 2),
          itemBuilder: (context, index) => itemBuilder(raw[index]),
        );
      },
    );
  }

  String _normalizePickedMime(String path) {
    final lower = path.trim().toLowerCase();
    final guessed = (lookupMimeType(path) ?? '').trim();
    if (guessed.isNotEmpty) {
      if (lower.endsWith('.heic') || lower.endsWith('.heif')) {
        return 'image/heic';
      }
      return guessed;
    }
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.m4v')) return 'video/x-m4v';
    if (lower.endsWith('.webm')) return 'video/webm';
    if (lower.endsWith('.m4a')) return 'audio/mp4';
    if (lower.endsWith('.aac')) return 'audio/aac';
    if (lower.endsWith('.mp3')) return 'audio/mpeg';
    if (lower.endsWith('.wav')) return 'audio/wav';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return '';
  }

  Future<void> _pickClassroomFiles() async {
    if (_sending || _recording) return;

    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'gif',
        'heic',
        'heif',
        'mp4',
        'mov',
        'm4v',
        'webm',
        'm4a',
        'aac',
        'mp3',
        'wav',
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
        'zip',
      ],
    );

    final paths = (picked?.files ?? const [])
        .map((e) => e.path ?? '')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.trim())
        .toList();
    if (paths.isEmpty) return;

    await _sendClassroomPickedMedia(paths);
  }

  Future<void> _pickClassroomCameraOrUploadImage() async {
    if (_sending || _recording) return;

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

    List<String> initialPaths = const [];

    if (action == 'photo') {
      final shot = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (shot == null || !mounted || shot.path.trim().isEmpty) return;
      initialPaths = [shot.path.trim()];
    } else if (action == 'video') {
      final shot = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: const Duration(minutes: 2),
      );
      if (shot == null || !mounted || shot.path.trim().isEmpty) return;
      initialPaths = [shot.path.trim()];
    } else if (action == 'gallery') {
      final picked = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media,
      );
      if (picked == null || !mounted) return;
      initialPaths = picked.files
          .map((e) => e.path ?? '')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => e.trim())
          .toList();
      if (initialPaths.isEmpty) return;
    } else {
      return;
    }

    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) => ChatMediaPreviewScreen(
          initialPaths: initialPaths,
          title: 'Preview',
        ),
      ),
    );
    if (!mounted || result == null) return;

    final paths = result.paths.isNotEmpty ? result.paths : initialPaths;
    if (paths.isEmpty) return;

    await _sendClassroomPickedMedia(
      paths.where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList(),
      caption: result.caption.trim(),
    );
  }

  Future<void> _pickClassroomPhoto() async {
    if (_sending || _recording) return;
    final shot = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (shot == null || !mounted || shot.path.trim().isEmpty) return;
    await _previewClassroomPickedMedia([shot.path.trim()]);
  }

  Future<void> _recordClassroomVideo() async {
    if (_sending || _recording) return;
    final shot = await _imagePicker.pickVideo(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxDuration: const Duration(minutes: 2),
    );
    if (shot == null || !mounted || shot.path.trim().isEmpty) return;
    await _previewClassroomPickedMedia([shot.path.trim()]);
  }

  Future<void> _pickClassroomGalleryMedia() async {
    if (_sending || _recording) return;
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );
    if (picked == null || !mounted) return;
    final paths = picked.files
        .map((e) => e.path ?? '')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.trim())
        .toList();
    if (paths.isEmpty) return;
    await _previewClassroomPickedMedia(paths);
  }

  Future<void> _previewClassroomPickedMedia(List<String> initialPaths) async {
    final result = await Navigator.of(context).push<ChatMediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) => ChatMediaPreviewScreen(
          initialPaths: initialPaths,
          title: 'Preview',
        ),
      ),
    );
    if (!mounted || result == null) return;

    final paths = result.paths.isNotEmpty ? result.paths : initialPaths;
    if (paths.isEmpty) return;

    await _sendClassroomPickedMedia(
      paths.where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList(),
      caption: result.caption.trim(),
    );
  }

  Future<void> _sendClassroomPickedMedia(
    List<String> paths, {
    String caption = '',
  }) async {
    final clean = paths
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.trim())
        .toList();
    if (clean.isEmpty) return;

    final repo = ref.read(classroomsRepoProvider);

    HapticFeedback.lightImpact();
    if (mounted) {
      setState(() {
        _sending = true;
        _draftAttachments.clear();
        _draftVoicePath = null;
        _draftVoicePlaying = false;
        _draftVoiceReady = false;
        _draftVoicePosition = Duration.zero;
        _draftVoiceDuration = Duration.zero;
      });
    }

    try {
      for (var i = 0; i < clean.length; i++) {
        final path = clean[i];
        final mime = _normalizePickedMime(path);
        final lowerPath = path.trim().toLowerCase();
        final inlineMedia =
            mime.startsWith('image/') ||
            mime.startsWith('video/') ||
            mime.startsWith('audio/') ||
            lowerPath.endsWith('.jpg') ||
            lowerPath.endsWith('.jpeg') ||
            lowerPath.endsWith('.png') ||
            lowerPath.endsWith('.webp') ||
            lowerPath.endsWith('.gif') ||
            lowerPath.endsWith('.heic') ||
            lowerPath.endsWith('.heif') ||
            lowerPath.endsWith('.mp4') ||
            lowerPath.endsWith('.mov') ||
            lowerPath.endsWith('.m4v') ||
            lowerPath.endsWith('.webm') ||
            lowerPath.endsWith('.m4a') ||
            lowerPath.endsWith('.aac') ||
            lowerPath.endsWith('.mp3') ||
            lowerPath.endsWith('.wav');

        await repo.sendChatMedia(
          widget.courseId,
          path,
          mimeType: mime.isEmpty ? null : mime,
          fileName: inlineMedia ? null : path.split('/').last,
          text: i == 0 && caption.trim().isNotEmpty ? caption.trim() : null,
        );
      }

      _clearReply();
      ref.invalidate(
        classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
      );
      _pinClassroomToBottom(jump: true);
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _draftAttachments.clear();
          _draftVoicePath = null;
          _draftVoicePlaying = false;
          _draftVoiceReady = false;
          _draftVoicePosition = Duration.zero;
          _draftVoiceDuration = Duration.zero;
          _voicePaused = false;
          _recordElapsed = Duration.zero;
        });
      }
    }
  }

  Future<void> _startVoiceNote() async => _toggleClassroomMic();
  Future<void> _stopVoiceNoteAndSend() async =>
      _toggleClassroomMic(sendNow: true);

  Future<void> _stopVoiceNoteAndSendNow() async {
    if (!_recording) return;

    final path = await _recorder.stop();
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
    });

    final resolved = (path ?? '').trim();
    if (resolved.isEmpty) return;

    final repo = ref.read(classroomsRepoProvider);
    await repo.sendChatMedia(
      widget.courseId,
      resolved,
      mimeType: lookupMimeType(resolved) ?? 'audio/mp4',
    );

    try {
      final f = File(resolved);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _draftVoicePlaying = false;
      _draftVoiceReady = false;
      _draftVoicePosition = Duration.zero;
      _draftVoiceDuration = Duration.zero;
      _draftVoicePath = null;
      _voicePaused = false;
      _recordElapsed = Duration.zero;
    });
  }

  Future<void> _sendRecordedClassroomVoice(String path) async {
    final resolved = path.trim();
    if (resolved.isEmpty) return;

    final repo = ref.read(classroomsRepoProvider);
    await repo.sendChatMedia(
      widget.courseId,
      resolved,
      mimeType: lookupMimeType(resolved) ?? 'audio/mp4',
    );

    try {
      final f = File(resolved);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}

    ref.invalidate(
      classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
    );
    _pinClassroomToBottom(jump: true);

    if (!mounted) return;
    setState(() {
      _draftAttachments.clear();
      _draftVoicePlaying = false;
      _draftVoiceReady = false;
      _draftVoicePosition = Duration.zero;
      _draftVoiceDuration = Duration.zero;
      _draftVoicePath = null;
      _voicePaused = false;
      _recordElapsed = Duration.zero;
      _holdDx = 0;
      _holdDy = 0;
      _voiceLocked = false;
      _voiceCancelled = false;
    });
  }

  Future<void> _micHoldStart(LongPressStartDetails d) async {
    if (_sending || _recording) return;
    _holdStartGlobal = d.globalPosition;
    _holdDx = 0;
    _holdDy = 0;
    _voiceLocked = false;
    _voicePaused = false;
    _voiceCancelled = false;
    await _toggleClassroomMic();
  }

  void _updateActiveHold(Offset globalPosition) {
    if (!_recording || _holdStartGlobal == null) return;

    final dx = globalPosition.dx - _holdStartGlobal!.dx;
    final dy = globalPosition.dy - _holdStartGlobal!.dy;

    final willCancel = dx <= -chatRecordingCancelThreshold;
    final willLock = dy <= -chatRecordingLockThreshold;

    setState(() {
      _holdDx = dx;
      _holdDy = dy;
      _voiceCancelled = willCancel;
      _voiceLocked = willLock;
      if (!willLock) {
        _voicePaused = false;
      }
    });
  }

  void _micHoldMove(LongPressMoveUpdateDetails d) {
    _updateActiveHold(d.globalPosition);
  }

  Future<void> _finishActiveHold() async {
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

    await _toggleClassroomMic(sendNow: true);
  }

  Future<void> _micHoldEnd(LongPressEndDetails d) async {
    await _finishActiveHold();
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

    final path = (_draftVoicePath ?? '').trim();
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
      _draftVoicePath = null;
      _draftVoicePlaying = false;
      _draftVoiceReady = false;
      _draftVoicePosition = Duration.zero;
      _draftVoiceDuration = Duration.zero;
      _recordElapsed = Duration.zero;
    });
  }

  Future<void> _toggleClassroomMic({bool sendNow = false}) async {
    if (_sending) {
      return;
    }

    if (_recording) {
      final stoppedPath = await _recorder.stop();

      _stopRecordTicker();
      final path = (stoppedPath ?? '').trim();

      if (!mounted) return;
      setState(() {
        _recording = false;
        _voiceLocked = false;
        _voicePaused = false;
        _voiceCancelled = false;
        _holdDx = 0;
        _holdDy = 0;
        _holdStartGlobal = null;
        _draftVoicePath = null;
        _draftVoicePlaying = false;
        _draftVoiceReady = false;
        _draftVoicePosition = Duration.zero;
        _draftVoiceDuration = Duration.zero;
        _recordElapsed = Duration.zero;
      });

      if (path.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No audio captured.')));
        return;
      }

      await _sendRecordedClassroomVoice(path);
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: Text(
            AppLocalizations.of(dialogCtx)!
                .classroomDetailMicrophoneAccessTitle,
          ),
          content: Text(
            AppLocalizations.of(dialogCtx)!
                .classroomDetailMicrophoneAccessBody,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(AppLocalizations.of(dialogCtx)!.classroomsForwardCancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await launchUrl(Uri.parse('app-settings:'));
              },
              child: Text(
                AppLocalizations.of(dialogCtx)!
                    .classroomDetailOpenSettingsAction,
              ),
            ),
          ],
        ),
      );
      return;
    }

    final dir = Directory.systemTemp;
    final filePath =
        '${dir.path}/classroom-voice-${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      return;
    }

    _startRecordTicker();
    if (!mounted) return;
    final keepLocked = _voiceLocked;
    setState(() {
      _recording = true;
      _voiceLocked = keepLocked;
      _voicePaused = false;
      _voiceCancelled = false;
      _holdDx = 0;
      _holdDy = 0;
      _recordElapsed = Duration.zero;
      _voiceLocked = sendNow;
      _draftVoicePath = null;
      _draftVoicePlaying = false;
      _draftVoiceReady = false;
      _draftVoicePosition = Duration.zero;
      _draftVoiceDuration = Duration.zero;
    });
  }

  Future<void> _sendClassroomChat() async {
    final repo = ref.read(classroomsRepoProvider);
    final text = _chatCtl.text.trim();

    if (_editingMessageId != null) {
      final original = (_editingOriginalText ?? '').trim();
      if (text == original) {
        if (!mounted) return;
        setState(() {
          _deleteSelection.clear();
          _clearClassroomEdit();
          _chatCtl.clear();
        });
        return;
      }

      if (text.isEmpty) return;

      HapticFeedback.lightImpact();
      setState(() => _sending = true);
      try {
        await repo.editChatMessage(
          widget.courseId,
          messageId: _editingMessageId!,
          text: text,
        );

        _chatCtl.clear();
        _clearClassroomEdit();

        ref.invalidate(
          classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
        );
        _pinClassroomToBottom(jump: true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message editing is temporarily unavailable.'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _sending = false);
        }
      }
      return;
    }

    final composedText = _replyToMessageId != null
        ? composeReplyText(
            sender: (_replyToSender ?? '').trim(),
            preview: (_replyToText ?? '').trim(),
            body: text,
          )
        : text;

    if (text.isEmpty &&
        _draftAttachments.isEmpty &&
        (_draftVoicePath ?? '').trim().isEmpty) {
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _sending = true);
    try {
      var sentAnyMedia = false;

      for (final a in List<Map<String, String>>.from(_draftAttachments)) {
        final p = (a['path'] ?? '').trim();
        if (p.isEmpty) continue;
        await repo.sendChatMedia(widget.courseId, p);
        sentAnyMedia = true;
      }

      if (mounted) {
        setState(() {
          _draftAttachments.clear();
          _draftVoicePlaying = false;
          _draftVoiceReady = false;
          _draftVoicePosition = Duration.zero;
          _draftVoiceDuration = Duration.zero;
          _voicePaused = false;
          _recordElapsed = Duration.zero;
        });
      }

      if (_draftAttachments.isNotEmpty && mounted) {
        setState(() {
          _draftAttachments.clear();
        });
      }

      final voicePath = (_draftVoicePath ?? '').trim();
      if (voicePath.isNotEmpty) {
        await _draftVoicePlayer.stop();
        await repo.sendChatMedia(
          widget.courseId,
          voicePath,
          mimeType: lookupMimeType(voicePath) ?? 'audio/mp4',
        );
        sentAnyMedia = true;
        if (mounted) {
          setState(() {
            _draftAttachments.clear();
            _draftVoicePlaying = false;
            _draftVoiceReady = false;
            _draftVoicePosition = Duration.zero;
            _draftVoiceDuration = Duration.zero;
            _draftVoicePath = null;
            _voicePaused = false;
            _recordElapsed = Duration.zero;
          });
        }
        if (mounted) {
          setState(() {
            _draftVoicePlaying = false;
            _draftVoiceReady = false;
            _draftVoicePosition = Duration.zero;
            _draftVoiceDuration = Duration.zero;
            _draftVoicePath = null;
            _voicePaused = false;
            _recordElapsed = Duration.zero;
          });
        }
      }

      if (text.isNotEmpty) {
        _recentOwnMessageTexts.add(composedText.trim());
        await repo.sendChatText(widget.courseId, composedText);
        _chatCtl.clear();
        // Optimistic: show message immediately before the server re-fetch lands.
        if (mounted) {
          setState(() {
            _optimisticMessages.add(<String, dynamic>{
              'id': 'optimistic-${DateTime.now().millisecondsSinceEpoch}',
              'text': composedText.trim(),
              'body': composedText.trim(),
              'senderName': 'You',
              'isMine': true,
              'kind': 'TEXT',
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            });
          });
        }
      }

      if (text.isNotEmpty || sentAnyMedia) {
        _clearReply();
        _clearClassroomEdit();
      }

      if (mounted) {
        setState(() {
          _holdDx = 0;
          _holdDy = 0;
          _voiceLocked = false;
          _voiceCancelled = false;
        });
      }

      ref.invalidate(
        classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
      );
      _pinClassroomToBottom(jump: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not send message. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Widget _classroomComposerButton({
    required IconData icon,
    required VoidCallback? onTap,
    Color fill = const Color(0xFF1C232B),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
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
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Future<void> _toggleClassroomDraftVoicePlayback() async {
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

  Future<void> _cycleClassroomDraftVoiceSpeed() async {
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

  Future<void> _seekClassroomDraftVoiceToRatio(double ratio) async {
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

  Widget _classroomVoiceDraftChip() {
    final totalMs = _draftVoiceDuration.inMilliseconds <= 0
        ? 1
        : _draftVoiceDuration.inMilliseconds;
    final posMs = _draftVoicePosition.inMilliseconds.clamp(0, totalMs);
    final progress = (posMs / totalMs).clamp(0.0, 1.0);

    Widget seekBar() {
      return LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth <= 0 ? 1.0 : (c.maxWidth * 0.84);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) async {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final local = box.globalToLocal(d.globalPosition);
              final ratio = (local.dx / width).clamp(0.0, 1.0);
              await _seekClassroomDraftVoiceToRatio(ratio);
            },
            onTapDown: (d) async {
              final ratio = (d.localPosition.dx / width).clamp(0.0, 1.0);
              await _seekClassroomDraftVoiceToRatio(ratio);
            },
            child: Container(
              height: 14,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (width - 10) * progress,
                    top: -3,
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
        },
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF171D24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggleClassroomDraftVoicePlayback,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2630),
                borderRadius: BorderRadius.circular(10),
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
          const SizedBox(width: 6),
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
                      onTap: _cycleClassroomDraftVoiceSpeed,
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

  Widget _classroomComposerTopContent() {
    final hasDrafts =
        _draftAttachments.isNotEmpty ||
        (_draftVoicePath ?? '').trim().isNotEmpty;

    if (!hasDrafts) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 72,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._draftAttachments.map(_classroomDraftChip),
              if ((_draftVoicePath ?? '').trim().isNotEmpty)
                _classroomVoiceDraftChip(),
            ],
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }

  Widget _classroomDraftChip(Map<String, String> a) {
    final kind = (a['kind'] ?? '').trim().toUpperCase();
    final icon = switch (kind) {
      'VIDEO' => Icons.videocam_rounded,
      'IMAGE' => Icons.photo_rounded,
      _ => Icons.insert_drive_file_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF161C23),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => setState(() => _draftAttachments.remove(a)),
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

  Widget _classroomTypingIndicator() {
    // Show animated dots briefly after the user sends a message,
    // giving live feedback while waiting for peers to respond.
    if (!_sending) return const SizedBox.shrink();
    return const TypingIndicatorRow(label: 'Sending...');
  }

  Widget _classroomComposer() {
    final l = AppLocalizations.of(context)!;
    if (_deleteSelection.isNotEmpty) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final ids = _deleteSelection.toList(growable: false);
                  if (ids.isEmpty) return;

                  final choice = await showModalBottomSheet<String>(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete_outline_rounded),
                            title: const Text('Delete for me'),
                            onTap: () => Navigator.of(context).pop('me'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete_forever_rounded),
                            title: const Text('Delete for everyone'),
                            subtitle: const Text('Removes for all participants'),
                            onTap: () => Navigator.of(context).pop('everyone'),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (!mounted || choice == null || choice.trim().isEmpty) {
                    return;
                  }

                  if (choice == 'everyone') {
                    setState(() {
                      _deletedForEveryoneMessageIds.addAll(ids);
                      for (final id in ids) {
                        _reactionByMessage.remove(id);
                        _editedTextByMessage.remove(id);
                        _deletedMessageIds.remove(id);
                      }
                      _deleteSelection.clear();
                      _clearClassroomEdit();
                    });
                    await _persistLocalChatState();
                    return;
                  }

                  for (final id in ids) {
                    await _deleteMessage(id);
                  }

                  if (!mounted) return;
                  setState(() {
                    _deleteSelection.clear();
                    _clearClassroomEdit();
                  });
                },
                icon: const Icon(Icons.delete_rounded),
                label: Text(
                  l.classroomDetailDeleteCount(_deleteSelection.length),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l.classroomDetailSelectedCount(_deleteSelection.length),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              IconButton(
                tooltip: l.classroomDetailSelectAllTooltip,
                onPressed: () {
                  setState(() {
                    _deleteSelection.addAll(
                      _lastVisibleClassroomRows
                          .map((row) => _pick(row, 'id'))
                          .where((id) => id.isNotEmpty),
                    );
                  });
                },
                icon: const Icon(Icons.select_all_rounded),
              ),
              IconButton(
                tooltip: l.classroomDetailCancelTooltip,
                onPressed: () => setState(() {
                  _deleteSelection.clear();
                  _clearClassroomEdit();
                }),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      );
    }

    if (_isForwardSelectionMode) {
      return SafeArea(
        top: false,
        child: ChatComposer(
          controller: _chatCtl,
          topContent: const SizedBox.shrink(),
          enabled: false,
          isStreaming: false,
          isRecording: false,
          isVoiceLocked: false,
          isVoicePaused: false,
          recordingElapsed: Duration.zero,
          hintText: 'Message',
          onSend: () {},
          onCamera: () {},
          onAttach: () {},
          onMic: () {},
          onMicHoldStart: (_) {},
          onMicHoldMove: (_) {},
          onMicHoldEnd: (_) {},
          onMicHoldCancel: () {},
          onActiveHoldMove: (_) {},
          onActiveHoldRelease: () {},
          onActiveHoldCancel: () {},
          activeHoldDx: 0,
          activeHoldDy: 0,
          onTrashRecording: () {},
          onPauseRecording: () {},
          onResumeRecording: () {},
          showCamera: true,
          showAttach: true,
          showMic: true,
          forceMicOnlyTap: false,
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: NativeGlassView(
        borderRadius: 28,
        style: NativeGlassStyle.ultraThin,
        fallbackColor: isDark
            ? Colors.black.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.36),
        child: SafeArea(
      top: false,
      child: ChatComposer(
        controller: _chatCtl,
        replyingTo: _replyToMessageId == null
            ? null
            : (
                senderName: (_replyToSender ?? '').trim().isEmpty
                    ? 'Reply'
                    : (_replyToSender ?? '').trim(),
                text: (_replyToText ?? '').trim().isEmpty
                    ? 'Message'
                    : (_replyToText ?? '').trim(),
              ),
        onCancelReply: () {
          setState(() {
            _replyToMessageId = null;
            _replyToSender = null;
            _replyToText = null;
          });
        },
        onTapReplyPreview: _replyToMessageId == null
            ? null
            : () => _jumpToClassroomMessage(_replyToMessageId!),
        topContent: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _classroomTypingIndicator(),
            _classroomComposerTopContent(),
          ],
        ),
        enabled: !_sending,
        isStreaming: false,
        isRecording: _recording,
        isVoiceLocked: _voiceLocked,
        isVoicePaused: _voicePaused,
        recordingElapsed: _recordElapsed,
        hintText: 'Message',
        onSend: _sending || _recording ? () {} : _sendClassroomChat,
        onCamera: _sending || _recording ? () {} : _pickClassroomPhoto,
        onAttach: _sending || _recording ? () {} : _pickClassroomFiles,
        onVideo: _sending || _recording ? () {} : _recordClassroomVideo,
        onGallery: _sending || _recording ? () {} : _pickClassroomGalleryMedia,
        onMic: () async {
          if (_sending) return;
          if (_recording) {
            await _stopVoiceNoteAndSend();
            return;
          }
          await _startVoiceNote();
          if (!mounted) return;
          setState(() {
            _voiceLocked = true;
            _voicePaused = false;
            _voiceCancelled = false;
            _holdStartGlobal = null;
            _holdDx = 0;
            _holdDy = 0;
          });
        },
        onMicHoldStart: _micHoldStart,
        onMicHoldMove: _micHoldMove,
        onMicHoldEnd: _micHoldEnd,
        onMicHoldCancel: _micHoldCancel,
        onActiveHoldMove: _updateActiveHold,
        onActiveHoldRelease: _finishActiveHold,
        onActiveHoldCancel: _micHoldCancel,
        activeHoldDx: _holdDx,
        activeHoldDy: _holdDy,
        onTrashRecording: _cancelVoiceDraft,
        onPauseRecording: _pauseVoiceRecord,
        onResumeRecording: _resumeVoiceRecord,
        showCamera: true,
        showAttach: true,
        showMic: true,
        forceMicOnlyTap: false,
          ),    // ChatComposer
        ),      // SafeArea
      ),        // NativeGlassView
  );            // Padding
  }

  Future<void> _showClassroomWaActionsAt(
    Map<String, dynamic> item,
    Offset globalPosition,
  ) async {
    final _ = globalPosition;
    final messageId = _pick(item, 'id');
    final text =
        (_pick(item, 'text').trim().isNotEmpty
                ? _pick(item, 'text').trim()
                : (_pick(item, 'content').trim().isNotEmpty
                      ? _pick(item, 'content').trim()
                      : (_pick(item, 'message').trim().isNotEmpty
                            ? _pick(item, 'message').trim()
                            : '')))
            .trim();
    final mediaUrl = _pick(item, 'mediaUrl').trim();
    final kind = _pick(item, 'kind').trim();
    final senderLabel =
        (_pick(item, 'senderName').trim().isNotEmpty
                ? _pick(item, 'senderName').trim()
                : (_pick(item, 'sender').trim().isNotEmpty
                      ? _pick(item, 'sender').trim()
                      : 'Unknown'))
            .trim();
    final isMine = (_pick(item, 'isMine').trim().toLowerCase() == 'true');
    final timeLabel = _pick(item, 'timeLabel').trim();
    final deletedForEveryone =

        (_pick(item, 'deletedForEveryone').trim().toLowerCase() == 'true');
    final isForwarded =
        _isTruthyForwardedValue(_pick(item, 'forwarded')) ||
        _isClassroomForwardedText(text);


    if (deletedForEveryone) {

      final action = await ChatContextOverlay.show(
        context,
        isMine: isMine,
        canReply: false,
        canDelete: true,
        canCopy: false,
        canForward: false,
        canPin: false,
        canViewInfo: false,
        canEdit: false,
        messageBubble: ChatMessageBubble(
          contextForNavigation: context,
          rawText: text,
          mediaUrl: mediaUrl,
          isMine: isMine,
          showName: false,
          senderLabel: senderLabel,
          timeLabel: timeLabel,
          edited: false,
          reaction: null,
          forwarded: false,
          delivered: false,
          seen: false,
          deleteState: 'DELETED_FOR_EVERYONE',
          voiceDurationSeconds: null,
          voiceUnread: false,
          onVoicePlayed: null,
          replySender: null,
          replySnippet: null,
          mediaMimeType: null,
          messageKind: kind,
          maxWidth: 260,
        ),
      );


      if (action != 'delete') return;


      await _deleteMessage(messageId);

      if (!mounted) return;

      setState(() {

        _deleteSelection.remove(messageId);

        _clearClassroomEdit();

        _replyToMessageId = null;

        _replyToSender = null;

        _replyToText = null;

      });

      return;

    }


    final canEdit =

        isMine &&

        _classroomCanEditMessage(

          messageId: messageId,

          text: text,

          mediaUrl: mediaUrl,

          kind: kind,

        );


    final action = await ChatContextOverlay.show(
      context,
      isMine: isMine,
      canReply: !deletedForEveryone,
      canEdit: canEdit,
      canDelete: isMine,
      canViewInfo: isMine,
      canPin: true,
        pinLabel: _pinnedMessageIds.contains(messageId)
          ? AppLocalizations.of(context)!.classroomDetailUnpinAction
          : AppLocalizations.of(context)!.classroomDetailPinAction,
      canForward: !deletedForEveryone,
      canCopy: false,
      pickerAllowedEmojis: deletedForEveryone ? null : classroomAllowedEmojis,
      messageBubble: ChatMessageBubble(
        contextForNavigation: context,
        rawText: text,
        mediaUrl: mediaUrl,
        isMine: isMine,
        showName: false,
        senderLabel: senderLabel,
        timeLabel: timeLabel,
        edited: _pick(item, 'edited').trim().toLowerCase() == 'true',
        reaction: _reactionByMessage[messageId],
        forwarded: isForwarded,
        delivered: false,
        seen: false,
        deleteState: 'VISIBLE',
        voiceDurationSeconds:
            int.tryParse(_pick(item, 'durationSec').trim()),
        voiceUnread: false,
        onVoicePlayed: null,
        replySender: null,
        replySnippet: null,
        mediaMimeType: null,
        messageKind: kind,
        maxWidth: 260,
      ),
    );


    if (action == null || action.trim().isEmpty) return;


    if (action.startsWith('react:') && !deletedForEveryone) {
      final emoji = action.substring('react:'.length).trim();
      if (emoji.isNotEmpty) {
        await _setReaction(messageId, emoji);
      }
      return;
    }

    if (action == 'info' && !deletedForEveryone) {
      setState(() {
        _deleteSelection.clear();
        _clearClassroomEdit();
      });
      final durationSec = int.tryParse(_pick(item, 'durationSec').trim()) ?? 0;
      await _showClassroomMessageInfo(
        sentAt: timeLabel,
        isMine: isMine,
        edited: _pick(item, 'edited').trim().toLowerCase() == 'true',
        forwarded: isForwarded,
        deleteState: 'VISIBLE',
        kind: kind,
        previewTitle: _classroomSenderLabel(isMine, senderLabel),
        previewBody: _classroomPreviewBody(text, kind),
        previewMeta: timeLabel,
        previewMediaUrl: mediaUrl,
        previewBubbleBuilder: (infoContext) => ChatMessageBubble(
          contextForNavigation: context,
          rawText: text,
          mediaUrl: mediaUrl,
          isMine: isMine,
          showName: false,
          senderLabel: senderLabel,
          timeLabel: timeLabel,
          edited: _pick(item, 'edited').trim().toLowerCase() == 'true',
          reaction: _reactionByMessage[messageId],
          forwarded: isForwarded,
          delivered: false,
          seen: false,
          deleteState: 'VISIBLE',
          voiceDurationSeconds: durationSec > 0 ? durationSec : null,
          voiceUnread: false,
          onVoicePlayed: null,
          replySender: _splitReplyRaw(text).replyPrefix.trim(),
          replySnippet: _replyPreviewText(text),
          mediaMimeType: null,
          messageKind: kind,
          maxWidth: 280,
        ),
        voiceDurationSeconds: durationSec > 0 ? durationSec : null,
      );
      return;
    }

    if (action == 'reply' && !deletedForEveryone) {
      setState(() {
        _deleteSelection.clear();
        _clearClassroomEdit();
      });
      _replyTo(
        messageId: messageId,
        sender: senderLabel,
        text: _editableBodyText(text),
      );
      return;
    }

    if (action == 'forward' && !deletedForEveryone) {
      setState(() {
        _deleteSelection.clear();
        _clearClassroomEdit();
      });
      _enterForwardSelectionMode(messageId);
      return;
    }

    if (action == 'pin' && !deletedForEveryone) {
      setState(() {
        _deleteSelection.clear();
        _clearClassroomEdit();
      });
      await _togglePinMessage(messageId);
      return;
    }

    if (action == 'edit' && !deletedForEveryone) {
      final original = _editableBodyText(text);
      setState(() {
        _deleteSelection.clear();
        _editingMessageId = messageId;
        _editingOriginalText = original;
        _replyToMessageId = null;
        _replyToSender = null;
        _replyToText = null;
        _chatCtl.value = TextEditingValue(
          text: original,
          selection: TextSelection.collapsed(offset: original.length),
        );
      });
      _pinClassroomToBottom(jump: true);
      return;
    }

    if (action == 'delete') {
      setState(() {
        _clearClassroomEdit();
        _replyToMessageId = null;
        _replyToSender = null;
        _replyToText = null;
        if (_deleteSelection.contains(messageId)) {
          _deleteSelection.remove(messageId);
        } else {
          _deleteSelection.add(messageId);
        }
      });
      _pinClassroomToBottom(jump: true);
      return;
    }
  }

  List<Map<String, dynamic>> _pinnedClassroomRows(
    List<Map<String, dynamic>> rows,
  ) {
    return rows
        .where(
          (row) =>
              _pick(row, 'id').trim().isNotEmpty &&
              (_pick(row, 'isPinned').trim().toLowerCase() == 'true' ||
                  _pick(row, 'isPinned').trim() == '1' ||
                  _pinnedMessageIds.contains(_pick(row, 'id'))),
        )
        .toList();
  }

  Widget _waTopAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  bool _sameClassroomDay(String a, String b) {
    final da = DateTime.tryParse(a)?.toLocal();
    final db = DateTime.tryParse(b)?.toLocal();
    if (da == null || db == null) return false;
    return da.year == db.year && da.month == db.month && da.day == db.day;
  }

  String _classroomDayLabel(String raw) {
    final d = DateTime.tryParse(raw)?.toLocal();
    if (d == null) return 'Earlier';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  Widget _classroomDayChip(String raw) {
    final label = _classroomDayLabel(raw);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.20),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatTabWithInsets(
    AsyncValue<Map<String, dynamic>> value,
    AsyncValue<Map<String, dynamic>> people,
  ) {
    final mq = MediaQuery.of(context);
    final keyboardLift = mq.viewInsets.bottom > 0
        ? mq.viewInsets.bottom + 12
        : 0.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardLift),
      child: _chatTab(value, people),
    );
  }

  Widget _chatTab(
    AsyncValue<Map<String, dynamic>> value,
    AsyncValue<Map<String, dynamic>> people,
  ) {
    return Column(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: value.when(
            skipLoadingOnRefresh: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => _CenteredState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Could not load chat',
              subtitle: '$e',
            ),
            data: (m) {
              // Clear optimistic messages now that fresh data has arrived.
              if (_optimisticMessages.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _optimisticMessages.isNotEmpty) {
                    setState(() => _optimisticMessages.clear());
                  }
                });
              }
              final serverItems = (m['items'] is List)
                  ? (m['items'] as List)
                  : const [];
              // Merge server items + any optimistic messages not yet in server list
              final serverTexts = serverItems
                  .map((i) => (_pick(i as dynamic, 'text') as String).trim())
                  .toSet();
              final pendingNew = _optimisticMessages
                  .where((o) => !serverTexts.contains((o['text'] as String).trim()))
                  .toList();
              final rawItems = [...serverItems, ...pendingNew];

              final filtered =
                  rawItems
                      .where(
                        (item) =>
                            !_deletedMessageIds.contains(_pick(item, 'id')),
                      )
                      .toList()
                    ..sort((a, b) {
                      DateTime read(dynamic item) {
                        final candidates = <String>[
                          _pick(item, 'createdAt'),
                          _pick(item, 'sentAt'),
                          _pick(item, 'updatedAt'),
                        ];
                        for (final raw in candidates) {
                          final dt = DateTime.tryParse(raw);
                          if (dt != null) return dt.toLocal();
                        }
                        return DateTime.fromMillisecondsSinceEpoch(0);
                      }

                      final da = read(a);
                      final db = read(b);
                      return da.compareTo(db);
                    });

              final peopleMap = people.maybeWhen(
                data: (pm) {
                  final items = (pm['items'] is Map)
                      ? Map<String, dynamic>.from(pm['items'] as Map)
                      : <String, dynamic>{};

                  final out = <String, String>{};

                  final teacher = items['teacher'];
                  final teacherUserId = (items['teacherUserId'] ?? '')
                      .toString()
                      .trim();
                  if (teacher is Map && teacherUserId.isNotEmpty) {
                    out[teacherUserId] =
                        (teacher['name'] ?? teacher['email'] ?? 'Teacher')
                            .toString()
                            .trim();
                  }

                  final students = (items['students'] is List)
                      ? (items['students'] as List)
                      : const <dynamic>[];

                  for (final student in students) {
                    if (student is Map) {
                      final id = (student['id'] ?? '').toString().trim();
                      final name =
                          (student['name'] ?? student['email'] ?? 'Student')
                              .toString()
                              .trim();
                      if (id.isNotEmpty) {
                        out[id] = name;
                      }
                    }
                  }

                  return out;
                },
                orElse: () => const <String, String>{},
              );

              final myUserId = _resolveMyUserId(peopleMap);

              if (_lastChatCount != filtered.length) {
                if (_lastChatCount < 0) {
                  _lastChatCount = filtered.length;
                  _knownLastClassroomMessageId = filtered.isEmpty
                      ? null
                      : _pick(filtered.last, 'id');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom(jump: filtered.length <= 3);
                    _pinClassroomToBottom(jump: true);
                  });
                } else {
                  _onClassroomRowsRendered(
                    filtered.cast<Map<String, dynamic>>(),
                  );
                }
              }

              if (filtered.isEmpty) {
                return const _CenteredState(
                  icon: Icons.forum_outlined,
                  title: 'No messages yet',
                  subtitle: 'Start the classroom conversation.',
                );
              }

              _lastVisibleClassroomRows
                ..clear()
                ..addAll(filtered.map((e) => Map<String, dynamic>.from(e)));
              _lastVisibleClassroomMessageIds
                ..clear()
                ..addAll(
                  filtered
                      .map((e) => _pick(e, 'id'))
                      .where((e) => e.trim().isNotEmpty),
                );

              return ValueListenableBuilder<bool>(
                valueListenable: _showClassroomScrollToBottom,
                builder: (context, showScroll, child) {
                  return Stack(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollUpdateNotification &&
                              notification.dragDetails != null) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                          _handleClassroomScroll();
                          return false;
                        },
                        child: ListView.builder(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          controller: _chatScrollCtl,
                          cacheExtent: 900,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: true,
                          padding: EdgeInsets.fromLTRB(
                            12,
                            8,
                            12,
                            24 + MediaQuery.of(context).viewInsets.bottom,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final previous = index > 0
                                ? filtered[index - 1]
                                : null;
                            final showDaySeparator =
                                previous == null ||
                                !_sameClassroomDay(
                                  _pick(previous, 'createdAt'),
                                  _pick(item, 'createdAt'),
                                );

                            final messageId = _pick(item, 'id');
                            final senderId =
                                [
                                  _pick(item, 'senderUserId'),
                                  _pick(item, 'senderId'),
                                  _pick(item, 'userId'),
                                  _pick(item, 'authorId'),
                                  _pick(item, 'createdByUserId'),
                                ].firstWhere(
                                  (e) => e.trim().isNotEmpty,
                                  orElse: () => '',
                                );
                            final senderName = [
                              (peopleMap[senderId] ?? '').trim(),
                              _pick(item, 'senderName').trim(),
                              _pick(item, 'authorName').trim(),
                              _pick(item, 'createdByName').trim(),
                              _shortSender(senderId).trim(),
                            ].firstWhere((e) => e.isNotEmpty, orElse: () => '');
                            final createdRaw = _pick(item, 'createdAt');
                            final durationSecRaw = _pick(item, 'durationSec');
                            final durationSec =
                                int.tryParse(durationSecRaw.trim()) ?? 0;
                            final createdAt = DateTime.tryParse(
                              createdRaw,
                            )?.toLocal();
                            final reaction = _reactionByMessage[messageId];

                            final originalText = _pick(
                              item,
                              'text',
                              fallback: '(empty)',
                            );
                            final text =
                                (_editedTextByMessage[messageId] ??
                                        originalText)
                                    .trim();
                            final kind = _pick(item, 'kind').toUpperCase();
                            final mediaUrl = _pick(item, 'mediaUrl');
                            final isForwarded =
                                _isClassroomMessageForwarded(
                                  item,
                                  text: text,
                                  originalText: originalText,
                                );
                            final deletedForEveryone =
                                _deletedForEveryoneMessageIds.contains(messageId);
                            if (deletedForEveryone) {
                            }

                            String replySender = '';
                            String replySnippet = '';
                            String messageText = text
                                .replaceFirst(
                                  RegExp(
                                    r'^\[IMAGE\]\s*',
                                    caseSensitive: false,
                                  ),
                                  '',
                                )
                                .replaceFirst(
                                  RegExp(r'^\[FILE\]\s*', caseSensitive: false),
                                  '',
                                )
                                .replaceFirst(
                                  RegExp(
                                    r'^\[VIDEO\]\s*',
                                    caseSensitive: false,
                                  ),
                                  '',
                                )
                                .replaceFirst(
                                  RegExp(
                                    r'^\[VOICE\]\s*',
                                    caseSensitive: false,
                                  ),
                                  '',
                                )
                                .replaceFirst(
                                  RegExp(r'^\[FILE\]\s*', caseSensitive: false),
                                  '',
                                )
                                .replaceFirst(
                                  RegExp(
                                    r'^\[VIDEO\]\s*',
                                    caseSensitive: false,
                                  ),
                                  '',
                                )
                                .trim();

                            if (text.startsWith('↪ ')) {
                              final afterArrow = text.substring(2).trim();
                              final colon = afterArrow.indexOf(':');
                              if (colon != -1) {
                                replySender = afterArrow
                                    .substring(0, colon)
                                    .trim();
                                final rest = afterArrow
                                    .substring(colon + 1)
                                    .trim();
                                final dash = rest.lastIndexOf(' — ');
                                if (dash != -1) {
                                  replySnippet = rest.substring(0, dash).trim();
                                  messageText = rest.substring(dash + 3).trim();
                                } else {
                                  messageText = rest;
                                }
                              }
                            }

                            final session = ref.read(authSessionProvider);
                            final sessionDisplay = session.displayName
                                .trim()
                                .toLowerCase();
                            final sessionToken = (session.token ?? '')
                                .trim()
                                .toLowerCase();
                            final sessionTokenLocal = sessionToken.contains('@')
                                ? sessionToken
                                      .split('@')
                                      .first
                                      .trim()
                                      .toLowerCase()
                                : sessionToken;
                            final sessionTokenLocalClean = sessionTokenLocal
                                .replaceFirst(RegExp(r'^dev-token-'), '');

                            final normalizedText = text.trim();
                            final normalizedOriginalText = originalText.trim();

                            final isMine =
                                (myUserId.isNotEmpty &&
                                    senderId.trim() == myUserId) ||
                                senderName.trim().toLowerCase() == 'you' ||
                                (sessionDisplay.isNotEmpty &&
                                    (senderName.trim().toLowerCase() ==
                                            sessionDisplay ||
                                        senderName
                                            .trim()
                                            .toLowerCase()
                                            .contains(sessionDisplay) ||
                                        sessionDisplay.contains(
                                          senderName.trim().toLowerCase(),
                                        ))) ||
                                (sessionToken.isNotEmpty &&
                                    senderId.trim().toLowerCase() ==
                                        sessionToken) ||
                                (sessionTokenLocalClean.isNotEmpty &&
                                    (senderName.trim().toLowerCase() ==
                                            sessionTokenLocalClean ||
                                        senderName
                                            .trim()
                                            .toLowerCase()
                                            .contains(
                                              sessionTokenLocalClean,
                                            ))) ||
                                _recentOwnMessageTexts.contains(
                                  normalizedText,
                                ) ||
                                _recentOwnMessageTexts.contains(
                                  normalizedOriginalText,
                                );
                            final isVoiceMessage =
                                kind.trim().toUpperCase() == 'VOICE';

                            final previousSender = previous == null
                                ? ''
                                : _pick(previous, 'senderUserId');
                            final previousTime = previous == null
                                ? null
                                : DateTime.tryParse(
                                    _pick(previous, 'createdAt'),
                                  )?.toLocal();

                            final groupedWithPrevious =
                                previous != null &&
                                previousSender == senderId &&
                                createdAt != null &&
                                previousTime != null &&
                                createdAt
                                        .difference(previousTime)
                                        .inMinutes
                                        .abs() <=
                                    4;

                            final showAvatar = !groupedWithPrevious;
                            final showName = !groupedWithPrevious;
                            final swipeDx = _swipeDxByMessage[messageId] ?? 0;
                            final resolvedReplyTargetId =
                                _resolveClassroomReplyJumpTarget(
                                  Map<String, dynamic>.from(item),
                                  _lastVisibleClassroomRows,
                                );

                            final bubble = GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onHorizontalDragUpdate: _isForwardSelectionMode
                                  ? null
                                  : (details) {
                                      final current =
                                          _swipeDxByMessage[messageId] ?? 0.0;
                                      final next = (current + details.delta.dx)
                                          .clamp(-84.0, 84.0);
                                      if ((_swipeDxByMessage[messageId] ?? 0.0) !=
                                          next) {
                                        setState(() {
                                          _swipeDxByMessage[messageId] = next;
                                        });
                                      }
                                    },
                              onHorizontalDragEnd: _isForwardSelectionMode
                                  ? null
                                  : (_) async {
                                      final current =
                                          _swipeDxByMessage[messageId] ?? 0.0;

                                      if (_swipeDxByMessage.containsKey(messageId)) {
                                        setState(() {
                                          _swipeDxByMessage.remove(messageId);
                                        });
                                      }

                                if (current >= 44) {
                                  _replyTo(
                                    messageId: messageId,
                                    sender: _classroomSenderLabel(
                                      isMine,
                                      senderName,
                                    ),
                                    text: messageText.isEmpty
                                        ? _classroomEmptyPreviewLabel(kind)
                                        : messageText,
                                  );
                                  return;
                                }

                                if (current <= -44) {
                                  if (deletedForEveryone) {
                                    return;
                                  }
                                  await _showClassroomMessageInfo(
                                    sentAt: _friendlyTime(createdRaw),
                                    isMine: isMine,
                                    edited: _editedTextByMessage.containsKey(
                                      messageId,
                                    ),
                                    forwarded: isForwarded,
                                    deleteState: 'VISIBLE',
                                    kind: kind,
                                    previewTitle: _classroomSenderLabel(
                                      isMine,
                                      senderName,
                                    ),
                                    previewBody: messageText.isEmpty
                                        ? _classroomEmptyPreviewLabel(kind)
                                        : messageText,
                                    previewMeta: _friendlyTime(createdRaw),
                                    previewMediaUrl: mediaUrl,
                                    previewBubbleBuilder: (infoContext) =>
                                        ChatMessageBubble(
                                          contextForNavigation: context,
                                          rawText: text,
                                          mediaUrl: mediaUrl,
                                          isMine: isMine,
                                          showName: false,
                                          senderLabel: senderName,
                                          timeLabel: _friendlyTime(createdRaw),
                                          edited: _editedTextByMessage
                                              .containsKey(messageId),
                                          reaction:
                                              _reactionByMessage[messageId],
                                          reactions:
                                              (_reactionByMessage[messageId] ?? '')
                                                      .trim()
                                                      .isEmpty
                                                  ? const <String, List<String>>{}
                                                  : <String, List<String>>{
                                                      _reactionByMessage[messageId]!.trim(): const <String>['me'],
                                                    },
                                          onReactionTap:
                                              (_reactionByMessage[messageId] ?? '')
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : () => _openClassroomReactionDetails(
                                                        messageId,
                                                      ),
                                          forwarded: isForwarded,
                                          delivered: false,
                                          seen: false,
                                          deleteState: 'VISIBLE',
                                          voiceDurationSeconds: durationSec,
                                          voiceUnread: false,
                                          onVoicePlayed: null,
                                          replySender: replySender,
                                          replySnippet: replySnippet,
                                          mediaMimeType: null,
                                          messageKind: kind,
                                          maxWidth: 280,
                                        ),
                                    voiceDurationSeconds: durationSec,
                                  );
                                  return;
                                }
                              },
                              onHorizontalDragCancel: () {
                                if (_swipeDxByMessage.containsKey(messageId)) {
                                  setState(() {
                                    _swipeDxByMessage.remove(messageId);
                                  });
                                }
                              },
                              onTap: () {
                                if (_isForwardSelectionMode) {
                                  setState(() {
                                    if (_forwardSelectedMessageIds.contains(messageId)) {
                                      _forwardSelectedMessageIds.remove(messageId);
                                    } else {
                                      _forwardSelectedMessageIds.add(messageId);
                                    }
                                    if (_forwardSelectedMessageIds.isEmpty) {
                                      _isForwardSelectionMode = false;
                                    }
                                  });
                                  return;
                                }
                                if (_deleteSelection.isNotEmpty) {
                                  setState(() {
                                    if (_deleteSelection.contains(messageId)) {
                                      _deleteSelection.remove(messageId);
                                    } else {
                                      _deleteSelection.add(messageId);
                                    }
                                  });
                                  return;
                                }
                              },
                              onLongPressStart: (d) {
                                if (_isForwardSelectionMode) {
                                  setState(() {
                                    if (_forwardSelectedMessageIds.contains(messageId)) {
                                      _forwardSelectedMessageIds.remove(messageId);
                                    } else {
                                      _forwardSelectedMessageIds.add(messageId);
                                    }
                                    if (_forwardSelectedMessageIds.isEmpty) {
                                      _isForwardSelectionMode = false;
                                    }
                                  });
                                  return;
                                }
                                _showClassroomWaActionsAt(<String, dynamic>{
                                  'id': messageId,
                                  'text': text,
                                  'mediaUrl': mediaUrl,
                                  'kind': kind,
                                  'senderName': senderName,
                                  'sender': senderName,
                                  'isMine': '$isMine',
                                  'edited':
                                      '${_editedTextByMessage.containsKey(messageId)}',
                                  'timeLabel': _friendlyTime(createdRaw),
                                  'durationSec': durationSec,
                                  'deletedForEveryone': '$deletedForEveryone',
                                  'forwarded': '$isForwarded',
                                }, d.globalPosition);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                transform: Matrix4.translationValues(
                                  swipeDx,
                                  0,
                                  0,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: _highlightedMessageId == messageId
                                      ? 4
                                      : 0,
                                  vertical: _highlightedMessageId == messageId
                                      ? 2
                                      : 0,
                                ),
                                decoration: BoxDecoration(
                                  color: _forwardSelectedMessageIds.contains(messageId)
                                      ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        .withValues(alpha: 0.42)
                                      : _deleteSelection.contains(messageId)
                                          ? Theme.of(context)
                                                .colorScheme
                                                .error
                                        .withValues(alpha: 0.42)
                                          : _highlightedMessageId == messageId
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                            .withValues(alpha: 0.48)
                                              : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                  border: _forwardSelectedMessageIds.contains(messageId)
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          .withValues(alpha: 0.70),
                                        width: 1.7,
                                        )
                                      : _deleteSelection.contains(messageId)
                                          ? Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error
                                            .withValues(alpha: 0.70),
                                          width: 1.7,
                                            )
                                          : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: isMine
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    ChatMessageBubble(
                                      contextForNavigation: context,
                                      rawText: deletedForEveryone
                                          ? (isMine
                                          ? AppLocalizations.of(context)!
                                            .classroomDetailDeletedByYou
                                          : AppLocalizations.of(context)!
                                            .classroomDetailDeletedMessage)
                                          : (_editedTextByMessage[messageId] ??
                                              text),
                                      mediaUrl: deletedForEveryone
                                          ? ''
                                          : (mediaUrl.isEmpty
                                              ? ''
                                              : _absoluteMediaUrl(mediaUrl)),
                                      isMine: isMine,
                                      showName: showName,
                                      senderLabel: isMine
                                          ? AppLocalizations.of(context)!
                                            .tutorYou
                                          : senderName,
                                      timeLabel: _friendlyTime(createdRaw),
                                      edited: !deletedForEveryone &&
                                          _editedTextByMessage.containsKey(messageId),
                                      reaction: deletedForEveryone ? null : reaction,
                                      reactions:
                                          (reaction ?? '').trim().isEmpty
                                              ? const <String, List<String>>{}
                                              : <String, List<String>>{
                                                  reaction!.trim(): const <String>['me'],
                                                },
                                      onReactionTap:
                                          (reaction ?? '').trim().isEmpty
                                              ? null
                                              : () => _openClassroomReactionDetails(
                                                    messageId,
                                                  ),
                                      pinned:
                                          _pick(item, 'isPinned')
                                                      .trim()
                                                      .toLowerCase() ==
                                                  'true' ||
                                              _pick(item, 'isPinned')
                                                      .trim()
                                                      .toLowerCase() ==
                                                  '1' ||
                                              _pinnedMessageIds.contains(
                                                messageId,
                                              ),
                                      forwarded: deletedForEveryone ? false : isForwarded,
                                      delivered: false,
                                      seen: false,
                                      deleteState: deletedForEveryone
                                          ? 'DELETED_FOR_EVERYONE'
                                          : 'VISIBLE',
                                      voiceDurationSeconds:
                                          durationSec > 0 ? durationSec : null,
                                      voiceUnread: false,
                                      onVoicePlayed: null,
                                      replySender: deletedForEveryone
                                          ? null
                                          : (replySender.trim().isEmpty
                                              ? null
                                              : replySender),
                                      replySnippet: deletedForEveryone
                                          ? null
                                          : (replySnippet.trim().isEmpty
                                              ? null
                                              : replySnippet),
                                      onReplyTap:
                                          resolvedReplyTargetId == null
                                              ? null
                                              : () => _jumpToClassroomMessage(
                                                    resolvedReplyTargetId,
                                                  ),
                                      mediaMimeType: null,
                                      messageKind: kind,
                                      maxWidth: 280,
                                    ),
                                  ],
                                ),
                              ),
                            );

                            return KeyedSubtree(
                              key: _keyForClassroomMessage(messageId),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                if (showDaySeparator)
                                  _classroomDayChip(_pick(item, 'createdAt')),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: groupedWithPrevious ? 2 : 5,
                                    bottom: 1,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: isMine
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Reply arrow — fixed far left, fades in as bubble slides right
                                      Opacity(
                                        opacity: (swipeDx / 44).clamp(0.0, 1.0),
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.reply_rounded,
                                              size: 15,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!isMine)
                                        SizedBox(
                                          width: 36,
                                          child: showAvatar
                                              ? _InitialsAvatar(
                                                  name: senderName,
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      if (!isMine) const SizedBox(width: 6),
                                      Flexible(child: bubble),
                                      if (isMine) const SizedBox(width: 6),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            );
                          },
                        ),
                      ),
                      
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PinnedMessagesStrip extends StatelessWidget {
  const _PinnedMessagesStrip({
    required this.rows,
    required this.onTapMessage,
    required this.titleForMessage,
  });

  final List<Map<String, dynamic>> rows;
  final void Function(String messageId) onTapMessage;
  final String Function(Map<String, dynamic> item) titleForMessage;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: rows.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = rows[index];
            final id = _pick(item, 'id');
            final title = titleForMessage(item).trim();

            return InkWell(
              onTap: id.trim().isEmpty ? null : () => onTapMessage(id),
              borderRadius: BorderRadius.circular(999),
              child: LiquidGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: BorderRadius.circular(999),
                blurSigma: 8,
                color: cs.surfaceContainerLow.withValues(alpha: 0.92),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.push_pin_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        title.isEmpty ? 'Pinned message' : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.icon,
    required this.subject,
    required this.subtitle,
    required this.onRefresh,
    required this.onBack,
    required this.tabsCollapsed,
    required this.onToggleTabs,
    required this.onLeave,
  });

  final IconData icon;
  final String subject;
  final String subtitle;
  final VoidCallback onRefresh;
  final VoidCallback onBack;
  final bool tabsCollapsed;
  final VoidCallback onToggleTabs;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: BorderRadius.circular(16),
        blurSigma: 14,
        color: cs.surface.withValues(alpha: 0.88),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              tooltip: 'Back',
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.trim().isEmpty ? 'Classroom' : subject.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.trim().isEmpty ? ' ' : subtitle.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onLeave,
              icon: const Icon(Icons.logout_rounded, size: 20),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              tooltip: 'Leave classroom',
            ),
            IconButton(
              onPressed: onToggleTabs,
              icon: AnimatedRotation(
                turns: tabsCollapsed ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
              ),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                tooltip: tabsCollapsed ? 'Show tabs' : 'Hide tabs',
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: SizedBox(
        height: 84,
        child: LiquidGlassCard(
          borderRadius: BorderRadius.circular(18),
          blurSigma: 12,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CenteredTabs extends StatelessWidget {
  const _CenteredTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(6),
        borderRadius: BorderRadius.circular(14),
        blurSigma: 12,
        color: cs.surfaceContainerLow.withValues(alpha: 0.92),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          labelColor: cs.onPrimaryContainer,
          unselectedLabelColor: cs.onSurfaceVariant,
          splashBorderRadius: BorderRadius.circular(28),
          tabs: [
            Tab(
              child: _TabChipLabel(
                text: AppLocalizations.of(context)!.classroomDetailTabChat,
              ),
            ),
            Tab(
              child: _TabChipLabel(
                text: AppLocalizations.of(context)!.navAssignments,
              ),
            ),
            Tab(
              child: _TabChipLabel(
                text: AppLocalizations.of(context)!.classroomDetailTabMaterials,
              ),
            ),
            Tab(
              child: _TabChipLabel(
                text: AppLocalizations.of(context)!.navMeetings,
              ),
            ),
            Tab(
              child: _TabChipLabel(
                text: AppLocalizations.of(context)!.classroomDetailTabPeople,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChipLabel extends StatelessWidget {
  const _TabChipLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(14),
      blurSigma: 10,
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.84),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.24),
      ),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 145),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.trim().isEmpty ? 'Untitled' : title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle),
                ],
              ],
            ),
          ),
          if (trailing.trim().isNotEmpty) ...[
            const SizedBox(width: 2),
            Text(
              trailing,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LiquidGlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(24),
            blurSigma: 14,
            color: cs.surface.withValues(alpha: 0.82),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.45),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: cs.onSurfaceVariant),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final bg = _avatarColorForName(context, name);
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return SizedBox(
      width: 36,
      height: 36,
      child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(999),
        blurSigma: 8,
        color: bg,
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
        child: Center(
          child: Text(
            _initialsForName(name),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: cs.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
  );
}

String _pick(dynamic item, String key, {String fallback = ''}) {
  if (item is Map) {
    final value = item[key];
    return (value ?? fallback).toString();
  }
  return fallback;
}

String _friendlyTime(String raw) {
  if (raw.trim().isEmpty) return '';
  final dt = DateTime.tryParse(raw)?.toLocal();
  if (dt == null) return raw;
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _friendlyDateTime(String raw) {
  if (raw.trim().isEmpty) return '';
  final dt = DateTime.tryParse(raw)?.toLocal();
  if (dt == null) return raw;
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

String _shortSender(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return 'Unknown';
  if (value.length <= 12) return value;
  return '${value.substring(0, 8)}…';
}

IconData _subjectIcon(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('math')) return Icons.calculate_rounded;
  if (s.contains('physics')) return Icons.science_rounded;
  if (s.contains('chem')) return Icons.biotech_rounded;
  if (s.contains('bio')) return Icons.eco_rounded;
  if (s.contains('arabic') || s.contains('hebrew') || s.contains('english')) {
    return Icons.menu_book_rounded;
  }
  if (s.contains('history')) return Icons.history_edu_rounded;
  if (s.contains('geo')) return Icons.public_rounded;
  if (s.contains('cs') || s.contains('computer')) return Icons.memory_rounded;
  return Icons.book_rounded;
}

Color _avatarColorForName(BuildContext context, String name) {
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
  return palette[seed % palette.length];
}

String _initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final v = parts.first.trim();
    return v.length >= 2 ? v.substring(0, 2).toUpperCase() : v.toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

class BubbleTail extends StatelessWidget {
  final bool isMe;
  const BubbleTail({super.key, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(8, 10),
      painter: _BubbleTailPainter(isMe),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final bool isMe;
  _BubbleTailPainter(this.isMe);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMe ? const Color(0xFFDCF8C6) : const Color(0xFFECECEC);

    final path = Path();

    if (isMe) {
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClassroomDraftWaveBar extends StatelessWidget {
  const _ClassroomDraftWaveBar({required this.h});

  final double h;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 4,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
