#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ api-contract failed at line $LINENO: $BASH_COMMAND" >&2' ERR

API_LOCAL="http://localhost:3000/api"

# == e2e seed (admin-web) ==
curl -fsS -X POST "$API_LOCAL/test/seed/admin-web" >/dev/null || true

LOGIN_JSON="$(curl -fsS -X POST "$API_LOCAL/auth/login" \
  -H 'Content-Type: application/json' \
  --data-binary "{\"email\":\"${VERIFY_PARENT_EMAIL:-parent1@classmate.app}\",\"password\":\"${VERIFY_PARENT_PASSWORD:-dev}\"}" \
  || true)"
TOKEN="$(printf "%s" "$LOGIN_JSON" | python3 -c 'import sys,json; data=sys.stdin.read().strip(); print(json.loads(data).get("token","") if data else "")')"
if [ -z "$TOKEN" ]; then
  echo "❌ api-contract: login failed. body:" >&2
  echo "$LOGIN_JSON" >&2
  exit 1
fi

# unread-count contract
curl -fsS "$API_LOCAL/parent/notifications/unread-count" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -e '.ok == true and (.unread|type=="number")' >/dev/null

# list contract (minimal)
curl -fsS "$API_LOCAL/parent/notifications?take=1" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -e '.ok == true and (.notifications|type=="array")' >/dev/null

echo "✅ api contract ok"
