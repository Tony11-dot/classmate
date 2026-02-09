#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
echo "PID: $(cat .pilot.pid 2>/dev/null || echo none)"
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
curl -sS "http://localhost:3000/api/health" | jq || true
