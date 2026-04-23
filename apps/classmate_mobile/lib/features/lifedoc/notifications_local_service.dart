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

    await _plugin.show(
      id: _stableId(item.id),
      title: item.title,
      body: item.body,
      notificationDetails: details,
      payload: item.id,
    );
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