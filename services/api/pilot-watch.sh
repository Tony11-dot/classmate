#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
while true; do
  echo
  echo "=== $(date) ==="
  echo -n "PID file: "; cat .pilot.pid 2>/dev/null || echo "none"
  lsof -nP -iTCP:3000 -sTCP:LISTEN || true
  curl -sS "http://localhost:3000/api/health" | jq || true
  echo "--- last 5 log lines ---"
  tail -n 5 .pilot.log 2>/dev/null || true
  sleep 5
done
