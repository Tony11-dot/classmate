import '../../../l10n/app_localizations.dart';

/// Mirror of the server's plan.catalog.ts SubscriptionPlan type. Kept
/// as a Dart class (not freezed/json_serializable) so the data layer
/// has zero codegen dependency and is trivial to read in a code review.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.tier,
    required this.label,
    required this.blurb,
    required this.priceAgorot,
    required this.priceUsd,
    required this.monthlyTokens,
    required this.storeProductId,
  });

  /// 'FREE' | 'BUDGET' | 'BALANCE' | 'COMMITMENT'
  final String tier;
  final String label;
  final String blurb;
  /// 1900 = ₪19.00, 1990 = ₪19.90. Stored as int so the UI never
  /// renders 19.000000001-style floats.
  final int priceAgorot;
  final int priceUsd;
  final int monthlyTokens;
  /// The App Store Connect / Play Console product identifier. Null for
  /// the free tier (nothing to buy). The Flutter paywall passes this
  /// to RevenueCat when the user taps a tier's "Upgrade" button.
  final String? storeProductId;

  bool get isFree => tier == 'FREE';

  /// Localized tier name. Falls back to the server-provided English
  /// label when the tier key is unknown (forward-compat with tiers
  /// added on the server before the client has an ARB key).
  String labelLocalized(AppLocalizations l) => switch (tier) {
        'FREE' => l.planTierFree,
        'BUDGET' => l.planTierBudget,
        'BALANCE' => l.planTierBalance,
        'COMMITMENT' => l.planTierCommitment,
        _ => label,
      };

  /// "₪19.90" — uses comma-less Hebrew-friendly format.
  String get priceLabel {
    if (priceAgorot == 0) return 'Free';
    final shekels = priceAgorot ~/ 100;
    final agorot = priceAgorot % 100;
    return agorot == 0
        ? '₪$shekels'
        : '₪$shekels.${agorot.toString().padLeft(2, '0')}';
  }

  /// "300,000 tokens / month" — human-friendly with thousands separator.
  String get tokensLabel {
    final formatted = monthlyTokens
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '$formatted tokens / month';
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      tier: (json['tier'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      blurb: (json['blurb'] ?? '').toString(),
      priceAgorot: (json['priceAgorot'] as num?)?.toInt() ?? 0,
      priceUsd: (json['priceUsd'] as num?)?.toInt() ?? 0,
      monthlyTokens: (json['monthlyTokens'] as num?)?.toInt() ?? 0,
      storeProductId: json['storeProductId']?.toString(),
    );
  }
}

class TopupPack {
  const TopupPack({
    required this.label,
    required this.priceAgorot,
    required this.priceUsd,
    required this.tokens,
    required this.storeProductId,
  });

  final String label;
  final int priceAgorot;
  final int priceUsd;
  final int tokens;
  final String storeProductId;

  /// Pack size key derived from the storeProductId
  /// (com.classmate.tokens.{small|medium|large|mega}).
  String get _sizeKey {
    final last = storeProductId.split('.').last.toLowerCase();
    return last;
  }

  String labelLocalized(AppLocalizations l) => switch (_sizeKey) {
        'small' => l.topupPackSmall,
        'medium' => l.topupPackMedium,
        'large' => l.topupPackLarge,
        'mega' => l.topupPackMega,
        _ => label,
      };

  String get priceLabel {
    final shekels = priceAgorot ~/ 100;
    final agorot = priceAgorot % 100;
    return agorot == 0
        ? '₪$shekels'
        : '₪$shekels.${agorot.toString().padLeft(2, '0')}';
  }

  String get tokensLabel {
    final formatted = tokens
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '$formatted tokens';
  }

  factory TopupPack.fromJson(Map<String, dynamic> json) {
    return TopupPack(
      label: (json['label'] ?? '').toString(),
      priceAgorot: (json['priceAgorot'] as num?)?.toInt() ?? 0,
      priceUsd: (json['priceUsd'] as num?)?.toInt() ?? 0,
      tokens: (json['tokens'] as num?)?.toInt() ?? 0,
      storeProductId: (json['storeProductId'] ?? '').toString(),
    );
  }
}

/// Server response from `GET /billing/me`.
class BalanceSnapshot {
  const BalanceSnapshot({
    required this.planTokensRemaining,
    required this.topupTokensRemaining,
    required this.totalRemaining,
    required this.resetAt,
    required this.activeTier,
  });

  final int planTokensRemaining;
  final int topupTokensRemaining;
  final int totalRemaining;
  final DateTime? resetAt;
  /// 'FREE' | 'BUDGET' | 'BALANCE' | 'COMMITMENT'
  final String activeTier;

  bool get isOutOfTokens => totalRemaining <= 0;
  bool get isPaid => activeTier != 'FREE';

  /// Reset date in "May 31" style. Returns empty if no reset is scheduled.
  String get resetLabel {
    if (resetAt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = resetAt!.toLocal();
    return '${months[d.month - 1]} ${d.day}';
  }

  factory BalanceSnapshot.fromJson(Map<String, dynamic> json) {
    final reset = json['resetAt'];
    return BalanceSnapshot(
      planTokensRemaining: (json['planTokensRemaining'] as num?)?.toInt() ?? 0,
      topupTokensRemaining: (json['topupTokensRemaining'] as num?)?.toInt() ?? 0,
      totalRemaining: (json['totalRemaining'] as num?)?.toInt() ?? 0,
      resetAt: reset is String ? DateTime.tryParse(reset) : null,
      activeTier: (json['activeTier'] ?? 'FREE').toString(),
    );
  }
}
