#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ check-env failed at line $LINENO: $BASH_COMMAND" >&2' ERR

cd "$(dirname "$0")/.."

need_file() { [ -f "$1" ] || { echo "❌ missing file: $1" >&2; exit 1; }; }
need_key() { grep -qE "^$1=" "$2" || { echo "❌ missing $1 in $2" >&2; exit 1; }; }

need_file .env
need_file apps/admin-web/.env.local
need_file apps/parent-web/.env.local

# API essentials (adjust if you use different names)
need_key DATABASE_URL .env
need_key JWT_SECRET .env
need_key PORT .env || true

# Next.js essentials (adjust if you use different names)
need_key NEXT_PUBLIC_API_BASE_URL apps/admin-web/.env.local || true
need_key NEXT_PUBLIC_API_BASE_URL apps/parent-web/.env.local || true

echo "✅ env files look sane"
