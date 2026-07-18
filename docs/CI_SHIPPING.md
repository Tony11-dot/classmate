# ClassMate — Ship from your phone (GitHub Actions)

The **Ship** workflow (`.github/workflows/ship.yml`) runs the same fastlane
lanes CI-side that `docs/SHIPPING.md` runs on a Mac — so you can release from
the **GitHub mobile app** with no laptop.

## Trigger a release (phone)

1. GitHub app → repo **Tony11-dot/classmate** → **Actions** tab.
2. Pick **Ship** → **Run workflow**.
3. Choose the branch (e.g. `claude/messaging-429-error-android-zmokzg` or
   `main` after merge), toggle targets (Android / iOS / Web / Railway), pick the
   Play track, **Run**.
4. Watch the run. iOS builds on a macOS runner; the rest on Linux. Sentry symbol
   upload happens automatically inside each mobile lane.

`workflow_dispatch` only appears once this workflow file is on the **default
branch** (merge it to `main` first), then it can run against any branch.

## One-time setup — add these secrets

GitHub → repo **Settings → Secrets and variables → Actions → New repository
secret**. Everything lives here (encrypted), never in the repo or the build
container.

### Shared
| Secret | What it is |
|---|---|
| `SENTRY_AUTH_TOKEN` | Contents of `~/.classmate_sentry_token` (org `classmate-02`, project `flutter`). |

### Android → Play
| Secret | How to get it |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Your upload keystore, base64'd: `base64 -i upload-keystore.jks \| pbcopy`. |
| `ANDROID_KEYSTORE_PASSWORD` | `storePassword` from your local `android/key.properties`. |
| `ANDROID_KEY_PASSWORD` | `keyPassword` from `android/key.properties`. |
| `ANDROID_KEY_ALIAS` | `keyAlias` from `android/key.properties`. |
| `PLAY_SERVICE_ACCOUNT_JSON` | Full contents of `fastlane/play-service-account.json` (Play Console → Setup → API access → service account with "Release to testing tracks"). |

### iOS → TestFlight
| Secret | How to get it |
|---|---|
| `IOS_DIST_CERT_P12_BASE64` | Export your **Apple Distribution** cert **with its private key** from Keychain Access → `.p12`, then `base64 -i cert.p12 \| pbcopy`. |
| `IOS_DIST_CERT_PASSWORD` | The password you set when exporting the `.p12`. |
| `IOS_PROVISION_PROFILE_BASE64` | The **"ClassMate AppStore"** App Store profile (`.mobileprovision`), base64'd. Generate once with `fastlane ios fix_signing` locally, find it in `~/Library/MobileDevice/Provisioning Profiles/`. |
| `ASC_KEY_P8_BASE64` | `base64 -i ~/Documents/AuthKey_28AUQ58BDS.p8 \| pbcopy`. |
| `ASC_KEY_ID` | `28AUQ58BDS`. |
| `ASC_ISSUER_ID` | App Store Connect → Users and Access → Integrations → App Store Connect API → Issuer ID. |

### Web → Firebase Hosting
| Secret | How to get it |
|---|---|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase Console → Project settings → Service accounts → **Generate new private key**. Grant it Firebase Hosting deploy (Editor works). Paste the whole JSON. |

### Railway (optional — only if backend changed)
| Secret | How to get it |
|---|---|
| `RAILWAY_TOKEN` | Railway → Account → Tokens (project or account token). |

## Notes / gotchas

- **iOS signing**: the workflow imports your *existing* distribution cert +
  profile (Apple caps distribution certs at ~2/account, so we don't mint a new
  one per run). If a run fails with "doesn't include signing certificate",
  regenerate the profile locally with `fastlane ios fix_signing` and refresh
  `IOS_PROVISION_PROFILE_BASE64`.
- **Build number**: still bump `apps/classmate_mobile/pubspec.yaml` above the
  last uploaded build before shipping (Play + TestFlight reject duplicates).
  Do it in the commit, or from the GitHub app's file editor on your phone.
- **Flutter version**: pinned to `channel: stable`. If a stable bump ever breaks
  the build, pin `flutter-version:` in `ship.yml` instead.
- **`google-services.json` / `GoogleService-Info.plist`** are committed, so no
  secret is needed for them.
- Runbook parity: this mirrors `docs/SHIPPING.md`. That doc stays the source of
  truth for what each lane does and the manual-Mac fallback.
