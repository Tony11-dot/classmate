import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Thin RevenueCat wrapper. The Flutter app's only entry point to the
/// purchase flow — every screen that buys / restores goes through here.
///
/// Why a wrapper:
///   - Single place to swap SDKs (we could replace RevenueCat with raw
///     in_app_purchase later without touching the paywall sheet)
///   - Keeps the SDK-init dance (configure + appUserID + invalidate)
///     out of UI code
///   - Lets us no-op on web / desktop without sprinkling Platform
///     checks across the codebase
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  /// Public iOS API key from RevenueCat. Safe to ship in source — RC
  /// validates against the app's bundle ID server-side, so a leaked key
  /// is useless to another app. The Android key is added once Google
  /// Play account verification clears and RC generates a goog_* key.
  static const String _iosApiKey = 'appl_YUklLZOkEIebPLhOndUSdEjOzQE';
  // ignore: unused_field
  static const String _androidApiKey = '';

  bool _configured = false;
  String? _currentAppUserId;

  /// Idempotent — call on app start. No-op on platforms we haven't
  /// shipped IAP on (web, desktop, Android until we have a goog_ key).
  Future<void> configure() async {
    if (_configured) return;
    if (kIsWeb) return;
    final String? key = _keyForCurrentPlatform();
    if (key == null || key.isEmpty) {
      // No key configured for this platform — paywall stays in
      // "Coming soon" mode until one is provided.
      return;
    }
    try {
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.warn,
      );
      await Purchases.configure(PurchasesConfiguration(key));
      _configured = true;
    } catch (e) {
      // eslint-disable-next-line no-console
      debugPrint('[rc] configure failed: $e');
    }
  }

  /// Bind RC purchases to our server user id. Called after login so
  /// every store event maps cleanly to a User row via app_user_id.
  /// Calling this with the same id is a no-op; switching ids triggers
  /// RC to migrate any anonymous purchases over.
  Future<void> identify(String userId) async {
    if (!_configured) return;
    if (userId.isEmpty || userId == _currentAppUserId) return;
    try {
      await Purchases.logIn(userId);
      _currentAppUserId = userId;
    } catch (e) {
      debugPrint('[rc] identify failed: $e');
    }
  }

  /// Called on logout. RC keeps the previous user's data linked to
  /// their userId — we just clear the local session so the next login
  /// gets a fresh state.
  Future<void> reset() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
      _currentAppUserId = null;
    } catch (_) {
      // Not logged in — fine.
    }
  }

  /// Returns the offering marked CURRENT in the RC dashboard. We named
  /// ours `main` (after the duplicate-default conflict during setup);
  /// if RC ever returns `current` instead we fall through to that.
  Future<Offering?> currentOffering() async {
    if (!_configured) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.getOffering('main') ?? offerings.current;
    } catch (e) {
      debugPrint('[rc] offerings failed: $e');
      return null;
    }
  }

  /// Look up the StoreProduct for one of our top-up product IDs.
  /// Top-ups aren't packaged in the RC offering — they're consumables
  /// fetched by raw product id and purchased directly.
  Future<StoreProduct?> topupProduct(String productId) async {
    if (!_configured) return null;
    try {
      final products = await Purchases.getProducts([productId]);
      return products.isEmpty ? null : products.first;
    } catch (e) {
      debugPrint('[rc] getProducts failed: $e');
      return null;
    }
  }

  /// Purchase a subscription package from the current offering.
  /// Returns the resulting CustomerInfo so the caller can check
  /// entitlements; throws PurchasesErrorCode.* on store-level failures.
  Future<CustomerInfo> purchasePackage(Package package) async {
    if (kIsWeb || !_configured) {
      throw StateError('Purchases unavailable on this platform');
    }
    final result = await Purchases.purchasePackage(package);
    return result;
  }

  /// Purchase a one-time consumable (token top-up). Same as above but
  /// uses the StoreProduct overload because top-ups aren't packages.
  Future<CustomerInfo> purchaseProduct(StoreProduct product) async {
    if (kIsWeb || !_configured) {
      throw StateError('Purchases unavailable on this platform');
    }
    final result = await Purchases.purchaseStoreProduct(product);
    return result;
  }

  /// Restore purchases — required by Apple's review guidelines for any
  /// app that sells subscriptions. The button calls this; RC pulls the
  /// receipts from Apple and re-syncs entitlements.
  Future<CustomerInfo> restorePurchases() async {
    if (kIsWeb || !_configured) {
      throw StateError('Purchases unavailable on this platform');
    }
    return Purchases.restorePurchases();
  }

  String? _keyForCurrentPlatform() {
    if (Platform.isIOS || Platform.isMacOS) return _iosApiKey;
    if (Platform.isAndroid) {
      return _androidApiKey.isEmpty ? null : _androidApiKey;
    }
    return null;
  }
}
