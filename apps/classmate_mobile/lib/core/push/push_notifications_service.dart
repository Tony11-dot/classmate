// ignore_for_file: avoid_print
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonEncode;

import '../../firebase_options.dart';
import '../config/env.dart';

/// Top-level handler — required by FCM for messages that arrive while
/// the app is fully terminated. Must not reference any Flutter widgets
/// or context (it runs in a separate isolate).
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Foreground/background banners are handled by the OS automatically
  // from the `notification` field — nothing for us to do here unless we
  // want side effects on terminated app (bookkeeping, badge counts).
  if (kDebugMode) {
    print('[push] background message: ${message.messageId} ${message.data}');
  }
}

/// Push-notifications glue. Owns:
///   • Firebase init (no-op if firebase_options.dart isn't generated yet)
///   • Permission request
///   • Token fetch + POST to /api/devices/register
///   • Token refresh hook (FCM rotates tokens periodically)
///   • Foreground tap routing — exposed via [onMessageTap] so the app
///     shell can listen and call go_router.push().
///
/// Designed to fail silently when Firebase isn't configured yet — the
/// app still boots, the user just doesn't get pushes until config is
/// uploaded and they re-launch. This lets us ship the code path before
/// the Firebase console is finalized.
class PushNotificationsService {
  PushNotificationsService._();
  static final PushNotificationsService instance = PushNotificationsService._();

  bool _initialized = false;
  String? _currentToken;

  /// Stream of `data` payloads from a notification the user tapped on
  /// (either from background or terminated state). The app shell
  /// subscribes and routes to the matching screen.
  final List<void Function(Map<String, dynamic>)> _tapListeners = [];

  void onMessageTap(void Function(Map<String, dynamic> data) handler) {
    _tapListeners.add(handler);
  }

  /// Call once from main() AFTER WidgetsFlutterBinding.ensureInitialized().
  /// Idempotent — safe to call multiple times.
  Future<void> init() async {
    if (_initialized) return;
    try {
      // Pass explicit options from the generated firebase_options.dart so
      // init works the same way across iOS, Android, macOS, Web, and
      // Windows. The native config files (google-services.json /
      // GoogleService-Info.plist) still drive APNs token resolution on
      // iOS — `options` covers everything else.
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      if (kDebugMode) print('[push] Firebase init skipped: $e');
      return;
    }
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Foreground messages — let the system banner show on iOS via the
    // default notification presentation options. On Android, the system
    // tray already handles foreground notifications when the payload
    // includes a `notification` field.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Tap-from-background — the user opened a message that was sitting
    // in the tray. Fan it out to listeners.
    FirebaseMessaging.onMessageOpenedApp.listen(_onTap);

    // Tap-from-terminated — the app launched because of a notification
    // tap. The initial message is available exactly once on startup.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      // Slight delay so the router is mounted before we try to push().
      Future.delayed(const Duration(milliseconds: 600), () => _onTap(initial));
    }
  }

  void _onTap(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    for (final h in List.of(_tapListeners)) {
      try {
        h(data);
      } catch (e) {
        if (kDebugMode) print('[push] tap handler threw: $e');
      }
    }
  }

  /// Request push permission, then register the device token with the
  /// backend. Call after the user successfully signs in (we need the
  /// JWT in [authToken] to authorize the register call).
  Future<void> registerForUser({required String authToken}) async {
    if (!_initialized) return;
    if (authToken.isEmpty) return;

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        if (kDebugMode) print('[push] permission denied');
        return;
      }
    } catch (e) {
      if (kDebugMode) print('[push] permission request failed: $e');
      return;
    }

    // iOS needs APNs token before FCM can mint one — getAPNSToken returns
    // null when called too early; the FCM SDK handles the wait internally,
    // we just need to call getToken() and let it block.
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) print('[push] getToken failed: $e');
      return;
    }
    if (token == null || token.isEmpty) return;
    _currentToken = token;

    await _postToken(authToken: authToken, token: token);

    // Token rotation — every time FCM mints a new token (rare but
    // happens), re-register with the backend. The current authToken
    // is captured in this closure.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _currentToken = newToken;
      _postToken(authToken: authToken, token: newToken);
    });
  }

  /// Tell the backend to forget this device — called on sign-out so
  /// the previous account stops getting pushes routed to this phone.
  Future<void> unregisterForUser({required String authToken}) async {
    final token = _currentToken;
    if (!_initialized) return;
    if (token == null || token.isEmpty) return;
    try {
      final base = Env.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$base/devices/$token');
      await http.delete(uri, headers: {
        'Authorization': 'Bearer $authToken',
      });
    } catch (_) {
      // Swallow — token will get reaped by FCM eventually anyway.
    }
    _currentToken = null;
  }

  Future<void> _postToken({required String authToken, required String token}) async {
    try {
      final base = Env.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$base/devices/register');
      await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      );
    } catch (e) {
      if (kDebugMode) print('[push] register POST failed: $e');
    }
  }
}
