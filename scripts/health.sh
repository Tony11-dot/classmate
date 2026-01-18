#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "▶ Start API (background)"
cd "$ROOT/services/api"

# Start Nest in background (adjust if your start command differs)
# If you don't have a start script that runs TS directly, we'll tweak after.
pnpm start &
API_PID=$!

cleanup() {
  echo "▶ Stop API"
  kill "$API_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "▶ Wait for API"
for i in $(seq 1 60); do
  if curl -sSf "http://localhost:3000/api/auth/me" >/dev/null 2>&1; then
    break
  fi
  # /api/auth/me returns 401 when up; treat that as "up"
  if curl -sS "http://localhost:3000/api/auth/me" 2>/dev/null | rg -q "Unauthorized"; then
    break
  fi
  sleep 1
done

echo "▶ API tests"
pnpm test

echo "▶ Admin-web E2E tests"
cd "$ROOT/apps/admin-web"
pnpm exec playwright test

echo "✅ ALL SYSTEMS GREEN"
