#!/usr/bin/env bash
set -euo pipefail

export API="${API:-http://localhost:3002}"
export PORT="${PORT:-3002}"

./scripts/guardrails.sh

# restart next dev in background
pkill -f "next dev" >/dev/null 2>&1 || true
rm -rf .next/dev/lock .next/dev || true
( PORT="$PORT" pnpm dev > /tmp/cm_backend_dev.log 2>&1 & echo $! > /tmp/cm_backend_pid ) >/dev/null

# wait for health
for i in {1..60}; do
  if curl -fsS "$API/api/health" >/dev/null 2>&1; then break; fi
  sleep 0.2
done
curl -fsS "$API/api/health" | jq

# seed + smoke
pnpm -s seed >/dev/null
./scripts/smoke.sh
