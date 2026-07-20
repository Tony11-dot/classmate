# Handoff → Claude Code on the Mac

You're picking up a release that was **mostly shipped from the cloud** (Claude Code
on the web, Linux — no Flutter/Xcode/store creds locally). Your job: **finish the
iOS build**, **set two missing secrets**, and **ship everywhere cleanly**. You have
Flutter, Xcode, and the signing material the cloud runner used — so you can verify
what the cloud couldn't.

Branch: `claude/security-review-themes-ai-support-boyo6w` (already merged to `main`,
fast-forward, at build `1.0.9+224`).

---

## What this release contains (so you know what you're shipping)
- **11 new themes** (20 total) in Settings → Theme — full curated palettes, no color picker.
- **Support AI assistant** (Groq, OpenAI-compatible) on the Support screen, alongside the FAQ.
- **Security fixes**: 10 cross-school/IDOR fixes, the `x-school-id` trust hole (H7), admin
  school-scoping (H6).
- **Ministry-of-Education SSO scaffold** — inert until `MOE_SSO_*` env is set.
- Dead-code cleanup (misplaced empty trees, duplicate decorators).

## What already shipped, and what didn't (cloud run `target=all`)
| Target | Result |
|---|---|
| Web → Firebase Hosting | ✅ **LIVE** |
| Android → Play internal | ✅/🔄 built + uploaded (check the run) |
| iOS → TestFlight | ❌ failed to archive `device_info_plus` (see Task 1) |
| Railway (backend/API) | ⏭️ **skipped — `RAILWAY_TOKEN` not set** (see Task 2A) |
| `main` merge | ✅ done |

> ⚠️ **The backend security fixes are not live until the API redeploys.** That's Task 2A.

---

## Task 1 — Verify & land the iOS fix

The iOS archive failed compiling `device_info_plus` 12.4.0 (transitive, via
`sentry_flutter`) against the runner SDK:
```
No visible @interface for 'NSProcessInfo' declares the selector 'isiOSAppOnVision'
  device_info_plus-12.4.0/ios/.../FPPDeviceInfoPlusPlugin.m:34
```

**Already staged on this branch (UNVERIFIED — the cloud has no Flutter):**
- `apps/classmate_mobile/pubspec.yaml` → `dependency_overrides: device_info_plus: ^13.2.0`
- `.github/workflows/ship.yml` → `FLUTTER_VERSION` `3.41.0` → `3.41.6`
  (13.x needs Flutter ≥ 3.41.6 / Dart ≥ 3.11.0).

**Verify it:**
```bash
cd apps/classmate_mobile
flutter --version          # confirm >= 3.41.6 locally (upgrade if not)
flutter pub get            # must resolve device_info_plus 13.x with no conflict
flutter analyze lib        # must be clean
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist  # must archive
git add pubspec.lock && git commit -m "chore(ios): lock device_info_plus 13.x"
```

- If `pub get` conflicts (another package caps device_info_plus at <13), either bump that
  package or drop the override and use the fallback below.
- If `analyze` regresses under 3.41.6, fix the findings.

**Fallback (fastest, most reliable):** your local Xcode's SDK almost certainly already
declares `isiOSAppOnVision`, so `device_info_plus` 12.4.0 may archive fine locally with **no
bump at all**. If so, you can revert both staged edits and just ship iOS from the Mac:
```bash
git checkout -- apps/classmate_mobile/pubspec.yaml .github/workflows/ship.yml
cd apps/classmate_mobile && fastlane ios beta
```
Pick whichever path archives cleanly. (If you ship iOS locally, bump the build number first
per `docs/SHIPPING.md` so TestFlight doesn't reject a duplicate.)

---

## Task 2 — Enable "ship everywhere" (the two missing secrets)

### 2A. `RAILWAY_TOKEN` — so the backend actually deploys
The ship pipeline's `railway` job cleanly **skips** when this secret is absent, which is why
the API didn't redeploy.

1. Railway → **Account Settings → Tokens → Create Token** (or a project-scoped token).
2. GitHub → repo **Settings → Secrets and variables → Actions → New repository secret**:
   - Name: `RAILWAY_TOKEN`   Value: `<token>`
3. (Alternative) If Railway is set to **auto-deploy from `main`** via its GitHub integration,
   the API already redeployed when `main` was pushed — check the Railway dashboard's Deployments
   tab. If it did, you don't need `RAILWAY_TOKEN` at all.

**Confirm the backend is live with the new code** after it deploys:
```bash
curl -s https://pacific-enchantment-production-7a80.up.railway.app/health   # or your health route
```

### 2B. `GROQ_API_KEY` — so the support assistant turns on
This is a **Railway env var**, not a GitHub secret.
1. console.groq.com → **API Keys → Create** → copy `gsk_...` (free, no card).
2. Railway → the **API service → Variables** → add `GROQ_API_KEY = gsk_...` → redeploy.
3. Verify (signed in): `GET /support/ai/status` → `{ "enabled": true }`. The app's "Ask AI"
   card appears automatically once this is true.

### 2C. Store/signing secrets — already present, nothing to do
The web/android/ios jobs all got **past** signing (only the iOS archive step failed), so these
are set: `ANDROID_KEYSTORE_BASE64/PASSWORD/…`, `PLAY_SERVICE_ACCOUNT_JSON`,
`FIREBASE_SERVICE_ACCOUNT_JSON`, `IOS_DIST_CERT_P12_BASE64/PASSWORD`,
`IOS_PROVISION_PROFILE_BASE64`, `ASC_KEY_P8_BASE64/ASC_KEY_ID/ASC_ISSUER_ID`. Only revisit if one rotates.

---

## Task 3 — Ship everywhere, then keep `main` current

Once Task 1 archives cleanly and Task 2A's token is set:

**Option A — CI (one click, from anywhere):**
GitHub → Actions → **Ship** → Run workflow → `target=all`. Or:
```bash
gh workflow run ship.yml -f target=all --ref claude/security-review-themes-ai-support-boyo6w
```

**Option B — Local Mac (full control, follows `docs/SHIPPING.md`):**
verify (`flutter analyze lib` + `tsc --noEmit`) → bump build → Railway → Web
(`flutter build web` + `firebase deploy`) → `fastlane android internal` → `fastlane ios beta`.

**After a green ship, keep `main` the source of truth:**
```bash
git checkout main && git merge --ff-only claude/security-review-themes-ai-support-boyo6w && git push origin main
```

---

## TL;DR
1. `flutter pub get && flutter analyze lib && flutter build ipa` on this branch — verify the
   staged `device_info_plus` 13.x bump. (Or revert it and `fastlane ios beta` locally.)
2. Add `RAILWAY_TOKEN` (GitHub secret) **and** `GROQ_API_KEY` (Railway var).
3. Re-run **Ship / target=all**, then fast-forward `main`.

That closes iOS + backend + support-AI, and every future `target=all` run ships all four
targets with no gaps.
