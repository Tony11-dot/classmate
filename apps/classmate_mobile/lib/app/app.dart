import 'dart:async';

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
        Locale('fr'), Locale('ru'),
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
        return _NotificationReceiverHost(child: scaledChild);
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

  void _openNotificationsInbox(String notificationId) {
    if (!mounted) return;
    final cleanId = notificationId.trim();
    if (cleanId.isEmpty) return;
    context.push('/notifications');
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
