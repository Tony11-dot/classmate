import 'package:flutter/widgets.dart';

/// Global hook to hard-restart the ENTIRE Riverpod provider tree — a true
/// "fresh world" like Instagram/Gmail account switching.
///
/// The root [ProviderScope] in main.dart lives under a swappable key; calling
/// [restart] regenerates that key, which disposes the whole provider container
/// (every provider, cache, controller, socket) and rebuilds it from scratch.
/// The new tree's AuthSession reads the newly-active account's token from
/// storage, so there is zero cross-account data bleed on switch OR on logout →
/// re-login.
///
/// Non-Riverpod state (static fields, SharedPreferences) SURVIVES a scope
/// restart, so the auth layer clears those explicitly BEFORE calling [restart].
class AppRestart {
  AppRestart._();

  static VoidCallback? _hook;

  /// Wired once by the root bootstrap widget in main.dart.
  static void register(VoidCallback hook) => _hook = hook;

  static void unregister(VoidCallback hook) {
    if (identical(_hook, hook)) _hook = null;
  }

  /// Tear down and rebuild the whole provider tree. No-op before the app has
  /// mounted (e.g. during early startup).
  static void restart() => _hook?.call();
}
