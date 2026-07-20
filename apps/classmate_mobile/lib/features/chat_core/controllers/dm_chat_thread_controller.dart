import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../classrooms/providers/classrooms_repo_provider.dart';
import '../../messages/data/messages_repository.dart';
import '../../messages/domain/message_thread_models.dart';
import '../../messages/providers/messages_repository_provider.dart';
import '../domain/chat_delete_mode.dart';
import '../domain/chat_message.dart';
import '../domain/chat_message_kind.dart';
import '../domain/chat_thread_type.dart';
import '../domain/forward_target.dart';
import '../ui/forward_target_picker_sheet.dart';
import 'chat_thread_controller.dart';

class DmChatThreadController extends ChatThreadController {
  DmChatThreadController({
    required this.ref,
    required String threadId,
    required String currentUserId,
  })  : _threadId = threadId,
        _currentUserId = currentUserId {
    _loadLocalMedia();
  }

  final WidgetRef ref;
  final String _threadId;
  final String _currentUserId;

  @override
  String get threadId => _threadId;

  @override
  ChatThreadType get threadType => ChatThreadType.direct;

  @override
  String get currentUserId => _currentUserId;

  MessagesRepository get _repo => ref.read(messagesRepositoryProvider);

  final List<ChatMessage> _optimisticMessages = [];
  List<ChatMessage> _cachedMessages = [];

  // ── Pagination (load older on scroll) ────────────────────────────────────
  // Raw older-than-window messages fetched on demand, oldest-first. Kept as
  // raw MessageItems (not converted) so sender-name resolution always uses the
  // freshest participant map at build time. The recent window itself comes
  // from messageThreadProvider and refreshes live; these accumulate above it.
  List<MessageItem> _olderRaw = [];
  bool _hasMoreOlder = false;
  bool _loadingOlder = false;

  /// True when there are older messages before the currently loaded set.
  @override
  bool get hasMoreOlder => _hasMoreOlder;

  /// True while an older page is being fetched (for a top spinner).
  @override
  bool get isLoadingOlder => _loadingOlder;

  /// Fetch the next older page and prepend it. No-op when already loading,
  /// nothing older remains, or we don't yet have a cursor (oldest loaded id).
  @override
  Future<void> loadOlder() async {
    if (_loadingOlder || !_hasMoreOlder) return;
    String? oldestId;
    for (final m in _cachedMessages) {
      if (!m.isOptimistic) {
        oldestId = m.id;
        break;
      }
    }
    if (oldestId == null) return;
    _loadingOlder = true;
    invalidate(); // reflect the loading state (top spinner)
    try {
      final page = await _repo.fetchThread(
        threadId: _threadId,
        limit: kDmPageSize,
        before: oldestId,
      );
      // Prepend older messages, de-duping against what we already hold.
      final existing = _olderRaw.map((m) => m.id).toSet();
      final fresh = page.messages.where((m) => !existing.contains(m.id));
      _olderRaw = [...fresh, ..._olderRaw];
      _hasMoreOlder = page.hasMoreOlder;
    } catch (_) {
      // Leave _hasMoreOlder as-is so the user can retry by scrolling again.
    } finally {
      _loadingOlder = false;
      invalidate();
    }
  }

  // Local deletion state — persisted so deletions survive exit + re-entry.
  // key: messageId (server or local), value: 'DELETED_FOR_ME' | 'DELETED_FOR_EVERYONE'
  Map<String, String> _localDeleted = {};

  // Durable deletion state keyed by the media CDN URL — the ONE identifier that
  // survives a message ID changing between the optimistic/local bubble and the
  // server-confirmed row. Without this a voice note deleted before the server
  // roundtrip completed would reappear "alive" on re-entry (the persisted
  // id-keyed map never matched the freshly-assigned server id). Persisted, so
  // deletion is unbreakable across exit + re-entry regardless of id churn.
  // key: mediaUrl, value: 'DELETED_FOR_ME' | 'DELETED_FOR_EVERYONE'
  Map<String, String> _deletedUrls = {};

  // Durable deletion state for TEXT messages, keyed by a content signature
  // ("senderId|text") rather than id. Text has no media URL to anchor to, so
  // without this a text deleted before the server confirmed its real id (i.e.
  // while it was still an "optimistic-…" bubble) would be re-issued to the
  // server as a 404 and then reappear with a fresh server id on re-entry.
  // Signature-based matching makes text deletion survive id churn + restarts,
  // exactly like the URL map does for media. Persisted.
  // key: 'senderId|trimmedText', value: 'DELETED_FOR_ME' | 'DELETED_FOR_EVERYONE'
  Map<String, String> _deletedTexts = {};

  static String _textSig(String senderId, String text) =>
      '$senderId|${text.trim()}';

  // Server ids we've already fired a compensating "delete for everyone" at, so
  // the merge retry (below) never spams the API for the same message.
  final Set<String> _reDeleteAttempted = {};

  // Static set of CDN URLs for media WE have sent.  Never pruned within a
  // session — used to determine isOwn even after _localMediaMessages is cleared.
  static final Map<String, Set<String>> _staticSentUrls = {};

  /// Wipe every static cache so a logout/login on the same device
  /// doesn't bleed the previous user's threads to the next one. The
  /// thread-id key includes the user, but the URL cache and outgoing
  /// media maps don't — so a full reset at auth boundary is the only
  /// safe play. AuthController.logout calls this.
  static void clearAllSessionCaches() {
    _staticSentUrls.clear();
    _sessionCache.clear();
    _staticLocalMedia.clear();
    _staticLastMessages.clear();
  }

  // Last successfully rendered message list per thread — survives controller
  // recreation within the session so re-opened threads paint instantly and a
  // transient fetch failure never blanks a previously seen conversation.
  // Bounded (see _mergeWithOptimistic): at most _kLastMsgThreadCap threads,
  // each capped to _kLastMsgPerThread messages.
  static final Map<String, List<ChatMessage>> _staticLastMessages = {};
  static const int _kLastMsgThreadCap = 24;
  static const int _kLastMsgPerThread = 80;

  Set<String> get _sentUrls =>
      _staticSentUrls.putIfAbsent(_threadId, () => {});

  String _deletedKey() => 'dm_deleted:$_threadId';
  String _deletedUrlsKey() => 'dm_deleted_urls:$_threadId';
  String _deletedTextsKey() => 'dm_deleted_texts:$_threadId';
  String _sentUrlsKey() => 'dm_sent_urls:$_threadId';

  Future<void> _persistLocalDeleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deletedKey(), jsonEncode(_localDeleted));
      await prefs.setString(_deletedUrlsKey(), jsonEncode(_deletedUrls));
      await prefs.setString(_deletedTextsKey(), jsonEncode(_deletedTexts));
    } catch (_) {}
  }

  // ── Media URL persistence ─────────────────────────────────────────────────
  //
  // TWO STATIC LAYERS so data is always available synchronously on re-entry
  // (no async race with SharedPreferences loading).
  //
  // Layer 1 — _sessionCache  (messageId → CDN URL, per thread)
  //   Populated whenever any URL is seen (upload or server GET).
  //   Static: survives controller recreations within the same app session.
  //   Also persisted to SharedPreferences for cross-session availability.
  //
  // Layer 2 — _staticLocalMedia  (outgoing media messages, per thread)
  //   Populated in sendMedia/sendVoice after a successful upload.
  //   Used as timestamp-based fallback when the session cache is empty.
  //   Static: immediately available to a new controller instance on re-entry.
  //   Also persisted to SharedPreferences (48-hour TTL).

  static final Map<String, String> _sessionCache = {};

  // Outgoing media messages keyed by threadId — static so a new controller
  // instance sees data from the previous instance without any async wait.
  static final Map<String, List<ChatMessage>> _staticLocalMedia = {};

  List<ChatMessage> get _localMediaMessages =>
      _staticLocalMedia.putIfAbsent(_threadId, () => []);
  set _localMediaMessages(List<ChatMessage> value) =>
      _staticLocalMedia[_threadId] = value;

  String _localKey() => 'dm_local_media:$_threadId';
  String _urlCacheKey() => 'dm_media_url_cache:$_threadId';
  String _sk(String msgId) => '$_threadId:$msgId';

  /// Returns the cached CDN URL for [messageId], or null.
  /// Checks the static session cache first (synchronous, always up-to-date),
  /// then the per-instance map populated from SharedPreferences.
  String? _cachedUrl(String messageId) => _sessionCache[_sk(messageId)];

  /// Records [url] for [messageId] in both the session cache and persists it
  /// asynchronously to SharedPreferences for cross-session availability.
  void _recordUrl(String messageId, String url) {
    if (messageId.isEmpty || url.isEmpty) return;
    // Reject real local device file paths (temp recordings, camera captures).
    // Server-relative paths like /uploads/dm/... ARE valid and must be cached.
    if (url.startsWith('file://') ||
        url.startsWith('/private/') ||
        url.startsWith('/var/') ||
        url.startsWith('/tmp/')) {
      return;
    }
    final key = _sk(messageId);
    if (_sessionCache[key] == url) return; // already known
    _sessionCache[key] = url;
    _persistUrlCache(); // fire-and-forget
  }

  Future<void> _persistUrlCache() async {
    try {
      // Collect only entries belonging to this thread.
      final prefix = '$_threadId:';
      final threadEntries = <String, String>{
        for (final e in _sessionCache.entries)
          if (e.key.startsWith(prefix))
            e.key.substring(prefix.length): e.value,
      };
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_urlCacheKey(), jsonEncode(threadEntries));
    } catch (_) {}
  }

  Future<void> _loadLocalMedia() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Restore message-ID → CDN URL cache from SharedPreferences into the
      // static session cache (only for entries not already present).
      final urlMapRaw = prefs.getString(_urlCacheKey()) ?? '{}';
      final urlDecoded = jsonDecode(urlMapRaw);
      if (urlDecoded is Map) {
        for (final e in urlDecoded.entries) {
          final key = _sk(e.key.toString());
          _sessionCache.putIfAbsent(key, () => e.value.toString());
        }
      }

      // Restore persisted local deletion state.
      final deletedRaw = prefs.getString(_deletedKey()) ?? '{}';
      final deletedDecoded = jsonDecode(deletedRaw);
      if (deletedDecoded is Map) {
        _localDeleted = deletedDecoded.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }

      // Restore durable URL-keyed deletion state (survives message-id churn).
      final deletedUrlsRaw = prefs.getString(_deletedUrlsKey()) ?? '{}';
      final deletedUrlsDecoded = jsonDecode(deletedUrlsRaw);
      if (deletedUrlsDecoded is Map) {
        _deletedUrls = deletedUrlsDecoded.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }

      // Restore durable text-signature deletion state.
      final deletedTextsRaw = prefs.getString(_deletedTextsKey()) ?? '{}';
      final deletedTextsDecoded = jsonDecode(deletedTextsRaw);
      if (deletedTextsDecoded is Map) {
        _deletedTexts = deletedTextsDecoded.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }

      // Restore sent CDN URLs (for isOwn detection even after list is pruned).
      final sentRaw = prefs.getString(_sentUrlsKey()) ?? '[]';
      final sentDecoded = jsonDecode(sentRaw);
      if (sentDecoded is List) {
        _sentUrls.addAll(sentDecoded.whereType<String>());
      }

      // Restore outgoing media messages (timestamp fallback, 48-hour TTL).
      final raw = prefs.getString(_localKey()) ?? '[]';
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final cutoff = DateTime.now().subtract(const Duration(hours: 48));
        _localMediaMessages = decoded
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .where((m) {
              final ts = DateTime.tryParse(
                  (m['savedAt'] ?? m['createdAt'] ?? '').toString());
              return ts != null && ts.isAfter(cutoff);
            })
            .map(_fromLocalMap)
            .whereType<ChatMessage>()
            .toList();
      }
    } catch (_) {
      _localMediaMessages = [];
    }

    // Trigger a re-merge when we have local media data OR pending deletions
    // so the correct deleted/visible state is applied immediately.
    if (_localMediaMessages.isNotEmpty ||
        _localDeleted.isNotEmpty ||
        _deletedUrls.isNotEmpty ||
        _deletedTexts.isNotEmpty ||
        _sessionCache.keys.any((k) => k.startsWith('$_threadId:'))) {
      invalidate();
    }
  }

  /// Returns true only for real on-device file paths (temp recordings, camera
  /// captures).  Server-relative paths like /uploads/dm/... start with / but
  /// are NOT local files — they must be resolved via the API base URL.
  static bool _isDeviceLocalPath(String url) {
    if (url.startsWith('file://')) return true;
    if (!url.startsWith('/')) return false;
    return url.startsWith('/private/') ||
        url.startsWith('/var/') ||
        url.startsWith('/tmp/') ||
        url.startsWith('/Users/');
  }

  /// Extracts the CDN URL from an upload response map, trying every field
  /// name the server might use. This is the fix for the root bug: if the
  /// server returns the URL under 'mediaUrl' instead of 'url', the old
  /// `uploadResult['url'] as String?` returned null and nothing was stored.
  static String? _pickUploadUrl(Map<String, dynamic> result) {
    const topKeys = ['url', 'mediaUrl', 'fileUrl', 'cdnUrl', 'attachmentUrl', 'src', 'location'];
    for (final k in topKeys) {
      final v = result[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    const nestKeys = ['data', 'media', 'file', 'attachment', 'result', 'upload'];
    for (final nk in nestKeys) {
      final obj = result[nk];
      if (obj is Map) {
        for (final k in topKeys) {
          final v = obj[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }
    }
    return null;
  }

  static String? _pickUploadMime(Map<String, dynamic> result) {
    const keys = ['mimeType', 'mime_type', 'contentType', 'content_type', 'type', 'mediaType'];
    for (final k in keys) {
      final v = result[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    for (final nk in const ['data', 'media', 'file', 'attachment']) {
      final obj = result[nk];
      if (obj is Map) {
        for (final k in keys) {
          final v = obj[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }
    }
    return null;
  }

  Future<void> _saveLocalMedia(ChatMessage msg) async {
    try {
      _localMediaMessages
        ..removeWhere((m) =>
            m.kind == msg.kind &&
            m.createdAt.difference(msg.createdAt).inSeconds.abs() < 5)
        ..add(msg);
      if (_localMediaMessages.length > 200) {
        _localMediaMessages.removeRange(0, _localMediaMessages.length - 200);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localKey(),
        jsonEncode(_localMediaMessages.map(_toLocalMap).toList()),
      );

      // Record the CDN URL in the static sent-URLs set so isOwn stays correct
      // even after _localMediaMessages is pruned.
      final url = msg.mediaUrl ?? '';
      if (url.isNotEmpty && !_isDeviceLocalPath(url)) {
        _sentUrls.add(url);
        await prefs.setString(
          _sentUrlsKey(),
          jsonEncode(_sentUrls.toList()),
        );
      }
    } catch (_) {}
  }

  /// Persists the current _localMediaMessages list (after removal).
  Future<void> _flushLocalMedia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localKey(),
        jsonEncode(_localMediaMessages.map(_toLocalMap).toList()),
      );
    } catch (_) {}
  }

  Map<String, dynamic> _toLocalMap(ChatMessage m) => {
        'id': m.id,
        'senderId': m.senderId,
        'senderName': m.senderName,
        'text': m.text,
        'kind': m.kind.name,
        'mediaUrl': m.mediaUrl ?? '',
        'mediaMimeType': m.mediaMimeType ?? '',
        'voiceDurationSeconds': m.voiceDurationSeconds ?? 0,
        'createdAt': m.createdAt.toIso8601String(),
        'isOwn': m.isOwn,
        'savedAt': DateTime.now().toIso8601String(),
      };

  ChatMessage? _fromLocalMap(Map<String, dynamic> m) {
    try {
      return ChatMessage(
        id: m['id'].toString(),
        senderId: m['senderId'].toString(),
        senderName: m['senderName'].toString(),
        text: m['text'].toString(),
        kind: ChatMessageKind.values.firstWhere(
          (k) => k.name == m['kind'].toString(),
          orElse: () => ChatMessageKind.text,
        ),
        mediaUrl: (m['mediaUrl'] as String?)?.isEmpty == false
            ? m['mediaUrl'].toString()
            : null,
        mediaMimeType: (m['mediaMimeType'] as String?)?.isEmpty == false
            ? m['mediaMimeType'].toString()
            : null,
        voiceDurationSeconds: m['voiceDurationSeconds'] as int?,
        createdAt: DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now(),
        isOwn: m['isOwn'] == true,
        isOptimistic: false,
      );
    } catch (_) {
      return null;
    }
  }

  List<ChatMessage> _mergeWithOptimistic(List<ChatMessage> server) {
    final serverIds = server.map((m) => m.id).toSet();
    final now = DateTime.now();

    // Prune confirmed/stale optimistics.
    // IMPORTANT: No kind-match requirement — the server may return kind:'TEXT'
    // for messages that were sent as images/voice, so we match media optimistics
    // by (isOwn + timestamp) rather than (kind + timestamp).
    _optimisticMessages.removeWhere((o) {
      if (serverIds.contains(o.id)) return true;
      if (now.difference(o.createdAt).inMinutes > 5) return true;
      for (final s in server) {
        if (o.kind == ChatMessageKind.text) {
          if (s.text == o.text && s.text.isNotEmpty) return true;
        } else {
          // Media optimistic: only match own server messages that also have
          // a media URL (or non-text kind). Matching plain text messages caused
          // false positives — nearby texts prematurely pruned the video optimistic.
          if (s.isOwn &&
              s.createdAt.difference(o.createdAt).inSeconds.abs() <= 60 &&
              ((s.mediaUrl ?? '').isNotEmpty || s.kind != ChatMessageKind.text)) {
            return true;
          }
        }
      }
      return false;
    });

    // Inject CDN URLs into server messages that lack them.
    //
    // Strategy 1 — session cache by ID (synchronous, no async, survives
    //   controller recreations within the same app session).
    // Strategy 2 — timestamp proximity from locally saved outgoing media
    //   (fallback when the server never returned the URL at all).
    //
    // Neither strategy requires a specific `kind` value — the server may
    // return kind:'TEXT' even for image/voice messages.
    // Inject CDN URLs only into OWN messages that the server returned without
    // a URL (rare — can happen when the CDN URL is not yet propagated).
    // Restricting to isOwn prevents cross-contamination: if Tony's local video
    // URL gets injected into Sally's message, the _sentUrls check would then
    // incorrectly force Sally's message to isOwn:true, moving it to the right.
    final patchedServer = server.map((s) {
      if ((s.mediaUrl ?? '').isNotEmpty) return s;

      // Strategy 1: session-cache lookup by message ID (O(1), always safe).
      final byId = _cachedUrl(s.id);
      if ((byId ?? '').isNotEmpty) {
        return s.copyWith(mediaUrl: byId);
      }

      // Strategy 2: timestamp match — ONLY for own messages.
      // Never inject into others' messages: if their message happens to be near
      // a locally sent video, the CDN URL would be wrong and _sentUrls would
      // then flip isOwn:true for their message, putting it on the wrong side.
      if (!s.isOwn) return s;
      if (s.text.isNotEmpty) return s;

      ChatMessage? best;
      var bestDiff = const Duration(seconds: 121);
      for (final local in _localMediaMessages) {
        final localUrl = local.mediaUrl ?? '';
        if (localUrl.isEmpty || _isDeviceLocalPath(localUrl)) continue;
        final diff = s.createdAt.difference(local.createdAt).abs();
        if (diff < bestDiff) {
          bestDiff = diff;
          best = local;
        }
      }
      if (best != null) {
        _recordUrl(s.id, best.mediaUrl!);
        return s.copyWith(
          mediaUrl: best.mediaUrl,
          mediaMimeType: (best.mediaMimeType ?? '').isNotEmpty
              ? best.mediaMimeType
              : s.mediaMimeType,
        );
      }
      return s;
    }).toList();

    // Prune local media entries only when the EXACT CDN URL appears in a
    // confirmed server message. Timestamp-based pruning caused false positives:
    // a nearby text or image from someone else would silently delete a voice
    // entry that was still needed.
    _localMediaMessages.removeWhere((local) {
      final localUrl = local.mediaUrl ?? '';
      if (localUrl.isEmpty || _isDeviceLocalPath(localUrl)) return true;
      return patchedServer.any((s) => s.mediaUrl == localUrl);
    });

    // CDN URLs already covered by an active optimistic — don't show the local
    // entry separately while the optimistic is still in the list.
    final optimisticCdnUrls = _optimisticMessages
        .map((o) => o.mediaUrl ?? '')
        .where((u) => u.isNotEmpty && !_isDeviceLocalPath(u))
        .toSet();

    final localIds = patchedServer.map((m) => m.id).toSet();

    // Build localOnly: apply local deletion state correctly.
    // DELETED_FOR_ME   → exclude entirely (hidden, same as classroom).
    // DELETED_FOR_EVERYONE → include but mark so the stamp shows (same as classroom).
    final localOnly = _localMediaMessages
        .where((m) {
          if (localIds.contains(m.id)) return false;
          final url = m.mediaUrl ?? '';
          final urlDel = url.isNotEmpty ? _deletedUrls[url] : null;
          final del = _localDeleted[m.id] ?? urlDel;
          // DELETED_FOR_ME: hide completely.
          if (del == 'DELETED_FOR_ME') return false;
          if (url.isNotEmpty && !_isDeviceLocalPath(url)) {
            if (optimisticCdnUrls.contains(url)) return false;
            // If the server version of this URL is DELETED_FOR_ME, hide.
            if (patchedServer.any((s) =>
                s.mediaUrl == url && _localDeleted[s.id] == 'DELETED_FOR_ME')) {
              return false;
            }
          }
          return true; // DELETED_FOR_EVERYONE or normal → keep
        })
        .map((m) {
          // Apply DELETED_FOR_EVERYONE stamp to local entries (by id or URL).
          final url = m.mediaUrl ?? '';
          final urlDel = url.isNotEmpty ? _deletedUrls[url] : null;
          final del = _localDeleted[m.id] ?? urlDel;
          if (del == 'DELETED_FOR_EVERYONE') {
            return m.copyWith(deletedForEveryone: true, mediaUrl: null);
          }
          // Check if server version with same URL is DELETED_FOR_EVERYONE.
          if (url.isNotEmpty) {
            final serverDel = patchedServer
                .where((s) => s.mediaUrl == url)
                .map((s) => _localDeleted[s.id])
                .firstWhere((d) => d != null, orElse: () => null);
            if (serverDel == 'DELETED_FOR_EVERYONE') {
              return m.copyWith(deletedForEveryone: true, mediaUrl: null);
            }
          }
          return m;
        })
        .toList();

    final merged = [...patchedServer, ...localOnly, ..._optimisticMessages];
    merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Deduplicate by message ID to prevent GlobalKey conflicts when the same
    // message appears in both patchedServer and localOnly.
    final seen = <String>{};
    final deduped = merged.where((m) => seen.add(m.id)).toList();

    _cachedMessages = deduped;
    // Session-scoped last-known snapshot: a NEW controller instance for a
    // recently opened thread renders this instantly (and on fetch failure)
    // instead of a spinner / error page, while the live fetch refreshes it.
    // Bounded so a session that opens many long threads can't grow this map
    // without limit: keep only the most-recent slice per thread, and evict the
    // oldest OTHER thread once we hold more than _kLastMsgThreadCap.
    _staticLastMessages[_threadId] = deduped.length > _kLastMsgPerThread
        ? deduped.sublist(deduped.length - _kLastMsgPerThread)
        : deduped;
    if (_staticLastMessages.length > _kLastMsgThreadCap) {
      final oldest = _staticLastMessages.keys
          .firstWhere((k) => k != _threadId, orElse: () => _threadId);
      if (oldest != _threadId) _staticLastMessages.remove(oldest);
    }
    return deduped;
  }

  @override
  AsyncValue<List<ChatMessage>> watchMessages(WidgetRef ref) {
    final provider = messageThreadProvider(_threadId);
    final threadAsync = ref.watch(provider);

    // skipLoadingOnRefresh: true means: while the provider is refreshing after
    // invalidate(), still call data() with the PREVIOUS thread value so that
    // _mergeWithOptimistic() can inject newly added optimistics into the list.
    // The manual _cachedMessages check was removed because it returned stale
    // data (without the new optimistic) and bypassed this mechanism.
    return threadAsync.when(
      skipLoadingOnRefresh: true,
      data: (thread) {
        // In a 1:1 DM the thread title IS the other person's display name.
        // Use it as a last-resort fallback so participants with no displayName
        // still have a readable name in their message bubbles.
        final threadTitle = thread.isGroup ? '' : thread.title.trim();

        final participantNames = <String, String>{
          for (final p in thread.participants)
            if (p.userId.isNotEmpty)
              p.userId: p.displayName.isNotEmpty
                  ? p.displayName
                  : (p.userId != _currentUserId ? threadTitle : ''),
        };
        // Baseline "older exists?" comes from the recent window. Once we've
        // paged older messages in, loadOlder() owns the flag (it knows the
        // deeper boundary), so don't let the window's value clobber it.
        if (_olderRaw.isEmpty) {
          _hasMoreOlder = thread.hasMoreOlder;
        }
        // Older pages (fetched on scroll) sit above the live recent window.
        // Converted here so names use the freshest participant map; dedup in
        // _mergeWithOptimistic handles any overlap.
        final older = _olderRaw
            .map((item) => _convertMessageItem(item, participantNames))
            .toList();
        final window = thread.messages
            .map((item) => _convertMessageItem(item, participantNames))
            .toList();
        final server = [...older, ...window];
        return AsyncValue.data(_mergeWithOptimistic(server));
      },
      loading: () {
        final fallback =
            _cachedMessages.isNotEmpty ? _cachedMessages : _staticLastMessages[_threadId];
        return (fallback != null && fallback.isNotEmpty)
            ? AsyncValue.data(fallback)
            : const AsyncValue.loading();
      },
      error: (err, stack) {
        final fallback =
            _cachedMessages.isNotEmpty ? _cachedMessages : _staticLastMessages[_threadId];
        return (fallback != null && fallback.isNotEmpty)
            ? AsyncValue.data(fallback)
            : AsyncValue.error(err, stack);
      },
    );
  }

  @override
  Future<void> retryInitialLoad() async {
    ref.invalidate(messageThreadProvider(_threadId));
    invalidate();
  }

  ChatMessage _convertMessageItem(MessageItem item,
      [Map<String, String> participantNames = const {}]) {
    final kind = _parseKind(item.kind);
    final deletedForMe = item.deleteState == 'DELETED_FOR_ME';
    final deletedForEveryone = item.deleteState == 'DELETED_FOR_EVERYONE';

    // Resolve the media URL using a two-way cache:
    // • If the server returns a CDN URL → store it so future re-entries can
    //   recover it even if the server omits it later.
    // • If the server omits the URL → inject it from the cache.
    String? mediaUrl = item.mediaUrl;

    if ((mediaUrl ?? '').isNotEmpty && !_isDeviceLocalPath(mediaUrl!)) {
      _recordUrl(item.id, mediaUrl);
    } else {
      final cached = _cachedUrl(item.id);
      if ((cached ?? '').isNotEmpty) mediaUrl = cached;
    }

    // Apply immediate local deletion state (set before server confirmation).
    // Two keys are consulted: the message id AND the media URL. The URL is the
    // durable identifier — it is stable even when the id changes between the
    // optimistic bubble and the server row, so a voice note deleted before the
    // server roundtrip completed stays deleted on re-entry instead of coming
    // "back alive".
    final localDelete = _localDeleted[item.id];
    final urlDelete =
        (mediaUrl ?? '').isNotEmpty ? _deletedUrls[mediaUrl] : null;
    final textDelete = (item.text.trim().isNotEmpty && (mediaUrl ?? '').isEmpty)
        ? _deletedTexts[_textSig(item.senderId, item.text)]
        : null;
    final resolvedDeletedForMe = deletedForMe ||
        localDelete == 'DELETED_FOR_ME' ||
        urlDelete == 'DELETED_FOR_ME' ||
        textDelete == 'DELETED_FOR_ME';
    final resolvedDeletedForEveryone = deletedForEveryone ||
        localDelete == 'DELETED_FOR_EVERYONE' ||
        urlDelete == 'DELETED_FOR_EVERYONE' ||
        textDelete == 'DELETED_FOR_EVERYONE';

    // Once a URL is marked deleted-for-everyone, the media must never be
    // resolvable again — drop it so no bubble can render or replay it.
    if (resolvedDeletedForEveryone) {
      mediaUrl = null;
    }

    // Compensating server delete: if WE deleted this for everyone while it was
    // still a local/optimistic bubble, the API call may have hit a 404 (the
    // server didn't know the id yet). Now that the server row exists and still
    // reports itself visible, re-issue the delete once so it's gone for the
    // peer and on our other devices too. Fire-and-forget; guarded so it runs
    // at most once per id.
    // What this viewer intended for this message, resolved via any durable key.
    final intendedDelete = urlDelete ?? textDelete ?? localDelete;
    final serverAlreadyDeleted = deletedForEveryone || deletedForMe;
    if (intendedDelete != null &&
        !serverAlreadyDeleted &&
        !item.id.startsWith('local-') &&
        !item.id.startsWith('optimistic-') &&
        // deleteForEveryone requires ownership; deleteForMe works for any msg.
        (intendedDelete == 'DELETED_FOR_ME' ||
            item.isMine ||
            item.senderId == _currentUserId) &&
        _reDeleteAttempted.add(item.id)) {
      // Promote the real server id into the id map so hiding never depends on
      // the re-delete round-trip succeeding, then push it to the server so the
      // deletion persists (for the peer on everyone-deletes, and per-user on
      // this account's other devices).
      _localDeleted[item.id] = intendedDelete;
      _persistLocalDeleted();
      _repo
          .deleteMessage(
            threadId: _threadId,
            messageId: item.id,
            mode: intendedDelete == 'DELETED_FOR_EVERYONE'
                ? 'deleteForEveryone'
                : 'deleteForMe',
          )
          .catchError((_) {});
    }

    // Server's isMine is authoritative (compared server-side as senderId === viewerId).
    // UUID comparison is a secondary check for cases where the server omits isMine.
    // The _sentUrls fallback is intentionally removed: it would flip isOwn:true for
    // any message whose URL matches a locally sent URL — exactly what causes the
    // other person's video to appear on the wrong (right) side when Strategy 2
    // accidentally injected our CDN URL into their message.
    final bool isOwn = item.isMine ||
        (item.senderId.isNotEmpty && item.senderId == _currentUserId);

    // Resolve sender name: server value → participant map → cached message name.
    String resolvedSenderName = item.senderName.isNotEmpty
        ? item.senderName
        : (participantNames[item.senderId] ?? '');
    if (resolvedSenderName.isEmpty && item.senderId.isNotEmpty) {
      // Last resort: find the name in the cached message list (survives re-entries).
      final cached = _cachedMessages
          .where((m) => m.senderId == item.senderId && m.senderName.isNotEmpty)
          .firstOrNull;
      if (cached != null) resolvedSenderName = cached.senderName;
    }

    return ChatMessage(
      id: item.id,
      senderId: item.senderId,
      senderName: resolvedSenderName,
      text: item.text,
      kind: kind,
      mediaUrl: mediaUrl,
      mediaMimeType: item.mediaMimeType,
      voiceDurationSeconds: item.voiceDurationSeconds,
      voicePlayed: item.voicePlayed,
      createdAt: item.sentAtDate ?? DateTime.now(),
      editedAt: item.edited ? DateTime.now() : null,
      replyToMessageId: item.replyToMessageId,
      replyToSenderName: item.replyPreview?.senderName,
      replyToText: item.replyPreview?.text,
      replyToKind: item.replyPreview?.kind,
      replyToMediaUrl: item.replyPreview?.mediaUrl,
      reactions: item.reactions,
      deletedForMe: resolvedDeletedForMe,
      deletedForEveryone: resolvedDeletedForEveryone,
      pinned: item.isPinned,
      isOwn: isOwn,
      forwarded: item.forwarded,
      delivered: item.delivered,
      seen: item.seen,
      deliveredAt: item.deliveredAtDate,
      seenAt: item.seenAtDate,
    );
  }

  ChatMessageKind _parseKind(String kind) {
    final upper = kind.toUpperCase();
    switch (upper) {
      case 'IMAGE':
        return ChatMessageKind.image;
      case 'FILE':
      case 'VIDEO':
        return ChatMessageKind.file;
      case 'VOICE':
        return ChatMessageKind.voice;
      case 'POLL':
        return ChatMessageKind.poll;
      case 'EVENT':
        return ChatMessageKind.event;
      case 'SYSTEM':
        return ChatMessageKind.system;
      default:
        return ChatMessageKind.text;
    }
  }

  ChatMessage? _findCachedMessage(String id) {
    for (final m in _cachedMessages) {
      if (m.id == id) return m;
    }
    for (final m in _optimisticMessages) {
      if (m.id == id) return m;
    }
    return null;
  }

  // Mirrors the wire enum the server uses for replyToKind so the
  // optimistic bubble's quoted preview chooses the right icon /
  // truncation logic that ChatMessageBubble uses for real messages.
  String? _kindToWire(ChatMessageKind k) => switch (k) {
        ChatMessageKind.text => 'TEXT',
        ChatMessageKind.image => 'IMAGE',
        ChatMessageKind.voice => 'VOICE',
        ChatMessageKind.file => 'FILE',
        ChatMessageKind.poll => 'POLL',
        ChatMessageKind.event => 'EVENT',
        ChatMessageKind.system => 'SYSTEM',
      };

  @override
  Future<void> sendText(String text, {String? replyToMessageId}) async {
    // When the caller passed a replyToMessageId, look up the target in
    // the current message cache so the optimistic bubble renders with
    // the quoted-reply header on the FIRST frame. Without this the
    // bubble paints as a plain message, then "blinks" into a reply when
    // the server confirms — exactly the bug the user reported.
    final replyTarget = replyToMessageId == null
        ? null
        : _findCachedMessage(replyToMessageId);
    final optimistic = ChatMessage(
      id: 'optimistic-${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId,
      senderName: 'You',
      text: text,
      kind: ChatMessageKind.text,
      createdAt: DateTime.now(),
      isOwn: true,
      isOptimistic: true,
      replyToMessageId: replyToMessageId,
      replyToSenderName: replyTarget?.senderName,
      replyToText: replyTarget?.text,
      replyToKind: replyTarget == null
          ? null
          : _kindToWire(replyTarget.kind),
      replyToMediaUrl: replyTarget?.mediaUrl,
    );
    _optimisticMessages.add(optimistic);
    // Trigger an immediate rebuild so the optimistic message appears in the list
    // before the network round-trip completes.  The view's .then() calls
    // invalidate() again once the server confirms.
    invalidate();
    try {
      await _repo.sendMessage(
        threadId: _threadId,
        text: text,
        replyToMessageId: replyToMessageId,
      );
    } finally {
      _optimisticMessages.remove(optimistic);
    }
  }

  /// Best-effort kind + mime guess from a local file's extension so the
  /// optimistic bubble (which paints before the upload finishes and the
  /// server hands back the canonical mime) doesn't render a video as an
  /// image, etc.
  ({ChatMessageKind kind, String? mime}) _kindFromFile(File f) {
    final ext = f.path.split('.').last.toLowerCase();
    const imageExts = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic', 'heif'};
    const videoExts = {'mp4', 'mov', 'm4v', '3gp', 'webm', 'avi', 'mkv'};
    const audioExts = {'m4a', 'aac', 'mp3', 'wav', 'ogg', 'opus', 'caf'};
    if (imageExts.contains(ext)) {
      return (kind: ChatMessageKind.image, mime: 'image/${ext == 'jpg' ? 'jpeg' : ext}');
    }
    if (videoExts.contains(ext)) {
      return (kind: ChatMessageKind.file, mime: 'video/${ext == 'mov' ? 'quicktime' : ext}');
    }
    if (audioExts.contains(ext)) {
      return (kind: ChatMessageKind.voice, mime: 'audio/$ext');
    }
    return (kind: ChatMessageKind.file, mime: null);
  }

  String _kindWireValue(ChatMessageKind k, String? mime) {
    // Server DTO requires uppercase values (TEXT/IMAGE/VOICE/VIDEO/FILE).
    // Sending lowercase was failing class-validator's @IsIn check with
    // "kind must be one of the following values: TEXT, IMAGE, VOICE,
    // VIDEO, FILE" — every photo/voice send from DM failed silently.
    // Classroom chat already used uppercase; DM is the outlier.
    final m = (mime ?? '').toLowerCase();
    if (k == ChatMessageKind.image || m.startsWith('image/')) return 'IMAGE';
    if (m.startsWith('video/')) return 'VIDEO';
    if (k == ChatMessageKind.voice || m.startsWith('audio/')) return 'VOICE';
    return 'FILE';
  }

  @override
  Future<void> sendMedia(
    List<File> files, {
    String? caption,
    String? replyToMessageId,
  }) async {
    // Show optimistic messages immediately (local file paths shown while uploading).
    final optimistics = <ChatMessage>[];
    final guesses = files.map(_kindFromFile).toList();
    // Reply target — only the FIRST optimistic carries the quoted
    // header so it matches what the server returns (reply attaches to
    // one message, not every file in the batch).
    final replyTarget = replyToMessageId == null
        ? null
        : _findCachedMessage(replyToMessageId);
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final g = guesses[i];
      final optimistic = ChatMessage(
        id: 'optimistic-${DateTime.now().millisecondsSinceEpoch}-$i',
        senderId: _currentUserId,
        senderName: 'You',
        text: i == 0 ? (caption ?? '') : '',
        kind: g.kind,
        mediaUrl: file.path,
        mediaMimeType: g.mime,
        createdAt: DateTime.now(),
        isOwn: true,
        isOptimistic: true,
        replyToMessageId: i == 0 ? replyToMessageId : null,
        replyToSenderName: i == 0 ? replyTarget?.senderName : null,
        replyToText: i == 0 ? replyTarget?.text : null,
        replyToKind: i == 0 && replyTarget != null
            ? _kindToWire(replyTarget.kind)
            : null,
        replyToMediaUrl: i == 0 ? replyTarget?.mediaUrl : null,
      );
      optimistics.add(optimistic);
      _optimisticMessages.add(optimistic);
    }
    invalidate(); // show optimistic bubbles immediately

    // No finally removal — _mergeWithOptimistic() prunes once server confirms.
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final optimistic = optimistics[i];
      final guess = guesses[i];
      final uploadResult = await _repo.uploadDmMedia(file.path);
      final mediaUrl = _pickUploadUrl(uploadResult);
      final mimeType = _pickUploadMime(uploadResult) ?? guess.mime;

      if (mediaUrl != null) {
        // Persist BEFORE sendMessage so the CDN URL is saved even if
        // sendMessage fails or the outer catchError swallows the exception.
        await _saveLocalMedia(ChatMessage(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}-media-$i',
          senderId: _currentUserId,
          senderName: 'You',
          text: i == 0 ? (caption ?? '') : '',
          kind: guess.kind,
          mediaUrl: mediaUrl,
          mediaMimeType: mimeType,
          createdAt: optimistic.createdAt,
          isOwn: true,
        ));

        // Swap local path → CDN URL so image is immediately viewable.
        final idx = _optimisticMessages.indexOf(optimistic);
        if (idx >= 0) {
          _optimisticMessages[idx] =
              optimistic.copyWith(mediaUrl: mediaUrl, mediaMimeType: mimeType);
          invalidate();
        }

        await _repo.sendMessage(
          threadId: _threadId,
          text: i == 0 ? (caption ?? '') : '',
          replyToMessageId: replyToMessageId,
          kind: _kindWireValue(guess.kind, mimeType),
          mediaUrl: mediaUrl,
          mediaMimeType: mimeType,
        );
      }
    }
  }

  @override
  Future<void> sendVoice(
    File file,
    Duration duration, {
    String? replyToMessageId,
  }) async {
    // Optimistic voice bubble shown immediately using the local file path.
    final replyTarget = replyToMessageId == null
        ? null
        : _findCachedMessage(replyToMessageId);
    final optimistic = ChatMessage(
      id: 'optimistic-${DateTime.now().millisecondsSinceEpoch}-voice',
      senderId: _currentUserId,
      senderName: 'You',
      text: '',
      kind: ChatMessageKind.voice,
      mediaUrl: file.path,
      voiceDurationSeconds: duration.inSeconds,
      createdAt: DateTime.now(),
      isOwn: true,
      isOptimistic: true,
      replyToMessageId: replyToMessageId,
      replyToSenderName: replyTarget?.senderName,
      replyToText: replyTarget?.text,
      replyToKind: replyTarget == null
          ? null
          : _kindToWire(replyTarget.kind),
      replyToMediaUrl: replyTarget?.mediaUrl,
    );
    _optimisticMessages.add(optimistic);
    invalidate(); // show optimistic immediately; .then() will invalidate again post-upload

    // No finally removal — _mergeWithOptimistic() prunes once server confirms.
    final uploadResult = await _repo.uploadDmMedia(file.path);
    final mediaUrl = _pickUploadUrl(uploadResult);
    final mimeType = _pickUploadMime(uploadResult);

    if (mediaUrl != null) {
      // Persist BEFORE sendMessage so the CDN URL is saved even if sendMessage
      // fails or the caller's catchError swallows the exception.
      await _saveLocalMedia(ChatMessage(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}-voice',
        senderId: _currentUserId,
        senderName: 'You',
        text: '',
        kind: ChatMessageKind.voice,
        mediaUrl: mediaUrl,
        mediaMimeType: mimeType,
        voiceDurationSeconds: duration.inSeconds,
        createdAt: optimistic.createdAt,
        isOwn: true,
      ));

      // Swap optimistic local path → CDN URL so the bubble is immediately playable.
      final idx = _optimisticMessages.indexOf(optimistic);
      if (idx >= 0) {
        _optimisticMessages[idx] =
            optimistic.copyWith(mediaUrl: mediaUrl, mediaMimeType: mimeType);
        invalidate();
      }

      await _repo.sendMessage(
        threadId: _threadId,
        text: '',
        replyToMessageId: replyToMessageId,
        kind: 'VOICE',
        mediaUrl: mediaUrl,
        mediaMimeType: mimeType,
      );
    }
  }

  @override
  Future<void> editMessage(String messageId, String newText) async {
    await _repo.editMessage(
      threadId: _threadId,
      messageId: messageId,
      text: newText,
    );
  }

  @override
  Future<void> deleteMessage(String messageId,
      {required ChatDeleteMode mode}) async {
    // Apply deletion immediately so the UI updates without waiting for a refetch.
    _optimisticMessages.removeWhere((m) => m.id == messageId);
    _localDeleted[messageId] = mode == ChatDeleteMode.deleteForEveryone
        ? 'DELETED_FOR_EVERYONE'
        : 'DELETED_FOR_ME';

    // Find the CDN URL of the deleted message.  The visible bubble may be a
    // local entry (id = 'local-xxx-voice') while the server knows it by a
    // different real ID — we need the URL as the stable cross-ID identifier.
    final deletedUrl = _cachedMessages
        .where((m) => m.id == messageId)
        .map((m) => m.mediaUrl ?? '')
        .firstWhere((u) => u.isNotEmpty, orElse: () => '');

    final modeLabel = mode == ChatDeleteMode.deleteForEveryone
        ? 'DELETED_FOR_EVERYONE'
        : 'DELETED_FOR_ME';

    // Durable, id-independent record for TEXT: keep this message hidden even
    // when its id changes (optimistic→server) or the app restarts. Mirrors the
    // URL map for media. Only meaningful for text-only messages.
    final deletedMsg = _cachedMessages.where((m) => m.id == messageId).firstOrNull;
    if (deletedMsg != null &&
        (deletedMsg.mediaUrl ?? '').isEmpty &&
        deletedMsg.text.trim().isNotEmpty) {
      _deletedTexts[_textSig(deletedMsg.senderId, deletedMsg.text)] = modeLabel;
    }

    if (deletedUrl.isNotEmpty) {
      // Durable, id-independent record: any message (now or in the future, with
      // any id) carrying this URL stays deleted. This is what makes deletion
      // unbreakable across the optimistic→server id swap and app restarts.
      _deletedUrls[deletedUrl] = modeLabel;

      // Mark ALL messages (by ID) that share this CDN URL as deleted.
      // This covers both the server message ID AND any local IDs like
      // 'local-xxx-voice' — local IDs persist in SharedPreferences and will
      // be matched on re-entry to keep the message hidden.
      for (final m in _cachedMessages) {
        if (m.mediaUrl == deletedUrl) {
          _localDeleted[m.id] = modeLabel;
        }
      }
      for (final l in _localMediaMessages) {
        if (l.mediaUrl == deletedUrl) {
          _localDeleted[l.id] = modeLabel;
        }
      }
      _optimisticMessages.removeWhere((m) => m.mediaUrl == deletedUrl);
      // DELETED_FOR_ME → remove entirely so the message is invisible.
      // DELETED_FOR_EVERYONE → keep in list so the stamp can be rendered;
      //   the localOnly .map() step transforms it to deletedForEveryone: true.
      if (mode == ChatDeleteMode.deleteForMe) {
        _localMediaMessages.removeWhere((l) => l.mediaUrl == deletedUrl);
        _flushLocalMedia();
      }
    }

    // Persist the deletion state so it survives exit + re-entry.
    _persistLocalDeleted();

    invalidate();

    // Find the real server-assigned message ID to use for the API call.
    // The incoming messageId might be a local ID like 'local-xxx-voice' (for
    // messages that came from _localMediaMessages).  The server doesn't know
    // about those IDs and returns 404, which would leave the message undeleted
    // on the server — meaning it reappears (with no stamp) on the next re-entry.
    String serverMessageId = messageId;
    if (deletedUrl.isNotEmpty &&
        (messageId.startsWith('local-') || messageId.startsWith('optimistic-'))) {
      // Look for a server-confirmed message with the same URL.
      for (final m in _cachedMessages) {
        if (m.mediaUrl == deletedUrl &&
            !m.id.startsWith('local-') &&
            !m.id.startsWith('optimistic-')) {
          serverMessageId = m.id;
          break;
        }
      }
    }

    final modeStr = mode == ChatDeleteMode.deleteForEveryone
        ? 'deleteForEveryone'
        : 'deleteForMe';
    try {
      await _repo.deleteMessage(
        threadId: _threadId,
        messageId: serverMessageId,
        mode: modeStr,
      );
    } catch (e) {
      // 404 = message was never confirmed server-side (optimistic/local-only).
      // Local deletion is still correct — the message won't come back from server.
      if (e.toString().contains('404') ||
          e.toString().toLowerCase().contains('not found')) {
        return;
      }
      // Other errors: revert local state.
      _localDeleted.remove(messageId);
      _persistLocalDeleted();
      invalidate();
      rethrow;
    }
  }

  @override
  Future<void> togglePin(String messageId) async {
    await _repo.togglePin(threadId: _threadId, messageId: messageId);
  }

  @override
  Future<void> react(String messageId, String? emoji) async {
    await _repo.reactMessage(
      threadId: _threadId,
      messageId: messageId,
      emoji: emoji,
    );
  }

  @override
  Future<void> reportMessage(String messageId, {String? reason}) async {
    await _repo.reportMessage(
      threadId: _threadId,
      messageId: messageId,
      reason: reason,
    );
  }

  @override
  Future<void> markRead() async {
    await _repo.markThreadRead(threadId: _threadId);
    // Refresh the inbox so unread badge drops immediately.
    try { ref.invalidate(messagesInboxProvider); } catch (_) {}
  }

  // ── Typing ────────────────────────────────────────────────────────────────

  @override
  AsyncValue<bool> watchTyping(WidgetRef ref) =>
      ref.watch(dmPeerTypingProvider(_threadId));

  DateTime _lastTypingSignal = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void notifyTyping() {
    // The peer-side indicator stays lit 4s per signal, so one ping every
    // 2.5s of continuous typing keeps it on without hammering the API.
    final now = DateTime.now();
    if (now.difference(_lastTypingSignal).inMilliseconds < 2500) return;
    _lastTypingSignal = now;
    // Fire-and-forget; the repo already swallows network errors.
    _repo.notifyTyping(threadId: _threadId);
  }

  @override
  Future<void> markVoicePlayed(String messageId) async {
    try {
      await _repo.markThreadRead(threadId: _threadId);
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
      sourceThreadType: ChatThreadType.direct,
      sourceThreadId: _threadId,
    );
  }

  @override
  Future<void> forwardMessages(
    List<String> messageIds,
    List<ForwardTarget> targets,
  ) async {
    if (targets.isEmpty) return;

    // Split targets by type so each message is forwarded via the correct API.
    final dmTargetIds = targets
        .whereType<ForwardTargetDm>()
        .map((t) => t.threadId)
        .toList();
    final classroomTargets = targets
        .whereType<ForwardTargetClassroom>()
        .toList();

    final classroomsRepo = ref.read(classroomsRepoProvider);

    for (final messageId in messageIds) {
      // DM → DM: use the messages API
      if (dmTargetIds.isNotEmpty) {
        await _repo.forwardMessage(
          fromThreadId: _threadId,
          messageId: messageId,
          targetThreadIds: dmTargetIds,
        );
      }
      // DM → Classroom: use the classrooms API per target course
      for (final ct in classroomTargets) {
        try {
          await classroomsRepo.forwardChatMessage(
            ct.courseId,
            messageId: messageId,
            targetThreadIds: [ct.courseId],
          );
        } catch (_) {
          // Fallback: try the messages forward API with the classroom id
          await _repo.forwardMessage(
            fromThreadId: _threadId,
            messageId: messageId,
            targetThreadIds: [ct.courseId],
          );
        }
      }
    }
  }

  @override
  void invalidate() {
    ref.invalidate(messageThreadProvider(_threadId));
  }
}
