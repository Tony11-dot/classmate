// NOVA + Practice plan catalog.
//
// Plans live in code (not the DB) because:
//   - the set rarely changes and code-review is the right gate
//   - App Store / Play Store products are also defined in code-equivalent
//     consoles, so keeping the source of truth here matches what the
//     storefront returns
//   - the cost model uses these constants to compute remaining margin —
//     keeping them as TypeScript values means refactors fail loud
//
// When prices change: update both this catalog AND the matching IAP
// products in App Store Connect + Google Play Console. The
// `storeProductId` is the actual identifier those consoles use, so
// receipt-validation logic looks up tier definitions by that key.

export type PlanTier = 'FREE' | 'BUDGET' | 'BALANCE' | 'COMMITMENT';

export interface SubscriptionPlan {
  tier: PlanTier;
  /// User-facing label (short, fits a tile header).
  label: string;
  /// User-facing one-liner pitched at the buyer.
  blurb: string;
  /// Monthly price in agorot (1 ILS = 100 agorot). Stored as integer to
  /// avoid float drift; the server never compares floats. 0 = free plan.
  priceAgorot: number;
  /// Approximate USD for the dashboard / margin math. Not used at runtime
  /// for pricing — Apple/Google handle FX conversion via their own tiers.
  priceUsd: number;
  /// Tokens granted at the start of each billing period. Reset to this
  /// amount on every renewal webhook.
  monthlyTokens: number;
  /// Store product identifier. MUST match the productId you create in
  /// App Store Connect + Google Play Console. Convention:
  ///   com.classmate.plan.{tier_lowercase}.monthly
  /// FREE has no product — there's nothing to buy.
  storeProductId: string | null;
}

export interface TopupPack {
  /// User-facing label.
  label: string;
  priceAgorot: number;
  priceUsd: number;
  tokens: number;
  /// Consumable IAP product id. Convention:
  ///   com.classmate.tokens.{size}
  storeProductId: string;
}

/// Subscription tiers — recurring monthly billing.
export const SUBSCRIPTION_PLANS: SubscriptionPlan[] = [
  {
    tier: 'FREE',
    label: 'Free',
    blurb: 'Get a taste of NOVA. Resets every month.',
    priceAgorot: 0,
    priceUsd: 0,
    // 200K tokens/student/month. Bumped from 150K once NOVA became
    // students-only: students are the sole NOVA users (and the paying
    // value), so giving them more headroom is the right call. Crucially,
    // the cap only *costs* on actual usage — the realistic bill barely
    // moves because most students never reach it; the bump just stops
    // heavy-study days from hitting a wall. Combined with the FREE-tier
    // knobs in tutor.reply.provider.ts (Haiku 4.5, max_tokens 400, last-6
    // history window, cached system prompt), full-utilisation cost is
    // ~$0.18/student/month.
    monthlyTokens: 200_000,
    storeProductId: null,
  },
  {
    tier: 'BUDGET',
    label: 'Budget',
    blurb: 'Daily homework help.',
    priceAgorot: 1990, // ₪19.90 (matches App Store Connect)
    priceUsd: 5,
    monthlyTokens: 300_000,
    storeProductId: 'com.classmate.plan.budget.monthly',
  },
  {
    tier: 'BALANCE',
    label: 'Balance',
    blurb: 'For students who study every day.',
    priceAgorot: 4990, // ₪49.90
    priceUsd: 13,
    monthlyTokens: 1_000_000,
    storeProductId: 'com.classmate.plan.balance.monthly',
  },
  {
    tier: 'COMMITMENT',
    label: 'Commitment',
    blurb: 'Heavy practice + unlimited curiosity.',
    priceAgorot: 9990, // ₪99.90
    priceUsd: 27,
    monthlyTokens: 2_500_000,
    storeProductId: 'com.classmate.plan.commitment.monthly',
  },
];

/// One-time consumable top-up packs. Tokens NEVER expire and stack on
/// top of whatever the active subscription grants.
export const TOPUP_PACKS: TopupPack[] = [
  {
    label: 'Small pack',
    priceAgorot: 1490, // ₪14.90 (matches App Store Connect)
    priceUsd: 4,
    tokens: 200_000,
    storeProductId: 'com.classmate.tokens.small',
  },
  {
    label: 'Medium pack',
    priceAgorot: 2990, // ₪29.90
    priceUsd: 8,
    tokens: 500_000,
    storeProductId: 'com.classmate.tokens.medium',
  },
  {
    label: 'Large pack',
    priceAgorot: 4990, // ₪49.90
    priceUsd: 13,
    tokens: 1_000_000,
    storeProductId: 'com.classmate.tokens.large',
  },
  {
    label: 'Mega pack',
    priceAgorot: 9990, // ₪99.90
    priceUsd: 27,
    tokens: 2_000_000,
    storeProductId: 'com.classmate.tokens.mega',
  },
];

export function findPlanByTier(tier: string): SubscriptionPlan | null {
  return SUBSCRIPTION_PLANS.find((p) => p.tier === tier) ?? null;
}

export function findPlanByProductId(productId: string): SubscriptionPlan | null {
  return SUBSCRIPTION_PLANS.find((p) => p.storeProductId === productId) ?? null;
}

export function findTopupByProductId(productId: string): TopupPack | null {
  return TOPUP_PACKS.find((p) => p.storeProductId === productId) ?? null;
}

/// Quota a user gets when they have no paid subscription. Same as the
/// FREE plan — split out so consumers don't have to special-case.
export function freeQuota(): number {
  return SUBSCRIPTION_PLANS.find((p) => p.tier === 'FREE')!.monthlyTokens;
}

/// Free-tier NOVA bucket for NON-student roles (teacher / parent /
/// secretary / admin). Two reasons it's smaller than the student 150K:
///   1. These roles use NOVA lightly — a teacher prepping a lesson or a
///      parent checking a kid's homework, not daily study sessions.
///   2. Unlike students, they bring NO subscription revenue (schools pay
///      per student; staff + parents ride free). A full 150K free bucket
///      for every parent is pure cost that scales with headcount.
/// 40K ≈ 5-6 substantial conversations/month — roomy for real staff/parent
/// use, but it roughly halves the worst-case AI spend at 1M-user scale.
/// A user who ALSO holds the STUDENT role keeps the full student bucket.
export const NON_STUDENT_FREE_TOKENS = 40_000;

export function nonStudentFreeQuota(): number {
  return NON_STUDENT_FREE_TOKENS;
}
