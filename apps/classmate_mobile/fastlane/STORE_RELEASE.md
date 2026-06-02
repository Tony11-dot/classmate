# Store release — one-command lanes

All commands run from `apps/classmate_mobile/`.

## TestFlight (already working)
```
fastlane ios beta
```
Builds the IPA and uploads to TestFlight. Uses interactive Apple-ID 2FA.

## App Store — submit for public review
```
fastlane ios release
```
Builds, uploads the binary, and **submits 1.0.6 for Apple review** using the
listing already in App Store Connect (it skips metadata/screenshots so it will
not touch your store page). `automatic_release: false` → after Apple approves,
you press **Release** yourself.

> First time it may prompt for 2FA. To make it fully non-interactive, create an
> App Store Connect API key (Users and Access → Integrations → App Store Connect
> API), download the `.p8`, and we can switch the lane to `app_store_connect_api_key`.

## Play Console — internal testing (use this for build 96)
```
fastlane android internal
```

## Play Console — production (after ~1 week of internal testing)
```
fastlane android production    # staged 20% rollout; edit `rollout:` in Fastfile
```

### One-time Play setup (required before the android lanes work)
1. Play Console → **Setup → API access → Service accounts**.
2. Create a service account (or link an existing GCP one), grant it
   **Release apps to testing tracks** and **Release to production**.
3. Download its JSON key and save it as:
   `apps/classmate_mobile/fastlane/play-service-account.json`
   (this path is gitignored — never commit it).
4. Verify: `fastlane run validate_play_store_json_key json_key:fastlane/play-service-account.json`

> Note: Play requires the **first** build of a brand-new app to be uploaded
> manually once. After that the `supply` lanes work.
