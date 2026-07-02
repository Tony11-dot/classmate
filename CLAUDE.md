# ClassMate

Monorepo: `services/api` (NestJS + Prisma + Postgres, on Railway) · `apps/classmate_mobile` (Flutter — iOS, Android, Web) · `marketing/` (static site). AI tutor "NOVA" is Anthropic Claude (students-only). Stack also: R2, Resend, Twilio, RevenueCat, Firebase, Sentry.

## Playbooks

Full runbooks live in `docs/SHIPPING.md` and `docs/SECURITY.md` — **read the relevant one only when doing that work** (shipping a release, or a security/auth pass). They are NOT auto-loaded, to keep each session lean; the TL;DR below is enough for everyday work.

TL;DR pointers:

- **Shipping a release** (full: `docs/SHIPPING.md`). Verify (`flutter analyze lib` + `tsc --noEmit`) → bump `pubspec.yaml` build number **above the last uploaded** → commit/push → **Railway (if backend changed) → Web (`flutter build web` + `firebase deploy`) → `fastlane android internal` → `fastlane ios beta`**.
  - ⚠ Sentry symbol upload **hangs intermittently** — it runs *after* the store upload, so the build is already delivered; `pkill -9 -f sentry-cli`. The `✅ Uploaded…` line prints *after* Sentry, so its absence ≠ failure.
  - ⚠ iOS "PLA Update available" = accept the Apple Developer Program License Agreement at developer.apple.com/account, `rm -f apps/classmate_mobile/build/ios/ipa/ClassMate.ipa`, re-run.

- **Security hardening** (full: `docs/SECURITY.md`). Rate-limit auth (5/15min via `@nestjs/throttler`), scan for hardcoded secrets (`gitleaks`), secrets in env only (never in the Flutter app or Git), global `ValidationPipe` (whitelist + body/file size limits), and the full authZ / school-isolation / CORS / headers audit checklist.

## Conventions

- Backend: NestJS modules under `services/api/src/<feature>`; Prisma schema at `services/api/prisma/schema.prisma`. Guards registered globally in `app.module.ts` (`JwtAuthGuard` + `RolesGuard`); gate AI/sensitive routes with `@Roles(...)`, not just auth.
- Every student/teacher read must be **school-scoped** (`schoolId`) — cross-school leaks are a recurring bug class.
- Flutter: features under `apps/classmate_mobile/lib/features/`; localized via ARB (`lib/l10n/app_en.arb` is the template — run `flutter gen-l10n` after edits; other locales fall back to English).
- Mobile holds **no server secrets** — only the user's JWT + public keys.
