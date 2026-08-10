import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router.dart';

import '../core/theme/theme_controller.dart';
import '../core/locale/locale_controller.dart';
import '../core/auth/auth_controller.dart';
import '../core/update/update_gate.dart';
import '../features/lifedoc/notifications_local_service.dart';
import '../features/lifedoc/notifications_provider.dart';
import '../ui/nav/desktop_chrome_shell.dart';
import '../l10n/app_localizations.dart';

final appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Persisted set of notification ids already surfaced as an OS notification /
/// snackbar, so each one fires exactly once across syncs and app launches.
const String _shownNotificationIdsKey = 'shown_notification_ids_v1';

class ClassMateApp extends ConsumerWidget {
  const ClassMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    final router = ref.watch(routerProvider);

    // One curated palette per theme. Concrete themes pin their own brightness;
    // only `system` follows the OS between the plain Light / Dark defaults.
    final themes = resolveAppTheme(t);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      // Flutter web overwrites the browser <title> from this at runtime; with
      // no title it blanks it and the tab falls back to showing the URL. Set
      // the full marketing title on web so every tab/route reads
      // "ClassMate — Your Smart School Companion" (matches the marketing site).
      // On mobile keep the short name so the OS task switcher isn't cluttered.
      onGenerateTitle: (_) =>
          kIsWeb ? 'ClassMate — Your Smart School Companion' : 'ClassMate',
      scaffoldMessengerKey: appScaffoldMessengerKey,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Only the locales we actually ship translations for (one .arb each).
      // de/pt/tr were listed here without any .arb, so the app could resolve to
      // a locale with zero translations (all-English UI) — removed.
      supportedLocales: const [
        Locale('en'), Locale('ar'), Locale('he'),
        Locale('fr'), Locale('ru'),
        // Pseudo-locale for translation-leak detection. Wraps every
        // translated string in ‹‹ ... ›› — switch to it in Settings to
        // visually flag any hardcoded English. Generated from app_en.arb
        // by scripts/generate_pseudo_locale.dart.
        Locale('ps'),
      ],
      themeMode: themes.mode,
      theme: themes.light,
      darkTheme: themes.dark,
      builder: (context, child) {
        final mediaQuery = MediaQuery.maybeOf(context);
        // Accessibility (WCAG 1.4.4 / IS 5568): honor the OS / Dynamic-Type
        // font-size setting instead of discarding it. Take the incoming OS
        // scale factor, multiply it by the in-app preference (the Settings
        // slider still works as a user multiplier on top), and clamp the
        // RESULT to at most 2.0 (200%). So a user who bumps their phone's
        // system font size is respected up to 200%, and the in-app slider
        // continues to fine-tune on top of that.
        final osScale = MediaQuery.textScalerOf(context).scale(1.0);
        final combinedScale = (osScale * t.textScale).clamp(0.85, 2.0);
        // Wrap the router's root navigator in the always-on desktop/tablet
        // chrome (persistent sidebar + top bar). It sits ABOVE the root
        // navigator so it survives every push — including full-screen
        // `rootNavigator: true` routes. No-op on phones. See DesktopChromeShell.
        final chromed = DesktopChromeShell(
          router: router,
          child: child ?? const SizedBox.shrink(),
        );
        final scaledChild = MediaQuery(
          data: (mediaQuery ?? const MediaQueryData()).copyWith(
            textScaler: TextScaler.linear(combinedScale),
            // Reduce-motion: flips the OS-level "disable animations" flag for
            // the whole tree. Hero flights, page transitions that honor it,
            // and our own widgets (which read MediaQuery.disableAnimations)
            // all go instant. The route helpers in router.dart and the
            // bottom-nav pill read this same flag, so one toggle quiets the
            // entire app's motion.
            disableAnimations: t.reduceMotion,
          ),
          child: chromed,
        );
        // Dismiss the keyboard whenever any scrollable below us starts a user
        // drag. Per-screen `keyboardDismissBehavior: onDrag` is the same idea
        // but inconsistently applied — this is the global safety net so a
        // text-input-bearing screen never needs to remember to opt in.
        final dismissOnDragChild = NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n is ScrollStartNotification && n.dragDetails != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
            return false;
          },
          child: scaledChild,
        );
        // Detail screens are native iOS pages (CupertinoPage) → they provide
        // the finger-following swipe-back themselves; top-level tabs keep the
        // Scaffold's native swipe-to-open-drawer. No custom edge gesture
        // needed (a custom one would fight the native back gesture).
        // The app's own shell already provides a proper desktop layout on wide
        // viewports (persistent nav rail + content capped at a readable width,
        // à la Twitter/Instagram web — see AppShell, breakpoint 900px). So we
        // hand off directly and let it fill the window; no extra frame (an
        // earlier max-width wrapper fought the shell and squished the rail).
        // UpdateGate paints ABOVE everything (chrome + all routes): the
        // once-per-release "a new version is ready" card with a jump to the
        // store — see core/update/update_gate.dart.
        return _NotificationReceiverHost(
          child: UpdateGate(child: dismissOnDragChild),
        );
      },
    );
  }
}

class _NotificationReceiverHost extends ConsumerStatefulWidget {
  const _NotificationReceiverHost({required this.child});

  final Widget child;

  @override
  ConsumerState<_NotificationReceiverHost> createState() =>
      _NotificationReceiverHostState();
}

class _NotificationReceiverHostState
    extends ConsumerState<_NotificationReceiverHost>
    with WidgetsBindingObserver {
  Timer? _poller;
  StreamSubscription<String>? _tapSubscription;
  bool _didBaseline = false;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureLocalNotifications();
      _sync(baselineIfNeeded: true);
    });
    _poller = Timer.periodic(const Duration(minutes: 1), (_) {
      _sync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poller?.cancel();
    _tapSubscription?.cancel();
    super.dispose();
  }

  Future<void> _configureLocalNotifications() async {
    final notifications = ref.read(localNotificationsServiceProvider);
    await notifications.initialize();
    await notifications.requestPermissions();

    _tapSubscription ??= notifications.tapStream.listen(_openNotificationsInbox);

    final pendingNotificationId = notifications.takePendingNotificationId();
    if ((pendingNotificationId ?? '').isNotEmpty) {
      _openNotificationsInbox(pendingNotificationId!);
    }
  }

  void _openNotificationsInbox(String payload) {
    if (!mounted) return;
    final clean = payload.trim();
    if (clean.isEmpty) return;
    // Payload is 'source|id' (new format) or just 'id' (legacy).
    final route = LocalNotificationsService.routeFromPayload(clean);
    // Route through the GoRouter INSTANCE, never `context.push`.
    //
    // This widget lives in `MaterialApp.router`'s `builder`, which runs ABOVE
    // the router's own Navigator — so `InheritedGoRouter` is not in this
    // context and `context.push` throws "No GoRouter found in context". It
    // only ever threw for someone who actually tapped a notification, which is
    // why it survived to production: the common path never touches this line.
    ref.read(routerProvider).push(route);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sync(baselineIfNeeded: true);
    }
  }

  Future<void> _sync({bool baselineIfNeeded = false}) async {
    if (!mounted || _syncing) return;

    final session = ref.read(authSessionProvider);
    if (!session.ready || !session.isLoggedIn) {
      return;
    }

    _syncing = true;
    try {
      final synced = await ref.read(notificationSyncServiceProvider).sync(
            baselineIfEmpty: baselineIfNeeded && !_didBaseline,
          );
      _didBaseline = true;

      if (!mounted || synced.isEmpty) return;

      // Only raise an OS notification / snackbar for REAL server-pushed
      // events — never for the client-derived insight items ("all good",
      // "grade risk", etc.), which recompute on every sync and were
      // re-firing constantly. And guard each id with a persisted set so a
      // given notification is surfaced exactly once, even if a later sync
      // returns it again.
      final prefs = await SharedPreferences.getInstance();
      final shown = (prefs.getStringList(_shownNotificationIdsKey) ?? const <String>[]).toSet();
      final newItems = synced
          .where((item) => !item.isLocal && item.id.trim().isNotEmpty && !shown.contains(item.id))
          .toList(growable: false);
      if (newItems.isEmpty) return;
      shown.addAll(newItems.map((item) => item.id));
      // Cap the persisted set so it can't grow unbounded.
      final capped = shown.toList();
      if (capped.length > 500) capped.removeRange(0, capped.length - 500);
      await prefs.setStringList(_shownNotificationIdsKey, capped);

      final localNotifications = ref.read(localNotificationsServiceProvider);
      for (final item in newItems) {
        await localNotifications.showNotification(item);
      }

      final first = newItems.first;
      final extra = newItems.length > 1 ? ' +${newItems.length - 1} more' : '';
      appScaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${first.title}$extra'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
    } finally {
      _syncing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
