import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.mode == PaywallMode.subscription) {
        final offering = await RevenueCatService.instance.currentOffering();
        if (offering == null) {
          throw Exception('Plans unavailable. Try again in a moment.');
        }
        final targetId = widget.initialPlan?.storeProductId ?? '';
        final pkg = offering.availablePackages.firstWhere(
          (p) => p.storeProduct.identifier == targetId,
          orElse: () => offering.availablePackages.isEmpty
              ? throw Exception('No packages found in offering')
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
          throw Exception(
              'Top-up unavailable. The store hasn\'t finished approving this product.');
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
    setState(() => _purchasing = true);
    try {
      rc.CustomerInfo info;
      if (widget.mode == PaywallMode.subscription && _package != null) {
        info = await RevenueCatService.instance.purchasePackage(_package!);
      } else if (widget.mode == PaywallMode.topup && _topupProduct != null) {
        info = await RevenueCatService.instance.purchaseProduct(_topupProduct!);
      } else {
        throw Exception('Nothing to purchase');
      }
      // RC fires the webhook server-side which credits tokens via our
      // /billing/webhooks/revenuecat endpoint. There's a small window
      // between purchase return and webhook delivery — kick the balance
      // refresh once now (in case webhook is fast) and again after 3s
      // as a safety net.
      ref.invalidate(tokenBalanceProvider);
      Future<void>.delayed(const Duration(seconds: 3), () {
        if (mounted) ref.invalidate(tokenBalanceProvider);
      });
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
        _error = _humanizeError(code, e.message);
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
    setState(() => _purchasing = true);
    try {
      final info = await RevenueCatService.instance.restorePurchases();
      ref.invalidate(tokenBalanceProvider);
      if (!mounted) return;
      final restored = info.entitlements.active.containsKey('pro_access');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(restored
            ? 'Your subscription was restored.'
            : 'No previous purchases found on this Apple ID.'),
      ));
      setState(() => _purchasing = false);
      if (restored) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _purchasing = false;
        _error = 'Restore failed: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  String _humanizeError(rc.PurchasesErrorCode code, String? raw) {
    switch (code) {
      case rc.PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases are restricted on this device.';
      case rc.PurchasesErrorCode.purchaseInvalidError:
        return 'This purchase isn\'t valid. Try a different payment method.';
      case rc.PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'This plan isn\'t available right now. Try again later.';
      case rc.PurchasesErrorCode.networkError:
        return 'Network issue. Check your connection and try again.';
      case rc.PurchasesErrorCode.paymentPendingError:
        return 'Payment is pending approval (parental controls, etc.). It\'ll activate once approved.';
      case rc.PurchasesErrorCode.storeProblemError:
        return 'The App Store had a problem. Try again in a minute.';
      default:
        return raw ?? 'Something went wrong. Try again.';
    }
  }

  void _showResultBanner({required bool success}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text(success
          ? (widget.mode == PaywallMode.subscription
              ? 'Welcome to ${widget.initialPlan?.label ?? 'your new plan'}! Tokens are on the way.'
              : 'Top-up added. Tokens are on the way.')
          : 'Purchase processed. Tokens will appear shortly.'),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final priceLabel = widget.mode == PaywallMode.subscription
        ? (_package?.storeProduct.priceString ?? widget.initialPlan?.priceLabel ?? '')
        : (_topupProduct?.priceString ?? widget.initialTopup?.priceLabel ?? '');
    final subtitle = widget.mode == PaywallMode.subscription
        ? 'per month · ${widget.initialPlan?.tokensLabel ?? ''}'
        : 'one-time · ${widget.initialTopup?.tokensLabel ?? ''}';

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
                        ? 'Subscribe to ${widget.initialPlan?.label ?? 'plan'}'
                        : 'Buy ${widget.initialTopup?.label ?? 'top-up'}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.initialPlan != null)
                    Text(
                      widget.initialPlan!.blurb,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  if (widget.initialTopup != null)
                    Text(
                      'One-time purchase. Tokens never expire and stack on top of your plan.',
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
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              widget.mode == PaywallMode.subscription
                                  ? 'Subscribe'
                                  : 'Buy',
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
                      child: const Text('Restore purchases'),
                    ),
                  TextButton(
                    onPressed: _purchasing ? null : () => Navigator.of(context).pop(),
                    child: const Text('Not now'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.mode == PaywallMode.subscription
                        ? 'By subscribing you agree to ClassMate\'s Terms and Privacy Policy. Subscriptions auto-renew monthly until cancelled. Manage anytime in your App Store account.'
                        : 'By purchasing you agree to ClassMate\'s Terms and Privacy Policy. Top-up tokens are non-refundable once consumed.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.3,
                    ),
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
    final features = const [
      'Use tokens across NOVA chat and Practice sessions',
      'Voice messages and image analysis included',
      'Tokens reset at the start of each month',
      'Cancel anytime — no commitment',
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.onErrorContainer),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
