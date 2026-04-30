import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../classrooms/data/classrooms_repository.dart';
import '../../classrooms/providers/classrooms_providers.dart';
import '../../classrooms/providers/classrooms_repo_provider.dart';
import '../domain/chat_delete_mode.dart';
import '../domain/chat_message.dart';
import '../domain/chat_message_kind.dart';
import '../domain/chat_thread_type.dart';
import '../domain/forward_target.dart';
import '../ui/forward_target_picker_sheet.dart';
import 'chat_thread_controller.dart';

class ClassroomChatThreadController extends ChatThreadController {
  ClassroomChatThreadController({
    required this.ref,
    required String courseId,
    required String currentUserId,
  })  : _courseId = courseId,
        _currentUserId = currentUserId {
    _loadLocalState();
  }

  final WidgetRef ref;
  final String _courseId;
  final String _currentUserId;

  final List<Map<String, dynamic>> _optimisticMessages = [];
  Map<String, String> _reactionByMessage = {};
  Map<String, String> _editedTextByMessage = {};
  // key = messageId, value = 'DELETED_FOR_ME' or 'DELETED_FOR_EVERYONE'
  Map<String, String> _deletedMessages = {};
  Set<String> _pinnedMessageIds = {};

  // Static session-level URL cache — key: '$courseId:$messageId' → CDN URL.
  static final Map<String, String> _sessionCache = {};

  // Latest sent message per course — used by the classroom inbox for preview.
  // Key: courseId, Value: {text, kind, createdAt}
  static final Map<String, Map<String, dynamic>> _lastMessageByCourse = {};

  /// Returns the latest locally-known message for [courseId], or null.
  /// Used by the classroom inbox when the server GET returns no items.
  static Map<String, dynamic>? lastMessage(String courseId) =>
      _lastMessageByCourse[courseId];

  // Local-persistence fallback: sent messages stored per course.
  // STATIC so a new controller instance sees data from the previous instance
  // immediately (no async race with SharedPreferences loading).
  static final Map<String, List<Map<String, dynamic>>> _staticLocalMessages = {};

  List<Map<String, dynamic>> get _localSentMessages =>
      _staticLocalMessages.putIfAbsent(_courseId, () => []);
  set _localSentMessages(List<Map<String, dynamic>> value) =>
      _staticLocalMessages[_courseId] = value;

  @override
  String get threadId => _courseId;

  @override
  ChatThreadType get threadType => ChatThreadType.classroom;

  @override
  String get currentUserId => _currentUserId;

  ClassroomsRepository get _repo => ref.read(classroomsRepoProvider);

  String _key(String suffix) => 'classroom_chat:$_courseId:$suffix';

  String _sk(String msgId) => '$_courseId:$msgId';
  String? _cachedUrl(String msgId) => _sessionCache[_sk(msgId)];

  static bool _isDeviceLocalPath(String url) {
    if (url.startsWith('file://')) return true;
    if (!url.startsWith('/')) return false;
    return url.startsWith('/private/') ||
        url.startsWith('/var/') ||
        url.startsWith('/tmp/') ||
        url.startsWith('/Users/');
  }

  void _cacheMediaUrl(String messageId, String url) {
    if (messageId.isEmpty || url.isEmpty || _isDeviceLocalPath(url)) return;
    final key = _sk(messageId);
    if (_sessionCache[key] == url) return;
    _sessionCache[key] = url;
    _persistUrlCache();
  }

  Future<void> _persistUrlCache() async {
    try {
      final prefix = '$_courseId:';
      final entries = <String, String>{
        for (final e in _sessionCache.entries)
          if (e.key.startsWith(prefix)) e.key.substring(prefix.length): e.value,
      };
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key('media_url_cache'), jsonEncode(entries));
    } catch (_) {}
  }

  Future<void> _loadLocalState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final reactionsRaw = prefs.getString(_key('reactions'));
      final editsRaw = prefs.getString(_key('edits'));
      final deletedRaw = prefs.getString(_key('deleted'));
      final pinnedRaw = prefs.getStringList('classroom_pinned_ids_$_courseId');

      if (reactionsRaw != null) {
        final decoded = jsonDecode(reactionsRaw);
        if (decoded is Map) {
          _reactionByMessage = decoded.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          );
        }
      }

      if (editsRaw != null) {
        final decoded = jsonDecode(editsRaw);
        if (decoded is Map) {
          _editedTextByMessage = decoded.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          );
        }
      }

      if (deletedRaw != null) {
        final decoded = jsonDecode(deletedRaw);
        if (decoded is Map) {
          _deletedMessages = decoded.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          );
        } else if (decoded is List) {
          // Legacy format: list of IDs → treat all as DELETED_FOR_ME
          _deletedMessages = {
            for (final e in decoded) e.toString(): 'DELETED_FOR_ME',
          };
        }
      }

      if (pinnedRaw != null) {
        _pinnedMessageIds = pinnedRaw.toSet();
      }

      // Load locally persisted sent messages (24-hour rolling window).
      final localMsgRaw = prefs.getString(_key('local_messages')) ?? '[]';
      final localDecoded = jsonDecode(localMsgRaw);
      if (localDecoded is List) {
        final cutoff = DateTime.now().subtract(const Duration(hours: 24));
        _localSentMessages = localDecoded
            .whereType<Map>()
            .where((m) {
              final ts = DateTime.tryParse(
                (m['savedAt'] ?? m['createdAt'] ?? '').toString(),
              );
              return ts != null && ts.isAfter(cutoff);
            })
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }

      // Restore message-ID → CDN URL cache into the static session cache.
      final urlCacheRaw = prefs.getString(_key('media_url_cache')) ?? '{}';
      final urlDecoded = jsonDecode(urlCacheRaw);
      if (urlDecoded is Map) {
        for (final e in urlDecoded.entries) {
          _sessionCache.putIfAbsent(_sk(e.key.toString()), () => e.value.toString());
        }
      }

      // Load last-message preview for the inbox (cross-session).
      await _loadLastMessagePreview(prefs);
    } catch (_) {}

    // Always invalidate when we have local data.  Classroom GET always returns
    // items:[], so _localSentMessages is the only source of messages.  The first
    // _computeMessages() ran with empty _localSentMessages (async race), so we
    // need a re-merge once the local store is loaded — regardless of whether
    // _cachedMessages already has messages.
    if (_localSentMessages.isNotEmpty ||
        _sessionCache.keys.any((k) => k.startsWith('$_courseId:'))) {
      invalidate();
    }
  }

  Future<void> _saveLocalMessage(Map<String, dynamic> msg) async {
    try {
      final entry = {...msg, 'savedAt': DateTime.now().toIso8601String()};
      _localSentMessages.add(entry);
      if (_localSentMessages.length > 100) {
        _localSentMessages.removeRange(0, _localSentMessages.length - 100);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key('local_messages'),
        jsonEncode(_localSentMessages),
      );

      // Update the inbox last-message tracker (static + SharedPreferences).
      final preview = {
        'text': (msg['text'] ?? msg['body'] ?? '').toString(),
        'kind': (msg['kind'] ?? 'TEXT').toString(),
        'createdAt': (msg['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      };
      _lastMessageByCourse[_courseId] = preview;
      await prefs.setString(_key('last_msg_preview'), jsonEncode(preview));
    } catch (_) {}
  }

  /// Loads the persisted last-message preview into the static map.
  /// Called from _loadLocalState so the inbox can display it synchronously.
  Future<void> _loadLastMessagePreview(SharedPreferences prefs) async {
    try {
      final raw = prefs.getString(_key('last_msg_preview'));
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map && !_lastMessageByCourse.containsKey(_courseId)) {
        _lastMessageByCourse[_courseId] =
            Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
  }

  Future<void> _persistLocalState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key('reactions'), jsonEncode(_reactionByMessage));
      await prefs.setString(_key('edits'), jsonEncode(_editedTextByMessage));
      await prefs.setString(
        _key('deleted'),
        jsonEncode(_deletedMessages),
      );
      await prefs.setStringList(
        'classroom_pinned_ids_$_courseId',
        _pinnedMessageIds.toList()..sort(),
      );
    } catch (_) {}
  }

  List<ChatMessage> _cachedMessages = [];

  List<ChatMessage> _computeMessages(dynamic chatData) {
    final serverItems = (chatData is Map && chatData['items'] is List)
        ? (chatData['items'] as List)
        : const [];


    final serverIds = serverItems
        .map((i) => _pick(i, 'id').toString())
        .toSet();

    // Prune confirmed and stale optimistics from the list (same logic that
    // decides stillPending — removes them from _optimisticMessages so they
    // don't accumulate after the server confirms the real message).
    final now = DateTime.now();
    _optimisticMessages.removeWhere((o) {
      if (serverIds.contains(o['id'].toString())) return true;
      if (_serverHasMatch(o, serverItems)) return true;
      final created = DateTime.tryParse((o['createdAt'] ?? '').toString());
      if (created != null && now.difference(created).inSeconds > 120) return true;
      return false;
    });

    final stillPending = _optimisticMessages.where((o) {
      // Anything still in the list after pruning above is pending.
      return !_deletedMessages.containsKey(_pick(o, 'id'));
    }).toList();

    // Inject CDN URLs into own server items that lack a media URL.
    // IMPORTANT: No kind restriction — the server may return kind:'TEXT' for
    // image/voice messages.  We match by isMine + closest timestamp from our
    // locally saved outgoing media entries.
    final patchedServerItems = serverItems.map((raw) {
      final isMine = _pick(raw, 'isMine') == 'true' ||
          (raw is Map && raw['isMine'] == true);
      if (!isMine) return raw; // Never patch others' messages

      final existingUrl = [
        _pick(raw, 'mediaUrl'),
        _pick(raw, 'fileUrl'),
        _pick(raw, 'url'),
        _pick(raw, 'attachmentUrl'),
      ].firstWhere((s) => s.isNotEmpty, orElse: () => '');
      if (existingUrl.isNotEmpty) return raw; // Already has a URL — nothing to do

      final created = _readTimestamp(raw);

      // Find closest local media entry by timestamp (no kind requirement).
      Map<String, dynamic>? best;
      var bestDiff = const Duration(seconds: 121);
      for (final local in _localSentMessages) {
        final localUrl = _pick(local, 'mediaUrl');
        if (localUrl.isEmpty || _isDeviceLocalPath(localUrl)) continue;
        final localCreated =
            DateTime.tryParse((local['createdAt'] ?? '').toString());
        if (localCreated == null) continue;
        final diff = created.difference(localCreated).abs();
        if (diff < bestDiff) {
          bestDiff = diff;
          best = local;
        }
      }
      if (best != null) {
        final patched = raw is Map
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};
        patched['mediaUrl'] = _pick(best, 'mediaUrl');
        final mimeType = _pick(best, 'mimeType');
        if (mimeType.isNotEmpty) patched['mimeType'] = mimeType;
        return patched;
      }
      return raw;
    }).toList();

    // Build the text set from patched server items for dedup.
    final serverTextSet = patchedServerItems
        .map((i) {
          final t = _pick(i, 'text').trim();
          return t.isNotEmpty ? t : _pick(i, 'body').trim();
        })
        .where((t) => t.isNotEmpty)
        .toSet();

    // Local fallback: messages the server hasn't confirmed yet.
    // For text: check exact content match.
    // For media: check timestamp proximity — no kind restriction.
    final localFallback = _localSentMessages.where((m) {
      final id = (m['id'] ?? '').toString();
      if (_deletedMessages[id] == 'DELETED_FOR_ME') return false;
      if (_deletedMessages.containsKey(id) && _deletedMessages[id] != 'DELETED_FOR_EVERYONE') return false;
      final kind = _pick(m, 'kind').toUpperCase();
      final text = _pick(m, 'text').trim().isNotEmpty
          ? _pick(m, 'text').trim()
          : _pick(m, 'body').trim();
      if (kind == 'TEXT') {
        return text.isNotEmpty && !serverTextSet.contains(text);
      }
      // For media: exclude from fallback once the server confirms by timestamp
      // (server may use a different kind, so don't require kind match).
      final created = DateTime.tryParse((m['createdAt'] ?? '').toString());
      if (created == null) return false;
      for (final si in patchedServerItems) {
        final sCreated = DateTime.tryParse(_pick(si, 'createdAt'));
        if (sCreated != null &&
            sCreated.difference(created).inSeconds.abs() <= 90) {
          return false; // Server has a message at this time — patched or not
        }
      }
      return true;
    }).toList();

    final rawItems = [...patchedServerItems, ...localFallback, ...stillPending];

    // Deduplicate by ID before filtering — prevents duplicate GlobalKey crashes
    // when the same message ID appears in multiple sources.
    final seenIds = <String>{};
    final dedupedRaw = rawItems.where((item) {
      final id = _pick(item, 'id');
      return id.isEmpty || seenIds.add(id);
    }).toList();

    final filtered = dedupedRaw
        .where((item) {
            final id = _pick(item, 'id');
            return _deletedMessages[id] != 'DELETED_FOR_ME';
          })
        .toList()
      ..sort((a, b) {
        final da = _readTimestamp(a);
        final db = _readTimestamp(b);
        return da.compareTo(db);
      });

    final messages = filtered.map(_convertClassroomRow).toList();
    _cachedMessages = messages;
    return messages;
  }

  @override
  AsyncValue<List<ChatMessage>> watchMessages(WidgetRef ref) {
    final provider = classroomChatProvider((id: _courseId, limit: 50, cursor: null));
    final chatAsync = ref.watch(provider);

    // skipLoadingOnRefresh: true means: while the provider is refreshing after
    // invalidate(), call data() with the PREVIOUS chatData so _computeMessages()
    // can inject newly added optimistics into the list.  The old manual
    // isLoading+_cachedMessages check was removed because it returned stale data
    // (without new optimistics) and short-circuited this mechanism.
    return chatAsync.when(
      skipLoadingOnRefresh: true,
      data: (chatData) => AsyncValue.data(_computeMessages(chatData)),
      loading: () => _cachedMessages.isNotEmpty
          ? AsyncValue.data(_cachedMessages)
          : const AsyncValue.loading(),
      error: (err, stack) => _cachedMessages.isNotEmpty
          ? AsyncValue.data(_cachedMessages)
          : AsyncValue.error(err, stack),
    );
  }

  String _pick(dynamic item, String key) {
    if (item is Map) {
      return (item[key] ?? '').toString().trim();
    }
    return '';
  }

  DateTime _readTimestamp(dynamic item) {
    final candidates = [
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

  /// Returns the text content of a server message item, checking multiple
  /// possible field names (servers vary: text / body / content).
  String _serverText(dynamic si) {
    for (final key in const ['text', 'body', 'content', 'message']) {
      final v = _pick(si, key).trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  bool _serverHasMatch(Map<String, dynamic> opt, List<dynamic> serverItems) {
    final optKind = (opt['kind'] ?? '').toString().toUpperCase();
    // Check both 'text' and 'body' fields on the optimistic too.
    final optText = [
      (opt['text'] ?? '').toString().trim(),
      (opt['body'] ?? '').toString().trim(),
    ].firstWhere((s) => s.isNotEmpty, orElse: () => '');
    final optCreated = DateTime.tryParse((opt['createdAt'] ?? '').toString());

    for (final si in serverItems) {
      final sKind = _pick(si, 'kind').toUpperCase();
      final sText = _serverText(si);
      final sCreated = DateTime.tryParse(_pick(si, 'createdAt'));

      if (sKind != optKind) continue;

      if (optKind == 'TEXT') {
        if (optText.isNotEmpty && sText == optText) return true;
      } else {
        if (optCreated == null || sCreated == null) return true;
        final diff = sCreated.difference(optCreated).inSeconds.abs();
        if (diff <= 30) return true;
      }
    }
    return false;
  }

  int? _pickInt(dynamic row, List<String> keys) {
    if (row is! Map) return null;
    for (final k in keys) {
      final v = row[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  ChatMessage _convertClassroomRow(dynamic row) {
    final id = _pick(row, 'id');
    final senderId = _pick(row, 'senderId');
    // Server may return senderName, authorName, or userName
    final senderName = [
      _pick(row, 'senderName'),
      _pick(row, 'authorName'),
      _pick(row, 'userName'),
      _pick(row, 'name'),
    ].firstWhere((s) => s.isNotEmpty, orElse: () => 'Unknown');

    final isMine = _pick(row, 'isMine') == 'true' ||
        row is Map && row['isMine'] == true;

    // Server may return text in 'text', 'body', or 'content'
    final rawText = _editedTextByMessage[id] ?? [
      _pick(row, 'text'),
      _pick(row, 'body'),
      _pick(row, 'content'),
    ].firstWhere((s) => s.isNotEmpty, orElse: () => '');

    final kind = _parseKind(_pick(row, 'kind'));

    // Server may use 'mediaUrl', 'fileUrl', 'url', or 'attachmentUrl'
    var mediaUrl = [
      _pick(row, 'mediaUrl'),
      _pick(row, 'fileUrl'),
      _pick(row, 'url'),
      _pick(row, 'attachmentUrl'),
    ].firstWhere((s) => s.isNotEmpty, orElse: () => '');


    // Two-way media URL cache: save when the server provides a CDN URL,
    // inject from cache when the server omits it on a subsequent GET.
    if (mediaUrl.isNotEmpty && !_isDeviceLocalPath(mediaUrl) && id.isNotEmpty) {
      _cacheMediaUrl(id, mediaUrl);
    } else if (mediaUrl.isEmpty && id.isNotEmpty) {
      final cached = _cachedUrl(id);
      if ((cached ?? '').isNotEmpty) mediaUrl = cached!;
    }

    // MIME type may be 'mimeType', 'mediaMimeType', or 'contentType'
    final mimeType = [
      _pick(row, 'mimeType'),
      _pick(row, 'mediaMimeType'),
      _pick(row, 'contentType'),
    ].firstWhere((s) => s.isNotEmpty, orElse: () => '');

    // Voice duration seconds
    final voiceDurationSeconds = _pickInt(row, [
      'voiceDurationSeconds',
      'durationSeconds',
      'duration',
      'voice_duration',
    ]);

    final createdAt = _readTimestamp(row);
    final pinned = _pinnedMessageIds.contains(id);

    // Reactions: server may include full reaction map
    final serverReactions = <String, List<String>>{};
    if (row is Map && row['reactions'] is Map) {
      final raw = row['reactions'] as Map;
      raw.forEach((emoji, users) {
        final e = emoji.toString();
        final userList = users is List
            ? users.map((u) => u.toString()).toList()
            : <String>[];
        if (e.isNotEmpty) serverReactions[e] = userList;
      });
    }

    // Local reaction overrides server reactions
    final myReaction = _reactionByMessage[id];
    final reactions = serverReactions.isNotEmpty
        ? serverReactions
        : <String, List<String>>{};
    if (myReaction != null && myReaction.isNotEmpty) {
      reactions[myReaction] = (reactions[myReaction] ?? [])
        ..removeWhere((u) => u == 'me' || u == _currentUserId)
        ..add('me');
    }

    final deleteMode = _deletedMessages[id];
    final deletedForEveryone = deleteMode == 'DELETED_FOR_EVERYONE';

    return ChatMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
      text: rawText,
      kind: kind,
      mediaUrl: mediaUrl.isEmpty ? null : mediaUrl,
      mediaMimeType: mimeType.isEmpty ? null : mimeType,
      voiceDurationSeconds: voiceDurationSeconds,
      createdAt: createdAt,
      editedAt: _editedTextByMessage.containsKey(id) ? DateTime.now() : null,
      reactions: reactions,
      pinned: pinned,
      isOwn: isMine,
      isOptimistic: id.startsWith('optimistic-'),
      deletedForEveryone: deletedForEveryone,
    );
  }

  ChatMessageKind _parseKind(String kind) {
    final upper = kind.toUpperCase();
    switch (upper) {
      case 'IMAGE':
        return ChatMessageKind.image;
      case 'DOC':
      case 'FILE':
        return ChatMessageKind.file;
      case 'VOICE':
        return ChatMessageKind.voice;
      default:
        return ChatMessageKind.text;
    }
  }

  @override
  Future<void> sendText(String text, {String? replyToMessageId}) async {
    final optimisticId = 'optimistic-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toUtc().toIso8601String();
    _optimisticMessages.add({
      'id': optimisticId,
      'text': text,
      'body': text,
      'senderName': 'You',
      'isMine': true,
      'kind': 'TEXT',
      'createdAt': now,
    });
    // Invalidate immediately so the widget rebuilds and shows the optimistic.
    invalidate();

    try {
      await _repo.sendChatText(_courseId, text);
      // Remove the optimistic immediately on success so it doesn't appear
      // alongside the real server message when the post-send invalidate fires.
      // The localSentMessages fallback provides persistence until the server
      // confirms the message in its next GET response.
      _optimisticMessages.removeWhere((m) => m['id'] == optimisticId);
      await _saveLocalMessage({
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'text': text,
        'body': text,
        'senderName': 'You',
        'isMine': true,
        'kind': 'TEXT',
        'createdAt': now,
      });
      // Caller handles the post-send invalidate() in .then()
    } catch (e) {
      _optimisticMessages.removeWhere((m) => m['id'] == optimisticId);
      rethrow;
    }
  }

  @override
  Future<void> sendMedia(
    List<File> files, {
    String? caption,
    String? replyToMessageId,
  }) async {
    final optimisticIds = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final optimisticId = 'optimistic-${DateTime.now().millisecondsSinceEpoch}-$i';
      optimisticIds.add(optimisticId);
      _optimisticMessages.add({
        'id': optimisticId,
        'text': i == 0 ? (caption ?? '') : '',
        'body': i == 0 ? (caption ?? '') : '',
        'senderName': 'You',
        'isMine': true,
        'kind': 'IMAGE',
        'mediaUrl': file.path,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
    }
    // Show optimistic bubbles immediately.
    invalidate();

    // No finally removal — _serverHasMatch() in _computeMessages() prunes these
    // once the server confirms.  Removing in finally caused the same 0.5 s gap.
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final now = DateTime.now().toUtc().toIso8601String();
      final result = await _repo.sendChatMedia(
        _courseId,
        file.path,
        text: i == 0 ? caption : null,
      );
      // Extract CDN URL + confirmed server ID from upload response.
      // The classroom server returns: {ok, item: {id, mediaUrl, createdAt, ...}}
      final cdnUrl = _pickCdnUrl(result, file.path);
      final confirmedId = _pickConfirmedId(result);
      final confirmedCreatedAt = _pickConfirmedCreatedAt(result);
      if (cdnUrl.isNotEmpty && cdnUrl != file.path) {
        // Remove the optimistic — the locally-saved confirmed entry replaces it.
        // IMPORTANT: do NOT update the optimistic's ID to the real server ID
        // before saving, as that would create two entries with the same ID
        // (optimistic in stillPending + local in localFallback) → GlobalKey crash.
        final optId = i < optimisticIds.length ? optimisticIds[i] : null;
        if (optId != null) {
          _optimisticMessages.removeWhere((m) => m['id'] == optId);
        }

        final localId = confirmedId.isNotEmpty
            ? confirmedId
            : 'local-${DateTime.now().millisecondsSinceEpoch}-media-$i';
        await _saveLocalMessage({
          'id': localId,
          'text': i == 0 ? (caption ?? '') : '',
          'body': i == 0 ? (caption ?? '') : '',
          'senderName': 'You',
          'isMine': true,
          'kind': 'IMAGE',
          'mediaUrl': cdnUrl,
          'mimeType': '',
          'createdAt': confirmedCreatedAt.isNotEmpty ? confirmedCreatedAt : now,
        });
        if (!_isDeviceLocalPath(cdnUrl)) {
          _cacheMediaUrl(localId, cdnUrl);
        }
        invalidate();
      }
    }
    // Caller handles the post-send invalidate()
  }

  @override
  Future<void> sendVoice(
    File file,
    Duration duration, {
    String? replyToMessageId,
  }) async {
    final optimisticId = 'optimistic-${DateTime.now().millisecondsSinceEpoch}-voice';
    final now = DateTime.now().toUtc().toIso8601String();
    _optimisticMessages.add({
      'id': optimisticId,
      'text': '',
      'body': '',
      'senderName': 'You',
      'isMine': true,
      'kind': 'VOICE',
      'mediaUrl': file.path,
      'voiceDurationSeconds': duration.inSeconds,
      'createdAt': now,
    });
    // Show optimistic voice bubble immediately.
    invalidate();

    // No finally removal — _serverHasMatch() prunes once server confirms.
    final result = await _repo.sendChatMedia(_courseId, file.path);
    // Extract CDN URL + confirmed server ID from upload response.
    final cdnUrl = _pickCdnUrl(result, file.path);
    final confirmedId = _pickConfirmedId(result);
    final confirmedCreatedAt = _pickConfirmedCreatedAt(result);
    if (cdnUrl.isNotEmpty && cdnUrl != file.path) {
      // Remove the optimistic immediately — the locally-saved confirmed entry
      // replaces it via localFallback. Never update the optimistic ID to the
      // server ID before removing, as that causes duplicate IDs → GlobalKey crash.
      _optimisticMessages.removeWhere((m) => m['id'] == optimisticId);
      final localId = confirmedId.isNotEmpty
          ? confirmedId
          : 'local-${DateTime.now().millisecondsSinceEpoch}-voice';
      await _saveLocalMessage({
        'id': localId,
        'text': '',
        'body': '',
        'senderName': 'You',
        'isMine': true,
        'kind': 'VOICE',
        'mediaUrl': cdnUrl,
        'voiceDurationSeconds': duration.inSeconds,
        'createdAt': confirmedCreatedAt.isNotEmpty ? confirmedCreatedAt : now,
      });
      if (!_isDeviceLocalPath(cdnUrl)) {
        _cacheMediaUrl(localId, cdnUrl);
      }
      invalidate();
    }
    // Caller handles the post-send invalidate()
  }

  /// Extracts the CDN URL from an upload response map.
  /// Falls back to [fallback] when no URL field is found.
  String _pickCdnUrl(Map<String, dynamic> result, String fallback) {
    const topKeys = ['url', 'mediaUrl', 'fileUrl', 'attachmentUrl', 'cdnUrl', 'src'];
    for (final k in topKeys) {
      final v = result[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    // 'item' is the key the classroom server uses in upload responses.
    for (final nk in const ['item', 'data', 'file', 'media', 'attachment', 'result']) {
      final obj = result[nk];
      if (obj is Map) {
        for (final k in topKeys) {
          final v = obj[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }
    }
    return fallback;
  }

  /// Extracts the real server-assigned message ID from an upload response.
  String _pickConfirmedId(Map<String, dynamic> result) {
    for (final nk in const ['item', 'data', 'message', 'result']) {
      final obj = result[nk];
      if (obj is Map) {
        final id = (obj['id'] ?? '').toString().trim();
        if (id.isNotEmpty) return id;
      }
    }
    return '';
  }

  /// Extracts the server-assigned createdAt from an upload response.
  String _pickConfirmedCreatedAt(Map<String, dynamic> result) {
    for (final nk in const ['item', 'data', 'message', 'result']) {
      final obj = result[nk];
      if (obj is Map) {
        final ts = (obj['createdAt'] ?? '').toString().trim();
        if (ts.isNotEmpty) return ts;
      }
    }
    return '';
  }

  @override
  Future<void> editMessage(String messageId, String newText) async {
    _editedTextByMessage[messageId] = newText;
    await _persistLocalState();
    
    try {
      await _repo.editChatMessage(
        _courseId,
        messageId: messageId,
        text: newText,
      );
    } catch (_) {
      // Edit on backend failed but local state updated
    }
  }

  @override
  Future<void> deleteMessage(
    String messageId, {
    required ChatDeleteMode mode,
  }) async {
    _deletedMessages[messageId] = mode == ChatDeleteMode.deleteForEveryone
        ? 'DELETED_FOR_EVERYONE'
        : 'DELETED_FOR_ME';
    _reactionByMessage.remove(messageId);
    _editedTextByMessage.remove(messageId);
    await _persistLocalState();
  }

  @override
  Future<void> togglePin(String messageId) async {
    if (_pinnedMessageIds.contains(messageId)) {
      _pinnedMessageIds.remove(messageId);
    } else {
      _pinnedMessageIds.add(messageId);
    }
    await _persistLocalState();
  }

  @override
  Future<void> react(String messageId, String? emoji) async {
    if (emoji == null || emoji.isEmpty) {
      _reactionByMessage.remove(messageId);
    } else {
      _reactionByMessage[messageId] = emoji;
    }
    await _persistLocalState();
  }

  @override
  Future<void> markRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'classroom_chat_seen_$_courseId',
        DateTime.now().toUtc().toIso8601String(),
      );
    } catch (_) {}
  }

  @override
  Future<List<ForwardTarget>?> showForwardPicker(
    BuildContext context,
    WidgetRef ref,
  ) {
    return showForwardTargetPicker(
      context,
      ref,
      sourceThreadType: ChatThreadType.classroom,
      sourceThreadId: _courseId,
    );
  }

  @override
  Future<void> forwardMessages(
    List<String> messageIds,
    List<ForwardTarget> targets,
  ) async {
    if (targets.isEmpty) return;
    final targetThreadIds = targets.map((t) => t.id).toList();
    for (final messageId in messageIds) {
      await _repo.forwardChatMessage(
        _courseId,
        messageId: messageId,
        targetThreadIds: targetThreadIds,
      );
    }
  }

  @override
  void invalidate() {
    ref.invalidate(classroomChatProvider((id: _courseId, limit: 50, cursor: null)));
  }
}
