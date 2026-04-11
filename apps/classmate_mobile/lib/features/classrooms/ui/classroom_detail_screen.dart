import 'dart:async';
// ignore_for_file: unused_element, unused_local_variable, use_build_context_synchronously, annotate_overrides, unnecessary_import
import 'dart:convert';

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
import '../../chat_core/utils/chat_reply_codec.dart';
import '../../chat_core/domain/chat_thread_type.dart';
import '../../messages/domain/message_thread_models.dart';
import '../../messages/providers/messages_repository_provider.dart';
import '../../chat_core/ui/chat_message_bubble.dart';
import '../../chat_core/ui/chat_message_actions_sheet.dart';
import '../../chat_core/ui/chat_media_preview_screen.dart';
import '../../chat_core/ui/chat_composer.dart';
import '../../chat_core/models/chat_message_info.dart';
import '../../chat_core/ui/chat_message_info_page.dart';
import '../../../core/auth/auth_session.dart';
import '../providers/classrooms_providers.dart';
import '../providers/classrooms_repo_provider.dart';

class _ClassroomForwardTargetPickerSheet extends ConsumerStatefulWidget {
  const _ClassroomForwardTargetPickerSheet();

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

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<MessageThreadSummary> _filtered(List<MessageThreadSummary> items) {
    final q = _query.trim().toLowerCase();
    final filtered = items.where((item) {
      if (item.type == ChatThreadType.classroom) return false;
      if (q.isEmpty) return true;
      return item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q);
    }).toList();

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

  String _editableBodyText(String raw) => _splitReplyRaw(raw).bodyText;

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
      return 'Photo';
    }
    if (RegExp(r'\.(m4a|aac|mp3|wav)$', caseSensitive: false).hasMatch(v)) {
      return 'Voice note';
    }
    if (v.isEmpty) return 'Message';
    return v;
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
  final Set<String> _pinnedMessageIds = <String>{};
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
    setState(() {
      _highlightedMessageId = messageId;
    });
    _highlightClearTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted || _highlightedMessageId != messageId) return;
      setState(() {
        _highlightedMessageId = null;
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
    final absolute = _absoluteMediaUrl(raw);
    if (absolute.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Attachment unavailable.')));
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
        ).showSnackBar(const SnackBar(content: Text('Audio unavailable.')));
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      ).showSnackBar(const SnackBar(content: Text('Attachment unavailable.')));
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open attachment.')),
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
    final v = text.trim();
    if (v.startsWith('[IMAGE] ')) return v.substring(8).trim();
    if (v.startsWith('[VOICE] ')) return v.substring(8).trim();
    if (v.startsWith('[VIDEO] ')) return v.substring(8).trim();
    if (v.startsWith('[FILE] ')) return v.substring(7).trim();

    if (v.isNotEmpty && v != '(empty)') return v;

    switch (kind) {
      case 'VOICE':
        return 'Voice message';
      case 'VIDEO':
        return 'Video file';
      case 'DOC':
      case 'FILE':
        return 'Attached file';
      default:
        return 'Attachment';
    }
  }

  String _classroomKindInfoLabel(String kind) {
    switch (kind.trim().toUpperCase()) {
      case 'IMAGE':
        return 'Photo';
      case 'VOICE':
        return 'Voice note';
      case 'VIDEO':
        return 'Video';
      case 'DOC':
      case 'FILE':
        return 'File';
      case 'TEXT':
      default:
        return 'Message';
    }
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
            title: 'Message info',
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
  String? _replyToMessageId;
  String? _replyToSender;
  String? _replyToText;

  int _lastChatCount = -1;
  String? _knownLastClassroomMessageId;
  bool _classroomNewMessagesBelow = false;

  Map<String, String> _reactionByMessage = <String, String>{};
  Map<String, String> _editedTextByMessage = <String, String>{};
  Set<String> _deletedMessageIds = <String>{};

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
    Future.microtask(_markChatSeen);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging && _tabs.index == 0) {
        Future.microtask(_markChatSeen);
      }
    });
    _chatCtl.addListener(_onComposerChanged);
    _loadLocalChatState();
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

    Map<String, String> reactions = <String, String>{};
    Map<String, String> edits = <String, String>{};
    Set<String> deleted = <String>{};

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

    if (!mounted) {
      return;
    }
    setState(() {
      _reactionByMessage = reactions;
      _editedTextByMessage = edits;
      _deletedMessageIds = deleted;
    });
  }

  Future<void> _persistLocalChatState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key('reactions'), jsonEncode(_reactionByMessage));
    await prefs.setString(_key('edits'), jsonEncode(_editedTextByMessage));
    await prefs.setString(
      _key('deleted'),
      jsonEncode(_deletedMessageIds.toList()..sort()),
    );
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

  Future<void> _togglePinMessage(String messageId) async {
    setState(() {
      if (_pinnedMessageIds.contains(messageId)) {
        _pinnedMessageIds.remove(messageId);
      } else {
        _pinnedMessageIds.add(messageId);
      }
    });
    await _persistLocalChatState();
  }

  Future<List<String>?> _showClassroomForwardTargetPicker() {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ClassroomForwardTargetPickerSheet(),
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

  Future<void> _forwardPlaceholder({
    required String messageId,
    required String text,
    required String mediaUrl,
  }) async {
    final label = editableBodyText(text).trim().isNotEmpty
        ? editableBodyText(text).trim()
        : (mediaUrl.trim().isNotEmpty ? mediaUrl.split('/').last : 'Message');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Forward target picker next: $label')),
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    setState(() {
      _deletedMessageIds.add(messageId);
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
    final ctl = TextEditingController(text: editableBodyText(currentText));
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
              const Text(
                'Edit message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: ctl,
                autofocus: true,
                minLines: 2,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  hintText: 'Edit your message...',
                  contentPadding: EdgeInsets.symmetric(
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
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    fit: FlexFit.loose,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, ctl.text.trim()),
                      child: const Text('Save'),
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
      _replyToText = replyPreviewText(text);
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

    return editableBodyText(raw).trim().isNotEmpty;
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
    required String timeLabel,
    int? voiceDurationSeconds,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => ChatMessageActionsSheet(
        canEdit:
            isMine &&
            _classroomCanEditMessage(
              messageId: messageId,
              text: text,
              mediaUrl: mediaUrl,
              kind: kind,
            ),
        canDelete: isMine,
        canViewInfo: isMine,
        canPin: true,
        canForward: true,
      ),
    );

    if (action == null || action.trim().isEmpty) return;

    if (action == 'info') {
      await _showClassroomMessageInfo(
        sentAt: timeLabel,
        isMine: isMine,
        edited: edited,
        forwarded: _isClassroomForwardedText(text),
        deleteState: 'VISIBLE',
        kind: kind,
        previewTitle: isMine ? 'You' : senderLabel,
        previewBody: editableBodyText(text).trim().isEmpty
            ? (kind.trim().toUpperCase() == 'IMAGE'
                  ? 'Photo'
                  : kind.trim().toUpperCase() == 'VIDEO'
                  ? 'Video'
                  : kind.trim().toUpperCase() == 'VOICE'
                  ? 'Voice note'
                  : kind.trim().toUpperCase() == 'FILE'
                  ? 'File'
                  : '(empty)')
            : editableBodyText(text),
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
          forwarded: _isClassroomForwardedText(text),
          delivered: false,
          seen: false,
          deleteState: 'VISIBLE',
          voiceDurationSeconds: voiceDurationSeconds,
          voiceUnread: false,
          onVoicePlayed: null,
          replySender: splitReplyRaw(text).replyPrefix.trim(),
          replySnippet: replyPreviewText(text),
          mediaMimeType: null,
          messageKind: kind,
          maxWidth: 280,
        ),
      );
      return;
    }

    if (action == 'reply') {
      _replyTo(
        messageId: messageId,
        sender: senderLabel,
        text: editableBodyText(text),
      );
      return;
    }

    if (action == 'pin') {
      await _togglePinMessage(messageId);
      return;
    }

    if (action == 'forward') {
      final targetThreadIds = await _showClassroomForwardTargetPicker();
      if (!mounted || targetThreadIds == null || targetThreadIds.isEmpty) {
        return;
      }

      try {
        await ref
            .read(classroomsRepoProvider)
            .forwardChatMessage(
              widget.courseId,
              messageId: messageId,
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
        final message =
            text.contains('Cannot forward into a non-approved thread')
            ? 'Cannot forward into a request chat until it is approved'
            : 'Could not forward this message';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
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
      await _editMessage(context, messageId: messageId, currentText: text);
      return;
    }

    if (action == 'delete') {
      await _deleteMessage(messageId);
      return;
    }
  }

  Widget build(BuildContext context) {
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
      resizeToAvoidBottomInset: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_classroomComposer()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            detail.when(
              loading: () => const _HeaderSkeleton(),
              error: (e, st) => _TopHeader(
                icon: Icons.book_rounded,
                subject: 'Classroom',
                subtitle: widget.courseId,
                onRefresh: () async {
                  _refreshAll();
                },
                onBack: _goBackToClassrooms,
                tabsCollapsed: _classroomTabsCollapsed,
                onToggleTabs: () {
                  setState(() {
                    _classroomTabsCollapsed = !_classroomTabsCollapsed;
                  });
                },
              ),
              data: (m) => _TopHeader(
                icon: _subjectIcon((m['subject'] ?? '').toString()),
                subject:
                    ((m['name'] ?? '').toString().trim().isNotEmpty
                            ? (m['name'] ?? '').toString()
                            : (m['subject'] ?? 'Classroom').toString())
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
                onToggleTabs: () {
                  setState(() {
                    _classroomTabsCollapsed = !_classroomTabsCollapsed;
                  });
                },
              ),
            ),
            const SizedBox(height: 0),
            if (!_classroomTabsCollapsed)
              _CenteredTabs(controller: _tabs),
            if (_tabs.index == 0)
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

                  final body = editableBodyText(raw).trim();
                  final kind = _pick(item, 'kind').trim().toUpperCase();

                  final title = body.isNotEmpty
                      ? body
                      : (kind == 'IMAGE'
                            ? 'Photo'
                            : kind == 'VIDEO'
                            ? 'Video'
                            : kind == 'VOICE'
                            ? 'Voice note'
                            : kind == 'FILE'
                            ? 'File'
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
                    emptyTitle: 'No assignments yet',
                    emptySubtitle:
                        'This classroom has no assignments right now.',
                    itemBuilder: (item) => _SimpleCard(
                      title: _pick(item, 'title', fallback: 'Assignment'),
                      subtitle: _pick(item, 'body'),
                      trailing: _friendlyDateTime(_pick(item, 'dueAt')),
                    ),
                  ),
                  _listTab(
                    value: materials,
                    emptyTitle: 'No materials yet',
                    emptySubtitle: 'This classroom has no materials right now.',
                    itemBuilder: (item) => _SimpleCard(
                      title: _pick(item, 'title', fallback: 'Material'),
                      subtitle: _pick(item, 'description'),
                      trailing: _pick(item, 'mime'),
                    ),
                  ),
                  _listTab(
                    value: meetings,
                    emptyTitle: 'No meetings yet',
                    emptySubtitle: 'This classroom has no meetings right now.',
                    itemBuilder: (item) => _SimpleCard(
                      title: _pick(item, 'title', fallback: 'Meeting'),
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
    return people.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _CenteredState(
        icon: Icons.group_outlined,
        title: 'Could not load people',
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
            'name': (teacher['name'] ?? teacher['email'] ?? 'Teacher')
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
          return const _CenteredState(
            icon: Icons.group_outlined,
            title: 'No people yet',
            subtitle: 'Nobody is visible in this classroom yet.',
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
            final name = _pick(item, 'name', fallback: 'Student');
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
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _CenteredState(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load tab',
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

    final willCancel = dx <= -56;
    final willLock = dy <= -44;

    if (willCancel && !_voiceCancelled) {
      setState(() {
        _holdDx = dx;
        _holdDy = dy;
        _voiceCancelled = true;
      });
      _cancelVoiceDraft();
      return;
    }

    if (willLock && !_voiceLocked) {
      setState(() {
        _holdDx = dx;
        _holdDy = dy;
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

  Widget _recordHud() => const SizedBox.shrink();

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
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
      }

      if (text.isNotEmpty || sentAnyMedia) {
        _clearReply();
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _recordHud(),
        if (hasDrafts)
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
        if (hasDrafts) const SizedBox(height: 2),
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
    if (!_typing || _sending) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Typing…',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _classroomComposer() {
    return ChatComposer(
      controller: _chatCtl,
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
      onCamera: _sending || _recording
          ? () {}
          : _pickClassroomCameraOrUploadImage,
      onAttach: _sending || _recording ? () {} : _pickClassroomFiles,
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
      hasDraft:
          _draftAttachments.isNotEmpty ||
          (_draftVoicePath ?? '').trim().isNotEmpty,
      replyingTo: _replyToMessageId == null
          ? null
          : (
              senderName: _replyToSender?.trim().isNotEmpty == true
                  ? _replyToSender!.trim()
                  : 'Replying',
              text: (_replyToText ?? '').trim(),
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
    );
  }

  String _resolveMyUserId(Map<String, String> peopleMap) {
    final session = ref.read(authSessionProvider);
    final display = session.displayName.trim().toLowerCase();
    final token = (session.token ?? '').trim().toLowerCase();
    final tokenLocal = token.contains('@')
        ? token.split('@').first.trim().toLowerCase()
        : token;
    final tokenLocalClean = tokenLocal.replaceFirst(RegExp(r'^dev-token-'), '');

    for (final entry in peopleMap.entries) {
      final key = entry.key.trim().toLowerCase();
      final value = entry.value.trim().toLowerCase();

      if (display.isNotEmpty &&
          (value == display ||
              value.contains(display) ||
              display.contains(value))) {
        return entry.key.trim();
      }

      if (token.isNotEmpty && (key == token || value == token)) {
        return entry.key.trim();
      }

      if (tokenLocalClean.isNotEmpty &&
          (value == tokenLocalClean ||
              value.contains(tokenLocalClean) ||
              tokenLocalClean.contains(value))) {
        return entry.key.trim();
      }
    }

    return '';
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
    final edited = (_pick(item, 'edited').trim().toLowerCase() == 'true');
    final timeLabel = _pick(item, 'timeLabel').trim();
    final voiceDurationSeconds = int.tryParse(_pick(item, 'durationSec').trim());

    final canEdit =
        isMine &&
        _classroomCanEditMessage(
          messageId: messageId,
          text: text,
          mediaUrl: mediaUrl,
          kind: kind,
        );

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => ChatMessageActionsSheet(
        canEdit: canEdit,
        canDelete: isMine,
        canViewInfo: isMine,
        canPin: true,
        canForward: true,
      ),
    );

    if (action == null || action.trim().isEmpty) return;

    if (action.startsWith('react:')) {
      final emoji = action.substring('react:'.length).trim();
      if (emoji.isNotEmpty) {
        await _setReaction(messageId, emoji);
      }
      return;
    }

    if (action == 'reply') {
      _replyTo(
        messageId: messageId,
        sender: senderLabel,
        text: editableBodyText(text),
      );
      return;
    }

    if (action == 'forward') {
      final targetThreadIds = await _showClassroomForwardTargetPicker();
      if (!mounted || targetThreadIds == null || targetThreadIds.isEmpty) {
        return;
      }

      try {
        await ref
            .read(classroomsRepoProvider)
            .forwardChatMessage(
              widget.courseId,
              messageId: messageId,
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
        final message =
            text.contains('Cannot forward into a non-approved thread')
            ? 'Cannot forward into a request chat until it is approved'
            : 'Could not forward this message';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }

    if (action == 'pin') {
      await _togglePinMessage(messageId);
      return;
    }

    if (action == 'edit') {
      await _editMessage(context, messageId: messageId, currentText: text);
      return;
    }

    if (action == 'delete') {
      await _deleteMessage(messageId);
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => _CenteredState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Could not load chat',
              subtitle: '$e',
            ),
            data: (m) {
              final rawItems = (m['items'] is List)
                  ? (m['items'] as List)
                  : const [];

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
                                _isClassroomForwardedText(text) ||
                                _isClassroomForwardedText(originalText);

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
                              onHorizontalDragUpdate: (details) {
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
                              onHorizontalDragEnd: (_) async {
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
                                    sender: isMine ? 'You' : senderName,
                                    text: messageText.isEmpty
                                        ? '(empty)'
                                        : messageText,
                                  );
                                  return;
                                }

                                if (current <= -44) {
                                  await _showClassroomMessageInfo(
                                    sentAt: _friendlyTime(createdRaw),
                                    isMine: isMine,
                                    edited: _editedTextByMessage.containsKey(
                                      messageId,
                                    ),
                                    forwarded: isForwarded,
                                    deleteState: 'VISIBLE',
                                    kind: kind,
                                    previewTitle: isMine ? 'You' : senderName,
                                    previewBody: messageText.isEmpty
                                        ? (kind.trim().toUpperCase() == 'IMAGE'
                                              ? 'Photo'
                                              : kind.trim().toUpperCase() ==
                                                    'VIDEO'
                                              ? 'Video'
                                              : kind.trim().toUpperCase() ==
                                                    'VOICE'
                                              ? 'Voice note'
                                              : kind.trim().toUpperCase() ==
                                                    'FILE'
                                              ? 'File'
                                              : '(empty)')
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
                              onLongPressStart: (d) => _showClassroomWaActionsAt(<
                                String,
                                dynamic
                              >{
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
                              }, d.globalPosition),
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
                                  color: _highlightedMessageId == messageId
                                      ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.10)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMine
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    ChatMessageBubble(
                                      contextForNavigation: context,
                                      rawText:
                                          _editedTextByMessage[messageId] ??
                                          text,
                                      mediaUrl: mediaUrl.isEmpty
                                          ? ''
                                          : _absoluteMediaUrl(mediaUrl),
                                      isMine: isMine,
                                      showName: showName,
                                      senderLabel: isMine
                                          ? 'You'
                                          : senderName,
                                      timeLabel: _friendlyTime(createdRaw),
                                      edited: _editedTextByMessage
                                          .containsKey(messageId),
                                      reaction: reaction,
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
                                      forwarded: isForwarded,
                                      delivered: false,
                                      seen: false,
                                      deleteState: 'VISIBLE',
                                      voiceDurationSeconds:
                                          durationSec > 0 ? durationSec : null,
                                      voiceUnread: false,
                                      onVoicePlayed: null,
                                      replySender:
                                          replySender.trim().isEmpty
                                              ? null
                                              : replySender,
                                      replySnippet:
                                          replySnippet.trim().isEmpty
                                              ? null
                                              : replySnippet,
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
                      Positioned(
                        right: 16,
                        bottom: 0,
                        child: ChatScrollToBottomFab(
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.28),
                  ),
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
  });

  final IconData icon;
  final String subject;
  final String subtitle;
  final VoidCallback onRefresh;
  final VoidCallback onBack;
  final bool tabsCollapsed;
  final VoidCallback onToggleTabs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
        ),
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
    return const Padding(
      padding: EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: SizedBox(height: 84, child: Card()),
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
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
        ),
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
          tabs: const [
            Tab(child: _TabChipLabel(text: 'Chat')),
            Tab(child: _TabChipLabel(text: 'Assignments')),
            Tab(child: _TabChipLabel(text: 'Materials')),
            Tab(child: _TabChipLabel(text: 'Meetings')),
            Tab(child: _TabChipLabel(text: 'People')),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration(context),
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
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
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

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initialsForName(name),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
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
