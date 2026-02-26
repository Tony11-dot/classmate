#!/usr/bin/env bash
set -euo pipefail

# =========================
# safe env loader
# =========================
load_env_file() {
  local f="$1"
  [ -f "$f" ] || return 0
  while IFS= read -r line || [ -n "$line" ]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    # expect KEY=VALUE lines; export as-is
    export "$line"
  done < "$f"
}

# prefer env/.env.dev unless APP_ENV says otherwise
APP_ENV="${APP_ENV:-dev}"
case "$APP_ENV" in
  dev|development)   load_env_file "env/.env.dev" ;;
  staging)           load_env_file "env/.env.staging" ;;
  prod|production)   load_env_file "env/.env.prod" ;;
  *)                 load_env_file "env/.env.dev" ;;
esac

# Next.js requires standard NODE_ENV values
case "${APP_ENV:-dev}" in
  dev|development) export NODE_ENV=development ;;
  test)            export NODE_ENV=test ;;
  *)               export NODE_ENV=production ;;
esac

# =========================
# defaults (override in env files)
# =========================
export API_PORT="${API_PORT:-3002}"
export WEB_PORT="${WEB_PORT:-3001}"

export NEXT_PUBLIC_API_BASE_URL="${NEXT_PUBLIC_API_BASE_URL:-http://127.0.0.1:${API_PORT}/api}"
export NEXT_PUBLIC_API_BASE="${NEXT_PUBLIC_API_BASE:-http://127.0.0.1:${API_PORT}/api}"
export E2E_API_BASE_URL="${E2E_API_BASE_URL:-http://127.0.0.1:${API_PORT}}"
export WEB_BASE="${WEB_BASE:-http://127.0.0.1:${WEB_PORT}}"

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
