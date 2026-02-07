#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ api-contract failed at line $LINENO: $BASH_COMMAND" >&2' ERR

API_LOCAL="http://localhost:3000/api"

TOKEN="$(curl -fsS -X POST "$API_LOCAL/auth/login" \
  -H 'Content-Type: application/json' \
  --data-binary '{"email":"admin@classmate.dev","password":"Admin123!"}' \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("token",""))')"

# unread-count contract
curl -fsS "$API_LOCAL/parent/notifications/unread-count" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -e '.ok == true and (.unread|type=="number")' >/dev/null

# list contract (minimal)
curl -fsS "$API_LOCAL/parent/notifications?take=1" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -e '.ok == true and (.notifications|type=="array")' >/dev/null

echo "✅ api contract ok"
