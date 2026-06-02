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
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: _sourceLabel(item.source),
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: _sourceLabel(item.source),
      ),
    );

    // Payload encodes both source and id so we can deep-link on tap.
    await _plugin.show(
      id: _stableId(item.id),
      title: item.title,
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
      'solution_report' || 'solution_reported' || 'reported_solution' => '/admin/solution-reports',
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

  String _sourceLabel(String source) {
    switch (source.trim().toLowerCase()) {
      case 'grades':
        return 'Grades';
      case 'attendance':
        return 'Attendance';
      case 'practice':
        return 'Practice';
      case 'solutions':
        return 'Solutions';
      case 'system':
        return 'System';
      default:
        return source.trim().isEmpty ? 'ClassMate' : source.trim();
    }
  }
}