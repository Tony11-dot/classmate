#!/usr/bin/env bash
set -euo pipefail
PORT="${1:-3000}"

echo "who owns port $PORT?"
lsof -nP -iTCP:"$PORT" -sTCP:LISTEN || echo "port $PORT free ✅"
