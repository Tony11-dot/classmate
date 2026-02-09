#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# kill supervisor
if [ -f .pilot.pid ]; then
  kill -9 "$(cat .pilot.pid)" 2>/dev/null || true
  rm -f .pilot.pid
fi

# kill listener on port
lsof -ti tcp:3000 | xargs -I{} kill -9 {} 2>/dev/null || true

echo "✅ stopped"
