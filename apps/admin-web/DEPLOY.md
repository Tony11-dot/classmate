# ClassMate Web Deploy

Single Vercel project serves both surfaces under `classmateapp.org`:

| Path                                    | Served by                 | Source                                                    |
| --------------------------------------- | ------------------------- | --------------------------------------------------------- |
| `/`                                     | Next.js                   | `apps/admin-web/src/app/page.tsx` (marketing landing)     |
| `/login`                                | Next.js                   | `apps/admin-web/src/app/login/page.tsx`                   |
| `/attendance`, `/grades`, `/classrooms` | Next.js                   | legacy admin pages (kept until Flutter web replaces them) |
| `/legacy-dashboard`                     | Next.js                   | the old `/` dashboard, archived                           |
| `/app`, `/app/*`                        | Flutter web (compiled JS) | `apps/classmate_mobile/build/web/`                        |

## How `/app` works

The Flutter mobile app is compiled to JS with the `--base-href "/app/"` flag
and the output is dropped into `apps/admin-web/public/app/`. Next.js serves
the `public/` directory verbatim, so the Flutter SPA boots from any URL
under `/app`.

Routing inside the Flutter app is owned by `go_router`. With the base href
set, `/schedule` inside the app resolves to `classmateapp.org/app/schedule`.

## One-shot build (local)

```bash
# from repo root
./scripts/sync-flutter-web.sh         # builds Flutter web -> public/app
pnpm --filter admin-web build         # builds Next.js (which now bundles public/app)
```

## CI build (`.github/workflows/web-deploy.yml`)

The action checks out, installs Flutter + pnpm, runs `sync-flutter-web.sh`,
then defers to Vercel's git integration to build and deploy Next.js.

The Vercel project is configured with:

- Root directory: `apps/admin-web`
- Build command: `bash ../../scripts/sync-flutter-web.sh && next build`
  (Vercel runs from the project root directory)
- Install command: `pnpm install`

> **Note**: Vercel's build environment does not include the Flutter SDK by
> default. The current strategy is to ship `public/app/*` artifacts via a
> separate GH Action that builds Flutter, commits the artifacts to a
> deployed-only branch, and lets Vercel deploy from there — OR to use
> `vercel deploy --prebuilt` from a GH Action that builds locally with
> Flutter installed.

Pick one of the strategies above before pointing `classmateapp.org` at the
project. The split-domain alternative (marketing on Vercel, Flutter on
Cloudflare Pages) is documented in `docs/web-deploy-options.md` (TODO).

## Updating the Flutter app

Any merge to `main` that touches `apps/classmate_mobile/lib/**` triggers a
fresh Flutter web build via the GH Action, which pushes new
`apps/admin-web/public/app/*` artifacts and triggers a Vercel deploy. So
the web app stays in sync with mobile automatically — same code, same
features, same translations.

## Subscriptions on web

RevenueCat is iOS/Android only. The Flutter web build's purchase entries
in `revenuecat_service.dart` throw `StateError('Purchases unavailable on
this platform')`; the paywall sheet's existing `try/catch` surfaces a
clean error. The path forward is to add a Stripe Checkout fallback that
the paywall opens via `launchUrl` on web — endpoint already stubbed in
`services/api/src/billing/`.

## Push notifications on web

The service worker `apps/classmate_mobile/web/firebase-messaging-sw.js`
is in place — Flutter's web build automatically copies it into
`build/web/firebase-messaging-sw.js`, where FCM expects to find it.

Before the first deploy you still need to set the VAPID key (Firebase
console → Project settings → Cloud Messaging → Web Push certificates):

```bash
flutter build web --release --base-href "/app/" \
  --dart-define=CM_FCM_VAPID_KEY="BPj…your-vapid-key…"
```

Without the dart-define, web push registration silently no-ops (no
crash). The Flutter app still works, users just don't receive web
pushes until the key is wired in.

When the SW config changes (Firebase project apiKey, etc.), update both
`firebase-messaging-sw.js` AND `firebase_options.dart -> web` — they
duplicate the same config because service workers can't import Dart.
