import 'package:flutter/material.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../data/plan_models.dart';
import '../data/billing_repository.dart';
import '../data/revenuecat_service.dart';

enum PaywallMode { subscription, topup }

/// The actual purchase sheet that opens when the user picks a plan or
/// taps "Top up" on an empty-balance toast. Renders the product detail
/// + Subscribe/Buy CTA wired into RevenueCat's iOS flow.
///
/// Why ConsumerStatefulWidget: we hold transient state (loading,
/// resolved RC product/package) and need ref.invalidate on the token
/// balance after a successful purchase so the next AI call sees the
/// new tokens immediately.
class PaywallSheet extends ConsumerStatefulWidget {
  const PaywallSheet({
    super.key,
    this.initialPlan,
    this.initialTopup,
    required this.mode,
  });

  final SubscriptionPlan? initialPlan;
  final TopupPack? initialTopup;
  final PaywallMode mode;

  @override
  ConsumerState<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<PaywallSheet> {
  /// Loaded async on first build. While null, the CTA is disabled and
  /// shows a spinner. Resolves to either an rc.Package (subs) or an
  /// rc.StoreProduct (top-ups).
  rc.Package? _package;
  rc.StoreProduct? _topupProduct;
  bool _loading = true;
  bool _purchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadProduct);
  }

  Future<void> _loadProduct() async {
    final l = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.mode == PaywallMode.subscription) {
        final offering = await RevenueCatService.instance.currentOffering();
        if (offering == null) {
          throw Exception(l.paywallPlansUnavailable);
        }
        final targetId = widget.initialPlan?.storeProductId ?? '';
        final pkg = offering.availablePackages.firstWhere(
          (p) => p.storeProduct.identifier == targetId,
          orElse: () => offering.availablePackages.isEmpty
              ? throw Exception(l.paywallPlansUnavailable)
              : offering.availablePackages.first,
        );
        if (mounted) {
          setState(() {
            _package = pkg;
            _loading = false;
          });
        }
      } else {
        final productId = widget.initialTopup?.storeProductId ?? '';
        final prod = await RevenueCatService.instance.topupProduct(productId);
        if (prod == null) {
          throw Exception(l.paywallTopupUnavailable);
        }
        if (mounted) {
          setState(() {
            _topupProduct = prod;
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _purchase() async {
    final l = AppLocalizations.of(context)!;
    // Snapshot the balance BEFORE buying so we can tell when the server
    // has actually credited the purchase (tier changed or tokens went up).
    final pre = ref.read(tokenBalanceProvider).asData?.value;
    setState(() => _purchasing = true);
    try {
      rc.CustomerInfo info;
      if (widget.mode == PaywallMode.subscription && _package != null) {
        info = await RevenueCatService.instance.purchasePackage(_package!);
      } else if (widget.mode == PaywallMode.topup && _topupProduct != null) {
        info = await RevenueCatService.instance.purchaseProduct(_topupProduct!);
      } else {
        throw Exception(l.paywallGenericError);
      }
      // RC credits tokens server-side via our /billing/webhooks/revenuecat
      // endpoint, which lands a beat AFTER the purchase call returns. A single
      // immediate invalidate raced that webhook (re-fetching stale FREE/old
      // balance) and the old 3s "safety net" was dead code — the sheet had
      // already popped, so `mounted` was false. Instead, poll /billing/me
      // while the sheet is still up until the credit is reflected, THEN pop.
      // This drives both the plan pill and the token chip (they share this
      // one provider), so both update the moment the webhook lands.
      await _awaitBalanceChange(pre);
      if (!mounted) return;
      final isPaidNow = info.entitlements.active.containsKey('pro_access') ||
          widget.mode == PaywallMode.topup;
      _showResultBanner(success: isPaidNow);
      Navigator.of(context).pop(true);
    } on PlatformException catch (e) {
      // RC uses PlatformException for purchase errors. Code 1 = user
      // cancelled — we silently swallow that since cancel isn't an error.
      if (!mounted) return;
      final code = rc.PurchasesErrorHelper.getErrorCode(e);
      if (code == rc.PurchasesErrorCode.purchaseCancelledError) {
        setState(() => _purchasing = false);
        return;
      }
      setState(() {
        _purchasing = false;
        _error = _humanizeError(l, code, e.message);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _purchasing = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _restorePurchases() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _purchasing = true);
    final pre = ref.read(tokenBalanceProvider).asData?.value;
    try {
      final info = await RevenueCatService.instance.restorePurchases();
      // Same webhook race as _purchase(): restoring re-syncs entitlements on
      // the server, so poll until the balance/tier reflects it.
      await _awaitBalanceChange(pre);
      if (!mounted) return;
      final restored = info.entitlements.active.containsKey('pro_access');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(restored
            ? l.paywallRestored
            : l.paywallNoRestores),
      ));
      setState(() => _purchasing = false);
      if (restored) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _purchasing = false;
        _error = l.paywallRestoreFailed(e.toString().replaceFirst('Exception: ', ''));
      });
    }
  }

  /// Polls the server balance until it reflects the just-completed purchase
  /// (webhook credit), or a short budget elapses. Refreshing the shared
  /// [tokenBalanceProvider] updates every watcher (plan pill, NOVA token
  /// chip) at once. Runs while the sheet is still mounted so it never
  /// depends on post-pop lifecycle. Best-effort: if the webhook is unusually
  /// slow we still leave the freshest snapshot cached and pop; the next
  /// screen build shows the credited value.
  Future<void> _awaitBalanceChange(BalanceSnapshot? pre) async {
    const attempts = 6; // ~10s total worst case
    for (var i = 0; i < attempts; i++) {
      try {
        final snap = await ref.refresh(tokenBalanceProvider.future);
        if (_reflectsPurchase(pre, snap)) return;
      } catch (_) {
        // transient network/refresh error — keep polling
      }
      if (!mounted) return;
      if (i < attempts - 1) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  /// True once the fresh snapshot shows the purchase landed: a new tier
  /// (subscription) or more tokens than before (top-up). When we had no
  /// baseline, treat any non-FREE tier / positive balance as success.
  bool _reflectsPurchase(BalanceSnapshot? pre, BalanceSnapshot snap) {
    if (pre == null) {
      return snap.totalRemaining > 0 || snap.activeTier != 'FREE';
    }
    return snap.activeTier != pre.activeTier ||
        snap.totalRemaining > pre.totalRemaining;
  }

  String _humanizeError(AppLocalizations l, rc.PurchasesErrorCode code, String? raw) {
    switch (code) {
      case rc.PurchasesErrorCode.purchaseNotAllowedError:
        return l.paywallPurchasesRestricted;
      case rc.PurchasesErrorCode.purchaseInvalidError:
        return l.paywallPurchaseInvalid;
      case rc.PurchasesErrorCode.productNotAvailableForPurchaseError:
        return l.paywallProductNotAvailable;
      case rc.PurchasesErrorCode.networkError:
        return l.paywallNetworkError;
      case rc.PurchasesErrorCode.paymentPendingError:
        return l.paywallPaymentPending;
      case rc.PurchasesErrorCode.storeProblemError:
        return l.paywallStoreProblem;
      default:
        return raw ?? l.paywallGenericError;
    }
  }

  void _showResultBanner({required bool success}) {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text(success
          ? (widget.mode == PaywallMode.subscription
              ? l.paywallWelcomeMessage(widget.initialPlan?.labelLocalized(l) ?? l.paywallWelcomeFallback)
              : l.paywallTopupAdded)
          : l.paywallPurchaseProcessed),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    final priceLabel = widget.mode == PaywallMode.subscription
        ? (_package?.storeProduct.priceString ?? widget.initialPlan?.priceLabelLocalized(l) ?? '')
        : (_topupProduct?.priceString ?? widget.initialTopup?.priceLabel ?? '');
    // The paywallPerMonthWithTokens / paywallOneTimeWithTokens strings
    // already embed "/ month" / "one-time" — pass just the raw token
    // count so it doesn't double up.
    final tokensRaw = widget.mode == PaywallMode.subscription
        ? (widget.initialPlan != null
            ? widget.initialPlan!.tokensLabelLocalized(l).split(' ').first
            : '')
        : (widget.initialTopup != null
            ? widget.initialTopup!.tokensLabelLocalized(l).split(' ').first
            : '');
    final subtitle = widget.mode == PaywallMode.subscription
        ? l.paywallPerMonthWithTokens(tokensRaw)
        : l.paywallOneTimeWithTokens(tokensRaw);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  Text(
                    widget.mode == PaywallMode.subscription
                        ? l.paywallSubscribeTo(widget.initialPlan?.labelLocalized(l) ?? l.paywallPlanFallback)
                        : l.paywallBuyTopupNamed(widget.initialTopup?.labelLocalized(l) ?? l.paywallTopupFallback),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.initialPlan != null)
                    Text(
                      widget.initialPlan!.blurbLocalized(l),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  if (widget.initialTopup != null)
                    Text(
                      l.paywallTopupBlurb,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 20),
                  _PriceSummary(title: priceLabel, subtitle: subtitle),
                  const SizedBox(height: 24),

                  if (_error != null)
                    _ErrorBanner(
                      message: _error!,
                      onRetry: _loading ? null : _loadProduct,
                    ),
                  if (_error == null) _FeaturesList(),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (_loading || _purchasing || _error != null)
                          ? null
                          : _purchase,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _purchasing
                          ? const CmLoading(size: 20, color: Colors.white)
                          : Text(
                              widget.mode == PaywallMode.subscription
                                  ? l.paywallSubscribeButton
                                  : l.paywallBuyButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (widget.mode == PaywallMode.subscription)
                    TextButton(
                      onPressed: _purchasing ? null : _restorePurchases,
                      child: Text(l.paywallRestoreButton),
                    ),
                  TextButton(
                    onPressed: _purchasing ? null : () => Navigator.of(context).pop(),
                    child: Text(l.paywallNotNow),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.mode == PaywallMode.subscription
                        ? l.paywallTermsSubscription
                        : l.paywallTermsTopup,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Functional EULA + Privacy links are required by Apple
                  // Guideline 3.1.2(c) for any app offering auto-renewing
                  // subscriptions — the disclaimer above must include
                  // tappable links, not just plain text. Apple's standard
                  // EULA URL is used since we don't ship a custom one.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => launchUrl(
                          Uri.parse(
                            'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                          ),
                          mode: LaunchMode.externalApplication,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(l.paywallTermsLink),
                      ),
                      Text(
                        '·',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => launchUrl(
                          Uri.parse('https://tony11-dot.github.io/classmate-legal/privacy.html'),
                          mode: LaunchMode.externalApplication,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(l.paywallPrivacyLink),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isEmpty ? '—' : title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onPrimaryContainer,
              letterSpacing: -1.0,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final features = [
      l.paywallFeatureTokens,
      l.paywallFeatureImages,
      l.paywallFeatureReset,
      l.paywallFeatureCancel,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  /// The "plans unavailable" message from `currentOffering() == null`
  /// almost always means the App Store / Play Store products aren't
  /// loaded yet on the device (cold launch, no network, sandbox
  /// account in a weird state). We give the user a clear next step
  /// rather than dumping a raw exception.
  bool get _isUnavailable {
    final lower = message.toLowerCase();
    return lower.contains('unavailable') ||
        lower.contains('not available') ||
        lower.contains('no product');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final friendly = _isUnavailable
        ? "Plans aren't reachable from this device right now. This usually clears on its own — check your internet, make sure you're signed in to the App Store / Play Store, and try again."
        : message;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 18),
            const SizedBox(width: 8),
            Text(
              _isUnavailable ? 'Plans aren\'t reachable' : 'Something went wrong',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onErrorContainer,
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text(
            friendly,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onErrorContainer,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            if (onRetry != null)
              FilledButton.tonal(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context)!.commonRetry),
              ),
          ]),
        ],
      ),
    );
  }
}
