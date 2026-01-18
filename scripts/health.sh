#!/usr/bin/env bash
set -e

echo "▶ API tests"
cd services/api
pnpm test

echo "▶ Admin-web E2E tests"
cd ../../apps/admin-web
pnpm exec playwright test

echo "✅ ALL SYSTEMS GREEN"

