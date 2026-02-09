#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

set -a
[ -f .env.production ] && source .env.production
set +a

export BASE="${BASE:-http://localhost:3000}"

echo "== build =="
pnpm build

echo "== stop old (if any) =="
if [ -f .pilot.pid ]; then
  kill -9 "$(cat .pilot.pid)" 2>/dev/null || true
  rm -f .pilot.pid
fi
lsof -ti tcp:3000 | xargs -I{} kill -9 {} 2>/dev/null || true

echo "== start (background) =="
nohup pnpm start:prod:safe > .pilot.log 2>&1 &
echo $! > .pilot.pid
sleep 1

echo "== pid =="
cat .pilot.pid

echo "== health =="
curl -sS "$BASE/api/health" | jq

echo "✅ running (logs: tail -f .pilot.log)"
