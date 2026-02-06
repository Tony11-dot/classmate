#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/.."

./scripts/green.sh

echo "== docker build api image =="
docker compose build api

echo "== done ✅ =="

echo "== build admin-web =="
pnpm -C apps/admin-web -s build

echo "== build parent-web =="
pnpm -C apps/parent-web -s build
