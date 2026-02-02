#!/usr/bin/env bash
set -euo pipefail

# Always run from services/api (directory containing this script)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
API_DIR="$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)"
cd "$API_DIR"

PORT="${API_PORT:-3000}"
BASE="${E2E_API_BASE_URL:-http://localhost:$PORT}"

echo "restarting api in $API_DIR on port $PORT..."

# hard kill anything listening
pids="$(lsof -tiTCP:"$PORT" -sTCP:LISTEN || true)"
if [ -n "${pids:-}" ]; then
  echo "killing: $pids"
  kill -9 $pids || true
fi

# start fresh
pnpm -s start:dev >/tmp/api.log 2>&1 &
API_PID=$!
sleep 0.2

# if the process died immediately, show logs
if ! kill -0 "$API_PID" >/dev/null 2>&1; then
  echo "api process exited immediately ❌"
  tail -n 160 /tmp/api.log || true
  exit 1
fi

# healthcheck (retry a bit)
for i in {1..40}; do
  code="$(curl -sS --connect-timeout 1 -o /dev/null -w "%{http_code}" 2>/dev/null "$BASE/api/health" || true)"
  if [ "$code" = "200" ]; then
    echo "api healthy ✅ (pid=$API_PID)"
    exit 0
  fi
  sleep 0.25
done

echo "api failed healthcheck ❌"
tail -n 160 /tmp/api.log || true
exit 1
