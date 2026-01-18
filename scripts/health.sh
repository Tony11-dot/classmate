#!/usr/bin/env bash
set -euo pipefail

API_PORT="${API_PORT:-3000}"
API_URL="http://127.0.0.1:${API_PORT}"

echo "▶ Start API (background)"
pnpm -C services/api start > /tmp/api.log 2>&1 &
API_PID="$!"

cleanup() {
  echo "▶ Stop API"
  kill "$API_PID" >/dev/null 2>&1 || true
  wait "$API_PID" >/dev/null 2>&1 || true
  echo "▶ API log (tail)"
  tail -n 200 /tmp/api.log || true
}
trap cleanup EXIT

echo "▶ Wait for API on ${API_URL}"
for i in $(seq 1 60); do
  if (echo > /dev/tcp/127.0.0.1/"$API_PORT") >/dev/null 2>&1; then
    echo "✅ API is up"
    break
  fi
  sleep 1
done

echo "▶ API unit/e2e tests"
E2E_API_BASE_URL="${API_URL}" pnpm -C services/api test

echo "▶ Admin-web E2E tests"
pnpm -C apps/admin-web exec playwright test

echo "✅ ALL SYSTEMS GREEN"
