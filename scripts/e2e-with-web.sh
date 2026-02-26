#!/usr/bin/env bash
set -e

kill "$(lsof -ti tcp:3001)" 2>/dev/null || true
rm -rf apps/admin-web/.next

echo "▶ building admin-web..."
export NODE_ENV=production
NEXT_PUBLIC_API_BASE_URL=http://127.0.0.1:3002/api \
NEXT_PUBLIC_API_BASE=http://127.0.0.1:3002/api \
pnpm -C apps/admin-web -s build

echo "▶ starting admin-web on 3001..."
nohup env \
  NEXT_PUBLIC_API_BASE_URL=http://127.0.0.1:3002/api \
  NEXT_PUBLIC_API_BASE=http://127.0.0.1:3002/api \
  pnpm -C apps/admin-web -s start --port 3001 \
  >/tmp/admin-web.start.log 2>&1 &

PID=$!
sleep 1

echo "▶ running playwright..."
NEXT_PUBLIC_API_BASE_URL=http://127.0.0.1:3002/api \
NEXT_PUBLIC_API_BASE=http://127.0.0.1:3002/api \
E2E_API_BASE_URL=http://127.0.0.1:3002 \
WEB_BASE=http://127.0.0.1:3001 \
pnpm -C apps/admin-web -s exec playwright test --workers=1 || true

echo "▶ stopping admin-web..."
kill $PID 2>/dev/null || true
