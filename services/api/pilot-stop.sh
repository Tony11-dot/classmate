#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [ -f .pilot.pid ]; then
  kill -9 "$(cat .pilot.pid)" 2>/dev/null || true
  rm -f .pilot.pid
fi
lsof -ti tcp:3000 | xargs -I{} kill -9 {} 2>/dev/null || true
echo "✅ stopped"
