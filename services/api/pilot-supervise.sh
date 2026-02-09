#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

set -a
[ -f .env.production ] && source .env.production
set +a

export BASE="${BASE:-http://localhost:3000}"

echo "== build =="
pnpm build

echo "== supervise (auto-restart) =="
while true; do
  echo "== starting api at $(date) =="
  pnpm start:prod:safe
  code=$?
  echo "== api exited with $code at $(date) =="

  # backoff so it doesn't restart 1000x/sec if something is broken
  sleep 2
done
