import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifications_models.dart';

final localNotificationsServiceProvider = Provider<LocalNotificationsService>((
  ref,
) {
  return LocalNotificationsService.instance;
});

class LocalNotificationsService {
  LocalNotificationsService._();

  static final LocalNotificationsService instance =
      LocalNotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _tapController =
      StreamController<String>.broadcast();

  bool _initialized = false;
  String? _pendingNotificationId;

  Stream<String> get tapStream => _tapController.stream;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final launchPayload = launchDetails?.notificationResponse?.payload?.trim();
    if ((launchPayload ?? '').isNotEmpty) {
      _pendingNotificationId = launchPayload;
    }
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macos?.requestPermissions(alert: true, badge: true, sound: true);
  }

  String? takePendingNotificationId() {
    final pending = _pendingNotificationId;
    _pendingNotificationId = null;
    return pending;
  }

  Future<void> showNotification(StudentNotificationItem item) async {
    if (kIsWeb) return;
    await initialize();

    // A clean, minimal title with a leading category emoji — and NO ugly
    // machine-code subtitle line ("new_message", "grade_posted", …). The
    // title already says what happened; the emoji makes the type scannable.
    final title = _titleWithEmoji(item.title, item.source);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'classmate_updates',
        'ClassMate updates',
        channelDescription: 'Academic, classroom, and study notifications.',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.status,
        styleInformation: BigTextStyleInformation(item.body),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Payload encodes both source and id so we can deep-link on tap.
    await _plugin.show(
      id: _stableId(item.id),
      title: title,
      body: item.body,
      notificationDetails: details,
      payload: '${item.source}|${item.id}',
    );
  }

  /// Parses 'source|id' payload. Returns the in-app route for deep-linking.
  ///
  /// Source can be either the curated keys ('grades', 'messages', …) the
  /// app uses internally, OR the raw NotificationHub type enum
  /// ('NEW_EXAM', 'NEW_ASSIGNMENT', 'GRADE_POSTED', 'MESSAGE', …) the
  /// server stamps on each row. Both paths normalise to lowercase and
  /// route to the right tab so a tap on a push notification always
  /// lands where the user expects.
  static String routeFromPayload(String payload) {
    final parts = payload.trim().split('|');
    final source = parts.isNotEmpty ? parts.first.trim() : '';
    final id = parts.length > 1 ? parts[1].trim() : '';
    final s = source.toLowerCase();
    // Curated short-keys first.
    final curated = switch (s) {
      'grades' || 'grade' || 'grade_posted' => '/grades',
      'attendance' || 'attendance_marked' => '/attendance',
      'practice' || 'practice_completed' => '/practice',
      'solutions' || 'solution' => '/solutions',
      'solution_report' || 'solution_reported' || 'reported_solution' => '/admin/reports',
      'messages' || 'chat' || 'message' || 'new_message' || 'dm' || 'dm_message' => '/messages',
      'classrooms' || 'classroom' || 'classroom_message' => '/classrooms',
      'form' || 'forms' || 'new_form' =>
        id.isNotEmpty ? '/forms/$id' : '/forms',
      'assignments' || 'assignment' || 'new_assignment' =>
        id.isNotEmpty ? '/assignments/$id' : '/assignments',
      'meetings' || 'meeting' || 'new_meeting' =>
        id.isNotEmpty ? '/meetings/$id' : '/meetings',
      'announcements' || 'announcement' =>
        id.isNotEmpty ? '/announcements/$id' : '/announcements',
      'exam' || 'exams' || 'new_exam' =>
        id.isNotEmpty ? '/exams/$id' : '/exams',
      'material' || 'materials' || 'new_material' => '/materials',
      'diploma' || 'diplomas' || 'certificate' || 'new_diploma' => '/diplomas',
      'nova' || 'tutor' => '/tutor',
      _ => null,
    };
    return curated ?? '/notifications';
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload?.trim();
    if ((payload ?? '').isEmpty) return;
    _tapController.add(payload!);
  }

  int _stableId(String raw) {
    return raw.hashCode & 0x7fffffff;
  }

  /// Prepend a category emoji to the title unless it already starts with one
  /// (the backend's localized copy already carries the emoji, so we must not
  /// double it). Language-neutral: works for every locale.
  String _titleWithEmoji(String rawTitle, String source) {
    final title = rawTitle.trim();
    if (title.isEmpty) return _emojiForSource(source);
    if (_startsWithEmoji(title)) return title;
    return '${_emojiForSource(source)} $title';
  }

  /// Maps a notification source/type (curated key OR raw server enum, in any
  /// case, with '-' or '_' separators) to a single leading emoji.
  String _emojiForSource(String source) {
    final s = source.trim().toLowerCase().replaceAll('-', '_');
    switch (s) {
      case 'grade':
      case 'grades':
      case 'grade_posted':
        return '📊';
      case 'message':
      case 'messages':
      case 'new_message':
      case 'chat':
      case 'dm':
      case 'dm_message':
      case 'classroom_message':
        return '💬';
      case 'assignment':
      case 'assignments':
      case 'new_assignment':
        return '📝';
      case 'material':
      case 'materials':
      case 'new_material':
        return '📚';
      case 'meeting':
      case 'meetings':
      case 'new_meeting':
        return '📹';
      case 'exam':
      case 'exams':
      case 'new_exam':
        return '🎯';
      case 'form':
      case 'forms':
      case 'new_form':
        return '📋';
      case 'diploma':
      case 'diplomas':
      case 'certificate':
      case 'new_diploma':
        return '🏆';
      case 'announcement':
      case 'announcements':
        return '📣';
      case 'attendance':
      case 'attendance_alert':
      case 'attendance_marked':
        return '🚩';
      case 'classroom_invite':
      case 'classroom_update':
      case 'classrooms':
      case 'classroom':
        return '🎓';
      case 'solution':
      case 'solutions':
      case 'solution_report':
        return '💡';
      case 'practice':
      case 'practice_completed':
        return '🧠';
      case 'nova':
      case 'tutor':
        return '✨';
      default:
        return '🔔';
    }
  }

  /// True when the string's first character is in a common emoji range, so we
  /// don't prepend a second emoji to backend copy that already has one.
  bool _startsWithEmoji(String s) {
    if (s.isEmpty) return false;
    final r = s.runes.first;
    return (r >= 0x1F300 && r <= 0x1FAFF) || // symbols & pictographs, emoji
        (r >= 0x2600 && r <= 0x27BF) || // misc symbols + dingbats
        r == 0x2728 || // sparkles
        (r >= 0x1F1E6 && r <= 0x1F1FF); // regional indicators
  }
}