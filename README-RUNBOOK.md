# Classmate Runbook (minimal)

## One-command green reset (dev)
./scripts/green.sh

## Release check (dev)
./scripts/release-check.sh

## Canonical ports (dev)
- API: http://localhost:3000
- DB:  localhost:5434 -> container 5432

## Required env (api)
- DATABASE_URL
- JWT_SECRET (>= 16 chars)
Optional:
- PORT (default 3000)
- CORS_ORIGINS (comma-separated)
- ENABLE_E2E_SEED (default false; dev/test only)

## Useful helpers
- Tail api logs: ./scripts/logs-api.sh
- Smoke notifications: ./scripts/smoke-parent-notifications.sh

## Dev reset (fresh DB) + auth/roles matrix smoke

```bash
cd ~/Dev/classmate
docker compose down -v
docker compose up -d db api
until curl -fsS --noproxy "*" http://127.0.0.1:3000/api/health >/dev/null 2>&1; do sleep 0.5; done
curl -fsS --noproxy "*" -X POST http://127.0.0.1:3000/api/test/seed/admin-web >/dev/null

BASE="http://127.0.0.1:3000/api/admin/users"
TOKEN_ADMIN="$(curl -fsS --noproxy "*" -X POST http://127.0.0.1:3000/api/auth/login -H "content-type: application/json" -d '{"email":"admin1@classmate.app","password":"dev"}' | node -pe 'JSON.parse(require("fs").readFileSync(0,"utf8")).token')"
TOKEN_PARENT="$(curl -fsS --noproxy "*" -X POST http://127.0.0.1:3000/api/auth/login -H "content-type: application/json" -d '{"email":"parent1@classmate.app","password":"dev"}' | node -pe 'JSON.parse(require("fs").readFileSync(0,"utf8")).token')"

printf "no token: %s\n" "$(curl -sS -o /dev/null -w "%{http_code}" --noproxy "*" "$BASE")"                                         # 401
printf "parent:   %s\n" "$(curl -sS -o /dev/null -w "%{http_code}" --noproxy "*" "$BASE" -H "authorization: Bearer $TOKEN_PARENT")" # 403
printf "admin:    %s\n" "$(curl -sS -o /dev/null -w "%{http_code}" --noproxy "*" "$BASE" -H "authorization: Bearer $TOKEN_ADMIN")"  # 200
```
