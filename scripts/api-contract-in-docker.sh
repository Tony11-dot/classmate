#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ api-contract-in-docker failed at line $LINENO: $BASH_COMMAND" >&2' ERR

docker compose up -d --force-recreate api db

API_CID="$(docker compose ps -q api)"

# ✅ Use the actual network(s) the api container is attached to (no guessing)
NET="$(docker inspect "$API_CID" -f \'{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}\' | awk \'{print $1}\')"
echo "NET=$NET"
if [ -z "$NET" ]; then
  echo "❌ could not determine compose network for api container" >&2
  docker compose ps >&2 || true
  exit 1
fi

# Wait until API is reachable from inside the compose network
echo "== in-docker health =="
if ! docker run --rm --network "$NET" curlimages/curl:8.10.1 -fsS \
  --retry 30 --retry-all-errors --retry-connrefused --retry-delay 1 --max-time 10 \
  http://api:3000/api/health >/dev/null
then
  echo "❌ api not reachable from inside docker network ($NET)" >&2
  docker compose ps >&2 || true
  docker compose logs --tail 200 api >&2 || true
  exit 1
fi
# Seed (best-effort)
docker run --rm --network "$NET" curlimages/curl:8.10.1 -fsS   -X POST http://api:3000/api/test/seed/admin-web >/dev/null || true

LOGIN_JSON="$(docker run --rm --network "$NET" curlimages/curl:8.10.1 -fsS   --retry 10 --retry-connrefused --retry-delay 1 --max-time 10   -X POST http://api:3000/api/auth/login   -H 'Content-Type: application/json'   --data-binary '{"email":"parent1@classmate.app","password":"dev"}')"

JWT="$(printf '%s' "$LOGIN_JSON" | node -e 'let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{try{console.log(JSON.parse(d).token||"")}catch(e){console.log("")}})')"
[ -n "$JWT" ] || { echo "❌ no token returned from login. body:" >&2; echo "$LOGIN_JSON" >&2; exit 1; }

RESP="$(docker run --rm --network "$NET" curlimages/curl:8.10.1 -fsS   --retry 10 --retry-connrefused --retry-delay 1 --max-time 10   http://api:3000/api/parent/notifications/unread-count   -H "Authorization: Bearer $JWT")"

printf '%s' "$RESP" | node -e 'let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{const j=JSON.parse(d); if(!(j.ok===true && typeof j.unread==="number")) process.exit(1);});'

echo "✅ api contract (inside docker network) ok"
