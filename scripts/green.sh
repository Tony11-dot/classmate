#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BASE="${BASE:-http://localhost:3001}"
EXPECT_DB_PORT="${EXPECT_DB_PORT:-5433}"

echo "== bootstrap local db + api =="
API_PORT="${BASE##*:}" DB_PORT="$EXPECT_DB_PORT" ./scripts/devx.sh bootstrap

echo "== ports =="
DB_BIND="$(docker ps --format '{{.Names}} {{.Ports}}' | grep 'classmate-postgres' || true)"
echo "${DB_BIND:-"(db not published)"}"
echo "$BASE"

# Guardrail: DB port must match expected (extract published host port)
DB_PORT="$(printf '%s' "${DB_BIND:-}" | sed -En 's/.*0\.0\.0\.0:([0-9]+)->5432.*/\1/p')"
[ -n "$DB_PORT" ] || { echo "DB port missing (db not running/published)"; exit 1; }
[ "$DB_PORT" = "$EXPECT_DB_PORT" ] || { echo "DB port mismatch: got $DB_PORT expected $EXPECT_DB_PORT"; exit 1; }

# Guardrail: API must be reachable
echo "== api health =="
./scripts/wait-api.sh "$BASE/api/health" || { echo "API health failed"; exit 1; }
echo "ok"

if [ "${RUN_SMOKE:-0}" = "1" ]; then
	echo "== smoke =="
	BASE="$BASE" ./scripts/smoke-parent-notifications.sh
else
	echo "== smoke =="
	echo "skipped (set RUN_SMOKE=1 to run the older parent-notifications smoke flow)"
fi

echo "== GREEN ✅ =="
