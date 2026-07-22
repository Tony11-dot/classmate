# Billing go-live runbook — what's done, what waits for the bank account

State as of build 236 (2026-07-22). The **entire code path is finished and
shipped**: paywall + top-ups in the app (RevenueCat SDK 10.4.2, Play Billing
8.3.0-compliant), server plan catalog, RevenueCat webhook → token grants.
What remains is **console work that requires the business entity + bank
account** — none of it is code, and none of it needs to be shared with anyone:
bank/tax details are entered directly into Apple's and Google's consoles by
the account holder.

**Money flow (nothing to wire in code):** buyer pays Apple/Google → Apple/
Google pay out to the bank account registered in App Store Connect / Play
Console (monthly, ~15–45 days in arrears). RevenueCat never holds money — it
only validates receipts and tells our server who is entitled to what.

---

## Already DONE (no action)

- App: `RevenueCatService` (configure → identify(userId) → offering `main` →
  purchase/restore), paywall sheet, top-up purchases. iOS public key
  `appl_YUklLZOkEIebPLhOndUSdEjOzQE` shipped in source (safe — bound to our
  bundle id).
- Entitlement checked in-app: **`pro_access`**.
- Server: `GET /billing/plans` catalog + `POST /billing/webhooks/revenuecat`
  (secret in Railway env `REVENUECAT_WEBHOOK_SECRET`, already set) granting
  monthly/top-up tokens by `storeProductId`.
- Product IDs (source of truth: `services/api/src/billing/plan.catalog.ts`):

  | Kind | Product ID | Price |
  |---|---|---|
  | Sub | `com.classmate.plan.budget.monthly` | ₪19.90 |
  | Sub | `com.classmate.plan.balance.monthly` | see catalog |
  | Sub | `com.classmate.plan.commitment.monthly` | see catalog |
  | Consumable | `com.classmate.tokens.small` | see catalog |
  | Consumable | `com.classmate.tokens.medium` | see catalog |
  | Consumable | `com.classmate.tokens.large` | see catalog |
  | Consumable | `com.classmate.tokens.mega` | see catalog |

---

## Blocked on business entity + bank account — TONY's console checklist

Prereq (already in motion per ministry/Experis track): register the עוסק/בע"מ,
open a business bank account. Then, ~30–45 min total:

### 1 · Apple — App Store Connect (appstoreconnect.apple.com)

1. **Business → Agreements**: sign the **Paid Applications** agreement; add
   **bank account** + **tax forms** (US tax interview; W-8BEN for a non-US
   entity). ⚠ Until this agreement is Active, IAP does not work — not even
   in sandbox. This is THE unblock.
2. **App → Monetization → Subscriptions**: create one subscription group
   ("ClassMate Plans"), add the 3 monthly subs with the EXACT product IDs +
   prices above. Add localized display names (he/ar/en at minimum).
3. **In-App Purchases**: create the 4 **consumable** top-ups, same IDs.

### 2 · Google — Play Console (play.google.com/console)

1. **Setup → Payments profile**: create/link the payments profile with the
   business bank account. (This also clears the "account verification" that
   has been blocking RevenueCat's Android key.)
2. **Monetize → Subscriptions**: create the 3 subs (same IDs; Play wants a
   base plan per sub — monthly, auto-renewing).
3. **Monetize → In-app products**: create the 4 consumables (same IDs).
4. **Monetize → Monetization setup**: RevenueCat needs Real-Time Developer
   Notifications OFF-the-shelf via its Play service credential — see step 3.

### 3 · RevenueCat dashboard (app.revenuecat.com)

1. Project already exists (iOS app + `appl_` key). Add the **Play Store app**
   (package `com.tonyaboud.classmate`) — upload a Google **service-account
   JSON** with Play Android Publisher + Pub/Sub rights (RC's docs walk
   through it) → RC issues the **`goog_…` public API key**.
2. **Entitlements**: ensure `pro_access` exists and attach ALL 3 subscription
   products (both stores) to it.
3. **Offerings**: ensure offering **`main`** contains the 3 sub packages.
   Top-ups stay outside the offering (the app fetches them by product id).
4. **Webhook** (if not already pointing at prod): URL
   `https://pacific-enchantment-production-7a80.up.railway.app/billing/webhooks/revenuecat`,
   Authorization header = the value of `REVENUECAT_WEBHOOK_SECRET` in Railway.

### 4 · Hand back to Claude (the only thing to give me)

- The **`goog_…` RevenueCat public key** (safe to share/ship — like the
  `appl_` one). I paste it into `RevenueCatService._androidApiKey`, and
  Android's paywall flips from "coming soon" to live. NOT needed: bank
  details, tax info, service-account JSON — those never touch the repo.

### 5 · Verify end-to-end (together)

- iOS: Sandbox tester account → buy each sub + one top-up → check
  `pro_access` active, tokens granted (server logs `[rc.webhook]`), Restore
  works. Refund/cancel in sandbox → entitlement drops.
- Android: License tester → same pass on Play internal build.
- RevenueCat dashboard shows the transactions; Railway logs show the webhook
  grants.

---

## Gotchas (learned/known)

- Apple pays out only after the agreement is active AND the first threshold
  (~$150) is met; Play pays monthly after a small threshold. Neither needs
  anything from us in code.
- Changing prices later: update BOTH consoles AND `plan.catalog.ts` (the
  agorot values are display/margin only — stores own real pricing).
- Israeli VAT (מע״מ): Apple/Google act as merchant-of-record for consumer
  sales in most regions; confirm invoicing treatment with the accountant when
  the עוסק/בע"מ paperwork lands.
