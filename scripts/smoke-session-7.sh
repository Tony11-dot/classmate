#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/Dev/classmate"
API="${REPO}/services/api"
BASE="http://127.0.0.1:3001"
LOG="/tmp/classmate-api.dev.log"

token_from_login () {
  local email="$1"
  local pass="$2"
  curl -sS -X POST "$BASE/api/auth/login" \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"${email}\",\"password\":\"${pass}\"}" \
  | python3 -c 'import json,sys; j=json.load(sys.stdin); print(j.get("token",""))'
}

curl -sS -X POST "$BASE/api/test/seed/admin-web" >/dev/null

STOKEN="$(token_from_login "student1@classmate.app" "dev")"
PTOKEN="$(token_from_login "parent1@classmate.app"  "dev")"
echo "TOKENS: S=${#STOKEN} P=${#PTOKEN}"

echo
echo "== student.attendance =="
curl -sS "$BASE/api/student/attendance" -H "Authorization: Bearer $STOKEN" | python3 -m json.tool

echo
echo "== student.grades =="
curl -sS "$BASE/api/student/grades" -H "Authorization: Bearer $STOKEN" | python3 -m json.tool

CHILD_ID="$(
  curl -sS "$BASE/api/parent/children" -H "Authorization: Bearer $PTOKEN" \
  | python3 -c 'import json,sys; j=json.load(sys.stdin); items=(j.get("items") or j.get("children") or []) if isinstance(j,dict) else (j if isinstance(j,list) else []); first=(items[0] if items else {}); print((first.get("studentId") or first.get("id") or "") if isinstance(first,dict) else "")'
)"
echo
echo "CHILD_ID=$CHILD_ID"

echo
echo "== parent.attendance.week =="
curl -sS "$BASE/api/parent/attendance/week?studentId=$CHILD_ID" -H "Authorization: Bearer $PTOKEN" | python3 -m json.tool

echo
echo "== parent.grades =="
curl -sS "$BASE/api/parent/grades" -H "Authorization: Bearer $PTOKEN" | python3 -m json.tool

echo
echo "== tail log (last 60) =="
tail -n 60 "$LOG" || true
