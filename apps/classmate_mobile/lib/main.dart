import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
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
  // TEMP web diagnostic: render build errors as readable text instead of a
  // blank/grey screen, so a startup crash is visible without DevTools.
  if (kIsWeb) {
    ErrorWidget.builder = (FlutterErrorDetails details) => Material(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              'ClassMate error — screenshot this:\n\n${details.exceptionAsString()}\n\n${details.stack}',
              style: const TextStyle(color: Color(0xFFB00020), fontSize: 12, height: 1.4),
            ),
          ),
        );
  }
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

class _RootApp extends ConsumerStatefulWidget {
  const _RootApp();

  @override
  ConsumerState<_RootApp> createState() => _RootAppState();
}

class _RootAppState extends ConsumerState<_RootApp> {
  bool _animationDone = false;
  bool _forceReady = false;

  @override
  void initState() {
    super.initState();
    // Safety net so the splash can NEVER trap the app on a white screen — e.g.
    // if the Lottie intro fails to fire onComplete (seen on web) or the auth
    // session stalls. After a short grace, stop waiting on the animation; after
    // a longer one, hand off regardless so the router lands on login/home.
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted && !_animationDone) setState(() => _animationDone = true);
    });
    Timer(const Duration(seconds: 9), () {
      if (mounted && !_forceReady) setState(() => _forceReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep the splash on screen until BOTH the intro animation has finished
    // AND the auth session has resolved (token loaded + /auth/me validated).
    // Previously we handed off as soon as the animation completed — for an
    // already-logged-in user the router's initialLocation (/login) rendered
    // for one frame before the redirect bounced them home, producing a
    // visible login flash. Gating on session readiness removes that: a
    // logged-out user lands straight on /login, a logged-in user straight
    // on their home, with no wrong-page blink in between.
    final session = ref.watch(authSessionProvider);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final ready = _forceReady || (_animationDone && session.ready);
        // After splash: hand off to the full app (which has its own
        // MaterialApp, theme, etc.)
        if (ready) return const RealtimeListener(child: ClassMateApp());

        // Wrap splash in a minimal MaterialApp so Directionality,
        // DefaultTextStyle, MediaQuery, etc. are all available — avoids
        // "No Directionality widget found".
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(brightness: Brightness.light),
          home: Scaffold(
            // White all the way through — matches native splash, matches
            // Dart splash, matches the icon's white-baked background. No
            // more black flashes at any boundary.
            backgroundColor: Colors.white,
            body: SplashScreen(
              onComplete: () {
                if (mounted) setState(() => _animationDone = true);
              },
            ),
          ),
        );
      },
    );
  }
}
