#!/usr/bin/env bash
set -euo pipefail

cd "$(git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null || git -C "$HOME/Dev/classmate" rev-parse --show-toplevel)"

echo "[smoke] lint"
pnpm -w --filter @classmate/api lint >/dev/null

echo "[smoke] test"
pnpm -w --filter @classmate/api test >/dev/null

echo "[smoke] build"
pnpm -w -r run build >/dev/null || true

echo "[smoke] docker build+up"
docker compose up -d --build api >/dev/null

echo "[smoke] wait health"
until curl -fsS --noproxy "*" http://127.0.0.1:3000/api/health >/dev/null 2>&1; do sleep 0.5; done
curl -fsS --noproxy "*" http://127.0.0.1:3000/api/health >/dev/null && echo "[smoke] ok"
