import 'dart:async';
// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import '../../../ui/glass/native_glass_view.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmate_mobile/features/chat_core/ui/chat_scroll_to_bottom_fab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/domain/chat_thread_type.dart';
import '../../chat_core/ui/chat_composer.dart';
import '../../chat_core/ui/chat_context_overlay.dart';
import '../../chat_core/ui/chat_media_preview_screen.dart';
import '../../chat_core/ui/chat_message_bubble.dart';
import '../../chat_core/ui/chat_recording_tokens.dart';
import '../../../common/widgets/typing_dots.dart';
import '../../chat_core/models/chat_message_info.dart';
import '../../chat_core/ui/chat_message_info_page.dart';
import '../../chat_core/ui/chat_reaction_details_sheet.dart';
import '../../chat_core/utils/chat_reply_codec.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import '../../chat_core/utils/chat_time.dart';
import '../../classrooms/providers/classrooms_providers.dart';
import '../../classrooms/ui/classroom_detail_screen.dart';
import 'new_chat_screen.dart';

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

  MessageThreadSummary _classroomMapToSummary(Map<String, dynamic> map) {
    final l = AppLocalizations.of(context)!;
    final id = (map['id'] ?? '').toString().trim();
    final name = (map['name'] ?? map['title'] ?? '').toString().trim();
    final subject = (map['subject'] ?? '').toString().trim();
    final teacher = (map['teacherName'] ?? map['teacher'] ?? '').toString().trim();
    final displayTitle = name.isNotEmpty
        ? name
        : (subject.isNotEmpty ? subject : l.classroomsThreadTypeClassroom);
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

  List<MessageThreadSummary> _sortTargets(List<MessageThreadSummary> items) {
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
                      : Theme.of(context).colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.28)
                        : Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.16),
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
                                  style: Theme.of(context).textTheme.titleSmall
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                  ),
                                  child: Text(
                                    l.classroomsThreadTypeClassroom,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                  ),
                                  child: Text(
                                    l.classroomsThreadTypeGroup,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                  ),
                                  child: Text(
                                    l.classroomsThreadTypeDirectMessageShort,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
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

  @override
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
                error: (error, _) =>
                  Center(child: Text(l.classroomsForwardLoadError(error.toString()))),
                data: (inboxItems) {
                  final classrooms = _filtered(
                    (classroomsAsync.asData?.value ?? const [])
                        .map(_classroomMapToSummary)
                        .toList(),
                  );
                  final directMessages = _sortTargets(
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

class MessageThreadScreen extends ConsumerStatefulWidget {
  const MessageThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<MessageThreadScreen> createState() =>
      _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen> {
  static const List<String> dmAllowedEmojis = <String>[
    '❤️',
    '👍',
    '😂',
    '😮',
    '😢',
    '🙏',
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _pinnedMessageIds = <String>{};
  final Map<String, double> _swipeDxByMessage = <String, double>{};
  final Map<String, GlobalKey> _messageKeys = <String, GlobalKey>{};
  final Set<String> _forwardSelectedMessageIds = <String>{};
  bool _isForwardSelectionMode = false;
  final Set<String> _deleteSelection = <String>{};
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _highlightClearTimer;
  String? _highlightedMessageId;
  bool _showScrollToBottom = false;
  bool _newMessagesBelow = false;
  int _knownMessageCount = 0;
  String? _knownLastMessageId;
  final ImagePicker _imagePicker = ImagePicker();

  int? _replyIndex;
  bool _sending = false;
  bool _peerTyping = false;
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
  double _lastThreadInsetsBottom = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleThreadScroll);
  }

  bool _threadNearBottom([double threshold = 140]) {
    if (!_scrollController.hasClients) return true;
    final distance =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    return distance <= threshold;
  }

  void _handleThreadScroll() {
    if (!_scrollController.hasClients) return;

    final nearBottom = _threadNearBottom(96);
    if (nearBottom && _newMessagesBelow) {
      if (!mounted) return;
      setState(() {
        _newMessagesBelow = false;
        _showScrollToBottom = false;
      });
      return;
    }

    final shouldShow = !_threadNearBottom(180) || _newMessagesBelow;
    if (shouldShow == _showScrollToBottom || !mounted) return;
    setState(() {
      _showScrollToBottom = shouldShow;
    });
  }

  void _onThreadRowsRendered(List<MessageItem> rows) {
    final previousCount = _knownMessageCount;
    final previousLastMessageId = _knownLastMessageId;
    final currentLastMessageId = rows.isEmpty ? null : rows.last.id;

    _knownMessageCount = rows.length;
    _knownLastMessageId = currentLastMessageId;

    if (previousCount == 0 || currentLastMessageId == null) return;
    if (currentLastMessageId == previousLastMessageId) return;

    final shouldStickToBottom = _threadNearBottom(180);

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

      setState(() {
        _newMessagesBelow = true;
        _showScrollToBottom = true;
      });
    });
  }

  void _pulseMessage(String messageId) {
    _highlightClearTimer?.cancel();
    // Triple-flash: on → off → on → fade
    if (mounted) setState(() => _highlightedMessageId = messageId);
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

  Future<void> _refreshThread() async {
    ref.invalidate(messageThreadProvider(widget.threadId));
    ref.invalidate(messagesInboxProvider);
  }

  Future<void> _leaveGroup() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.messagesThreadLeaveGroupTitle),
        content: Text(l.messagesThreadLeaveGroupBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomDetailCancelTooltip),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.classroomDetailLeaveAction),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await ref
        .read(messagesRepositoryProvider)
        .leaveGroup(threadId: widget.threadId);
    ref.invalidate(messagesInboxProvider);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _blockDirectThread() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.messagesThreadBlockPersonTitle),
        content: Text(l.messagesThreadBlockPersonBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomDetailCancelTooltip),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.messagesBlockAction),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await ref
        .read(messagesRepositoryProvider)
        .blockDirectThread(threadId: widget.threadId);
    ref.invalidate(messagesInboxProvider);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _scrollToBottom({bool jump = false}) {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.position.maxScrollExtent;
    if (jump) {
      _scrollController.jumpTo(offset);
      return;
    }
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  String _kindInfoLabel(AppLocalizations l, MessageItem row) {
    final kind = row.kind.trim().toUpperCase();
    switch (kind) {
      case 'IMAGE':
        return l.classroomDetailPhoto;
      case 'VOICE':
        return l.classroomDetailVoiceNote;
      case 'VIDEO':
        return l.classroomDetailVideo;
      case 'FILE':
        return l.classroomDetailFile;
      case 'TEXT':
      default:
        return l.classroomsMessageFallback;
    }
  }

  DateTime _parseThreadMessageDate(MessageItem row) {
    return row.sentAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool _sameMessageDay(MessageItem a, MessageItem b) {
    return sameLocalCalendarDay(a.sentAtDate, b.sentAtDate);
  }

  String _messageDaySeparatorLabel(AppLocalizations l, MessageItem row) {
    return formatChatDayChipLabel(
      row.sentAtDate,
      includeYear: true,
      fallback: row.timeLabel.trim().isEmpty ? l.earlier : row.timeLabel.trim(),
    );
  }

  Widget _buildDaySeparatorChip(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.20),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  String _fmtDuration(int seconds) {
    final total = seconds < 0 ? 0 : seconds;
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Widget _threadMemberTile(BuildContext context, MessageParticipant p) {
    final l = AppLocalizations.of(context)!;
    final school = p.schoolName.trim().isEmpty ? l.profileEmptyValue : p.schoolName.trim();
    final grade = p.gradeLabel.trim().isEmpty ? l.profileEmptyValue : p.gradeLabel.trim();

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(
        p.displayName.trim().isEmpty ? l.messagesThreadPersonFallback : p.displayName.trim(),
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        (school == l.profileEmptyValue && grade == l.profileEmptyValue)
            ? l.messagesThreadProfileInfoUnavailable
            : '$school • $grade',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      children: [
        _infoRow(context, l.editProfileSchool, school),
        _infoRow(context, l.teacherGradesFieldGrade, grade),
      ],
    );
  }

  Future<void> _showThreadInfo(MessageThreadDetail detail) async {
    final l = AppLocalizations.of(context)!;
    final participantCount = detail.participants.length;
    final subtitle = detail.subtitle.trim().isEmpty
        ? l.profileEmptyValue
        : detail.subtitle.trim();

    String school = l.profileEmptyValue;
    String grade = l.profileEmptyValue;

    if (!detail.isGroup) {
      final parts = subtitle.split('/');
      if (parts.length >= 2) {
        school = parts.first.trim().isEmpty ? l.profileEmptyValue : parts.first.trim();
        grade = parts.sublist(1).join('/').trim().isEmpty
            ? l.profileEmptyValue
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
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  detail.title.trim().isEmpty
                      ? l.messagesThreadConversationFallback
                      : detail.title.trim(),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l.classroomsThreadTypeGroup,
                      style: Theme.of(sheetContext).textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (!detail.isGroup) ...[
                _infoRow(sheetContext, l.editProfileSchool, school),
                _infoRow(sheetContext, l.teacherGradesFieldGrade, grade),
              ] else ...[
                _infoRow(sheetContext, l.messagesThreadParticipants, '$participantCount'),
                if (detail.participants.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l.messagesThreadPeople,
                    style: Theme.of(sheetContext).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  ...detail.participants.map(
                    (p) => _threadMemberTile(sheetContext, p),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final l = AppLocalizations.of(context)!;
    final text = value.trim().isEmpty ? l.profileEmptyValue : value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Future<void> _showMessageInfo(MessageItem row) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (infoContext) => ChatMessageInfoPage(
          info: ChatMessageInfo(
            title: l.classroomDetailMessageInfoTitle,
            sentAt: row.timeLabel,
            deliveredAt: row.isMine ? row.deliveredAt : '',
            seenAt: row.isMine ? row.seenAt : '',
            delivered: row.isMine ? row.delivered : false,
            seen: row.isMine ? row.seen : false,
            edited: row.edited,
            forwarded: row.forwarded,
            deleteState: row.deleteState,
            isMine: row.isMine,
            messageType: _kindInfoLabel(l, row),
            voiceDuration:
                row.kind.trim().toUpperCase() == 'VOICE' &&
                    row.voiceDurationSeconds != null &&
                    row.voiceDurationSeconds! > 0
                ? _fmtDuration(row.voiceDurationSeconds!)
                : '',
          ),
          previewTitle: row.isMine ? l.tutorYou : row.senderName,
          previewBody: row.text.trim(),
          previewMeta: row.timeLabel,
          previewBubbleBuilder: (bubbleContext) => ChatMessageBubble(
            contextForNavigation: bubbleContext,
            rawText: row.text,
            mediaUrl: row.mediaUrl ?? '',
            isMine: row.isMine,
            showName: false,
            senderLabel: row.senderName,
            timeLabel: row.timeLabel,
            edited: row.edited,
            reaction: row.reaction,
            forwarded: row.forwarded,
            delivered: row.delivered,
            seen: row.seen,
            deleteState: row.deleteState,
            voiceDurationSeconds: row.voiceDurationSeconds,
            voiceUnread: false,
            onVoicePlayed: null,
            replySender: row.replyPreview?.senderName,
            replySnippet: row.replyPreview?.text,
            mediaMimeType: row.mediaMimeType,
            messageKind: row.kind,
            maxWidth: 236,
          ),
          seenByNames: const <String>[],
          deliveredToNames: const <String>[],
        ),
      ),
    );
  }

  Future<void> _editMessage(MessageItem row) async {
    final l = AppLocalizations.of(context)!;
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
              decoration: InputDecoration(
                labelText: l.classroomDetailEditMessageTitle,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    child: Text(l.classroomDetailCancelTooltip),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    child: Text(l.profileSave),
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

  Future<void> _openReactionDetails(MessageItem row) async {
    final picked = await ChatReactionDetailsSheet.show(
      context,
      myReaction: row.reaction,
      reactionUsers: row.reactions,
      pickerAllowedEmojis: null,
    );
    if (!mounted || (picked ?? '').trim().isEmpty) return;
    await _reactToMessage(row, picked == '__remove__' ? null : picked!.trim());
  }

  Future<void> _markVoicePlayed(MessageItem row) async {
    if (row.isMine || row.voicePlayed) return;
    await ref
        .read(messagesRepositoryProvider)
        .markThreadRead(threadId: widget.threadId)
        .catchError((_) {});
    if (!mounted) return;
    await _refreshThread();
  }

  // ignore: unused_element
  Future<String?> _showDeleteModeSheet() {
    final l = AppLocalizations.of(context)!;
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(l.messagesThreadDeleteForMe),
              onTap: () => Navigator.of(sheetContext).pop('me'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded),
              title: Text(l.messagesThreadDeleteForEveryone),
              onTap: () => Navigator.of(sheetContext).pop('everyone'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isApprovedForwardTarget(MessageThreadSummary item) {
    return item.requestState != ChatRequestState.pendingIncoming &&
        item.requestState != ChatRequestState.pendingOutgoing &&
        item.requestState != ChatRequestState.blocked;
  }

  void _openForwardedThreadIfSingle(List<String> targetThreadIds) {
    if (targetThreadIds.length != 1 || !mounted) return;

    final targetThreadId = targetThreadIds.first;
    if (targetThreadId == widget.threadId) return;

    // Check if the target is a known classroom (orderedStudentClassroomsProvider)
    final knownClassrooms = ref.read(orderedStudentClassroomsProvider).asData?.value ?? const [];
    final isClassroom = knownClassrooms.any(
      (c) => (c['id'] ?? '').toString().trim() == targetThreadId,
    );

    if (isClassroom) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ClassroomDetailScreen(courseId: targetThreadId),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => MessageThreadScreen(threadId: targetThreadId),
        ),
      );
    }
  }

  Future<List<String>?> _showForwardTargetPicker() async {
    final inbox = await ref.read(messagesInboxProvider.future);
    if (!mounted) return null;

    final hasApproved = inbox.any(
      (item) => item.id != widget.threadId && _isApprovedForwardTarget(item),
    );

    if (!hasApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No approved chats available')),
      );
      return null;
    }

    return showModalBottomSheet<List<String>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) =>
          _ForwardTargetPickerSheet(currentThreadId: widget.threadId),
    );
  }

  // ignore: unused_element
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

      ref.invalidate(messagesInboxProvider);
      for (final targetThreadId in targetThreadIds) {
        ref.invalidate(messageThreadProvider(targetThreadId));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            targetThreadIds.length == 1
                ? 'Forwarded to 1 chat'
                : 'Forwarded to ${targetThreadIds.length} chats',
          ),
        ),
      );
      _openForwardedThreadIfSingle(targetThreadIds);
    } catch (e) {
      if (!mounted) return;
      final text = e.toString();
      final message = text.contains('Cannot forward into a non-approved thread')
          ? 'Cannot forward into a request chat until it is approved'
          : 'Could not forward this message';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _enterForwardSelectionMode(String messageId) {
    if (!mounted) return;
    setState(() {
      _isForwardSelectionMode = true;
      _forwardSelectedMessageIds
        ..clear()
        ..add(messageId);
    });
  }

  void _exitForwardSelectionMode() {
    if (!mounted) return;
    setState(() {
      _isForwardSelectionMode = false;
      _forwardSelectedMessageIds.clear();
    });
  }

  void _toggleForwardMessageSelection(String messageId) {
    if (!_isForwardSelectionMode || !mounted) return;
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
  }

  Future<void> _forwardSelectedMessages() async {
    if (_forwardSelectedMessageIds.isEmpty) return;
    final targetThreadIds = await _showForwardTargetPicker();
    if (!mounted || targetThreadIds == null || targetThreadIds.isEmpty) return;

    final selectedRows = _lastRows
        .where((row) => _forwardSelectedMessageIds.contains(row.id))
        .toList();
    if (selectedRows.isEmpty) {
      _exitForwardSelectionMode();
      return;
    }

    try {
      for (final row in selectedRows) {
        await ref
            .read(messagesRepositoryProvider)
            .forwardMessage(
              fromThreadId: widget.threadId,
              messageId: row.id,
              targetThreadIds: targetThreadIds,
            );
      }

      ref.invalidate(messagesInboxProvider);
      for (final targetThreadId in targetThreadIds) {
        ref.invalidate(messageThreadProvider(targetThreadId));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            targetThreadIds.length == 1
                ? 'Forwarded ${selectedRows.length} messages to 1 chat'
                : 'Forwarded ${selectedRows.length} messages to ${targetThreadIds.length} chats',
          ),
        ),
      );
      _openForwardedThreadIfSingle(targetThreadIds);
    } catch (e) {
      if (!mounted) return;
      final text = e.toString();
      final message = text.contains('Cannot forward into a non-approved thread')
          ? 'Cannot forward into a request chat until it is approved'
          : 'Could not forward selected messages';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      _exitForwardSelectionMode();
    }
  }

  Future<void> _openBubbleMenu(MessageItem row, {required bool canPin}) async {
    final isDeletedForEveryone =
        row.deleteState.toUpperCase() == 'DELETED_FOR_EVERYONE';

    final action = await ChatContextOverlay.show(
      context,
      isMine: row.isMine,
      canReply: !isDeletedForEveryone,
      canEdit:
          !isDeletedForEveryone &&
          row.isMine &&
          (row.mediaUrl == null || row.mediaUrl!.trim().isEmpty),
      canDelete: row.isMine,
      canViewInfo: !isDeletedForEveryone,
      canPin: canPin,
      canForward: !isDeletedForEveryone,
      canCopy:
          !isDeletedForEveryone &&
          (row.mediaUrl == null || row.mediaUrl!.trim().isEmpty) &&
          row.text.trim().isNotEmpty,
      pickerAllowedEmojis: isDeletedForEveryone ? null : dmAllowedEmojis,
      messageBubble: ChatMessageBubble(
        contextForNavigation: context,
        rawText: row.text,
        mediaUrl: row.mediaUrl ?? '',
        isMine: row.isMine,
        showName: false,
        senderLabel: row.senderName,
        timeLabel: row.timeLabel,
        edited: row.edited,
        reaction: row.reaction,
        reactions: row.reactions,
        forwarded: row.forwarded,
        delivered: row.delivered,
        seen: row.seen,
        deleteState: row.deleteState,
        voiceDurationSeconds: row.voiceDurationSeconds,
        voiceUnread: false,
        onVoicePlayed: null,
        replySender: row.replyPreview?.senderName,
        replySnippet: row.replyPreview?.text,
        mediaMimeType: row.mediaMimeType,
        messageKind: row.kind,
        maxWidth: 260,
      ),
    );

    if (action == null || action.trim().isEmpty) return;

    if (action == 'reply') {
      final idx = rowIndexById(row.id);
      if (idx >= 0) setState(() => _replyIndex = idx);
      return;
    }

    if (action == 'copy') {
      final text = row.text.trim();
      if (text.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: text));
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Copied')));
      }
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
      _enterForwardSelectionMode(row.id);
      return;
    }

    if (action == 'edit') {
      await _editMessage(row);
      return;
    }

    if (action == 'delete') {
      setState(() => _deleteSelection.add(row.id));
      return;
    }

    if (action.startsWith('react:')) {
      final reaction = action.substring('react:'.length).trim();
      await _reactToMessage(row, reaction.isEmpty ? null : reaction);
      return;
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

  GlobalKey _messageKeyFor(String messageId) {
    return _messageKeys.putIfAbsent(messageId, () => GlobalKey());
  }

  void _jumpToMessage(String messageId) {
    final index = _lastRows.indexWhere((row) => row.id == messageId);
    if (index < 0 || !_scrollController.hasClients) return;

    void ensureAfterScroll() {
      Future<void>.delayed(const Duration(milliseconds: 40), () {
        if (!mounted) return;
        final ctx = _messageKeyFor(messageId).currentContext;
        if (ctx == null) return;
        _pulseMessage(messageId);
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: 0.18,
        );
      });
    }

    final target = _messageKeyFor(messageId).currentContext;
    if (target != null) {
      _pulseMessage(messageId);
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
      return;
    }

    final total = _lastRows.length;
    final fraction = total <= 1 ? 0.0 : index / (total - 1);
    final estimatedOffset =
        (_scrollController.position.maxScrollExtent * fraction).clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        );

    _scrollController
        .animateTo(
          estimatedOffset,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        )
        .then((_) {
          ensureAfterScroll();
        });
  }

  @override
  void dispose() {
    _highlightClearTimer?.cancel();
    _controller.dispose();
    _scrollController.removeListener(_handleThreadScroll);
    _scrollController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _send(MessageThreadDetail detail) async {
    final text = _controller.text.trim();
    if (_sending || !detail.canSend) return;
    if (text.isEmpty) return;

    final rows = [...detail.messages]
      ..sort((a, b) {
        final ad = _parseThreadMessageDate(a);
        final bd = _parseThreadMessageDate(b);
        final byDate = ad.compareTo(bd);
        if (byDate != 0) return byDate;
        return a.id.compareTo(b.id);
      });
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send message. Please try again.')),
        );
      }
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

    final rows = [...detail.messages]
      ..sort((a, b) {
        final ad = _parseThreadMessageDate(a);
        final bd = _parseThreadMessageDate(b);
        final byDate = ad.compareTo(bd);
        if (byDate != 0) return byDate;
        return a.id.compareTo(b.id);
      });
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

  Future<void> _pickPhoto(MessageThreadDetail detail) async {
    if (_sending || _recording || !detail.canSend) return;
    final shot = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (!mounted || shot == null || shot.path.trim().isEmpty) return;
    await _previewPickedMedia(detail, <String>[shot.path]);
  }

  Future<void> _recordVideo(MessageThreadDetail detail) async {
    if (_sending || _recording || !detail.canSend) return;
    final shot = await _imagePicker.pickVideo(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxDuration: const Duration(minutes: 2),
    );
    if (!mounted || shot == null || shot.path.trim().isEmpty) return;
    await _previewPickedMedia(detail, <String>[shot.path]);
  }

  Future<void> _pickGalleryMedia(MessageThreadDetail detail) async {
    if (_sending || _recording || !detail.canSend) return;
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );
    if (!mounted || picked == null || picked.files.isEmpty) return;
    final paths = picked.files
        .map((e) => e.path ?? '')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (paths.isEmpty) return;
    await _previewPickedMedia(detail, paths);
  }

  Future<void> _previewPickedMedia(
    MessageThreadDetail detail,
    List<String> initialPaths,
  ) async {
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
      final mime =
          lookupMimeType(path) ??
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
      _recordElapsed = Duration.zero;
    });
  }



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
        final f = File(path);
        if (!await f.exists()) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Voice recording file was not created. Please try again.',
              ),
            ),
          );
          setState(() {
            _voiceLocked = false;
            _voicePaused = false;
            _voiceCancelled = false;
            _holdDx = 0;
            _holdDy = 0;
            _recordingPath = null;
            _recordElapsed = Duration.zero;
          });
          return;
        }

        await _sendMediaFile(
          detail,
          path,
          kind: 'VOICE',
          fileName: path.split('/').last,
          mimeType: lookupMimeType(path) ?? 'audio/mp4',
        );

        try {
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
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Microphone access needed'),
          content: const Text(
            'Please allow microphone access in Settings → ClassMate to send voice notes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await launchUrl(Uri.parse('app-settings:'));
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
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

    _recordingPath = path;
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
    await _showMessageInfo(row);
  }

  String _avatarText(MessageThreadDetail detail) {
    String normalize(String value) => value.trim().replaceAll(',', '');

    final title = normalize(detail.title);
    if (title.isNotEmpty) {
      final parts = title
          .split(RegExp(r'\s+'))
          .map(normalize)
          .where((e) => e.isNotEmpty)
          .toList();

      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      if (parts.length == 1) {
        final word = parts.first;
        return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
      }
    }

    final others = detail.participants
        .where((p) {
          final normalized = normalize(p.displayName).toLowerCase();
          return normalized.isNotEmpty && normalized != 'person';
        })
        .toList();

    if (others.isNotEmpty) {
      final name = normalize(others.first.displayName);
      final parts = name
          .split(RegExp(r'\s+'))
          .where((e) => e.isNotEmpty)
          .toList();

      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      if (parts.length == 1) {
        final word = parts.first;
        return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
      }
    }

    return detail.isGroup ? 'G' : '?';
  }

  Future<void> _approveIncomingRequest() async {
    await ref
        .read(messagesRepositoryProvider)
        .approveRequest(threadId: widget.threadId);
    ref.invalidate(messageThreadProvider(widget.threadId));
    ref.invalidate(messagesInboxProvider);
  }

  Future<void> _blockIncomingRequest() async {
    await ref
        .read(messagesRepositoryProvider)
        .blockRequest(threadId: widget.threadId);
    ref.invalidate(messageThreadProvider(widget.threadId));
    ref.invalidate(messagesInboxProvider);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _incomingRequestBanner(MessageThreadDetail detail) {
    final title = detail.title.trim().isEmpty
        ? 'New request'
        : detail.title.trim();

    final subtitle = detail.subtitle.trim().isNotEmpty
        ? detail.subtitle.trim()
        : (detail.isGroup
              ? 'Wants you to join this group'
              : 'Wants to start chatting');

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.24),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 28, child: Text(_avatarText(detail))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _approveIncomingRequest,
                    child: Text(AppLocalizations.of(context)!.messagesApproveAction),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _blockIncomingRequest,
                    child: Text(
                      detail.isGroup
                          ? AppLocalizations.of(context)!.classroomDetailLeaveAction
                          : AppLocalizations.of(context)!.messagesBlockAction,
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

  Widget _senderAvatar(String senderName) {
    final colors = <Color>[
      const Color(0xFF9CCC65), const Color(0xFF4FC3F7), const Color(0xFFFFB74D),
      const Color(0xFFBA68C8), const Color(0xFFFF8A65), const Color(0xFF4DB6AC),
      const Color(0xFFA1887F), const Color(0xFF7986CB),
    ];
    final seed = senderName.trim().toLowerCase().runes.fold<int>(0, (a, b) => a + b);
    final bg = colors[seed % colors.length];
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final parts = senderName.trim().split(RegExp(r'\s+')).where((e) => e.trim().isNotEmpty).toList();
    final initials = parts.isEmpty
        ? '?'
        : parts.length == 1
            ? (parts.first.length >= 2 ? parts.first.substring(0, 2).toUpperCase() : parts.first.toUpperCase())
            : (parts.first[0] + parts.last[0]).toUpperCase();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  Widget _pendingBanner(BuildContext context, MessageThreadDetail detail) {
    if (detail.requestState == ChatRequestState.pendingIncoming) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final title = detail.requestState == ChatRequestState.pendingOutgoing
        ? 'Request sent'
        : (detail.requestState == ChatRequestState.blocked
              ? 'Messaging unavailable'
              : 'Messaging unavailable');

    final text = detail.requestState == ChatRequestState.pendingOutgoing
        ? (detail.isGroup
              ? 'Waiting for approval before you can join this group.'
              : 'Waiting for approval before you can chat here.')
        : (detail.requestState == ChatRequestState.blocked
              ? 'You blocked this chat. Unblock from the blocked people page to chat again.'
              : 'You cannot send messages in this chat right now.');

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.20),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
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

    final threadInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    if (threadInsetsBottom != _lastThreadInsetsBottom) {
      _lastThreadInsetsBottom = threadInsetsBottom;
      if (threadInsetsBottom > 0 && _threadNearBottom(220)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _scrollToBottom(jump: true);
        });
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ChatScrollToBottomFab(
        heroTag: 'dm_thread_scroll_to_bottom_${widget.threadId}',
        show: _showScrollToBottom,
        hasUnreadBelow: _newMessagesBelow,
        bottomInset: MediaQuery.of(context).viewInsets.bottom,
        onPressed: () {
          if (!mounted) return;
          setState(() {
            _newMessagesBelow = false;
            _showScrollToBottom = false;
          });
          _scrollToBottom();
        },
      ),
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
                    .markThreadRead(threadId: widget.threadId)
                    .catchError((_) {});
                if (!mounted) return;
              } catch (_) {}
              ref.invalidate(messagesInboxProvider);
            });

            final rows = [...detail.messages]
              ..sort((a, b) {
                final ad = _parseThreadMessageDate(a);
                final bd = _parseThreadMessageDate(b);
                final byDate = ad.compareTo(bd);
                if (byDate != 0) return byDate;
                return a.id.compareTo(b.id);
              });
            _lastRows = rows;
            _onThreadRowsRendered(rows);

            return Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  leading: _isForwardSelectionMode
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _exitForwardSelectionMode,
                        )
                      : null,
                  title: _isForwardSelectionMode
                      ? Text('Forward (${_forwardSelectedMessageIds.length})')
                      : Row(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.onSurfaceVariant,
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
                  actions: _isForwardSelectionMode
                      ? [
                          IconButton(
                            icon: const Icon(Icons.forward_rounded),
                            tooltip: _forwardSelectedMessageIds.isEmpty
                                ? 'Select messages to forward'
                                : 'Forward selected messages',
                            onPressed: _forwardSelectedMessageIds.isEmpty
                                ? null
                                : _forwardSelectedMessages,
                          ),
                        ]
                      : [
                          if (!detail.isGroup)
                            IconButton(
                              tooltip: 'Block person',
                              onPressed: _blockDirectThread,
                              icon: const Icon(Icons.block_rounded),
                            ),
                          if (detail.isGroup)
                            IconButton(
                              tooltip: 'Leave group',
                              onPressed: _leaveGroup,
                              icon: const Icon(Icons.logout_rounded),
                            ),
                        ],
                ),
                if (detail.requestState == ChatRequestState.pendingIncoming)
                  _incomingRequestBanner(detail),
                if (!detail.canSend ||
                    detail.requestState == ChatRequestState.pendingOutgoing)
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
                                      : (_kindInfoLabel(AppLocalizations.of(context)!, pinned)))
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
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 24),
                    itemCount: rows.length + (_peerTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Typing bubble as the last item in the list
                      if (index == rows.length) {
                        final peerRows = rows.where((r) => !r.isMine);
                        final peerName = peerRows.isEmpty ? null : peerRows.last.senderName;
                        return Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 36,
                                child: _senderAvatar(peerName ?? ''),
                              ),
                              const SizedBox(width: 6),
                              TypingBubble(senderName: peerName),
                            ],
                          ),
                        );
                      }
                      final row = rows[index];
                      final showDaySeparator =
                          index == 0 || !_sameMessageDay(rows[index - 1], row);
                      final startsGroup = _startsGroup(rows, index);
                      final endsGroup = _endsGroup(rows, index);
                      final isSystemStamp = row.text.trim().startsWith(
                        '[SYSTEM]',
                      );
                      if (isSystemStamp) {
                        final label = row.text
                            .trim()
                            .replaceFirst('[SYSTEM]', '')
                            .trim();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: _buildDaySeparatorChip(
                              context,
                              label.isEmpty ? 'System' : label,
                            ),
                          ),
                        );
                      }

                      final swipeDx = _swipeDxByMessage[row.id] ?? 0.0;
                      final isHighlighted = _highlightedMessageId == row.id;
                      final isSelected = _forwardSelectedMessageIds.contains(row.id);

                      return KeyedSubtree(
                        key: _messageKeyFor(row.id),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showDaySeparator)
                              _buildDaySeparatorChip(
                                context,
                                _messageDaySeparatorLabel(AppLocalizations.of(context)!, row),
                              ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: startsGroup ? 8 : 2,
                                bottom: endsGroup ? 4 : 2,
                              ),
                              child: Row(
                                mainAxisAlignment: row.isMine
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Reply arrow — fixed to far left, fades in as bubble slides right
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
                                  if (!row.isMine) ...[
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
                                      onTap: _isForwardSelectionMode
                                          ? () => _toggleForwardMessageSelection(row.id)
                                          : _deleteSelection.isNotEmpty
                                          ? () {
                                              setState(() {
                                                if (_deleteSelection.contains(row.id)) {
                                                  _deleteSelection.remove(row.id);
                                                } else {
                                                  _deleteSelection.add(row.id);
                                                }
                                              });
                                            }
                                          : null,
                                      onHorizontalDragUpdate: (_isForwardSelectionMode || _deleteSelection.isNotEmpty)
                                          ? null
                                          : (details) {
                                              final current =
                                                  _swipeDxByMessage[row.id] ?? 0.0;
                                              final next = (current + details.delta.dx)
                                                  .clamp(-84.0, 84.0);
                                              if ((_swipeDxByMessage[row.id] ?? 0.0) !=
                                                  next) {
                                                setState(() {
                                                  _swipeDxByMessage[row.id] = next;
                                                });
                                              }
                                            },
                                      onHorizontalDragEnd: (_isForwardSelectionMode || _deleteSelection.isNotEmpty)
                                          ? null
                                          : (_) async {
                                              final current =
                                                  _swipeDxByMessage[row.id] ?? 0.0;

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
                                        if (_isForwardSelectionMode) {
                                          _toggleForwardMessageSelection(row.id);
                                          return;
                                        }
                                        if (_deleteSelection.isNotEmpty) {
                                          setState(() {
                                            if (_deleteSelection.contains(row.id)) {
                                              _deleteSelection.remove(row.id);
                                            } else {
                                              _deleteSelection.add(row.id);
                                            }
                                          });
                                          return;
                                        }
                                        await _openBubbleMenu(
                                          row,
                                          canPin: detail.isGroup || row.isMine,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 160),
                                        curve: Curves.easeOutCubic,
                                        transform: Matrix4.translationValues(
                                          swipeDx,
                                          0,
                                          0,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isHighlighted ? 4 : 0,
                                          vertical: isHighlighted ? 2 : 0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _deleteSelection.contains(row.id)
                                              ? Theme.of(context)
                                                    .colorScheme
                                                .error
                                                .withValues(alpha: 0.42)
                                              : isSelected
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                .withValues(alpha: 0.42)
                                              : isHighlighted
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                .withValues(alpha: 0.48)
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: _deleteSelection.contains(row.id)
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .error
                                              .withValues(alpha: 0.70)
                                                : isSelected
                                                    ? Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                  .withValues(alpha: 0.70)
                                                    : Colors.transparent,
                                            width: 1.7,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: row.isMine
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            if (row.deleteState.toUpperCase() !=
                                                'DELETED_FOR_ME')
                                              ChatMessageBubble(
                                                contextForNavigation: context,
                                                rawText: row.text,
                                                mediaUrl: row.mediaUrl ?? '',
                                                isMine: row.isMine,
                                                showName:
                                                    startsGroup &&
                                                    !row.isMine,
                                                senderLabel: row.senderName,
                                                timeLabel: row.timeLabel,
                                                edited: row.edited,
                                                reaction: row.reaction,
                                                reactions: row.reactions,
                                                onReactionTap:
                                                    (row.reaction ?? '')
                                                        .trim()
                                                        .isEmpty
                                                    ? null
                                                    : () =>
                                                          _openReactionDetails(row),
                                                forwarded: row.forwarded,
                                                delivered: row.delivered,
                                                seen: row.seen,
                                                deleteState: row.deleteState,
                                                voiceDurationSeconds:
                                                    row.voiceDurationSeconds,
                                                voiceUnread:
                                                    !row.isMine &&
                                                    row.kind.toUpperCase() ==
                                                        'VOICE' &&
                                                    !row.voicePlayed,
                                                onVoicePlayed:
                                                    row.kind.toUpperCase() ==
                                                        'VOICE'
                                                    ? () => _markVoicePlayed(row)
                                                    : null,
                                                replySender:
                                                    row.replyPreview?.senderName,
                                                replySnippet:
                                                    row.replyPreview?.text,
                                                onReplyTap:
                                                    row.replyToMessageId == null
                                                    ? null
                                                    : () => _jumpToMessage(
                                                        row.replyToMessageId!,
                                                      ),
                                                mediaMimeType: row.mediaMimeType,
                                                messageKind: row.kind,
                                                pinned:
                                                    row.isPinned ||
                                                    _pinnedMessageIds.contains(
                                                      row.id,
                                                    ),
                                                maxWidth: 280,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ), // Flexible
                                  if (row.isMine) const SizedBox(width: 6),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (_deleteSelection.isNotEmpty)
                  SafeArea(
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
                                        title: Text(AppLocalizations.of(context)!.messagesThreadDeleteForMe),
                                        onTap: () => Navigator.of(context).pop('me'),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.delete_forever_rounded),
                                        title: Text(AppLocalizations.of(context)!.messagesThreadDeleteForEveryone),
                                        subtitle: Text(AppLocalizations.of(context)!.messagesThreadDeleteForEveryoneSubtitle),
                                        onTap: () => Navigator.of(context).pop('everyone'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              if (!mounted || choice == null) return;
                              final selectedRows = _lastRows
                                  .where((r) => ids.contains(r.id))
                                  .toList(growable: false);
                              if (choice == 'everyone') {
                                for (final r in selectedRows) {
                                  await _deleteForEveryone(r);
                                }
                              } else {
                                for (final r in selectedRows) {
                                  await _deleteForMe(r);
                                }
                              }
                              if (!mounted) return;
                              setState(() => _deleteSelection.clear());
                            },
                            icon: const Icon(Icons.delete_rounded),
                            label: Text(AppLocalizations.of(context)!.classroomDetailDeleteCount(_deleteSelection.length)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.classroomDetailSelectedCount(_deleteSelection.length),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: AppLocalizations.of(context)!.classroomDetailSelectAllTooltip,
                            onPressed: () {
                              setState(() {
                                _deleteSelection.addAll(
                                  _lastRows
                                      .where((r) =>
                                          r.deleteState.toUpperCase() !=
                                              'DELETED_FOR_EVERYONE' &&
                                          r.deleteState.toUpperCase() !=
                                              'DELETED_FOR_ME')
                                      .map((r) => r.id),
                                );
                              });
                            },
                            icon: const Icon(Icons.select_all_rounded),
                          ),
                          IconButton(
                            tooltip: AppLocalizations.of(context)!.classroomDetailCancelTooltip,
                            onPressed: () => setState(() => _deleteSelection.clear()),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_deleteSelection.isEmpty)
                Builder(builder: (ctx) {
                  final isDark = Theme.of(ctx).brightness == Brightness.dark;
                  return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                  child: NativeGlassView(
                    borderRadius: 28,
                    style: NativeGlassStyle.ultraThin,
                    fallbackColor: isDark
                        ? Colors.black.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.36),
                    child: ChatComposer(
                  controller: _controller,
                  replyingTo: _replyIndex == null
                      ? null
                      : (
                          senderName: rows[_replyIndex!].isMine
                          ? AppLocalizations.of(context)!.tutorYou
                              : rows[_replyIndex!].senderName,
                          text: replyPreviewText(rows[_replyIndex!].text),
                        ),
                  onCancelReply: () {
                    setState(() => _replyIndex = null);
                  },
                  onTapReplyPreview: _replyIndex == null
                      ? null
                      : () => _jumpToMessage(rows[_replyIndex!].id),
                  onSend: _isForwardSelectionMode ? () {} : () => _send(detail),
                    onCamera: _isForwardSelectionMode ? () {} : () => _pickPhoto(detail),
                    onAttach: _isForwardSelectionMode ? () {} : () => _pickFiles(detail),
                    onVideo: _isForwardSelectionMode ? () {} : () => _recordVideo(detail),
                    onGallery:
                      _isForwardSelectionMode ? () {} : () => _pickGalleryMedia(detail),
                  onMic: _isForwardSelectionMode
                      ? () {}
                      : () async {
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
                  onMicHoldStart:
                      _isForwardSelectionMode ? (_) {} : (d) => _micHoldStart(detail, d),
                  onMicHoldMove: _isForwardSelectionMode ? (_) {} : _micHoldMove,
                  onMicHoldEnd:
                      _isForwardSelectionMode ? (_) {} : (d) => _micHoldEnd(detail, d),
                  onMicHoldCancel: _isForwardSelectionMode ? () {} : _micHoldCancel,
                  onActiveHoldMove: _isForwardSelectionMode ? (_) {} : _updateActiveHold,
                  onActiveHoldRelease: _isForwardSelectionMode
                      ? () {}
                      : () async => _finishActiveHold(detail),
                  onActiveHoldCancel:
                      _isForwardSelectionMode ? () {} : _micHoldCancel,
                  activeHoldDx: _holdDx,
                  activeHoldDy: _holdDy,
                  onTrashRecording: _isForwardSelectionMode ? () {} : _cancelVoiceDraft,
                  onPauseRecording: _isForwardSelectionMode ? () {} : _pauseVoiceRecord,
                  onResumeRecording: _isForwardSelectionMode ? () {} : _resumeVoiceRecord,
                  enabled: !_isForwardSelectionMode && detail.canSend && !_sending,
                  isRecording: _recording,
                  isVoiceLocked: _voiceLocked,
                  isVoicePaused: _voicePaused,
                  recordingElapsed: _recordElapsed,
                  hintText: detail.canSend
                      ? (_sending
                        ? AppLocalizations.of(context)!.messagesThreadSending
                        : AppLocalizations.of(context)!.chatComposerDefaultHint)
                      : AppLocalizations.of(context)!.messagesThreadWaitingForApproval,
                  forceMicOnlyTap: false,
                    ),
                  ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
