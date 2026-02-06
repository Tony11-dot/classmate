#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BASE="${BASE:-http://localhost:3000}"
EXPECT_DB_PORT="${EXPECT_DB_PORT:-5434}"

echo "== compose up (db, api) =="
docker compose up -d db api

echo "== ports =="
DB_BIND="$(docker compose port db 5432 2>/dev/null || true)"
API_BIND="$(docker compose port api 3000 2>/dev/null || true)"
echo "${DB_BIND:-"(db not published)"}"
echo "${API_BIND:-"(api not published)"}"

# Guardrail: DB port must match expected (extract last :PORT)
DB_PORT="$(printf '%s' "${DB_BIND:-}" | sed -E 's/.*:([0-9]+)$/\1/')"
[ -n "$DB_PORT" ] || { echo "DB port missing (db not running/published)"; exit 1; }
[ "$DB_PORT" = "$EXPECT_DB_PORT" ] || { echo "DB port mismatch: got $DB_PORT expected $EXPECT_DB_PORT"; exit 1; }

# Guardrail: API must be reachable
echo "== api health =="
curl -fsS "$BASE/api/health" >/dev/null || { echo "API health failed"; exit 1; }
echo "ok"

echo "== migrate deploy =="
(cd services/api && pnpm -s prisma migrate deploy --schema prisma/schema.prisma)

echo "== seed =="
(cd services/api && pnpm -s db:seed)

echo "== smoke =="
./scripts/smoke-parent-notifications.sh

echo "== GREEN ✅ =="
