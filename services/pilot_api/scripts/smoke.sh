#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE:-http://localhost:3000}"
EMAIL="${EMAIL:-admin@demo.com}"
PASSWORD="${PASSWORD:-Password123!}"

echo "== health =="
for i in {1..30}; do
  if curl -fsS "$BASE/api/health" >/tmp/health.json 2>/dev/null; then
    cat /tmp/health.json | jq .
    break
  fi
  sleep 0.2
  if [ "$i" -eq 30 ]; then
    echo "❌ health never became reachable"
    exit 1
  fi
done

echo "== login =="
LOGIN="$(curl -sS -X POST "$BASE/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")"
echo "$LOGIN" | jq .

TOKEN="$(echo "$LOGIN" | jq -r .token)"
echo "TOKEN_PREFIX=$(echo "$TOKEN" | cut -c1-20)..."

echo "== me =="
curl -sS "$BASE/api/me" -H "Authorization: Bearer $TOKEN" | jq .

echo "== admin ping =="
curl -sS "$BASE/api/admin/ping" -H "Authorization: Bearer $TOKEN" | jq .

echo "== assignments =="
curl -sS "$BASE/api/assignments" -H "Authorization: Bearer $TOKEN" | jq .

echo "== grades =="
curl -sS "$BASE/api/grades" -H "Authorization: Bearer $TOKEN" | jq .
