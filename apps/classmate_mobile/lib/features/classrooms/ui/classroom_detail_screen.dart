// ignore_for_file: unused_element, unused_local_variable, use_build_context_synchronously, annotate_overrides, unnecessary_import
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/media/image_viewer_screen.dart';
import '../../common/media/pdf_viewer_screen.dart';
import '../../chat_core/utils/chat_reply_codec.dart';
import '../../chat_core/ui/chat_message_bubble.dart';
import '../../chat_core/ui/chat_message_actions_sheet.dart';
import '../../../core/auth/auth_session.dart';
import '../providers/classrooms_providers.dart';
import '../providers/classrooms_repo_provider.dart';

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
  String? _draftVoicePath;
  bool _draftVoicePlaying = false;
  double _draftVoiceSpeed = 1.0;
  Duration _draftVoicePosition = Duration.zero;
  Duration _draftVoiceDuration = Duration.zero;
  bool _draftVoiceReady = false;

  bool _sending = false;
  void _handleClassroomScroll() {
    if (!_chatScrollCtl.hasClients) {
      return;
    }
    final pos = _chatScrollCtl.position;
    final distance = pos.maxScrollExtent - pos.pixels;
    _showClassroomScrollToBottom.value = distance > 120;
  }

  void _pinClassroomToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_chatScrollCtl.hasClients) {
        return;
      }
      final target = _chatScrollCtl.position.maxScrollExtent;
      _chatScrollCtl.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  bool _recording = false;
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
  String? _replyToMessageId;
  String? _replyToSender;
  String? _replyToText;

  int _lastChatCount = -1;

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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
      ),
    );

    if (action == null || action.trim().isEmpty) return;

    if (action == 'reply') {
      _replyTo(
        messageId: messageId,
        sender: senderLabel,
        text: editableBodyText(text),
      );
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _classroomComposer(),
      body: SafeArea(
        child: Column(
          children: [
            detail.when(
              loading: () => const _HeaderSkeleton(),
              error: (e, st) => _TopHeader(
                icon: Icons.book_rounded,
                subject: 'Classroom',
                subtitle: widget.courseId,
                onRefresh: _refreshAll,
                onBack: _goBackToClassrooms,
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
                onRefresh: _refreshAll,
                onBack: _goBackToClassrooms,
              ),
            ),
            const SizedBox(height: 0),
            _CenteredTabs(controller: _tabs),
            const SizedBox(height: 2),
            Flexible(
              fit: FlexFit.loose,
              child: TabBarView(
                controller: _tabs,
                children: [
                  _chatTab(chat, people),
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
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          itemCount: raw.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          itemCount: raw.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, index) => itemBuilder(raw[index]),
        );
      },
    );
  }

  Future<void> _pickClassroomFiles() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.any);
    final path = picked?.files.single.path;
    if (path == null || path.trim().isEmpty) return;
    setState(() {
      _draftAttachments.add(<String, String>{
        'path': path,
        'name': path.split('/').last,
        'kind': 'FILE',
      });
    });
  }

  Future<void> _pickClassroomCameraOrUploadImage() async {
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

    setState(() {
      _draftAttachments.add(<String, String>{
        'kind': 'IMAGE',
        'path': path!,
        'name': path.split('/').last,
      });
    });
  }

  Future<void> _startVoiceNote() async => _toggleClassroomMic();
  Future<void> _stopVoiceNoteAndSend() async => _toggleClassroomMic();

  Future<void> _toggleClassroomMic() async {
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
        '${dir.path}/classroom-voice-${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: filePath,
    );

    if (!mounted) {
      return;
    }
    setState(() => _recording = true);
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
      for (final a in List<Map<String, String>>.from(_draftAttachments)) {
        final p = (a['path'] ?? '').trim();
        if (p.isEmpty) continue;
        await repo.sendChatMedia(widget.courseId, p);
      }

      if (_draftAttachments.isNotEmpty) {
        setState(() {
          _draftAttachments.clear();
        });
      }
      final voicePath = (_draftVoicePath ?? '').trim();
      if (voicePath.isNotEmpty) {
        await _draftVoicePlayer.stop();
        await repo.sendChatMedia(widget.courseId, voicePath);
        if (mounted) {
          setState(() {
            _draftVoicePlaying = false;
            _draftVoiceReady = false;
            _draftVoicePosition = Duration.zero;
            _draftVoiceDuration = Duration.zero;
            _draftVoicePath = null;
          });
        }
      }

      if (text.isNotEmpty) {
        _recentOwnMessageTexts.add(composedText.trim());
        await repo.sendChatText(widget.courseId, composedText);
        _chatCtl.clear();
        _clearReply();
      }

      ref.invalidate(
        classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
      );
      _pinClassroomToBottom();
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
        width: 42,
        height: 42,
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
          final width = c.maxWidth <= 0 ? 1.0 : c.maxWidth;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              width: 40,
              height: 40,
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
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 190),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _classroomDraftChip(Map<String, String> a) {
    final path = (a['path'] ?? '').trim();
    final kind = (a['kind'] ?? '').trim().toUpperCase();
    final isImage = kind == 'IMAGE';

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
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
          const SizedBox(width: 6),
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

  Widget _classroomComposer() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                blurRadius: 28,
                offset: const Offset(0, 6),
                color: Colors.black.withValues(alpha: 0.28),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_draftAttachments.isNotEmpty ||
                  (_draftVoicePath ?? '').trim().isNotEmpty)
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
              if (_draftAttachments.isNotEmpty ||
                  (_draftVoicePath ?? '').trim().isNotEmpty)
                const SizedBox(height: 8),
              Row(
                children: [
                  _classroomComposerButton(
                    icon: Icons.camera_alt_rounded,
                    onTap: _sending || _recording
                        ? null
                        : _pickClassroomCameraOrUploadImage,
                  ),
                  const SizedBox(width: 6),
                  _classroomComposerButton(
                    icon: Icons.attach_file_rounded,
                    onTap: _sending || _recording ? null : _pickClassroomFiles,
                  ),
                  const SizedBox(width: 6),
                  _classroomComposerButton(
                    icon: _recording
                        ? Icons.stop_rounded
                        : Icons.mic_none_rounded,
                    onTap: _sending
                        ? null
                        : () async {
                            if (_recording) {
                              await _stopVoiceNoteAndSend();
                            } else {
                              await _startVoiceNote();
                            }
                          },
                    fill: _recording
                        ? const Color(0xFF8E2E2E)
                        : const Color(0xFF1C232B),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    fit: FlexFit.loose,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      constraints: const BoxConstraints(minHeight: 42),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F141A).withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _chatCtl.text.trim().isNotEmpty
                              ? const Color(0xFF0A84FF).withValues(alpha: 0.28)
                              : Colors.white.withValues(alpha: 0.05),
                        ),
                        boxShadow: _chatCtl.text.trim().isNotEmpty
                            ? [
                                BoxShadow(
                                  blurRadius: 20,
                                  spreadRadius: -10,
                                  color: const Color(
                                    0xFF0A84FF,
                                  ).withValues(alpha: 0.34),
                                ),
                              ]
                            : const [],
                      ),
                      child: Center(
                        child: TextField(
                          controller: _chatCtl,
                          minLines: 1,
                          maxLines: 6,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendClassroomChat(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: _chatCtl.text.trim().isNotEmpty
                          ? [
                              BoxShadow(
                                blurRadius: 26,
                                spreadRadius: -8,
                                color: const Color(
                                  0xFF0A84FF,
                                ).withValues(alpha: 0.42),
                              ),
                            ]
                          : const [],
                    ),
                    child: _classroomComposerButton(
                      icon: Icons.send_rounded,
                      onTap: _sending || _recording ? null : _sendClassroomChat,
                      fill: _chatCtl.text.trim().isNotEmpty
                          ? const Color(0xFF0A84FF)
                          : const Color(0xFF143B5C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                      final da =
                          DateTime.tryParse(_pick(a, 'createdAt')) ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      final db =
                          DateTime.tryParse(_pick(b, 'createdAt')) ??
                          DateTime.fromMillisecondsSinceEpoch(0);
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
                _lastChatCount = filtered.length;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom(jump: filtered.length <= 3);
                });
              }

              if (filtered.isEmpty) {
                return const _CenteredState(
                  icon: Icons.forum_outlined,
                  title: 'No messages yet',
                  subtitle: 'Start the classroom conversation.',
                );
              }

              if (filtered.isEmpty) {
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
                          Icons.forum_outlined,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Start the classroom chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ask a question, send a file, or share an update.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.56),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ValueListenableBuilder<bool>(
                valueListenable: _showClassroomScrollToBottom,
                builder: (context, showScroll, child) {
                  return Stack(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          _handleClassroomScroll();
                          return false;
                        },
                        child: ListView.builder(
                          controller: _chatScrollCtl,
                          cacheExtent: 900,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: true,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final previous = index > 0
                                ? filtered[index - 1]
                                : null;

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

                            final bubble = GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onHorizontalDragUpdate: (details) {
                                final next = (swipeDx + details.delta.dx).clamp(
                                  0.0,
                                  84.0,
                                );
                                if ((_swipeDxByMessage[messageId] ?? 0) !=
                                    next) {
                                  setState(() {
                                    _swipeDxByMessage[messageId] = next;
                                  });
                                }
                              },
                              onHorizontalDragEnd: (_) {
                                final current =
                                    _swipeDxByMessage[messageId] ?? 0;
                                if (current >= 44) {
                                  _replyTo(
                                    messageId: messageId,
                                    sender: isMine ? 'You' : senderName,
                                    text: messageText.isEmpty
                                        ? '(empty)'
                                        : messageText,
                                  );
                                }
                                if (_swipeDxByMessage.containsKey(messageId)) {
                                  setState(() {
                                    _swipeDxByMessage.remove(messageId);
                                  });
                                }
                              },
                              onHorizontalDragCancel: () {
                                if (_swipeDxByMessage.containsKey(messageId)) {
                                  setState(() {
                                    _swipeDxByMessage.remove(messageId);
                                  });
                                }
                              },
                              onLongPress: () => _openBubbleMenu(
                                context,
                                messageId: messageId,
                                text: text,
                                mediaUrl: mediaUrl,
                                kind: kind,
                                senderLabel: isMine ? 'You' : senderName,
                                isMine: isMine,
                              ),
                              child: Transform.translate(
                                offset: Offset(swipeDx, 0),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0.96, end: 1),
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, scale, child) =>
                                      Transform.scale(
                                        scale: scale,
                                        child: child,
                                      ),
                                  child: ChatMessageBubble(
                                    contextForNavigation: context,
                                    rawText:
                                        _editedTextByMessage[messageId] ?? text,
                                    mediaUrl: mediaUrl.isEmpty
                                        ? ''
                                        : _absoluteMediaUrl(mediaUrl),
                                    isMine: isMine,
                                    showName: showName,
                                    senderLabel: isMine ? 'You' : senderName,
                                    timeLabel: _friendlyTime(createdRaw),
                                    edited: _editedTextByMessage.containsKey(
                                      messageId,
                                    ),
                                    reaction: reaction,
                                    maxWidth: 380,
                                  ),
                                ),
                              ),
                            );

                            return Padding(
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
                                          ? _InitialsAvatar(name: senderName)
                                          : const SizedBox.shrink(),
                                    ),
                                  if (!isMine) const SizedBox(width: 6),
                                  Flexible(child: bubble),
                                  if (isMine) const SizedBox(width: 6),
                                  if (isMine) const SizedBox(width: 6),
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
                                heroTag: 'classroom-scroll-bottom',
                                backgroundColor: const Color(0xFF0A84FF),
                                foregroundColor: Colors.white,
                                onPressed: _pinClassroomToBottom,
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
        if (_typing && !_sending)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
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
          ),
        if (_replyToMessageId != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyToSender?.trim().isNotEmpty == true
                              ? _replyToSender!.trim()
                              : 'Replying',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          (_replyToText ?? '').trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _clearReply,
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
      ],
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
  });

  final IconData icon;
  final String subject;
  final String subtitle;
  final VoidCallback onRefresh;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              label: const Text('Back'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 14),
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.trim().isEmpty ? 'Classroom' : subject.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.trim().isEmpty ? ' ' : subtitle.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            constraints: const BoxConstraints(maxWidth: 170),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          constraints: const BoxConstraints(maxWidth: 520),
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
    borderRadius: BorderRadius.circular(20),
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
