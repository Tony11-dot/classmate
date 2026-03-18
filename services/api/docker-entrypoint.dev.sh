#!/bin/sh
set -eu

export DATABASE_URL="${DATABASE_URL:-postgresql://postgres:postgres@postgres:5432/classmate?schema=public}"

echo "[entrypoint] prisma db push..."
pnpm prisma db push --schema=prisma/schema.prisma

echo "[entrypoint] starting app..."
exec pnpm start:prod
