#!/usr/bin/env bash
set -euo pipefail


# --- robust login (route may differ between admin/parent) ---
try_login() {
  local base="$1"
  local email="$2"
  local password="$3"
  shift 3 || true

  local paths=(
    "/auth/login"
    "/auth/admin/login"
    "/admin/auth/login"
    "/auth/signin"
    "/api/auth/login"
    "/api/auth/admin/login"
    "/api/admin/auth/login"
  )

  for path in "${paths[@]}"; do
    local url="${base}${path}"
    local out
    out="$(curl -sS -X POST "$url" -H 'Content-Type: application/json' \
      --data-binary "{\"email\":\"$email\",\"password\":\"$password\"}" \
      -w "\n%{http_code}" || true)"

    local code="$(printf "%s" "$out" | tail -n 1)"
    local body="$(printf "%s" "$out" | sed '$d')"

    if [ "$code" = "200" ] || [ "$code" = "201" ]; then
      printf "%s" "$body"
      return 0
    fi
  done

  echo "❌ login failed on all known endpoints" >&2
  echo "$body" >&2
  echo "last http_code=$code" >&2
  return 1
}

IFS=$'\n\t'
trap 'echo "❌ verify failed at line $LINENO: $BASH_COMMAND" >&2' ERR

echo "== git clean check =="
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ working tree not clean. Commit/stash before verify for reproducible results." >&2
  git status --porcelain
  exit 1
fi

cd "$(dirname "$0")/.."

echo "== node/pnpm =="
node -v
pnpm -v

echo "== env checks =="
bash ./scripts/check-env.sh

echo "== build (api + webs) =="
pnpm -r -w --workspace-concurrency=1 \
  --filter ./services/api \
  --filter ./apps/admin-web \
  --filter ./apps/parent-web \
  run build

echo "== docker build (api image) =="
docker compose build api

echo "== db verify ==" 
bash ./scripts/db-verify.sh

echo "== api runtime smoke =="
docker compose up -d --force-recreate api db

API_LOCAL="http://localhost:3000/api"
api_ok=0
for i in $(seq 1 60); do
  if curl -fsS "$API_LOCAL/health" >/dev/null 2>&1; then
    echo "api: ok"
    api_ok=1
    break
  fi
  sleep 1
done


if [ "$api_ok" != "1" ]; then echo "❌ api: failed to become healthy" >&2; docker logs --tail 200 classmate-api-1 || true; exit 1; fi
TOKEN="$(curl -fsS -X POST "$API_LOCAL/auth/login" \
  -H 'Content-Type: application/json' \
  --data-binary '{"email":"admin@classmate.dev","password":"Admin123!"}' \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("token",""))')"

curl -fsS "$API_LOCAL/parent/notifications?take=2" \
  -H "Authorization: Bearer $TOKEN" >/dev/null

curl -fsS "$API_LOCAL/parent/notifications/unread-count" \
  -H "Authorization: Bearer $TOKEN" >/dev/null

echo "api runtime smoke: ok"

echo "== api contract ==" 
bash ./scripts/api-contract.sh

echo "== api contract (inside docker) =="
bash ./scripts/api-contract-in-docker.sh

echo "== smoke (unread preserved) =="
SMOKE_MARK_SEEN=0 bash ./scripts/green.sh

# assert unread preserved (expect 1)
API_LOCAL="http://localhost:3000/api"
LOGIN_JSON="$(try_login "$API_LOCAL" "admin@classmate.dev" "Admin123!")"
TOKEN="$(printf "%s" "$LOGIN_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("token",""))')"

UNREAD="$(curl -fsS "$API_LOCAL/parent/notifications/unread-count"   -H "Authorization: Bearer $TOKEN" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("unread"))')"
echo "unread=$UNREAD"
if [ "$UNREAD" != "1" ]; then echo "❌ expected unread=1 after SMOKE_MARK_SEEN=0" >&2; exit 1; fi

echo "== smoke (mark-seen path) =="
SMOKE_MARK_SEEN=1 bash ./scripts/green.sh

# assert mark-seen applied (expect 0)
API_LOCAL="http://localhost:3000/api"
TOKEN="$(curl -fsS -X POST "$API_LOCAL/auth/login"   -H 'Content-Type: application/json'   --data-binary '{"email":"admin@classmate.dev","password":"Admin123!"}'   | python3 -c 'import sys,json; print(json.load(sys.stdin).get("token",""))')"

UNREAD="$(curl -fsS "$API_LOCAL/parent/notifications/unread-count"   -H "Authorization: Bearer $TOKEN" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("unread"))')"
echo "unread=$UNREAD"
if [ "$UNREAD" != "0" ]; then echo "❌ expected unread=0 after SMOKE_MARK_SEEN=1" >&2; exit 1; fi

echo "✅ VERIFY OK"
