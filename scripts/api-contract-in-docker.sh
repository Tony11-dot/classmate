#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ api-contract-in-docker failed at line $LINENO: $BASH_COMMAND" >&2' ERR

docker compose up -d --force-recreate api db

# run curl+jq inside the api container (or a tiny curl container) against api itself
docker exec -i classmate-api-1 sh -lc '
  set -euo pipefail
  API_LOCAL="http://localhost:3000/api"

  TOKEN="$(curl -fsS -X POST "$API_LOCAL/auth/login" \
    -H "Content-Type: application/json" \
    --data-binary "{\"email\":\"admin@classmate.dev\",\"password\":\"Admin123!\"}" \
    | node -e "let d=\"\";process.stdin.on(\"data\",c=>d+=c);process.stdin.on(\"end\",()=>{try{console.log(JSON.parse(d).token||\"\")}catch(e){console.log(\"\")}});")"

  curl -fsS "$API_LOCAL/parent/notifications/unread-count" \
    -H "Authorization: Bearer $TOKEN" \
    | node -e "let d=\"\";process.stdin.on(\"data\",c=>d+=c);process.stdin.on(\"end\",()=>{const j=JSON.parse(d); if(!(j.ok===true && typeof j.unread===\"number\")) process.exit(1);});"

  echo "✅ api contract (inside docker) ok"
'
