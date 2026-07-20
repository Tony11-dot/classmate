# ClassMate — Cloud Shipping & Secrets (ship from anywhere, incl. your phone)

The `.github/workflows/ship.yml` workflow builds and ships ClassMate on GitHub's
runners using signing material kept in **GitHub Actions secrets**. This means a
release needs **no signing keys on the machine that triggers it** — you can ship
from a laptop, a browser, or Claude Code on your phone.

It is a faithful clone of the local Mac flow, in this order:
**verify (`flutter analyze` + `tsc`) → bump build → Railway → Web → Android → iOS → Sentry.**
The `verify` job gates everything (a red analyze/tsc stops the release before any
upload). The `railway` job mirrors `railway up` and **no-ops cleanly until you add
a `RAILWAY_TOKEN` secret** (Railway → Account → Tokens) — the app targets don't
need it.

> **The one thing to understand about the keys:** they live in GitHub, not on
> your phone. Your phone only sends a "go" signal (it triggers the workflow);
> GitHub does the signed build. Never copy a keystore, `.p12`, `.p8`, or
> service-account JSON onto the phone.

---

## How to ship (from a phone or anywhere)

You need a GitHub token with `repo` + `workflow` scope (Claude Code's `gh` already
has this — it's how it "gave the first prompt"). Then:

```bash
# ship everything (Android + Web + iOS), auto-bumping the build number
gh workflow run ship.yml -f target=all

# or just one target
gh workflow run ship.yml -f target=android
gh workflow run ship.yml -f target=web
gh workflow run ship.yml -f target=ios

# watch it
gh run watch $(gh run list --workflow=ship.yml -L1 --json databaseId -q '.[0].databaseId')
```

Or from the GitHub UI: **Actions → Ship → Run workflow**.

The `version` job bumps `pubspec.yaml` (`+N → +N+1`) and commits it, so Play and
TestFlight never reject a duplicate build number. Set `bump_build=false` to skip.

---

## Secrets registry

All values are stored via `gh secret set <NAME> --repo Tony11-dot/classmate`
(piped from a file/stdin — never printed). To rotate one, re-run that command
with the new value.

### Android — Google Play internal (6)
| Secret | Source |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `base64 < ~/classmate-upload-key.jks` (the upload keystore) |
| `ANDROID_KEYSTORE_PASSWORD` | `storePassword` in `apps/classmate_mobile/android/key.properties` |
| `ANDROID_KEY_PASSWORD` | `keyPassword` in `key.properties` |
| `ANDROID_KEY_ALIAS` | `keyAlias` in `key.properties` |
| `PLAY_SERVICE_ACCOUNT_JSON` | `apps/classmate_mobile/fastlane/play-service-account.json` |
| `SENTRY_AUTH_TOKEN` | `~/.classmate_sentry_token` (also used by iOS) |

### iOS — TestFlight (6)
| Secret | Source |
| --- | --- |
| `ASC_KEY_P8_BASE64` | `base64 < ~/Documents/AuthKey_28AUQ58BDS.p8` (App Store Connect API key) |
| `ASC_KEY_ID` | `28AUQ58BDS` |
| `ASC_ISSUER_ID` | App Store Connect → Users and Access → Integrations (the issuer UUID; also `export`ed in `~/.zshrc`) |
| `IOS_PROVISION_PROFILE_BASE64` | `base64 < apps/classmate_mobile/fastlane/profiles/AppStore_com.tonyaboud.classmate.mobileprovision` (profile name "ClassMate AppStore") |
| `IOS_DIST_CERT_P12_BASE64` | `base64` of an **Apple Distribution** identity exported to `.p12` |
| `IOS_DIST_CERT_PASSWORD` | the password that protects that `.p12` |

Re-export the distribution `.p12` from the login keychain (identity already
present as `Apple Distribution: Tony Aboud (NNFD7CKGLG)`):

```bash
security export -k login.keychain-db -t identities -f pkcs12 \
  -P '<password>' -o /tmp/dist.p12 "Apple Distribution: Tony Aboud (NNFD7CKGLG)"
base64 < /tmp/dist.p12 | gh secret set IOS_DIST_CERT_P12_BASE64 --repo Tony11-dot/classmate
printf '%s' '<password>' | gh secret set IOS_DIST_CERT_PASSWORD --repo Tony11-dot/classmate
rm -f /tmp/dist.p12
```

If the cert is ever lost/expired, regenerate it + the profile with
`cd apps/classmate_mobile && fastlane ios fix_signing`, then re-export as above.

### Web — Firebase Hosting (1)
| Secret | Source |
| --- | --- |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase Console → Project settings → Service accounts → **Generate new private key** (`classmate-f17d6-…json`) |

---

## Security rules for these secrets

- **Least privilege.** The Play service account needs only "Release to testing
  tracks"; the Firebase key is a Hosting deployer. Don't grant Owner.
- **Never commit them.** `.gitignore` already blocks `*.jks`, `*.p12`, `*.p8`,
  `*-service-account.json`, `key.properties`, `*.mobileprovision`. Keep it that
  way — the workflow reconstructs every file at runtime from secrets.
- **Rotate on exposure.** If a value is ever pasted into a chat/log/PR, treat it
  as burned: revoke it at the source (Play/Firebase/ASC/keystore) and re-set the
  secret. GitHub secret values are write-only — you can overwrite but never read
  them back, which is why this file lists *sources*, not values.
- **The phone holds no keys** — only a GitHub token. If the phone is lost, revoke
  that token (github.com → Settings → Developer settings → Tokens); the signing
  material is untouched.
- **Runner hygiene.** The iOS job builds in a throwaway keychain in `$RUNNER_TEMP`
  and the runner is destroyed after the job, so no signing material persists.

---

## Coverage status

| Target | Secrets | Ready |
| --- | --- | --- |
| Android | 6/6 | ✅ |
| Web | 1/1 | ✅ |
| iOS | 6/6 | ✅ |
| Railway | `RAILWAY_TOKEN` | ⛔ optional — job skips cleanly until the token is set |

Confirm names anytime with `gh secret list --repo Tony11-dot/classmate`.
The Railway job runs on `target=all` or `target=railway` and no-ops with a warning
until you add `RAILWAY_TOKEN` (Railway → Account → Tokens):
`printf '%s' '<token>' | gh secret set RAILWAY_TOKEN --repo Tony11-dot/classmate`.

> `gh secret list` showing `RAILWAY_TOKEN` is **not** proof it works — a secret can
> exist with an empty value, and the guard step then skips as if it were absent.
> The tell is in the job log: a real secret prints as `RAILWAY_TOKEN: ***`, an empty
> one prints as `RAILWAY_TOKEN:` with nothing after it.
>
> Losing this job is not the same as losing the deploy: Railway's own GitHub
> integration auto-deploys the API on pushes to `main` that touch backend paths
> (other pushes show as `SKIPPED` in its Deployments tab). `RAILWAY_TOKEN` only
> buys a *deterministic* deploy inside the ship run.

---

## The iOS job needs an Xcode **26** runner — don't "fix" it with a package bump

`device_info_plus` (transitive, via `sentry_flutter`) calls
`NSProcessInfo.isiOSAppOnVision`, which Foundation declares as
`API_AVAILABLE(ios(26.1))` — it exists **only in the iOS 26.1+ SDK**. On any older
runner the archive dies with:

```text
No visible @interface for 'NSProcessInfo' declares the selector 'isiOSAppOnVision'
```

That is an **SDK-availability** problem, not a package-version one. `macos-15` tops
out at Xcode 16.4 / iOS SDK 18.5, so it can never archive this app; `macos-26` ships
Xcode 26.x / iOS SDK 26.x — the same toolchain the Mac ships from. Hence
`runs-on: macos-26` plus a `Select newest Xcode 26.x` step that **fails loudly** if
no 26.x is present (an Xcode 16 archive cannot succeed, so burning four minutes to
reach the same error helps nobody).

Two dead ends, recorded so nobody re-walks them:

- **Bumping `device_info_plus` to 13.x doesn't resolve at all** — 13.1+ needs
  `win32 ^6.0.1` and `file_picker 10.x` pins `win32 ^5.9.0`, so `pub get` hard-fails.
- **It was never necessary.** `flutter build ipa` with `device_info_plus` 12.4.0
  archives cleanly on a local Xcode 26.6. The package was always fine; the SDK wasn't.
