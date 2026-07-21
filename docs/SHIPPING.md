# ClassMate — Shipping Runbook

The tested release flow. **Order:** verify → bump → commit → **Railway → Web → Android (Play) → iOS (TestFlight)**. Sentry symbol/dSYM upload runs automatically inside the mobile fastlane lanes.

> **Ship from the cloud / your phone:** the same build can run on GitHub's
> runners with zero signing keys on your device — `gh workflow run ship.yml -f target=all`.
> The keystore, `.p12`, `.p8`, and service-account JSONs live in GitHub Actions
> secrets, not on the triggering machine. Full secret registry + the "keys never
> touch the phone" model: **[CI_SHIPPING.md](CI_SHIPPING.md)**. The manual
> local flow below still works and is the fallback if a CI signing step fails.

## 0 · Pre-ship (always)

```bash
# from repo root
cd apps/classmate_mobile && flutter analyze lib            # expect 0 errors/warnings (info lints OK)
cd ../../services/api && npx tsc -p tsconfig.json --noEmit  # expect exit 0
```

Bump the build number — **must be higher than the last uploaded build** (Play + TestFlight both reject duplicates):

```
apps/classmate_mobile/pubspec.yaml →  version: 1.0.8+N   (N = N + 1)
services/api/src/version/version.controller.ts →  FALLBACK_LATEST_MOBILE_BUILD = N
```

The second constant drives the in-app "Update available" prompt (`/version` →
`mobile.latestBuild`; the app compares its own build via package_info_plus and
nudges once per new build). Env `MOBILE_LATEST_BUILD` on Railway overrides it
without a deploy; `MOBILE_IOS_UPDATE_URL` / `MOBILE_ANDROID_UPDATE_URL` steer
the store links (iOS defaults to the TestFlight deep link until the App Store
launch).

Commit + push:

```bash
git add -A && git commit -m "…" && git push origin main
```

## 1 · Railway (backend) — only if backend changed

```bash
# from REPO ROOT (not services/api). .railwayignore must exclude **/build/ or it 413s after a mobile build.
railway up --detach
curl -s https://pacific-enchantment-production-7a80.up.railway.app/health   # → {"ok":true}
```

`db push` runs on boot. GitHub auto-deploy is flaky/SKIPPED — use `railway up`.

## 2 · Web (Firebase Hosting)

```bash
cd apps/classmate_mobile
flutter build web --release
firebase deploy --only hosting        # → https://classmate-f17d6.web.app
```

Web is NOT auto-built with mobile. Always build from `apps/classmate_mobile`, verify `build/web` mtime before deploying.

## 3 · Android → Play internal

```bash
cd apps/classmate_mobile
fastlane android internal             # builds AAB → Play internal track → Sentry symbols
# success: "✅ Uploaded to Play internal testing!"
```

## 4 · iOS → TestFlight

```bash
cd apps/classmate_mobile
fastlane ios beta                     # builds IPA → TestFlight → dSYMs → Sentry
# success: "✅ Uploaded to TestFlight!"
```

App Store Connect API key auth works from the ambient env: `ASC_KEY_ID=28AUQ58BDS`, key at `~/Documents/AuthKey_28AUQ58BDS.p8`, `ASC_ISSUER_ID` exported. No 2FA needed when the key is valid.

---

## Gotchas (all hit in real ships)

### Sentry symbol upload HANGS (frequent)
`sentry-cli … debug-files upload` sometimes sits at 0% CPU (state S) for many minutes/hours. It runs **after** the store upload, so the build is **already delivered**. Kill it and move on:

```bash
pkill -9 -f sentry-cli ; pkill -9 -f "fastlane ios" ; pkill -9 -f "fastlane android"
```

⚠ The lane's `✅ Uploaded to …` line prints **after** the Sentry step, so its absence does **NOT** mean the store upload failed. Confirm via the log:
- iOS: `Successfully uploaded the new binary to App Store Connect`
- Android: `Uploading all changes to Google Play...`

Sentry token: `~/.classmate_sentry_token` (org `classmate-02`, project `flutter`).

### iOS "PLA Update available" (signing block)
`error: exportArchive … Unable to process request - PLA Update available` + `No signing certificate "iOS Distribution" found` = Apple published a new **Developer Program License Agreement** the account holder must accept.

1. Accept it at **developer.apple.com/account** (banner "Review Agreement") or App Store Connect → Business → Agreements.
2. `rm -f apps/classmate_mobile/build/ios/ipa/ClassMate.ipa` — so a failed export can't silently re-upload the **previous** IPA (which triggers "bundle version must be higher than <N-1>").
3. Re-run `fastlane ios beta`.

### iOS export: "No Accounts" / "No signing certificate iOS Distribution found" (cert lost)
Export fails repeatedly with `exportArchive: No Accounts` + `No signing certificate "iOS Distribution" found` (the **archive** succeeds; only **export** fails). Means this Mac's keychain has **no Apple Distribution cert for the app's team** (team `NNFD7CKGLG`, bundle `com.tonyaboud.classmate`) and **no Apple ID is signed into Xcode**. A keychain reset/cert removal causes it; the private key is **not** recoverable from Apple, so a new cert must be issued. The project uses *automatic* signing with no `match`, so there's no cert backup.

Fix — fully headless via the ASC API key (no Xcode GUI):
```bash
cd apps/classmate_mobile
fastlane ios fix_signing          # creates+installs an Apple Distribution cert
                                  # + a "ClassMate AppStore" App Store profile
                                  # that INCLUDES that cert (sigh force:true)
rm -f build/ios/ipa/ClassMate.ipa # drop any stale IPA so a retry can't re-upload it
fastlane ios beta                 # export now uses manual signing (ExportOptions.plist)
```
- `fastlane ios fix_signing` is a dedicated lane (in the Fastfile). It must regenerate the profile with `force: true` — a stale Xcode-managed profile references the *old* cert and export then errors `profile … doesn't include signing certificate`.
- `ios/ExportOptions.plist` is set to **manual** signing (`signingStyle=manual`, `signingCertificate=Apple Distribution`, profile `ClassMate AppStore`) — automatic signing can't work at export without an Xcode account even when the cert is present.
- Cert/profile artifacts land in `fastlane/certs/` + `fastlane/profiles/` (the `.p12` private key) — **gitignored, never commit**.
- Apple caps Apple Distribution certs at ~2/account. If `fix_signing` reports "reached the limit", revoke an unused one at developer.apple.com/account → Certificates, then re-run.

### Version-number collisions
Bump above the last uploaded build. Play: "Version code N has already been used". TestFlight: "bundle version must be higher than the previously uploaded version".

### Build artifact contention
Each mobile lane uploads its own symbols right after building, so Android/iOS order doesn't matter for correctness — but **don't run two `flutter build`s concurrently** (they share `build/symbols` and clobber each other).

### Tooling locations
- fastlane lanes + Appfile + Fastfile: `apps/classmate_mobile/fastlane/`
- Play service account: `apps/classmate_mobile/fastlane/play-service-account.json`
- Prod API: `https://pacific-enchantment-production-7a80.up.railway.app`
- Web: `classmate-f17d6.web.app` (Firebase project `classmate-f17d6`)
