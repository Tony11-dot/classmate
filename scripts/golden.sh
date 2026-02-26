#!/usr/bin/env bash
set -euo pipefail

if [ -f env/.env.dev ]; then
  export $(grep -v '^#' env/.env.dev | xargs)
fi


export NEXT_PUBLIC_API_BASE_URL="${NEXT_PUBLIC_API_BASE_URL:-http://127.0.0.1:3002/api}"
export NEXT_PUBLIC_API_BASE="${NEXT_PUBLIC_API_BASE:-http://127.0.0.1:3002/api}"
export E2E_API_BASE_URL="${E2E_API_BASE_URL:-http://127.0.0.1:3002}"
export WEB_BASE


# map APP_ENV -> NODE_ENV (Next.js requires standard values)
case "${APP_ENV:-dev}" in
  dev|development) export NODE_ENV=development ;;
  staging|prod|production) export NODE_ENV=production ;;
  test) export NODE_ENV=test ;;
  *) export NODE_ENV=production ;;
esac
="${WEB_BASE:-http://127.0.0.1:3001}"

echo "==> install"
pnpm -s -w i

echo "==> typecheck/lint (best effort)"
pnpm -s -w -r run typecheck || true
pnpm -s -w -r run lint || true

echo "==> admin-web e2e"
if [[ -x scripts/e2e-with-web.sh ]]; then
  ./scripts/e2e-with-web.sh
else
  pnpm -C apps/admin-web -s exec playwright test --workers=1
fi
