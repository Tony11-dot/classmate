#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ verify failed at line $LINENO: $BASH_COMMAND" >&2' ERR

cd "$(dirname "$0")/.."

echo "== node/pnpm =="
node -v
pnpm -v

echo "== build (api + webs) =="
pnpm -r -w --workspace-concurrency=1 \
  --filter ./services/api \
  --filter ./apps/admin-web \
  --filter ./apps/parent-web \
  run build

echo "== docker build (api image) =="
docker compose build api

echo "== smoke (unread preserved) =="
SMOKE_MARK_SEEN=0 bash ./scripts/green.sh

echo "== smoke (mark-seen path) =="
SMOKE_MARK_SEEN=1 bash ./scripts/green.sh

echo "✅ VERIFY OK"
