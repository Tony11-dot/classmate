#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE:-http://localhost:3000}"

if [[ -z "${STUDENT_EMAIL:-}" || -z "${STUDENT_PASSWORD:-}" ]]; then
  echo "Set STUDENT_EMAIL and STUDENT_PASSWORD"
  exit 1
fi

TOKEN="$(curl -sS "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"$STUDENT_PASSWORD\"}" \
  | python3 -c "import sys,json; j=json.loads(sys.stdin.read()); print(j.get('token') or j.get('accessToken') or j.get('access_token') or j.get('jwt') or '')")"

if [[ -z "$TOKEN" ]]; then
  echo "Login failed (no token)"
  exit 1
fi

echo "== week"
curl -sS "$BASE/schedule/week" -H "Authorization: Bearer $TOKEN" | jq '.ok, (.days|length)'
echo

echo "== week first day"
curl -sS "$BASE/schedule/week" -H "Authorization: Bearer $TOKEN" | jq '.days[0]'
echo

echo "== today"
curl -sS "$BASE/schedule/today" -H "Authorization: Bearer $TOKEN" | jq
echo

echo "✅ student smoke ok"
