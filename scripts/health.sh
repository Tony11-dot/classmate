#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

API_PORT="${API_PORT:-3000}"
API_BASE="${E2E_API_BASE_URL:-http://localhost:${API_PORT}}"

echo "▶ Start API (background)"
cd "$ROOT/services/api"
pnpm start &
API_PID=$!

cleanup() {
  echo "▶ Stop API"
  kill "$API_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "▶ Wait for API"
for i in $(seq 1 60); do
  code="$(curl -s -o /dev/null -w "%{http_code}" "${API_BASE}/api/auth/me" || true)"
  if [ "$code" = "401" ] || [ "$code" = "200" ]; then
    break
  fi
  sleep 1
done

code="$(curl -s -o /dev/null -w "%{http_code}" "${API_BASE}/api/auth/me" || true)"
if [ "$code" != "401" ] && [ "$code" != "200" ]; then
  echo "❌ API did not become ready (last status: $code)"
  exit 1
fi

echo "▶ API tests"
cd "$ROOT/services/api"
pnpm test

echo "▶ Admin-web E2E tests"
cd "$ROOT/apps/admin-web"
pnpm exec playwright test

echo "✅ ALL SYSTEMS GREEN"
