#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo -n "Supervisor PID file: "
cat .pilot.pid 2>/dev/null || echo "none"

echo "Listener on :3000 (node pid):"
lsof -nP -iTCP:3000 -sTCP:LISTEN || true

echo "Health:"
curl -sS "http://localhost:3000/api/health" | jq || true
