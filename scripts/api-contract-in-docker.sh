#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ api-contract-in-docker failed at line $LINENO: $BASH_COMMAND" >&2' ERR

docker compose up -d --force-recreate api db

# Determine compose project name (network is usually "<project>_default")
PROJECT="$(docker compose ls --format json | node -e 'let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{try{const j=JSON.parse(d); const p=j.find(x=>x.Name); console.log((p&&p.Name)||"classmate")}catch(e){console.log("classmate")}})')"
NET="${PROJECT}_default"

# Use a tiny curl image to hit the API container over compose network DNS ("api")
docker run --rm --network "$NET" curlimages/curl:8.10.1 \
  -fsS --connect-timeout 2 --max-time 10 \
  http://api:3000/api/health >/dev/null

TOKEN="$(docker run --rm --network "$NET" curlimages/curl:8.10.1 \
  -fsS --connect-timeout 2 --max-time 10 \
  -X POST http://api:3000/api/auth/login \
  -H 'Content-Type: application/json' \
  --data-binary '{"email":"admin@classmate.dev","password":"Admin123!"}')"

# parse token with node (available locally)
JWT="$(printf '%s' "$TOKEN" | node -e 'let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{try{console.log(JSON.parse(d).token||"")}catch(e){console.log("")}})')"
[ -n "$JWT" ] || { echo "❌ no token returned from login" >&2; exit 1; }

RESP="$(docker run --rm --network "$NET" curlimages/curl:8.10.1 \
  -fsS --connect-timeout 2 --max-time 10 \
  http://api:3000/api/parent/notifications/unread-count \
  -H "Authorization: Bearer $JWT")"

printf '%s' "$RESP" | node -e 'let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{const j=JSON.parse(d); if(!(j.ok===true && typeof j.unread==="number")) process.exit(1);});'

echo "✅ api contract (inside docker network) ok"
