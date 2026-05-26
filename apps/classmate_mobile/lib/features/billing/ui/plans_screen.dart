import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../data/billing_repository.dart';
import '../data/plan_models.dart';
import 'paywall_sheet.dart';

/// NOVA Plans — the user-facing storefront. Renders entirely from
/// `/billing/plans` (catalog) + `/billing/me` (balance) so we can move
/// prices/quotas/copy without a Flutter release. Real purchases happen
/// inside [PaywallSheet] when the user taps "Upgrade" on a tier.
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final catalogAsync = ref.watch(plansCatalogProvider);
    final balanceAsync = ref.watch(tokenBalanceProvider);

    // No local Scaffold/AppBar — the shell wraps every route with its
    // top-bar pill which already shows "NOVA Plans" (see _pageTitle()
    // in app_shell.dart). Returning a bare RefreshIndicator keeps the
    // pill from being doubled.
    return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(plansCatalogProvider);
          ref.invalidate(tokenBalanceProvider);
        },
        child: catalogAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _Error(message: e.toString(), onRetry: () {
            ref.invalidate(plansCatalogProvider);
          }),
          data: (catalog) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // ── Balance hero ─────────────────────────────────────────
              _BalanceCard(balanceAsync: balanceAsync),

              // ── Manage subscription (only when on a paid tier) ───────
              if (balanceAsync.asData?.value.activeTier != null &&
                  balanceAsync.asData!.value.activeTier != 'FREE') ...[
                const SizedBox(height: 12),
                _ManageSubscriptionButton(cs: cs),
              ],

              const SizedBox(height: 24),

              // ── Token explainer ──────────────────────────────────────
              _TokenExplainer(theme: theme, cs: cs),
              const SizedBox(height: 24),

              // ── Subscription tiers ───────────────────────────────────
              Text(
                'Monthly plans',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ...catalog.subscriptions.map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PlanTile(
                      plan: plan,
                      isCurrent: balanceAsync.asData?.value.activeTier == plan.tier,
                    ),
                  )),

              const SizedBox(height: 24),

              // ── Top-up packs ─────────────────────────────────────────
              Text(
                'Token top-ups',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'One-time purchases. Never expire. Stack on top of your plan.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ...catalog.topups.map((pack) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TopupTile(pack: pack),
                  )),
            ],
          ),
        ),
      );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balanceAsync});
  final AsyncValue<BalanceSnapshot> balanceAsync;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: balanceAsync.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Text(
          'Couldn\'t load your balance',
          style: TextStyle(color: cs.onPrimaryContainer),
        ),
        data: (b) {
          final formatted = b.totalRemaining
              .toString()
              .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      b.activeTier == 'FREE' ? 'Free plan' : b.activeTier,
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                formatted,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onPrimaryContainer,
                  letterSpacing: -1.0,
                ),
              ),
              Text(
                'tokens remaining',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                ),
              ),
              if (b.resetLabel.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 14, color: cs.onPrimaryContainer.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      'Plan resets ${b.resetLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
              if (b.topupTokensRemaining > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 14, color: cs.onPrimaryContainer.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      '${b.topupTokensRemaining.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} top-up tokens (no expiry)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Opens the OS-managed subscription settings page so the user can
/// cancel, downgrade, or change billing details. Apple and Google both
/// require this be handled in their own UI — apps are forbidden from
/// cancelling subs themselves.
class _ManageSubscriptionButton extends StatelessWidget {
  const _ManageSubscriptionButton({required this.cs});
  final ColorScheme cs;

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context)!;
    Uri uri;
    if (Platform.isIOS) {
      uri = Uri.parse('itms-apps://apps.apple.com/account/subscriptions');
    } else if (Platform.isAndroid) {
      uri = Uri.parse(
        'https://play.google.com/store/account/subscriptions'
        '?package=com.tonyaboud.classmate',
      );
    } else {
      uri = Uri.parse('https://apps.apple.com/account/subscriptions');
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(content: Text(l.plansCouldNotOpenSubscription)),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.plansFailedToOpen(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _open(context),
        icon: const Icon(Icons.settings_rounded, size: 18),
        label: Text(AppLocalizations.of(context)!.plansManageSubscription),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: cs.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _TokenExplainer extends StatelessWidget {
  const _TokenExplainer({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'How tokens work',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tokens are how AI counts its work.\n'
            '• A short question ≈ 2,000 tokens\n'
            '• A long explanation or practice session ≈ 5,000–10,000\n'
            '• Image analysis costs a bit more\n\n'
            'Your monthly tokens reset on the 1st. Top-up tokens never expire.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan, required this.isCurrent});
  final SubscriptionPlan plan;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: plan.isFree
          ? null
          : () => _openPaywall(context, plan: plan),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent ? cs.primaryContainer.withValues(alpha: 0.4) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrent ? cs.primary : cs.outlineVariant,
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        plan.label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'CURRENT',
                            style: TextStyle(
                              color: cs.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  plan.priceLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
                if (!plan.isFree)
                  Text(
                    ' / mo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              plan.blurb,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: cs.secondary),
                const SizedBox(width: 4),
                Text(
                  plan.tokensLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (!plan.isFree && !isCurrent) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _openPaywall(context, plan: plan),
                  child: Text(AppLocalizations.of(context)!.plansUpgrade),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openPaywall(BuildContext context, {required SubscriptionPlan plan}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PaywallSheet(initialPlan: plan, mode: PaywallMode.subscription),
    );
  }
}

class _TopupTile extends StatelessWidget {
  const _TopupTile({required this.pack});
  final TopupPack pack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openPaywall(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.bolt_rounded, color: cs.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    pack.tokensLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              pack.priceLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPaywall(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PaywallSheet(initialTopup: pack, mode: PaywallMode.topup),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: cs.error),
            const SizedBox(height: 12),
            Text(
              'Couldn\'t load plans',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.plansTryAgain)),
          ],
        ),
      ),
    );
  }
}
