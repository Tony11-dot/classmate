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
