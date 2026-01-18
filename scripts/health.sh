#!/usr/bin/env bash
set -euo pipefail

# IMPORTANT: ensure API + tests use the same DB as CI
export DATABASE_URL="${DATABASE_URL:-postgresql://postgres:postgres@postgres:5432/classmate_test}"
export NODE_ENV=test

echo "▶ Start API (background)"
cd services/api
pnpm start &
API_PID=$!

echo "▶ Wait for API"
for i in {1..30}; do
  if curl -sf http://localhost:3000/api/auth/me >/dev/null; then
    break
  fi
  sleep 1
done

echo "▶ API tests"
pnpm test

echo "▶ Admin-web E2E tests"
cd ../../apps/admin-web
pnpm exec playwright test

echo "▶ Stop API"
kill $API_PID

echo "✅ ALL SYSTEMS GREEN"
