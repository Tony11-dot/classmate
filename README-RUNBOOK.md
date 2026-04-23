# Classmate Runbook (minimal)

## One-command green reset (dev)
./scripts/green.sh

## One-command local bootstrap (dev)
./scripts/devx.sh bootstrap

## Release check (dev)
./scripts/release-check.sh

## Canonical ports (dev)
- API: http://localhost:3001
- DB:  localhost:5433 -> container 5432

## Required env (api)
- DATABASE_URL
- JWT_SECRET (>= 16 chars)
Optional:
- PORT (default 3001)
- CORS_ORIGINS (comma-separated)
- ENABLE_E2E_SEED (default false; dev/test only)

## Useful helpers
- Tail api logs: ./scripts/logs-api.sh
- Smoke notifications: ./scripts/smoke-parent-notifications.sh
