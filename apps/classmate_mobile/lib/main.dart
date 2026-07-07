import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'core/app_restart.dart';
import 'core/auth/auth_session.dart';
import 'core/config/env.dart';
import 'features/onboarding/onboarding_controller.dart';
import 'core/push/push_notifications_service.dart';
import 'core/realtime/realtime_listener.dart';
import 'features/billing/data/revenuecat_service.dart';
import 'ui/widgets/splash_screen.dart';

// Sentry DSN for the "classmate-app" project. A Sentry DSN is a write-only
// client ingestion key — it can only SEND error events, never read anything —
// so it's safe to ship in the binary (it's already public in any deployed
// build). Kept as a default here so every release build reports with no extra
// build flags; a --dart-define=SENTRY_DSN can still override it. Reporting is
// gated on release mode below, so local debug runs never spam Sentry.
const _sentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue:
      'https://66f592c9b2752d72912c700c5b91deb9@o4511514135887872.ingest.de.sentry.io/4511514153975888',
);
const _sentryEnv =
    String.fromEnvironment('SENTRY_ENV', defaultValue: 'production');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init();
  // Seed the first-launch onboarding flag before the first frame so the
  // router's (synchronous) redirect can decide whether to show the
  // walkthrough without awaiting SharedPreferences.
  try {
    final prefs = await SharedPreferences.getInstance();
    onboardingSeenAtBoot = prefs.getBool(kOnboardingSeenKey) ?? false;
  } catch (_) {
    onboardingSeenAtBoot = false;
  }
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

  void runRoot() => runApp(const _Bootstrap());

  // Release builds only — never report from local debug `flutter run`.
  if (_sentryDsn.isEmpty || !kReleaseMode) {
    runRoot();
  } else {
    // SentryFlutter.init installs FlutterError + zone error handlers, so
    // uncaught Dart/Flutter errors and crashes report automatically — with
    // the screen, OS, and app version attached. Errors only (no perf
    // tracing) to stay free and add no runtime overhead.
    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;
        options.environment = _sentryEnv;
        options.tracesSampleRate = 0.0;
      },
      appRunner: runRoot,
    );
  }
}

/// Holds the root [ProviderScope] under a swappable key so [AppRestart] can
/// tear the whole tree down and rebuild it (a true account-switch "fresh
/// world"). Lives ABOVE the scope, so it itself survives the restart.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  Key _scopeKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    AppRestart.register(_restart);
  }

  @override
  void dispose() {
    AppRestart.unregister(_restart);
    super.dispose();
  }

  void _restart() {
    if (mounted) setState(() => _scopeKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(key: _scopeKey, child: const _RootApp());
  }
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
        // Follow the OS light/dark here (no MediaQuery exists above this
        // MaterialApp, so read the platform dispatcher directly). The splash
        // itself already picks the matching light/dark animation + colors —
        // this keeps the surrounding scaffold from flashing white in dark
        // mode on launch AND on the account-switch restart.
        final platformDark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: platformDark ? Brightness.dark : Brightness.light,
          ),
          home: Scaffold(
            // Match the splash content's background end-to-end (native splash
            // → Dart splash → first app frame) so there is no color flash at
            // any boundary, in either appearance.
            backgroundColor: platformDark ? Colors.black : Colors.white,
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
