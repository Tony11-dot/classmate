# ClassMate — Security Hardening Playbook

A repeatable security pass. Run before major releases or when touching auth, payments, or user input. Stack: NestJS + Prisma (`services/api`), Flutter (`apps/classmate_mobile`), Railway, Postgres, R2, Anthropic/OpenAI, Resend, Twilio, RevenueCat, Firebase, Sentry.

## 1 · Rate limiting (all endpoints; auth = max 5 / 15 min)

Use `@nestjs/throttler`.

- Global default throttle (e.g. 100 req/min/IP) registered as an `APP_GUARD` in `app.module.ts`.
- Strict per-route override on auth/sensitive routes — **5 attempts / 15 min**:
  ```ts
  @Throttle({ default: { limit: 5, ttl: 15 * 60 * 1000 } })
  ```
  Apply to: `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/reset-password`, phone/email verify (`startVerify`/`confirmVerify`), and the biometric password-confirm path (`/auth/login` re-use).
- Behind Railway's proxy, trust the proxy and key the limiter on the real client IP (`X-Forwarded-For`), not the proxy IP — otherwise everyone shares one bucket.
- Return `429 Too Many Requests` with a generic message (don't leak which field was wrong).

## 2 · Scan for hardcoded secrets

```bash
# fast grep pass (run from repo root)
grep -rnE "(sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9-]{20,}|AIza[0-9A-Za-z_-]{30,}|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9A-Za-z-]+|-----BEGIN [A-Z ]*PRIVATE KEY-----|appl_[A-Za-z0-9]+|goog_[A-Za-z0-9]+)" \
  --include='*.ts' --include='*.dart' --include='*.js' --include='*.json' --include='*.env*' . \
  | grep -vE "node_modules|/build/|\.dart_tool|pubspec.lock|package-lock"
# deeper: install gitleaks and scan history
gitleaks detect --source . --redact
```
Known-OK public keys that are *safe* to ship (validated server-side against the bundle ID): the RevenueCat **public** iOS key (`appl_*`) in source. Everything else (Anthropic, OpenAI, Resend, Twilio, ASC `.p8`, Play service-account JSON, Firebase admin) must NOT be in source.

## 3 · Secrets in env vars only; nothing in frontend or Git

- All backend secrets via `process.env` on Railway (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `RESEND_*`, `TWILIO_*`, `JWT_SECRET`, `DATABASE_URL`, R2 creds, etc.). Never commit `.env`.
- Verify `.gitignore` covers: `**/.env*`, `apps/classmate_mobile/fastlane/play-service-account.json`, `*.p8`, any `*service-account*.json`, Firebase admin keys.
- **Frontend must hold no server secrets.** The Flutter app should only carry *public* keys (RevenueCat public, Firebase client config). Confirm no Anthropic/OpenAI/Resend/Twilio keys are compiled into the app (`grep -rnE "sk-ant|sk-|whisper|RESEND|TWILIO_AUTH" apps/classmate_mobile/lib`).
- Confirm nothing leaked historically: `gitleaks detect` over full history; if a real secret was ever committed, **rotate it** (removing from HEAD isn't enough).
- The mobile app talks to the API only with the user's JWT — never an API provider key.

## 4 · Input validation & payload limits

- Global `ValidationPipe` with `whitelist: true`, `forbidNonWhitelisted: true`, `transform: true` in `main.ts`, and DTOs (`class-validator`) on every body. Strips unknown fields, rejects malformed types.
- **Body size limit**: cap JSON body (e.g. `app.use(json({ limit: '1mb' }))`) and file uploads (Multer `limits.fileSize`, e.g. 10–20 MB for images/PDFs; reject the rest with 413).
- Validate file **type** (mime + magic bytes) on uploads to R2 / NOVA vision — not just extension.
- Prisma parameterizes queries (no raw SQL string-building) — keep it that way; audit any `$queryRaw`.
- Reject oversized arrays in audience targeting / bulk endpoints (cap list lengths).

## 5 · Full audit & report

Checklist to verify and report on:
- [ ] AuthZ on every endpoint — role guards (`@Roles`) match the data, not just `JwtAuthGuard`. (We already fixed an unmetered NOVA endpoint; recheck `/nova/*`, admin, teacher, parent scopes.)
- [ ] School isolation — every student/teacher read is scoped by `schoolId` (the materials/meetings leak is fixed; re-grep for `findMany` without school scope).
- [ ] JWT: strong `JWT_SECRET`, sane expiry, no sensitive data in claims beyond ids/roles/schoolId.
- [ ] CORS locked to known origins (web app + marketing), not `*`.
- [ ] Security headers (`helmet`).
- [ ] No stack traces / internal errors leaked to clients (Sentry captures server-side; clients get generic messages).
- [ ] Passwords hashed (bcrypt/argon2), reset tokens single-use + hashed + short-lived (already done).
- [ ] Rate limiting live on auth (section 1).
- [ ] Dependency audit: `pnpm audit` (api) + `flutter pub outdated` for known-vuln packages.
- [ ] R2 objects not publicly listable; signed URLs or access-checked downloads.

Report = list each item PASS/FAIL with file:line for any FAIL, then fix highest-severity first.
