#!/usr/bin/env bash
set -euo pipefail

WEB_PORT="${WEB_PORT:-3001}"
API_PORT="${API_PORT:-3002}"

export NODE_ENV=production
export NEXT_PUBLIC_API_BASE_URL="${NEXT_PUBLIC_API_BASE_URL:-http://127.0.0.1:${API_PORT}/api}"
export NEXT_PUBLIC_API_BASE="${NEXT_PUBLIC_API_BASE:-http://127.0.0.1:${API_PORT}/api}"
export E2E_API_BASE_URL="${E2E_API_BASE_URL:-http://127.0.0.1:${API_PORT}}"
export WEB_BASE="${WEB_BASE:-http://127.0.0.1:${WEB_PORT}}"

# stop any previous server
kill "$(lsof -ti tcp:${WEB_PORT} 2>/dev/null || true)" 2>/dev/null || true
rm -rf apps/admin-web/.next

echo "▶ building admin-web..."
pnpm -C apps/admin-web -s exec next build

echo "▶ starting admin-web on ${WEB_PORT}..."
nohup env \
  NODE_ENV=production \
  NEXT_PUBLIC_API_BASE_URL="${NEXT_PUBLIC_API_BASE_URL}" \
  NEXT_PUBLIC_API_BASE="${NEXT_PUBLIC_API_BASE}" \
  pnpm -C apps/admin-web -s exec next start -p "${WEB_PORT}" \
  >/tmp/admin-web.start.log 2>&1 &

PID=$!
sleep 1

echo "▶ running playwright..."
NODE_ENV=production \
NEXT_PUBLIC_API_BASE_URL="${NEXT_PUBLIC_API_BASE_URL}" \
NEXT_PUBLIC_API_BASE="${NEXT_PUBLIC_API_BASE}" \
E2E_API_BASE_URL="${E2E_API_BASE_URL}" \
WEB_BASE="${WEB_BASE}" \
pnpm -C apps/admin-web -s exec playwright test --workers=1

echo "▶ stopping admin-web..."
kill "$PID" 2>/dev/null || true
