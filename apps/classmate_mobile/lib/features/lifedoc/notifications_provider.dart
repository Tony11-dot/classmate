import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_controller.dart';
import '../parent/data/viewed_student_context.dart';
import '../insights/domain/insights_models.dart';
import '../insights/providers/insights_providers.dart';
import 'announcements_models.dart';
import 'announcements_provider.dart';
import 'notifications_api.dart';
import 'notifications_models.dart';

const _localNotificationsPrefsKey = 'lifedoc_notifications_local_v2';
const _knownRemoteNotificationsPrefsKey = 'lifedoc_notifications_known_remote_ids_v1';
const _notificationReadOverridesPrefsKey = 'lifedoc_notifications_read_overrides_v1';

final persistedNotificationsProvider =
    FutureProvider<List<StudentNotificationItem>>((ref) async {
      final api = ref.watch(notificationsApiProvider);
      try {
        return await api.list(limit: 100);
      } catch (_) {
        return const <StudentNotificationItem>[];
      }
    });

final localNotificationsProvider =
    AsyncNotifierProvider<LocalNotificationsController, List<StudentNotificationItem>>(
      LocalNotificationsController.new,
    );

final notificationInboxProvider =
    FutureProvider<List<StudentNotificationItem>>((ref) async {
      final persisted = await ref.watch(persistedNotificationsProvider.future);
      final local = await ref.watch(localNotificationsProvider.future);
      final merged = _mergeNotifications(<StudentNotificationItem>[...persisted, ...local]);
      return _applyReadOverrides(merged);
    });

final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final items = await ref.watch(notificationInboxProvider.future);
  return items.where((item) => !item.isRead).length;
});

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref);
});

final notificationSyncServiceProvider = Provider<NotificationSyncService>((ref) {
  return NotificationSyncService(ref);
});

class LocalNotificationsController extends AsyncNotifier<List<StudentNotificationItem>> {
  @override
  Future<List<StudentNotificationItem>> build() async {
    return _loadStoredItems();
  }

  Future<List<StudentNotificationItem>> sync({bool baselineIfEmpty = false}) async {
    final current = state.asData?.value ?? await _loadStoredItems();
    final derived = await _buildDerivedNotifications(ref);

    if (current.isEmpty && baselineIfEmpty) {
      final seeded = _mergeNotifications(derived);
      state = AsyncData(seeded);
      await _persist(seeded);
      return const <StudentNotificationItem>[];
    }

    final existingIds = current.map((item) => item.id).toSet();
    final newItems = derived
        .where((item) => !existingIds.contains(item.id))
        .toList(growable: false);

    if (newItems.isEmpty) {
      final refreshed = _mergeNotifications(<StudentNotificationItem>[...current, ...derived]);
      if (!_sameIds(current, refreshed)) {
        state = AsyncData(refreshed);
        await _persist(refreshed);
      }
      return const <StudentNotificationItem>[];
    }

    final next = _mergeNotifications(<StudentNotificationItem>[...newItems, ...current, ...derived]);
    state = AsyncData(next);
    await _persist(next);
    return newItems;
  }

  Future<void> markRead(String id) async {
    final current = state.asData?.value ?? await _loadStoredItems();
    final next = current
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList(growable: false);
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> markUnread(String id) async {
    final current = state.asData?.value ?? await _loadStoredItems();
    final next = current
        .map((item) => item.id == id ? item.copyWith(isRead: false) : item)
        .toList(growable: false);
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> markAllRead() async {
    final current = state.asData?.value ?? await _loadStoredItems();
    final next = current.map((item) => item.copyWith(isRead: true)).toList(growable: false);
    state = AsyncData(next);
    await _persist(next);
  }

  Future<List<StudentNotificationItem>> _loadStoredItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localNotificationsPrefsKey);
    if ((raw ?? '').trim().isEmpty) return const <StudentNotificationItem>[];

    try {
      final decoded = jsonDecode(raw!);
      if (decoded is! List) return const <StudentNotificationItem>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => StudentNotificationItem.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const <StudentNotificationItem>[];
    }
  }

  Future<void> _persist(List<StudentNotificationItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localNotificationsPrefsKey,
      jsonEncode(items.map((item) => item.toJson()).toList(growable: false)),
    );
  }
}

class NotificationActions {
  const NotificationActions(this.ref);

  final Ref ref;

  Future<void> markRead(StudentNotificationItem item) async {
    if (item.isLocal) {
      await ref.read(localNotificationsProvider.notifier).markRead(item.id);
    } else {
      // Fire-and-forget server sync: a transient network/offline failure must
      // NOT throw (the local read-override below still marks it read in the UI,
      // and the server reconciles on the next successful load). Swallowing here
      // keeps DNS/"Failed host lookup" errors out of Sentry.
      try {
        await ref.read(notificationsApiProvider).markSeen(<String>[item.id]);
        ref.invalidate(persistedNotificationsProvider);
      } catch (_) {
        // ignored — best-effort, reconciled on next sync
      }
    }
    await _setReadOverride(item.id, true);
    ref.invalidate(notificationInboxProvider);
  }

  Future<void> markUnread(StudentNotificationItem item) async {
    if (item.isLocal) {
      await ref.read(localNotificationsProvider.notifier).markUnread(item.id);
    }
    await _setReadOverride(item.id, false);
    ref.invalidate(notificationInboxProvider);
  }

  Future<void> markAllRead(List<StudentNotificationItem> items) async {
    final localItems = items.where((item) => item.isLocal).toList(growable: false);
    final remoteIds = items
        .where((item) => !item.isLocal && !item.isRead)
        .map((item) => item.id)
        .toList(growable: false);

    if (localItems.isNotEmpty) {
      await ref.read(localNotificationsProvider.notifier).markAllRead();
    }
    if (remoteIds.isNotEmpty) {
      // Best-effort server sync — offline/DNS failures are swallowed (the local
      // overrides below still mark everything read; next sync reconciles).
      try {
        await ref.read(notificationsApiProvider).markSeen(remoteIds);
        ref.invalidate(persistedNotificationsProvider);
      } catch (_) {
        // ignored — best-effort
      }
    }
    await _setReadOverrides(items.map((item) => item.id), true);
    ref.invalidate(notificationInboxProvider);
  }

  Future<void> _setReadOverride(String id, bool isRead) async {
    await _setReadOverrides(<String>[id], isRead);
  }

  Future<void> _setReadOverrides(Iterable<String> ids, bool isRead) async {
    final overrides = await _loadReadOverrides();
    for (final rawId in ids) {
      final id = rawId.trim();
      if (id.isEmpty) {
        continue;
      }
      overrides[id] = isRead;
    }
    await _persistReadOverrides(overrides);
  }
}

class NotificationSyncService {
  const NotificationSyncService(this.ref);

  final Ref ref;

  Future<List<StudentNotificationItem>> sync({bool baselineIfEmpty = false}) async {
    final session = ref.read(authSessionProvider);
    if (!session.ready || !session.isLoggedIn) {
      return const <StudentNotificationItem>[];
    }

    ref.invalidate(unifiedStudentInsightsProvider);
    ref.invalidate(persistedNotificationsProvider);

    final newLocal = await ref
        .read(localNotificationsProvider.notifier)
        .sync(baselineIfEmpty: baselineIfEmpty);

    List<StudentNotificationItem> remoteItems = const <StudentNotificationItem>[];
    try {
      remoteItems = await ref.read(persistedNotificationsProvider.future);
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final knownRemoteIds = (prefs.getStringList(_knownRemoteNotificationsPrefsKey) ?? const <String>[])
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();

    final currentRemoteIds = remoteItems.map((item) => item.id).where((item) => item.trim().isNotEmpty).toSet();
    final remoteNew = baselineIfEmpty && knownRemoteIds.isEmpty
        ? const <StudentNotificationItem>[]
        : remoteItems.where((item) => !knownRemoteIds.contains(item.id)).toList(growable: false);

    // Persist the UNION of every remote id we've ever seen — NOT just the
    // current fetch. Overwriting with only the current page meant a
    // notification that scrolled out of the (capped) inbox fetch was treated
    // as brand-new again on the next sync, re-firing its in-app banner "out
    // of nowhere". Keep the freshest ids on the tail and cap the set so it
    // can't grow without bound.
    const maxKnownIds = 800;
    final mergedKnown = <String>[];
    final seenKnown = <String>{};
    for (final id in <String>[...knownRemoteIds, ...currentRemoteIds]) {
      if (seenKnown.add(id)) mergedKnown.add(id);
    }
    final trimmedKnown = mergedKnown.length > maxKnownIds
        ? mergedKnown.sublist(mergedKnown.length - maxKnownIds)
        : mergedKnown;
    await prefs.setStringList(
      _knownRemoteNotificationsPrefsKey,
      trimmedKnown,
    );

    ref.invalidate(notificationInboxProvider);
    return _mergeNotifications(<StudentNotificationItem>[...remoteNew, ...newLocal]);
  }
}

Future<List<StudentNotificationItem>> _buildDerivedNotifications(Ref ref) async {
  // These are STUDENT insight alerts (grade risk, weak subject, low
  // attendance, …) derived from the viewer's own academic data. They make no
  // sense for a teacher/admin/secretary — suppress them unless the viewer is a
  // student (or a parent viewing a child, who sees the child's insights).
  final session = ref.read(authSessionProvider);
  final isStudent = session.primaryRole == 'STUDENT';
  final isParentViewingChild =
      session.roles.contains('PARENT') && ref.read(viewedStudentIdProvider) != null;
  if (!isStudent && !isParentViewingChild) {
    return const <StudentNotificationItem>[];
  }

  final announcements = ref.read(announcementsProvider);
  final items = <StudentNotificationItem>[];

  for (final announcement in announcements) {
    final severity = switch (announcement.severity) {
      AnnouncementSeverity.critical => StudentNotificationSeverity.critical,
      AnnouncementSeverity.warning => StudentNotificationSeverity.warning,
      AnnouncementSeverity.info => StudentNotificationSeverity.info,
    };

    items.add(
      StudentNotificationItem(
        id: 'local-announcement-${announcement.id}',
        title: announcement.title,
        body: announcement.body,
        source: announcement.source,
        createdAt: announcement.createdAt,
        severity: severity,
        isRead: false,
        isLocal: true,
      ),
    );
  }

  UnifiedStudentInsights? unified;
  try {
    unified = await ref.read(unifiedStudentInsightsProvider.future);
  } catch (_) {
    unified = null;
  }

  if (unified == null) {
    return _mergeNotifications(items);
  }

  for (final grade in unified.grades.latest) {
    final createdAt = _parseFlexibleDate(grade.date) ?? _parseFlexibleDate(unified.generatedAt) ?? DateTime.now();
    final subjectLabel = grade.subject.trim().isNotEmpty ? grade.subject.trim() : grade.courseName.trim();
    items.add(
      StudentNotificationItem(
        id: 'local-grade-${grade.id}',
        title: subjectLabel.isEmpty ? 'New grade posted' : 'New grade posted in $subjectLabel',
        template: subjectLabel.isEmpty
            ? StudentNotificationTemplate.newGradePosted
            : StudentNotificationTemplate.newGradePostedIn,
        templateArgs: subjectLabel.isEmpty ? const {} : {'subject': subjectLabel},
        body: '${grade.assessmentTitle.trim().isEmpty ? 'Assessment' : grade.assessmentTitle.trim()} • ${grade.label ?? '${grade.grade.toStringAsFixed(grade.grade % 1 == 0 ? 0 : 1)} / ${grade.maxGrade ?? 100}'}',
        source: 'grades',
        createdAt: createdAt,
        severity: grade.grade < 70 ? StudentNotificationSeverity.warning : StudentNotificationSeverity.info,
        isRead: false,
        isLocal: true,
      ),
    );
  }

  for (final attendance in unified.attendance.latest) {
    final normalizedStatus = attendance.status.trim().toLowerCase();
    if (normalizedStatus == 'present') {
      continue;
    }

    final createdAt = _parseFlexibleDate(attendance.date) ?? DateTime.now();
    final subjectLabel = (attendance.subject ?? '').trim().isNotEmpty
        ? attendance.subject!.trim()
        : (attendance.courseName ?? '').trim();
    final title = switch (normalizedStatus) {
      'absent' => 'New absence recorded',
      'late' => 'Late attendance recorded',
      'justified' => 'Attendance updated as justified',
      _ => 'Attendance updated',
    };
    final bodyParts = <String>[];
    if (subjectLabel.isNotEmpty) bodyParts.add(subjectLabel);
    if (attendance.period > 0) bodyParts.add('Period ${attendance.period}');
    bodyParts.add(attendance.status);

    items.add(
      StudentNotificationItem(
        id: 'local-attendance-${attendance.date}-${attendance.period}-${attendance.status}-$subjectLabel',
        title: title,
        body: bodyParts.join(' • '),
        source: 'attendance',
        createdAt: createdAt,
        severity: normalizedStatus == 'absent'
            ? StudentNotificationSeverity.critical
            : normalizedStatus == 'late'
            ? StudentNotificationSeverity.warning
            : StudentNotificationSeverity.info,
        isRead: false,
        isLocal: true,
      ),
    );
  }

  return _mergeNotifications(items);
}

DateTime? _parseFlexibleDate(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return null;

  final iso = DateTime.tryParse(value);
  if (iso != null) return iso;

  final slash = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{2,4})$').firstMatch(value);
  if (slash != null) {
    final first = int.tryParse(slash.group(1)!);
    final second = int.tryParse(slash.group(2)!);
    final yearRaw = int.tryParse(slash.group(3)!);
    if (first != null && second != null && yearRaw != null) {
      final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;
      if (second > 12) {
        return DateTime.tryParse(
          '$year-${first.toString().padLeft(2, '0')}-${second.toString().padLeft(2, '0')}',
        );
      }
      return DateTime.tryParse(
        '$year-${second.toString().padLeft(2, '0')}-${first.toString().padLeft(2, '0')}',
      );
    }
  }

  final dash = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{2,4})$').firstMatch(value);
  if (dash != null) {
    final first = int.tryParse(dash.group(1)!);
    final second = int.tryParse(dash.group(2)!);
    final yearRaw = int.tryParse(dash.group(3)!);
    if (first != null && second != null && yearRaw != null) {
      final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;
      if (first > 12) {
        return DateTime.tryParse(
          '$year-${second.toString().padLeft(2, '0')}-${first.toString().padLeft(2, '0')}',
        );
      }
      return DateTime.tryParse(
        '$year-${first.toString().padLeft(2, '0')}-${second.toString().padLeft(2, '0')}',
      );
    }
  }

  return null;
}

List<StudentNotificationItem> _mergeNotifications(List<StudentNotificationItem> items) {
  final byId = <String, StudentNotificationItem>{};
  for (final item in items) {
    final existing = byId[item.id];
    if (existing == null || item.createdAt.isAfter(existing.createdAt)) {
      byId[item.id] = item;
    } else if (existing.id == item.id && existing.isRead != item.isRead && item.isRead) {
      byId[item.id] = item;
    }
  }

  final merged = byId.values.toList(growable: false)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return merged;
}

bool _sameIds(List<StudentNotificationItem> a, List<StudentNotificationItem> b) {
  if (a.length != b.length) return false;
  for (var index = 0; index < a.length; index++) {
    if (a[index].id != b[index].id || a[index].isRead != b[index].isRead) {
      return false;
    }
  }
  return true;
}

Future<Map<String, bool>> _loadReadOverrides() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_notificationReadOverridesPrefsKey);
  if ((raw ?? '').trim().isEmpty) {
    return <String, bool>{};
  }

  try {
    final decoded = jsonDecode(raw!);
    if (decoded is! Map) {
      return <String, bool>{};
    }
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value == true),
    );
  } catch (_) {
    return <String, bool>{};
  }
}

Future<void> _persistReadOverrides(Map<String, bool> overrides) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _notificationReadOverridesPrefsKey,
    jsonEncode(overrides),
  );
}

Future<List<StudentNotificationItem>> _applyReadOverrides(
  List<StudentNotificationItem> items,
) async {
  final overrides = await _loadReadOverrides();
  if (overrides.isEmpty) {
    return items;
  }

  return items
      .map((item) {
        final override = overrides[item.id];
        if (override == null || override == item.isRead) {
          return item;
        }
        return item.copyWith(isRead: override);
      })
      .toList(growable: false);
}
