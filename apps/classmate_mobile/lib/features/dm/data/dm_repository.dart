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

  Future<List<DmThread>> listThreads() async {
    final raw = await _api.getJson('/dm/threads');
    final list = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : const [];

    return list
        .whereType<Map>()
        .map((e) {
          final m = e.map((k, v) => MapEntry(k.toString(), v));
          final stateRaw = '${m['requestState'] ?? 'ACCEPTED'}';
          final state = switch (stateRaw) {
            'PENDING_INCOMING' => DmRequestState.pendingIncoming,
            'PENDING_OUTGOING' => DmRequestState.pendingOutgoing,
            'BLOCKED' => DmRequestState.blocked,
            'ACCEPTED' => DmRequestState.accepted,
            _ => DmRequestState.none,
          };

          return DmThread(
            id: '${m['id'] ?? ''}',
            type: m['isGroup'] == true
                ? DmThreadType.group
                : DmThreadType.direct,
            title: '${m['title'] ?? ''}',
            subtitle: '${m['subtitle'] ?? ''}',
            avatarText: '${m['title'] ?? 'Messages'}'
                .trim()
                .split(' ')
                .take(2)
                .map((x) => x.isEmpty ? '' : x[0])
                .join()
                .toUpperCase(),
            requestState: state,
            isGroup: m['isGroup'] == true,
            isBlocked: m['isBlocked'] == true,
            unreadCount: int.tryParse('${m['unreadCount'] ?? 0}') ?? 0,
            updatedAt:
                DateTime.tryParse('${m['updatedAt'] ?? ''}') ?? DateTime.now(),
            participants: const [],
          );
        })
        .toList(growable: false);
  }

  Future<List<DmMessage>> listMessages(String threadId) async {
    final raw = await _api.getJson('/dm/threads/$threadId/messages');
    final list = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : const [];

    return list
        .whereType<Map>()
        .map((e) {
          final m = e.map((k, v) => MapEntry(k.toString(), v));
          final kind = switch ('${m['kind'] ?? 'TEXT'}') {
            'IMAGE' => DmMessageKind.image,
            'VOICE' => DmMessageKind.voice,
            'SYSTEM' => DmMessageKind.system,
            _ => DmMessageKind.text,
          };
          final mediaMode = switch ('${m['mediaMode'] ?? ''}') {
            'ONCE' => DmMediaMode.once,
            'REPLAY' => DmMediaMode.replay,
            'KEEP' => DmMediaMode.keep,
            _ => null,
          };

          return DmMessage(
            id: '${m['id'] ?? ''}',
            senderId: '${m['senderId'] ?? ''}',
            senderName: m['mine'] == true ? 'You' : 'Student',
            isMine: m['mine'] == true,
            kind: kind,
            text: '${m['text'] ?? ''}',
            mediaUrl: m['mediaUrl'] == null ? null : '${m['mediaUrl']}',
            mediaMode: mediaMode,
            voiceDuration: null,
            createdAt:
                DateTime.tryParse('${m['createdAt'] ?? ''}') ?? DateTime.now(),
            reactions: m['reactions'] is List
                ? (m['reactions'] as List)
                      .map((x) => '$x')
                      .toList(growable: false)
                : const [],
          );
        })
        .toList(growable: false);
  }

  Future<void> acceptRequest(String threadId) async {
    await _api.postJson(
      '/dm/threads/$threadId/request',
      body: {'action': 'accept'},
    );
  }

  Future<void> blockUser(String threadId) async {
    await _api.postJson(
      '/dm/threads/$threadId/request',
      body: {'action': 'block'},
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
      body: {'kind': 'TEXT', 'text': text},
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

  Future<void> sendImage(String threadId, String path, DmMediaMode mode) async {
    final file = await uploadMedia(path);
    await _api.postJson(
      '/dm/threads/$threadId/messages',
      body: {
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
      body: {
        'kind': 'VOICE',
        'mediaUrl': file['url'],
        'mediaMimeType': file['mimeType'],
        'mediaMode': _mode(mode),
        'text': '',
      },
    );
  }

  Future<void> createGroup(String title, List<String> userIds) async {
    await _api.postJson(
      '/dm/threads',
      body: {'title': title, 'participantIds': userIds, 'isGroup': true},
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
      body: {'emoji': emoji},
    );
  }

  String _mode(DmMediaMode mode) => switch (mode) {
    DmMediaMode.once => 'ONCE',
    DmMediaMode.replay => 'REPLAY',
    DmMediaMode.keep => 'KEEP',
  };
}
