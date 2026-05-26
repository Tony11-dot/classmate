import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/auth/auth_session.dart';
import 'core/config/env.dart';
import 'core/push/push_notifications_service.dart';
import 'core/realtime/realtime_listener.dart';
import 'features/billing/data/revenuecat_service.dart';
import 'ui/widgets/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init();
  // Lock the app to portrait — landscape layouts are not designed for and
  // produce broken-looking screens on phones.
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // RevenueCat — configure as early as possible so by the time the
  // user opens the Plans screen we already have offerings cached.
  // No-ops cleanly on web / Android-without-key, so safe to always call.
  RevenueCatService.instance.configure();
  // Hook AuthSession → RevenueCat so every JWT change re-identifies
  // the RC user. The session doesn't import the SDK directly to keep
  // its dependency surface small; we register the factory here.
  AuthSession.registerRcServiceFactory(() => RevenueCatService.instance);
  // Firebase / FCM init. No-ops gracefully when firebase_options.dart
  // or the native config files aren't present yet, so safe to always
  // call — the app still boots without push.
  unawaited(PushNotificationsService.instance.init());
  // Hook AuthSession → push registration so every login/logout updates
  // the device's bound user on the backend.
  AuthSession.registerPushService(PushNotificationsService.instance);
  runApp(const ProviderScope(child: _RootApp()));
}

class _RootApp extends StatefulWidget {
  const _RootApp();

  @override
  State<_RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<_RootApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    // After splash: hand off to the full app (which has its own MaterialApp, theme, etc.)
    if (_splashDone) return const RealtimeListener(child: ClassMateApp());

    // Wrap splash in a minimal MaterialApp so Directionality, DefaultTextStyle,
    // MediaQuery, etc. are all available — avoids "No Directionality widget found"
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      home: Scaffold(
        // White all the way through — matches native splash, matches Dart
        // splash, matches the icon's white-baked background. No more
        // black flashes at any boundary.
        backgroundColor: Colors.white,
        body: SplashScreen(
          onComplete: () {
            if (mounted) setState(() => _splashDone = true);
          },
        ),
      ),
    );
  }
}
