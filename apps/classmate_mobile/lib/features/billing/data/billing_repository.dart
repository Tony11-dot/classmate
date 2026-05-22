import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';
import 'plan_models.dart';

final billingRepositoryProvider = Provider.autoDispose<BillingRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return BillingRepository(token: token);
});

class PlansCatalog {
  const PlansCatalog({required this.subscriptions, required this.topups});
  final List<SubscriptionPlan> subscriptions;
  final List<TopupPack> topups;
}

class BillingRepository {
  BillingRepository({required this.token});
  final String token;

  CMApi get _api => CMApi(token: token);

  /// Fetches the server-owned plan catalog. The Plans screen renders
  /// straight from this so we can adjust prices/quotas/copy without a
  /// Flutter release.
  Future<PlansCatalog> fetchCatalog() async {
    final raw = await _api.getJson('/billing/plans');
    if (raw is! Map) {
      return const PlansCatalog(subscriptions: [], topups: []);
    }
    final subs = (raw['subscriptions'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
    final tops = (raw['topups'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => TopupPack.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
    return PlansCatalog(subscriptions: subs, topups: tops);
  }

  /// Authed call — returns this user's balance + active tier. Falls
  /// back to a synthetic FREE snapshot on 401 / network errors so the
  /// UI always has something to render.
  Future<BalanceSnapshot> fetchBalance() async {
    try {
      final raw = await _api.getJson('/billing/me');
      if (raw is Map && raw['balance'] is Map) {
        return BalanceSnapshot.fromJson(
            Map<String, dynamic>.from(raw['balance'] as Map));
      }
    } catch (_) {
      // fall through to synthetic
    }
    return BalanceSnapshot(
      planTokensRemaining: 0,
      topupTokensRemaining: 0,
      totalRemaining: 0,
      resetAt: null,
      activeTier: 'FREE',
    );
  }
}

/// Catalog rarely changes during a session — cache it for the lifetime
/// of the screen via autoDispose. Plans screen builds will share a
/// single fetch.
final plansCatalogProvider = FutureProvider.autoDispose<PlansCatalog>((ref) async {
  final repo = ref.watch(billingRepositoryProvider);
  return repo.fetchCatalog();
});

/// Balance is checked frequently (paywall trigger, drawer badge, etc.).
/// AutoDispose so invalidate() always pulls fresh after a purchase.
final tokenBalanceProvider = FutureProvider.autoDispose<BalanceSnapshot>((ref) async {
  final repo = ref.watch(billingRepositoryProvider);
  return repo.fetchBalance();
});
