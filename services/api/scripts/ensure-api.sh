#!/usr/bin/env bash
set -euo pipefail

PORT="${API_PORT:-3000}"
BASE="${E2E_API_BASE_URL:-http://localhost:$PORT}"

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  exit 0
fi

echo "api not listening on $PORT -> starting..."
pnpm -s start:dev >/tmp/api.log 2>&1 &
sleep 1

code="$(curl -sS -o /dev/null -w "%{http_code}" "$BASE/api/health" || true)"
if [ "$code" != "200" ]; then
  echo "api failed healthcheck (code=$code)"
  tail -n 80 /tmp/api.log || true
  exit 1
fi
