import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

import '../core/theme/theme_controller.dart';
import '../core/locale/locale_controller.dart';
import '../core/auth/auth_controller.dart';
import '../features/lifedoc/notifications_local_service.dart';
import '../features/lifedoc/notifications_provider.dart';
import '../l10n/app_localizations.dart';

final appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class ClassMateApp extends ConsumerWidget {
  const ClassMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      routerConfig: ref.watch(routerProvider),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), Locale('ar'), Locale('he'),
        Locale('fr'), Locale('ru'), Locale('de'),
        Locale('pt'), Locale('tr'),
        // Pseudo-locale for translation-leak detection. Wraps every
        // translated string in ‹‹ ... ›› — switch to it in Settings to
        // visually flag any hardcoded English. Generated from app_en.arb
        // by scripts/generate_pseudo_locale.dart.
        Locale('ps'),
      ],
      themeMode: t.mode,
      theme: buildTheme(brightness: Brightness.light, s: t),
      darkTheme: buildTheme(brightness: Brightness.dark, s: t),
      builder: (context, child) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final scaledChild = MediaQuery(
          data: (mediaQuery ?? const MediaQueryData()).copyWith(
            textScaler: TextScaler.linear(t.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
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
        final framed = kIsWeb
            ? _WebPhoneFrame(child: dismissOnDragChild)
            : dismissOnDragChild;
        return _NotificationReceiverHost(child: framed);
      },
    );
  }
}

/// Wraps the whole app in a centered phone-shaped frame when running on
/// web on a wide viewport. Below the breakpoint the child fills the
/// viewport edge-to-edge — same behavior as native mobile. Above it, the
/// app renders inside a fixed-width column flanked by a subtle gradient
/// so the existing mobile UI doesn't stretch awkwardly across a 27"
/// monitor. Per-screen responsive layouts can opt out by checking
/// MediaQuery.sizeOf(context).width themselves.
class _WebPhoneFrame extends StatelessWidget {
  const _WebPhoneFrame({required this.child});

  final Widget child;

  static const double _frameWidth = 520;
  static const double _breakpoint = 720;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width < _breakpoint) return child;

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : const Color(0xFFF2F2F7);
    final frameTint = isDark
        ? cs.surfaceContainerHighest
        : Colors.white;

    return ColoredBox(
      color: bg,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _frameWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: frameTint,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                  blurRadius: 40,
                  spreadRadius: 0,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRect(child: child),
          ),
        ),
      ),
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
    context.push(route);
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
      final newItems = await ref.read(notificationSyncServiceProvider).sync(
            baselineIfEmpty: baselineIfNeeded && !_didBaseline,
          );
      _didBaseline = true;

      if (!mounted || newItems.isEmpty) return;

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
