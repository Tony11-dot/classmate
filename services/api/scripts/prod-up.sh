#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
API_DIR="$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)"
cd "$API_DIR"

PORT="${API_PORT:-3000}"
BASE="${E2E_API_BASE_URL:-http://localhost:$PORT}"

# load local prod env (optional)
if [ ! -f .env.prod ]; then echo "❌ .env.prod missing" >&2; exit 1; fi

if [ -f .env.prod ]; then
  set -a
  source .env.prod
  set +a
fi

echo "prod-up in $API_DIR on port $PORT..."
echo "NODE_ENV=production"
echo "ENABLE_E2E_SEED=(empty)"
echo "JWT_SECRET=${JWT_SECRET:+(set)}"

# build must exist
if [ ! -f dist/src/main.js ]; then
  echo "dist/src/main.js missing -> building..."
  pnpm -s build
fi

# kill port
pids="$(lsof -tiTCP:"$PORT" -sTCP:LISTEN || true)"
if [ -n "${pids:-}" ]; then
  echo "killing listeners: $pids"
  kill -9 $pids || true
fi

# start prod
ENABLE_E2E_SEED= NODE_ENV=production node dist/src/main.js >/tmp/api-prod.log 2>&1 &
PID=$!

sleep 0.25
if ! kill -0 "$PID" >/dev/null 2>&1; then
  echo "prod process died immediately ❌"
  tail -n 200 /tmp/api-prod.log || true
  exit 1
fi

for i in {1..40}; do
  code="$(curl -sS --connect-timeout 1 -o /dev/null -w "%{http_code}" 2>/dev/null "$BASE/api/health" || true)"
  if [ "$code" = "200" ]; then
    echo "prod healthy ✅ (pid=$PID)"
    exit 0
  fi
  sleep 0.25
done

echo "prod failed healthcheck ❌ (pid=$PID)"
tail -n 200 /tmp/api-prod.log || true
exit 1
