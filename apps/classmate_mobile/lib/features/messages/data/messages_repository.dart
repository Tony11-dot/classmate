import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env.dart';
import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/domain/chat_thread_type.dart';
import '../domain/message_thread_models.dart';
import '../../chat_core/utils/chat_time.dart';

abstract class MessagesRepository {
  Future<List<MessageThreadSummary>> fetchInbox();

  Future<MessageThreadDetail> fetchThread({required String threadId});

  Future<MessageThreadDetail> fetchRequest({required String threadId});

  Future<List<MessageDirectoryPerson>> fetchSameSchoolPeople();

  Future<MessageThreadDetail> createDirectRequest({
    required String recipientUserId,
    required String firstMessage,
  });

  Future<void> approveRequest({required String threadId});

  Future<void> blockRequest({required String threadId});

  Future<MessageThreadDetail> createGroup({
    required String title,
    required List<String> memberIds,
  });

  Future<void> leaveGroup({required String threadId});
  Future<void> blockThread({required String threadId});
  Future<List<Map<String, dynamic>>> listBlockedPeople();
  Future<void> unblockDirectThread({required String threadId});
  Future<void> blockDirectThread({required String threadId});

  Future<void> sendMessage({
    required String threadId,
    required String text,
    String? replyToMessageId,
    String? kind,
    String? mediaUrl,
    String? mediaMimeType,
  });

  Future<Map<String, dynamic>> uploadDmMedia(
    String filePath, {
    String? fileName,
    String? mimeType,
  });

  Future<void> editMessage({
    required String threadId,
    required String messageId,
    required String text,
  });

  Future<void> togglePin({required String threadId, required String messageId});

  Future<void> deleteMessage({
    required String threadId,
    required String messageId,
    String mode = 'deleteForMe',
  });

  Future<void> forwardMessage({
    required String fromThreadId,
    required String messageId,
    required List<String> targetThreadIds,
  });

  Future<void> reactMessage({
    required String threadId,
    required String messageId,
    String? emoji,
  });

  Future<void> markThreadRead({required String threadId});
}

// NOTE: The group management methods (fetchThreadInfo, addGroupMember, etc.)
// are concrete methods on ApiMessagesRepository, not on the abstract interface,
// since they're only used via cast in _ThreadInfoSheet.

class ApiMessagesRepository implements MessagesRepository {
  ApiMessagesRepository({http.Client? client, String? baseUrl, String? token})
    : _client = client ?? http.Client(),
      _baseUrl =
          (baseUrl ?? Env.apiBaseUrl)
              .replaceAll(RegExp(r'/$'), ''),
      _token = (token ?? '').trim();

  final http.Client _client;
  final String _baseUrl;
  final String _token;

  List<String> get _baseCandidates {
    final fallback = Env.stripApiSuffix(_baseUrl).replaceAll(RegExp(r'/$'), '');
    if (fallback == _baseUrl) return <String>[_baseUrl];
    return <String>[_baseUrl, fallback];
  }

  static const _timeout = Duration(seconds: 15);

  Future<String> _readToken() async {
    if (_token.isNotEmpty && _token != 'SIM_TOKEN') return _token;

    final prefs = await SharedPreferences.getInstance();
    const candidates = <String>[
      'auth_token_v2',
      'auth_token',
      'token',
      'jwt',
      'access_token',
      'accessToken',
      'cm_token',
    ];

    for (final key in candidates) {
      final value = prefs.getString(key)?.trim() ?? '';
      if (value.isNotEmpty && value != 'SIM_TOKEN') return value;
    }

    return '';
  }

  Uri _uriWithBase(String base, String path) {
    final clean = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$clean');
  }

  Uri _uri(String path) {
    return _uriWithBase(_baseUrl, path);
  }

  Future<http.Response> _sendWithFallback(
    Future<http.Response> Function(Uri uri) send,
    String path,
  ) async {
    late http.Response lastResponse;

    for (var index = 0; index < _baseCandidates.length; index++) {
      final uri = _uriWithBase(_baseCandidates[index], path);
      lastResponse = await send(uri).timeout(_timeout);
      if (lastResponse.statusCode != 404 || index == _baseCandidates.length - 1) {
        return lastResponse;
      }
    }

    return lastResponse;
  }

  // Convenience: POST JSON body with base-candidate fallback.
  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    final hdrs = await _headers();
    return _sendWithFallback(
      (uri) async => _client.post(uri, headers: hdrs, body: jsonEncode(body)),
      path,
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = await _readToken();
    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  bool _ok(http.Response response) =>
      response.statusCode >= 200 && response.statusCode < 300;

  Never _fail(String label, http.Response response) {
    throw Exception(
      '$label failed (${response.statusCode}): ${response.body.isEmpty ? 'empty body' : response.body}',
    );
  }

  ChatThreadType _threadType(String raw) {
    switch (raw.trim().toUpperCase()) {
      case 'GROUP':
        return ChatThreadType.group;
      case 'CLASSROOM':
        return ChatThreadType.classroom;
      case 'NOVA':
        return ChatThreadType.nova;
      case 'DIRECT':
      default:
        return ChatThreadType.direct;
    }
  }


  Map<String, List<String>> _parseDmReactions(dynamic raw) {
    if (raw is! Map) return const <String, List<String>>{};
    final out = <String, List<String>>{};
    raw.forEach((key, value) {
      final emoji = key.toString().trim();
      if (emoji.isEmpty) return;
      if (value is List) {
        final users = value
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
        if (users.isNotEmpty) {
          out[emoji] = users;
        }
      }
    });
    return out;
  }

  String _digString(dynamic root, List<String> path) {
    dynamic current = root;
    for (final part in path) {
      if (current is Map) {
        current = current[part];
      } else {
        return '';
      }
    }
    return (current ?? '').toString().trim();
  }

  String _pickDeepFirstNonEmpty(dynamic json, List<List<String>> paths) {
    for (final path in paths) {
      final value = _digString(json, path);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  DateTime _parseServerishDate(String raw) {
    return parseChatTimestamp(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatDmMessageTime(DateTime? dt, String fallback) {
    if (dt == null) return fallback.trim();
    return formatChatTime12(dt);
  }

  String _normalizeInitials(String raw) =>
      raw.replaceAll(',', '').replaceAll(' ', '').trim().toUpperCase();

  ChatRequestState _requestState(String raw) {
    final value = raw.trim();
    final upper = value.toUpperCase();
    switch (upper) {
      case 'PENDING_INCOMING':
      case 'PENDINGINCOMING':
        return ChatRequestState.pendingIncoming;
      case 'PENDING_OUTGOING':
      case 'PENDINGOUTGOING':
        return ChatRequestState.pendingOutgoing;
      case 'APPROVED':
        return ChatRequestState.approved;
      case 'BLOCKED':
        return ChatRequestState.blocked;
      case 'NONE':
      default:
        if (value == 'pendingIncoming') return ChatRequestState.pendingIncoming;
        if (value == 'pendingOutgoing') return ChatRequestState.pendingOutgoing;
        if (value == 'approved') return ChatRequestState.approved;
        if (value == 'blocked') return ChatRequestState.blocked;
        if (value == 'none') return ChatRequestState.none;
        return ChatRequestState.none;
    }
  }

  MessageThreadSummary _summaryFromJson(Map<String, dynamic> json) {
    final rawLastMessageAt = _pickDeepFirstNonEmpty(json, const [
      ['lastMessageCreatedAt'],
      ['lastMessageSentAt'],
      ['lastActivityAt'],
      ['updatedAt'],
      ['createdAt'],
      ['updated_at'],
      ['created_at'],
      ['last_activity_at'],
      ['last_message_created_at'],
      ['last_message_sent_at'],
      ['lastMessage', 'createdAt'],
      ['lastMessage', 'sentAt'],
      ['lastMessage', 'updatedAt'],
      ['lastMessage', 'created_at'],
      ['lastMessage', 'sent_at'],
      ['lastMessage', 'updated_at'],
      ['message', 'createdAt'],
      ['message', 'sentAt'],
      ['message', 'updatedAt'],
      ['message', 'created_at'],
      ['message', 'sent_at'],
      ['message', 'updated_at'],
      ['meta', 'createdAt'],
      ['meta', 'sentAt'],
      ['meta', 'updatedAt'],
      ['meta', 'created_at'],
      ['meta', 'sent_at'],
      ['meta', 'updated_at'],
      ['lastMessageAtRaw'],
      ['lastMessageAt'],
      ['last_message_at'],
    ]);
    final parsedLastMessageAt = parseChatTimestamp(rawLastMessageAt) ??
        parseChatTimestamp((json['lastMessageAt'] ?? '').toString());

    return MessageThreadSummary(
      id: (json['id'] ?? '').toString(),
      type: _threadType((json['type'] ?? '').toString()),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      isGroup: (json['isGroup'] ?? false) == true,
      isUnread: (json['isUnread'] ?? false) == true,
      unreadCount: (json['unreadCount'] ?? 0) is int
          ? (json['unreadCount'] ?? 0) as int
          : int.tryParse((json['unreadCount'] ?? '0').toString()) ?? 0,
      lastMessageAt: formatChatInboxTrailingLabel(
        parsedLastMessageAt,
        fallback: (json['lastMessageAt'] ?? '').toString(),
      ),
      lastMessageAtRaw: rawLastMessageAt,
      requestState: _requestState((json['requestState'] ?? '').toString()),
      initials: _normalizeInitials((json['initials'] ?? '').toString()),
      groupAvatarUrl: (json['groupAvatarUrl'] ?? '').toString().trim().isEmpty
          ? null
          : (json['groupAvatarUrl'] ?? '').toString().trim(),
    );
  }

  MessageParticipant _participantFromJson(Map<String, dynamic> json) {
    return MessageParticipant(
      userId: (json['userId'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      initials: _normalizeInitials((json['initials'] ?? '').toString()),
      isAdmin: (json['isAdmin'] ?? false) == true,
      isBlocked: (json['isBlocked'] ?? false) == true,
    );
  }

  MessageDirectoryPerson _directoryPersonFromJson(Map<String, dynamic> json) {
    final displayName = (json['displayName'] ?? json['name'] ?? '').toString().trim();
    final initials = _normalizeInitials((json['initials'] ?? '').toString());
    return MessageDirectoryPerson(
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
      displayName: displayName.isEmpty ? 'Person' : displayName,
      initials: initials.isNotEmpty
          ? initials
          : displayName
                .split(' ')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .take(2)
                .map((e) => e[0].toUpperCase())
                .join(),
      schoolName: (json['schoolName'] ?? '').toString(),
      gradeLabel: (json['gradeLabel'] ?? '').toString(),
    );
  }

  MessageReplyRef? _replyPreviewFromJson(dynamic value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    return MessageReplyRef(
      id: (json['id'] ?? '').toString(),
      senderName: (json['senderName'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      kind: (json['kind'] ?? 'TEXT').toString(),
      mediaUrl: (json['mediaUrl'] ?? '').toString().trim().isEmpty
          ? null
          : (json['mediaUrl'] ?? '').toString().trim(),
    );
  }

  MessageItem _messageFromJson(Map<String, dynamic> json) {
    // Try every field name and nested object the server might use for the URL.
    String rawMedia = '';
    for (final key in const ['mediaUrl', 'fileUrl', 'url', 'attachmentUrl', 'cdnUrl', 'src']) {
      final v = (json[key] ?? '').toString().trim();
      if (v.isNotEmpty) { rawMedia = v; break; }
    }
    if (rawMedia.isEmpty) {
      for (final nk in const ['media', 'attachment', 'file', 'upload', 'content']) {
        final obj = json[nk];
        if (obj is Map) {
          for (final key in const ['url', 'mediaUrl', 'fileUrl', 'cdnUrl', 'src']) {
            final v = (obj[key] ?? '').toString().trim();
            if (v.isNotEmpty) { rawMedia = v; break; }
          }
          if (rawMedia.isNotEmpty) break;
        }
      }
    }
    final rawReply = (json['replyToMessageId'] ?? '').toString().trim();
    final originalTimeLabel = (json['timeLabel'] ?? '').toString();
    final rawSentAt = _pickDeepFirstNonEmpty(json, const [
      ['sentAtRaw'],
      ['sentAt'],
      ['createdAt'],
      ['updatedAt'],
      ['sent_at'],
      ['created_at'],
      ['updated_at'],
      ['message', 'createdAt'],
      ['message', 'sentAt'],
      ['message', 'updatedAt'],
      ['message', 'sent_at'],
      ['message', 'created_at'],
      ['message', 'updated_at'],
      ['meta', 'createdAt'],
      ['meta', 'sentAt'],
      ['meta', 'updatedAt'],
      ['meta', 'sent_at'],
      ['meta', 'created_at'],
      ['meta', 'updated_at'],
    ]);
    final parsedSentAt =
        parseChatTimestamp(rawSentAt) ?? parseChatTimestamp(originalTimeLabel);

    return MessageItem(
      id: (json['id'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      senderName: (json['senderName'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      timeLabel: _formatDmMessageTime(parsedSentAt, originalTimeLabel),
      sentAtRaw: rawSentAt.isNotEmpty
          ? rawSentAt
          : (parseChatTimestamp(originalTimeLabel) != null ? originalTimeLabel : ''),
      isMine: (json['isMine'] ?? false) == true,
      reaction: (json['reaction'] ?? '').toString().trim().isEmpty
          ? null
          : (json['reaction'] ?? '').toString().trim(),
      reactions: _parseDmReactions(json['reactions']),
      isPinned: (json['isPinned'] ?? false) == true,
      edited: (json['edited'] ?? false) == true,
      forwarded: (json['forwarded'] ?? false) == true,
      deleteState: (json['deleteState'] ?? 'VISIBLE').toString(),
      delivered: (json['delivered'] ?? false) == true,
      seen: (json['seen'] ?? false) == true,
      deliveredAt: (json['deliveredAt'] ?? '').toString(),
      seenAt: (json['seenAt'] ?? '').toString(),
      kind: (json['kind'] ?? 'TEXT').toString(),
      mediaUrl: rawMedia.isEmpty ? null : rawMedia,
      mediaMimeType: (json['mediaMimeType'] ?? '').toString().trim().isEmpty
          ? null
          : (json['mediaMimeType'] ?? '').toString().trim(),
      voiceDurationSeconds: (json['voiceDurationSeconds'] ?? 0) is int
          ? (((json['voiceDurationSeconds'] ?? 0) as int) <= 0
                ? null
                : (json['voiceDurationSeconds'] as int))
          : (() {
              final parsed = int.tryParse(
                (json['voiceDurationSeconds'] ?? '').toString().trim(),
              );
              return (parsed == null || parsed <= 0) ? null : parsed;
            })(),
      voicePlayed: (json['voicePlayed'] ?? false) == true,
      replyToMessageId: rawReply.isEmpty ? null : rawReply,
      replyPreview: _replyPreviewFromJson(json['replyPreview']),
    );
  }

  MessageThreadDetail _detailFromJson(Map<String, dynamic> json) {
    final participantsRaw = (json['participants'] is List)
        ? json['participants'] as List
        : const [];
    final messagesRaw = (json['messages'] is List)
        ? json['messages'] as List
        : const [];

    final messages = messagesRaw
        .whereType<Map>()
        .map((item) => _messageFromJson(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) {
        final ad = _parseServerishDate(a.sentAtRaw);
        final bd = _parseServerishDate(b.sentAtRaw);
        final byDate = ad.compareTo(bd);
        if (byDate != 0) return byDate;
        return a.id.compareTo(b.id);
      });

    return MessageThreadDetail(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      isGroup: (json['isGroup'] ?? false) == true,
      requestState: _requestState((json['requestState'] ?? '').toString()),
      participants: participantsRaw
          .whereType<Map>()
          .map((item) => _participantFromJson(Map<String, dynamic>.from(item)))
          .toList(),
      messages: messages,
      canSend: (json['canSend'] ?? true) == true,
    );
  }

  @override
  Future<List<MessageThreadSummary>> fetchInbox() async {
    final response = await _sendWithFallback(
      (uri) async => _client.get(uri, headers: await _headers()),
      '/messages/inbox',
    );

    if (!_ok(response)) _fail('messages.fetchInbox', response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (body['items'] is List) ? body['items'] as List : const [];
    return items
        .whereType<Map>()
        .map((item) => _summaryFromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<MessageThreadDetail> fetchThread({required String threadId}) async {
    final response = await _sendWithFallback(
      (uri) async => _client.get(uri, headers: await _headers()),
      '/messages/threads/$threadId',
    );

    if (!_ok(response)) _fail('messages.fetchThread', response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _detailFromJson(Map<String, dynamic>.from(body['thread'] as Map));
  }

  @override
  Future<MessageThreadDetail> fetchRequest({required String threadId}) async {
    final response = await _sendWithFallback(
      (uri) async => _client.get(uri, headers: await _headers()),
      '/messages/requests/$threadId',
    );

    if (!_ok(response)) _fail('messages.fetchRequest', response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _detailFromJson(Map<String, dynamic>.from(body['request'] as Map));
  }

  @override
  Future<List<MessageDirectoryPerson>> fetchSameSchoolPeople() async {
    final response = await _sendWithFallback(
      (uri) async => _client.get(uri, headers: await _headers()),
      '/messages/people/same-school',
    );

    if (!_ok(response)) _fail('messages.fetchSameSchoolPeople', response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = (body['items'] as List? ?? const []);
    return raw
        .whereType<Map>()
        .map((item) => _directoryPersonFromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<MessageThreadDetail> createDirectRequest({
    required String recipientUserId,
    required String firstMessage,
  }) async {
    final response = await _sendWithFallback(
      (uri) async => _client.post(
        uri,
        headers: await _headers(),
        body: jsonEncode(<String, dynamic>{
          'recipientUserId': recipientUserId,
          if (firstMessage.trim().isNotEmpty) 'firstMessage': firstMessage.trim(),
        }),
      ),
      '/messages/requests/direct',
    );

    if (!_ok(response)) _fail('messages.createDirectRequest', response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _detailFromJson(Map<String, dynamic>.from(body['thread'] as Map));
  }

  @override
  Future<void> approveRequest({required String threadId}) async {
    final r = await _post('/messages/requests/approve', {'threadId': threadId});
    if (!_ok(r)) _fail('messages.approveRequest', r);
  }

  @override
  Future<void> blockRequest({required String threadId}) async {
    final r = await _post('/messages/requests/block', {'threadId': threadId});
    if (!_ok(r)) _fail('messages.blockRequest', r);
  }

  @override
  Future<MessageThreadDetail> createGroup({
    required String title,
    required List<String> memberIds,
  }) async {
    final r = await _post('/messages/threads/group', {'title': title, 'memberIds': memberIds});
    if (!_ok(r)) _fail('messages.createGroup', r);
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return _detailFromJson(Map<String, dynamic>.from(body['thread'] as Map));
  }

  @override
  Future<void> leaveGroup({required String threadId}) async {
    final r = await _post('/messages/groups/leave', {'threadId': threadId});
    if (!_ok(r)) _fail('messages.leaveGroup', r);
  }

  @override
  Future<void> blockThread({required String threadId}) async {
    final r = await _post('/messages/threads/block', {'threadId': threadId});
    if (!_ok(r)) _fail('messages.blockThread', r);
  }

  @override
  Future<List<Map<String, dynamic>>> listBlockedPeople() async {
    final response = await _sendWithFallback(
      (uri) async => _client.get(uri, headers: await _headers()),
      '/messages/blocked',
    );
    if (!_ok(response)) _fail('messages.listBlockedPeople', response);
    if (response.body.trim().isEmpty) return <Map<String, dynamic>>[];
    final json = jsonDecode(response.body);
    final raw = json is Map ? (json['items'] as List? ?? const []) : const [];
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> unblockDirectThread({required String threadId}) async {
    final r = await _post('/messages/threads/unblock', {'threadId': threadId});
    if (!_ok(r)) _fail('messages.unblockDirectThread', r);
  }

  @override
  Future<void> blockDirectThread({required String threadId}) async {
    final r = await _post('/messages/threads/block', {'threadId': threadId});
    if (!_ok(r)) _fail('messages.blockDirectThread', r);
  }

  @override
  Future<void> sendMessage({
    required String threadId,
    required String text,
    String? replyToMessageId,
    String? kind,
    String? mediaUrl,
    String? mediaMimeType,
  }) async {
    final body = jsonEncode(<String, dynamic>{
      'threadId': threadId,
      'text': text,
      if ((kind ?? '').trim().isNotEmpty) 'kind': kind!.trim(),
      if ((mediaUrl ?? '').trim().isNotEmpty) 'mediaUrl': mediaUrl!.trim(),
      if ((mediaMimeType ?? '').trim().isNotEmpty) 'mediaMimeType': mediaMimeType!.trim(),
      if ((replyToMessageId ?? '').trim().isNotEmpty) 'replyToMessageId': replyToMessageId!.trim(),
    });
    final hdrs = await _headers();
    final response = await _sendWithFallback(
      (uri) async => _client.post(uri, headers: hdrs, body: body),
      '/messages/send',
    );
    if (!_ok(response)) _fail('messages.sendMessage', response);
  }

  @override
  Future<Map<String, dynamic>> uploadDmMedia(
    String filePath, {
    String? fileName,
    String? mimeType,
  }) async {
    final path = filePath.trim();
    if (path.isEmpty) {
      throw ArgumentError('filePath cannot be empty');
    }

    final req = http.MultipartRequest('POST', _uri('/uploads/dm-media'));
    req.headers.addAll(await _headers());

    if ((mimeType ?? '').trim().isNotEmpty) {
      req.fields['mimeType'] = mimeType!.trim();
    }

    final resolvedName = (fileName ?? '').trim().isNotEmpty
        ? fileName!.trim()
        : path.split('/').last;

    req.files.add(
      await http.MultipartFile.fromPath('file', path, filename: resolvedName),
    );

    final streamed = await req.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (!_ok(response)) _fail('messages.uploadDmMedia', response);

    final body = response.body.trim();
    if (body.isEmpty) return <String, dynamic>{'ok': true};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{'ok': true};
  }

  @override
  Future<void> editMessage({
    required String threadId,
    required String messageId,
    required String text,
  }) async {
    final r = await _post('/messages/edit', {'threadId': threadId, 'messageId': messageId, 'text': text});
    if (!_ok(r)) _fail('messages.editMessage', r);
  }

  @override
  Future<void> deleteMessage({
    required String threadId,
    required String messageId,
    String mode = 'deleteForMe',
  }) async {
    final r = await _post('/messages/delete', {'threadId': threadId, 'messageId': messageId, 'mode': mode});
    if (!_ok(r)) _fail('messages.deleteMessage', r);
  }

  @override
  Future<void> forwardMessage({
    required String fromThreadId,
    required String messageId,
    required List<String> targetThreadIds,
  }) async {
    final r = await _post('/messages/forward', {
      'fromThreadId': fromThreadId,
      'messageId': messageId,
      'targetThreadIds': targetThreadIds,
    });
    if (!_ok(r)) _fail('messages.forwardMessage', r);
  }

  @override
  Future<void> togglePin({
    required String threadId,
    required String messageId,
  }) async {
    final r = await _post('/messages/pin/toggle', {'threadId': threadId, 'messageId': messageId});
    if (!_ok(r)) _fail('messages.togglePin', r);
  }

  @override
  Future<void> reactMessage({
    required String threadId,
    required String messageId,
    String? emoji,
  }) async {
    final r = await _post('/messages/react', {
      'threadId': threadId,
      'messageId': messageId,
      if ((emoji ?? '').trim().isNotEmpty) 'emoji': emoji!.trim(),
    });
    if (!_ok(r)) _fail('messages.reactMessage', r);
  }

  @override
  Future<void> markThreadRead({required String threadId}) async {
    final r = await _post('/messages/read', {'threadId': threadId});
    if (!_ok(r)) _fail('messages.markThreadRead', r);
  }

  // ── Group management ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchThreadInfo({required String threadId}) async {
    final response = await _sendWithFallback(
      (uri) async => _client.get(uri, headers: await _headers()),
      '/messages/threads/$threadId/info',
    );
    if (!_ok(response)) _fail('messages.fetchThreadInfo', response);
    final body = jsonDecode(response.body);
    if (body is Map) return Map<String, dynamic>.from(body);
    return <String, dynamic>{};
  }

  Future<void> addGroupMember({required String threadId, String? userId, String? email}) async {
    final r = await _post('/messages/threads/$threadId/members', {
      if (userId != null) 'userId': userId,
      if (email != null) 'email': email,
    });
    if (!_ok(r)) _fail('messages.addGroupMember', r);
  }

  Future<void> removeGroupMember({required String threadId, required String userId}) async {
    final response = await _sendWithFallback(
      (uri) async => _client.delete(uri, headers: await _headers()),
      '/messages/threads/$threadId/members/$userId',
    );
    if (!_ok(response)) _fail('messages.removeGroupMember', response);
  }

  Future<void> updateMemberRole({required String threadId, required String userId, required String role}) async {
    final hdrs = await _headers();
    final response = await _sendWithFallback(
      (uri) async => _client.patch(uri, headers: hdrs, body: jsonEncode({'role': role})),
      '/messages/threads/$threadId/members/$userId/role',
    );
    if (!_ok(response)) _fail('messages.updateMemberRole', response);
  }

  Future<bool> toggleMuteThread({required String threadId}) async {
    final r = await _post('/messages/threads/$threadId/mute', {});
    if (!_ok(r)) _fail('messages.toggleMuteThread', r);
    final body = jsonDecode(r.body);
    return body is Map ? (body['isMuted'] == true) : false;
  }

  Future<void> updateGroupTitle({required String threadId, required String title}) async {
    final hdrs = await _headers();
    final response = await _sendWithFallback(
      (uri) async => _client.patch(uri, headers: hdrs, body: jsonEncode({'title': title})),
      '/messages/threads/$threadId/title',
    );
    if (!_ok(response)) _fail('messages.updateGroupTitle', response);
  }

  Future<void> blockGroupMember({required String threadId, required String userId}) async {
    final r = await _post('/messages/threads/$threadId/members/$userId/block', {});
    if (!_ok(r)) _fail('messages.blockGroupMember', r);
  }

  Future<String> generateGroupInviteCode({required String threadId}) async {
    final r = await _post('/messages/threads/$threadId/invite-code', {});
    if (!_ok(r)) _fail('messages.generateGroupInviteCode', r);
    final body = jsonDecode(r.body);
    return (body is Map ? body['inviteCode'] : null)?.toString() ?? '';
  }

  Future<String?> joinGroupByCode({required String code}) async {
    final r = await _post('/messages/groups/join', {'code': code.trim()});
    if (!_ok(r)) {
      // Parse error message
      try {
        final body = jsonDecode(r.body);
        if (body is Map && body['message'] != null) throw Exception(body['message'].toString());
      } catch (_) {}
      _fail('messages.joinGroupByCode', r);
    }
    final body = jsonDecode(r.body);
    return body is Map ? body['threadId']?.toString() : null;
  }
}
