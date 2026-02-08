#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API="$ROOT/services/api"

cd "$API"

# Prisma loads from .env by default (good). Ensure it's present.
if [[ ! -f ".env" ]]; then
  echo "❌ $API/.env missing (Prisma uses it)."
  exit 1
fi

# Runtime env
if [[ ! -f ".env.production" ]]; then
  echo "❌ $API/.env.production missing (runtime uses it)."
  exit 1
fi

set -a
source ".env.production"
set +a

echo "🔎 NODE_ENV=$NODE_ENV"
echo "🔎 DATABASE_URL=$DATABASE_URL"

echo "🧬 Prisma migrate deploy..."
npx prisma migrate deploy
npx prisma generate

echo "🧹 Freeing port 3000..."
if lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  PID="$(lsof -ti tcp:3000 | head -n 1)"
  echo "Killing PID $PID on :3000"
  kill -9 "$PID" || true
fi

echo "🚀 Starting API..."
pnpm start:prod:safe
