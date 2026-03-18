#!/bin/sh
set -eu

export DATABASE_URL="${DATABASE_URL:-postgresql://postgres:postgres@postgres:5432/classmate?schema=public}"

echo "[entrypoint] prisma db push..."
pnpm prisma db push --schema=prisma/schema.prisma

echo "[entrypoint] starting app..."
if [ -f .env.prod ]; then
  set -a
  . ./.env.prod
  set +a
fi

exec env ENABLE_E2E_SEED= NODE_ENV=production node dist/main.js
