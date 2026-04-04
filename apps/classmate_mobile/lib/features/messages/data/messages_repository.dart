import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/domain/chat_thread_type.dart';
import '../domain/message_thread_models.dart';
import '../../chat_core/utils/chat_time.dart';

abstract class MessagesRepository {
  Future<List<MessageThreadSummary>> fetchInbox();

  Future<MessageThreadDetail> fetchThread({required String threadId});

  Future<MessageThreadDetail> fetchRequest({required String threadId});

  Future<void> createDirectRequest({
    required String recipientUserId,
    required String firstMessage,
  });

  Future<void> approveRequest({required String threadId});

  Future<void> blockRequest({required String threadId});

  Future<void> createGroup({
    required String title,
    required List<String> memberIds,
  });

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

class ApiMessagesRepository implements MessagesRepository {
  ApiMessagesRepository({http.Client? client, String? baseUrl, String? token})
    : _client = client ?? http.Client(),
      _baseUrl =
          (baseUrl ??
                  const String.fromEnvironment(
                    'CM_API_BASE_URL',
                    defaultValue: 'http://127.0.0.1:3001/api',
                  ))
              .replaceAll(RegExp(r'/$'), ''),
      _token = (token ?? '').trim();

  final http.Client _client;
  final String _baseUrl;
  final String _token;

  static const _timeout = Duration(seconds: 15);
  static const _devStudentToken = 'dev-token-student@classmate.local';

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

    return _devStudentToken;
  }

  Uri _uri(String path) {
    final clean = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$clean');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _readToken();
    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
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


  // ignore: unused_element
  String _pickFirstNonEmpty(dynamic json, List<String> keys) {
    if (json is! Map) return '';
    for (final key in keys) {
      final value = (json[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return '';
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

  ChatRequestState _requestState(String raw) {
    switch (raw.trim().toUpperCase()) {
      case 'PENDING_INCOMING':
        return ChatRequestState.pendingIncoming;
      case 'PENDING_OUTGOING':
        return ChatRequestState.pendingOutgoing;
      case 'APPROVED':
        return ChatRequestState.approved;
      case 'BLOCKED':
        return ChatRequestState.blocked;
      case 'NONE':
      default:
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
      initials: (json['initials'] ?? '').toString(),
      groupAvatarUrl: (json['groupAvatarUrl'] ?? '').toString().trim().isEmpty
          ? null
          : (json['groupAvatarUrl'] ?? '').toString().trim(),
    );
  }

  MessageParticipant _participantFromJson(Map<String, dynamic> json) {
    return MessageParticipant(
      userId: (json['userId'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      initials: (json['initials'] ?? '').toString(),
      isAdmin: (json['isAdmin'] ?? false) == true,
      isBlocked: (json['isBlocked'] ?? false) == true,
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
    final rawMedia = (json['mediaUrl'] ?? '').toString().trim();
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
    final response = await _client
        .get(_uri('/messages/inbox'), headers: await _headers())
        .timeout(_timeout);

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
    final response = await _client
        .get(_uri('/messages/threads/$threadId'), headers: await _headers())
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.fetchThread', response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _detailFromJson(Map<String, dynamic>.from(body['thread'] as Map));
  }

  @override
  Future<MessageThreadDetail> fetchRequest({required String threadId}) async {
    final response = await _client
        .get(_uri('/messages/requests/$threadId'), headers: await _headers())
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.fetchRequest', response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _detailFromJson(Map<String, dynamic>.from(body['request'] as Map));
  }

  @override
  Future<void> createDirectRequest({
    required String recipientUserId,
    required String firstMessage,
  }) async {
    final response = await _client
        .post(
          _uri('/messages/requests/direct'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{
            'recipientUserId': recipientUserId,
            'firstMessage': firstMessage,
          }),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.createDirectRequest', response);
  }

  @override
  Future<void> approveRequest({required String threadId}) async {
    final response = await _client
        .post(
          _uri('/messages/requests/approve'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{'threadId': threadId}),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.approveRequest', response);
  }

  @override
  Future<void> blockRequest({required String threadId}) async {
    final response = await _client
        .post(
          _uri('/messages/requests/block'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{'threadId': threadId}),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.blockRequest', response);
  }

  @override
  Future<void> createGroup({
    required String title,
    required List<String> memberIds,
  }) async {
    final response = await _client
        .post(
          _uri('/messages/threads/group'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{
            'title': title,
            'memberIds': memberIds,
          }),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.createGroup', response);
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
    final response = await _client
        .post(
          _uri('/messages/send'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{
            'threadId': threadId,
            'text': text,
            if ((kind ?? '').trim().isNotEmpty) 'kind': kind!.trim(),
            if ((mediaUrl ?? '').trim().isNotEmpty)
              'mediaUrl': mediaUrl!.trim(),
            if ((mediaMimeType ?? '').trim().isNotEmpty)
              'mediaMimeType': mediaMimeType!.trim(),
            if ((replyToMessageId ?? '').trim().isNotEmpty)
              'replyToMessageId': replyToMessageId!.trim(),
          }),
        )
        .timeout(_timeout);

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
    final response = await _client
        .post(
          _uri('/messages/edit'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{
            'threadId': threadId,
            'messageId': messageId,
            'text': text,
          }),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.editMessage', response);
  }

  @override
  Future<void> deleteMessage({
    required String threadId,
    required String messageId,
    String mode = 'deleteForMe',
  }) async {
    final response = await _client
        .post(
          _uri('/messages/delete'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{
            'threadId': threadId,
            'messageId': messageId,
            'mode': mode,
          }),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.deleteMessage', response);
  }

  @override
  Future<void> forwardMessage({
    required String fromThreadId,
    required String messageId,
    required List<String> targetThreadIds,
  }) async {
    final response = await _client
        .post(
          _uri('/messages/forward'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{
            'fromThreadId': fromThreadId,
            'messageId': messageId,
            'targetThreadIds': targetThreadIds,
          }),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.forwardMessage', response);
  }

  @override
  Future<void> togglePin({
    required String threadId,
    required String messageId,
  }) async {
    final response = await _client
        .post(
          _uri('/messages/pin/toggle'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{
            'threadId': threadId,
            'messageId': messageId,
          }),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.togglePin', response);
  }

  @override
  Future<void> reactMessage({
    required String threadId,
    required String messageId,
    String? emoji,
  }) async {
    final response = await _client
        .post(
          _uri('/messages/react'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{
            'threadId': threadId,
            'messageId': messageId,
            if ((emoji ?? '').trim().isNotEmpty) 'emoji': emoji!.trim(),
          }),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.reactMessage', response);
  }

  @override
  Future<void> markThreadRead({required String threadId}) async {
    final response = await _client
        .post(
          _uri('/messages/read'),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{'threadId': threadId}),
        )
        .timeout(_timeout);

    if (!_ok(response)) _fail('messages.markThreadRead', response);
  }
}
