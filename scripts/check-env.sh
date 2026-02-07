#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ check-env failed at line $LINENO: $BASH_COMMAND" >&2' ERR

cd "$(dirname "$0")/.."

need_file() { [ -f "$1" ] || { echo "❌ missing file: $1" >&2; exit 1; }; }
need_key() { grep -qE "^$1=" "$2" || { echo "❌ missing $1 in $2" >&2; exit 1; }; }

need_file .env
if [ ! -f "apps/admin-web/.env.local" ]; then
  echo "⚠️  missing apps/admin-web/.env.local (ok if you use example)" 
  need_file "apps/admin-web/.env.local.example"
fi
if [ ! -f "apps/parent-web/.env.local" ]; then
  echo "⚠️  missing apps/parent-web/.env.local (ok if you use example)" 
  need_file "apps/parent-web/.env.local.example"
fi
# API essentials (adjust if you use different names)
need_key DATABASE_URL .env
need_key JWT_SECRET .env

# PORT is optional (docker/compose can own port mapping)
if ! grep -qE "^PORT=" .env; then
  echo "⚠️  PORT missing in .env (ok)";
fi

# Next.js essentials (adjust if you use different names)
if [ -f apps/admin-web/.env.local ]; then need_key NEXT_PUBLIC_API_BASE_URL apps/admin-web/.env.local; else need_key NEXT_PUBLIC_API_BASE_URL apps/admin-web/.env.local.example; fi
if [ -f apps/parent-web/.env.local ]; then need_key NEXT_PUBLIC_API_BASE_URL apps/parent-web/.env.local; else need_key NEXT_PUBLIC_API_BASE_URL apps/parent-web/.env.local.example; fi

echo "✅ env files look sane"
