API_LOCAL="${API_LOCAL:-http://localhost:$API_PORT_IN_DOCKER/api}"

# == e2e seed (admin-web) ==
curl -fsS -X POST "$API_LOCAL/test/seed/admin-web" >/dev/null || true
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ api-contract-in-docker failed at line $LINENO: $BASH_COMMAND" >&2' ERR

docker compose up -d --force-recreate api db

# Determine compose project name (network is usually "<project>_default")
PROJECT="$(docker compose ls --format json | node -e 'let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{try{const j=JSON.parse(d); const p=j.find(x=>x.Name); console.log((p&&p.Name)||"classmate")}catch(e){console.log("classmate")}})')"
NET="${PROJECT}_default"


# --- resolve internal API port (container-side) ---
API_CID="$(docker compose ps -q api)"
# prefer container port bound to host 3000; if not present, pick first exposed container port
PORT_JSON="$(docker inspect "$API_CID" --format '{{json .NetworkSettings.Ports}}')"
API_PORT_IN_DOCKER="$(printf '%s' "$PORT_JSON" | node -e '
let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{
  const ports = JSON.parse(d||"{}");
  // try to find containerPort that maps to HostPort 3000
  for (const k of Object.keys(ports)) {
    const arr = ports[k] || [];
    if (arr.some(x => x && x.HostPort === "3000")) { console.log(k.split("/")[0]); return; }
  }
  // fallback: first container port key
  const first = Object.keys(ports)[0];
  console.log(first ? first.split("/")[0] : "3000");
});
')"

# Use a tiny curl image to hit the API container over compose network DNS ("api")
docker run --rm --network "$NET" curlimages/curl:8.10.1 \
  -fsS --connect-timeout 2 --max-time 10 \
  http://classmate-api-1:$API_PORT_IN_DOCKER/api/health >/dev/null

TOKEN="$(docker run --rm --network "$NET" curlimages/curl:8.10.1 \
  -fsS --connect-timeout 2 --max-time 10 \
  -X POST http://api:$API_PORT_IN_DOCKER/api/auth/login \
  -H 'Content-Type: application/json' \
  --data-binary '{"email":"parent1@classmate.app","password":"dev"}')"

# parse token with node (available locally)
JWT="$(printf '%s' "$TOKEN" | node -e 'let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{try{console.log(JSON.parse(d).token||"")}catch(e){console.log("")}})')"
[ -n "$JWT" ] || { echo "❌ no token returned from login" >&2; exit 1; }

RESP="$(docker run --rm --network "$NET" curlimages/curl:8.10.1 \
  -fsS --connect-timeout 2 --max-time 10 \
  http://api:$API_PORT_IN_DOCKER/api/parent/notifications/unread-count \
  -H "Authorization: Bearer $JWT")"

printf '%s' "$RESP" | node -e 'let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{const j=JSON.parse(d); if(!(j.ok===true && typeof j.unread==="number")) process.exit(1);});'

echo "✅ api contract (inside docker network) ok"
