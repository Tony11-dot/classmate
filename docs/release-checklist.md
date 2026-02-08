# Release checklist

## Preflight
- [ ] `bash ./scripts/verify.sh` green on clean clone
- [ ] `docker compose up` works on fresh machine (no local state)
- [ ] DB migrations: `prisma migrate deploy` no pending
- [ ] Seed: admin created, login works

## API
- [ ] `/api/health` ok
- [ ] Notifications list/unread/mark-seen ok
- [ ] SSE connect + receive events ok
- [ ] Auth roles/scopes enforced

## Webs
- [ ] Admin: login, attendance, grades
- [ ] Parent: dashboard, notifications page, SSE live updates

## Ops
- [ ] logs are readable (`scripts/logs-api.sh`)
- [ ] env docs updated
- [ ] tag created (semver)
