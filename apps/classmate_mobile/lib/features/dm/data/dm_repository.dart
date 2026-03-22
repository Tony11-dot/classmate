import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../../../core/http/cm_api.dart';
import '../domain/dm_models.dart';

const _devStudentToken = 'dev-token-student@classmate.local';

final dmRepositoryProvider = Provider<DmRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();

  return DmRepository(
    baseUrl: Env.apiBaseUrl,
    token: token.isEmpty ? _devStudentToken : token,
  );
});

class DmRepository {
  const DmRepository({required this.baseUrl, required this.token});

  final String baseUrl;
  final String token;

  CMApi get _api => CMApi(token: token);

  Uri _uri(String path) {
    final b = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$b$path');
  }

  Map<String, String> _headers() {
    final trimmed = token.trim();
    final isJwtish = trimmed.split('.').length >= 3;
    final isDevToken = trimmed.startsWith('dev-token-');
    final hasToken = trimmed.isNotEmpty && (isJwtish || isDevToken);

    return <String, String>{
      if (hasToken) 'Authorization': 'Bearer $trimmed',
      if (!hasToken) ...<String, String>{
        'x-dev-role': 'STUDENT',
        'x-dev-user-id': 'dev-student',
        'x-dev-grade': '10',
        'x-dev-school-id': 'test-school',
      },
    };
  }

  List<Map<String, dynamic>> _asMapList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList(growable: false);
    }

    if (raw is Map && raw['items'] is List) {
      return (raw['items'] as List)
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList(growable: false);
    }

    return const <Map<String, dynamic>>[];
  }

  String _initials(String raw, {String fallback = 'DM'}) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return fallback;
    final parts = cleaned.split(' ').where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return fallback;
    return parts.take(2).map((e) => e.trim()[0]).join().toUpperCase();
  }

  DmRequestState _requestStateFromRaw(String stateRaw) {
    switch (stateRaw.toUpperCase()) {
      case 'PENDING_INCOMING':
        return DmRequestState.pendingIncoming;
      case 'PENDING_OUTGOING':
        return DmRequestState.pendingOutgoing;
      case 'BLOCKED':
        return DmRequestState.blocked;
      case 'ACCEPTED':
        return DmRequestState.accepted;
      default:
        return DmRequestState.none;
    }
  }

  Future<List<DmThread>> listThreads() async {
    final rows = _asMapList(await _api.getJson('/dm/threads'));

    return rows
        .map((m) {
          final stateRaw = (m['requestState'] ?? m['state'] ?? 'accepted')
              .toString()
              .trim();
          final title = (m['title'] ?? '').toString().trim();
          final subtitle = (m['subtitle'] ?? '').toString().trim();
          final avatarTextRaw = (m['avatarText'] ?? '').toString().trim();

          return DmThread(
            id: (m['id'] ?? '').toString(),
            type: m['isGroup'] == true
                ? DmThreadType.group
                : DmThreadType.direct,
            title: title,
            subtitle: subtitle,
            avatarText: avatarTextRaw.isNotEmpty
                ? avatarTextRaw
                : _initials(title, fallback: 'DM'),
            avatarUrl:
                ((m['avatarUrl'] ??
                        m['groupAvatarUrl'] ??
                        m['photoUrl'] ??
                        m['profileImageUrl'] ??
                        '')
                    .toString()
                    .trim()
                    .isEmpty)
                ? null
                : (m['avatarUrl'] ??
                          m['groupAvatarUrl'] ??
                          m['photoUrl'] ??
                          m['profileImageUrl'] ??
                          '')
                      .toString()
                      .trim(),
            requestState: _requestStateFromRaw(stateRaw),
            isGroup: m['isGroup'] == true,
            isBlocked: m['isBlocked'] == true,
            unreadCount: int.tryParse('${m['unreadCount'] ?? 0}') ?? 0,
            updatedAt:
                DateTime.tryParse('${m['updatedAt'] ?? ''}') ?? DateTime.now(),
            participants: const <DmUserLite>[],
          );
        })
        .toList(growable: false);
  }

  Future<List<DmUserLite>> listCandidateUsers() async {
    try {
      final rows = _asMapList(await _api.getJson('/dm/users'));
      final mapped = rows
          .map((m) {
            final fullName = (m['fullName'] ?? m['name'] ?? m['title'] ?? '')
                .toString()
                .trim();
            final userId = (m['userId'] ?? m['id'] ?? '').toString().trim();
            final avatarUrl = (m['avatarUrl'] ?? m['photoUrl'])
                ?.toString()
                .trim();
            return DmUserLite(
              userId: userId,
              fullName: fullName.isEmpty ? 'Student' : fullName,
              avatarText: _initials(fullName, fallback: 'ST'),
              avatarUrl: (avatarUrl?.isNotEmpty == true) ? avatarUrl : null,
            );
          })
          .where((u) => u.userId.isNotEmpty)
          .toList(growable: false);

      if (mapped.isNotEmpty) return mapped;
    } catch (_) {}

    const fallback = <DmUserLite>[
      DmUserLite(userId: 'u-1', fullName: 'Ahmad K.', avatarText: 'AK'),
      DmUserLite(userId: 'u-2', fullName: 'Maya R.', avatarText: 'MR'),
      DmUserLite(userId: 'u-3', fullName: 'Lina T.', avatarText: 'LT'),
      DmUserLite(userId: 'u-4', fullName: 'Yousef H.', avatarText: 'YH'),
      DmUserLite(userId: 'u-5', fullName: 'Sama A.', avatarText: 'SA'),
      DmUserLite(userId: 'u-6', fullName: 'Raneen M.', avatarText: 'RM'),
      DmUserLite(userId: 'u-7', fullName: 'Tariq N.', avatarText: 'TN'),
      DmUserLite(userId: 'u-8', fullName: 'Jana S.', avatarText: 'JS'),
    ];
    return fallback;
  }

  Future<List<DmMessage>> listMessages(String threadId) async {
    final rows = _asMapList(
      await _api.getJson('/dm/threads/$threadId/messages'),
    );

    return rows
        .map((m) {
          final kind = switch ((m['kind'] ?? 'TEXT')
              .toString()
              .trim()
              .toUpperCase()) {
            'IMAGE' => DmMessageKind.image,
            'VOICE' => DmMessageKind.voice,
            'FILE' => DmMessageKind.system,
            'VIDEO' => DmMessageKind.system,
            'SYSTEM' => DmMessageKind.system,
            _ => DmMessageKind.text,
          };

          final mediaMode = switch ((m['mediaMode'] ?? '')
              .toString()
              .trim()
              .toUpperCase()) {
            'ONCE' => DmMediaMode.once,
            'REPLAY' => DmMediaMode.replay,
            'KEEP' => DmMediaMode.keep,
            _ => null,
          };

          return DmMessage(
            id: (m['id'] ?? '').toString(),
            senderId: (m['senderId'] ?? '').toString(),
            senderName:
                (m['senderName'] ??
                        m['fullName'] ??
                        (m['mine'] == true ? 'You' : 'Student'))
                    .toString(),
            isMine: m['mine'] == true,
            kind: kind,
            text: (m['text'] ?? '').toString(),
            mediaUrl: m['mediaUrl']?.toString(),
            mediaMode: mediaMode,
            voiceDuration: m['voiceDuration'] is num
                ? Duration(seconds: (m['voiceDuration'] as num).toInt())
                : null,
            createdAt:
                DateTime.tryParse('${m['createdAt'] ?? ''}') ?? DateTime.now(),
            reactions: m['reactions'] is List
                ? (m['reactions'] as List)
                      .map((x) => '$x')
                      .toList(growable: false)
                : const <String>[],
          );
        })
        .toList(growable: false);
  }

  Future<List<DmUserLite>> listUserCandidates() async {
    dynamic raw;
    try {
      raw = await _api.getJson('/dm/users');
    } catch (_) {
      try {
        raw = await _api.getJson('/dm/candidates');
      } catch (_) {
        return const <DmUserLite>[
          DmUserLite(userId: 'u-1', fullName: 'Ahmad K.', avatarText: 'AK'),
          DmUserLite(userId: 'u-2', fullName: 'Maya R.', avatarText: 'MR'),
          DmUserLite(userId: 'u-3', fullName: 'Lina T.', avatarText: 'LT'),
          DmUserLite(userId: 'u-4', fullName: 'Yousef H.', avatarText: 'YH'),
          DmUserLite(userId: 'u-5', fullName: 'Sama A.', avatarText: 'SA'),
          DmUserLite(userId: 'u-6', fullName: 'Raneen M.', avatarText: 'RM'),
          DmUserLite(userId: 'u-7', fullName: 'Tariq N.', avatarText: 'TN'),
          DmUserLite(userId: 'u-8', fullName: 'Jana S.', avatarText: 'JS'),
        ];
      }
    }

    final rows = _asMapList(raw);
    final users = rows
        .map((m) {
          final fullName = (m['fullName'] ?? m['name'] ?? '').toString().trim();
          final avatarTextRaw = (m['avatarText'] ?? '').toString().trim();
          final avatarText = avatarTextRaw.isNotEmpty
              ? avatarTextRaw
              : (fullName.isNotEmpty
                    ? fullName
                          .split(' ')
                          .where((e) => e.trim().isNotEmpty)
                          .take(2)
                          .map((e) => e.trim()[0])
                          .join()
                          .toUpperCase()
                    : 'ST');
          final avatarUrl =
              (m['avatarUrl'] ??
                      m['photoUrl'] ??
                      m['groupAvatarUrl'] ??
                      m['profileImageUrl'] ??
                      '')
                  .toString()
                  .trim();

          return DmUserLite(
            userId: (m['userId'] ?? m['id'] ?? '').toString(),
            fullName: fullName.isEmpty ? 'Student' : fullName,
            avatarText: avatarText,
            avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
          );
        })
        .where((u) => u.userId.trim().isNotEmpty)
        .toList(growable: false);

    if (users.isNotEmpty) return users;

    return const <DmUserLite>[
      DmUserLite(userId: 'u-1', fullName: 'Ahmad K.', avatarText: 'AK'),
      DmUserLite(userId: 'u-2', fullName: 'Maya R.', avatarText: 'MR'),
      DmUserLite(userId: 'u-3', fullName: 'Lina T.', avatarText: 'LT'),
      DmUserLite(userId: 'u-4', fullName: 'Yousef H.', avatarText: 'YH'),
      DmUserLite(userId: 'u-5', fullName: 'Sama A.', avatarText: 'SA'),
      DmUserLite(userId: 'u-6', fullName: 'Raneen M.', avatarText: 'RM'),
      DmUserLite(userId: 'u-7', fullName: 'Tariq N.', avatarText: 'TN'),
      DmUserLite(userId: 'u-8', fullName: 'Jana S.', avatarText: 'JS'),
    ];
  }

  Future<void> acceptRequest(String threadId) async {
    await _api.postJson(
      '/dm/threads/$threadId/request',
      body: const <String, dynamic>{'action': 'accept'},
    );
  }

  Future<void> declineRequest(String threadId) async {
    await _api.postJson(
      '/dm/threads/$threadId/request',
      body: const <String, dynamic>{'action': 'decline'},
    );
  }

  Future<void> blockUser(String threadId) async {
    await _api.postJson(
      '/dm/threads/$threadId/request',
      body: const <String, dynamic>{'action': 'block'},
    );
  }

  Future<void> unblockUser(String threadId) async {
    await _api.postJson(
      '/dm/threads/$threadId/unblock',
      body: const <String, dynamic>{},
    );
  }

  Future<void> sendText(String threadId, String text) async {
    await _api.postJson(
      '/dm/threads/$threadId/messages',
      body: <String, dynamic>{'kind': 'TEXT', 'text': text.trim()},
    );
  }

  Future<Map<String, dynamic>> uploadMedia(String path) async {
    final req = http.MultipartRequest('POST', _uri('/uploads/dm-media'));
    req.headers.addAll(_headers());
    req.files.add(await http.MultipartFile.fromPath('file', path));

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('upload failed (${streamed.statusCode}): $body');
    }

    final decoded = jsonDecode(body);
    return decoded is Map && decoded['file'] is Map
        ? Map<String, dynamic>.from(decoded['file'] as Map)
        : <String, dynamic>{};
  }

  Future<void> sendFile(String threadId, String path, DmMediaMode mode) async {
    final file = await uploadMedia(path);
    final name = path.split('/').last.trim();
    final label = name.isEmpty ? 'file' : name;
    final mimeType = (file['mimeType']?.toString().trim().isNotEmpty == true)
        ? file['mimeType'].toString().trim()
        : 'application/octet-stream';
    final lower = mimeType.toLowerCase();
    final kind = lower.startsWith('video/') ? 'VIDEO' : 'FILE';

    await _api.postJson(
      '/dm/threads/$threadId/messages',
      body: <String, dynamic>{
        'kind': kind,
        'mediaUrl': file['url'],
        'mediaMimeType': mimeType,
        'text': kind == 'VIDEO' ? '[VIDEO] $label' : '[FILE] $label',
      },
    );
  }

  Future<void> sendImage(String threadId, String path, DmMediaMode mode) async {
    final file = await uploadMedia(path);

    await _api.postJson(
      '/dm/threads/$threadId/messages',
      body: <String, dynamic>{
        'kind': 'IMAGE',
        'mediaUrl': file['url'],
        'mediaMimeType': file['mimeType'],
        'mediaMode': _mode(mode),
        'text': '',
      },
    );
  }

  Future<void> sendVoice(String threadId, String path, DmMediaMode mode) async {
    final file = await uploadMedia(path);

    await _api.postJson(
      '/dm/threads/$threadId/messages',
      body: <String, dynamic>{
        'kind': 'VOICE',
        'mediaUrl': file['url'],
        'mediaMimeType': file['mimeType'],
        'mediaMode': _mode(mode),
        'text': '',
      },
    );
  }

  Future<void> createGroup({
    required String title,
    required List<String> participantIds,
    String? avatarPath,
  }) async {
    final cleanedTitle = title.trim();
    final cleanedIds = participantIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    if (cleanedIds.isEmpty) {
      throw Exception('At least one participant is required');
    }

    // backend currently rejects avatarUrl/groupAvatarUrl/avatarMediaUrl on /dm/threads
    await _api.postJson(
      '/dm/threads',
      body: <String, dynamic>{
        'title': cleanedTitle.isEmpty ? 'New group' : cleanedTitle,
        'participantIds': cleanedIds,
        'isGroup': true,
      },
    );
  }

  Future<void> recordView(String messageId) async {
    await _api.postJson(
      '/dm/messages/$messageId/view',
      body: const <String, dynamic>{},
    );
  }

  Future<void> react(String messageId, String emoji) async {
    await _api.postJson(
      '/dm/messages/$messageId/react',
      body: <String, dynamic>{'emoji': emoji},
    );
  }

  String _mode(DmMediaMode mode) => switch (mode) {
    DmMediaMode.once => 'ONCE',
    DmMediaMode.replay => 'REPLAY',
    DmMediaMode.keep => 'KEEP',
  };
}
