import 'package:flutter/material.dart';

import '../data/plan_models.dart';

enum PaywallMode { subscription, topup }

/// The actual purchase sheet that opens when the user picks a plan or
/// taps "Top up" on an empty-balance toast. Renders a single product
/// detail page with the "Subscribe" / "Buy" CTA.
///
/// The RevenueCat SDK call (`Purchases.purchasePackage(...)`) is wired
/// in a separate commit once the user finishes setting up:
///   1. Google Play Console payments profile
///   2. RevenueCat → Products imported from App Store + Play
///   3. RevenueCat → "pro_access" entitlement created
///   4. RevenueCat → "default" offering with the 3 subscription packages
///   5. RevenueCat → webhook URL pointing at our /billing/webhooks/revenuecat
///
/// Until then this sheet shows a friendly "coming soon" panel so the
/// rest of the Plans UI can ship and be reviewed without blocking on
/// store-side configuration.
class PaywallSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
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
                    mode == PaywallMode.subscription
                        ? 'Subscribe to ${initialPlan?.label ?? 'plan'}'
                        : 'Buy ${initialTopup?.label ?? 'top-up'}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (initialPlan != null) ...[
                    Text(
                      initialPlan!.blurb,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PriceSummary(
                      title: initialPlan!.priceLabel,
                      subtitle: 'per month · ${initialPlan!.tokensLabel}',
                    ),
                  ],
                  if (initialTopup != null) ...[
                    Text(
                      'One-time purchase. Tokens never expire and stack on top of your plan.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PriceSummary(
                      title: initialTopup!.priceLabel,
                      subtitle: 'one-time · ${initialTopup!.tokensLabel}',
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ── Coming soon panel ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timelapse_rounded, color: cs.tertiary),
                            const SizedBox(width: 8),
                            Text(
                              'Coming soon',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'In-app purchases are nearly ready. We\'re finishing the connection between the app and Apple\'s payment system. You\'ll be able to subscribe directly from here in the next build.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _FeaturesList(),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        mode == PaywallMode.subscription ? 'Subscribe' : 'Buy',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Not now'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'By subscribing you agree to ClassMate\'s Terms and Privacy Policy. Subscriptions auto-renew monthly until cancelled. Manage anytime in your App Store account.',
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
            title,
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
                    Expanded(
                      child: Text(
                        f,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
