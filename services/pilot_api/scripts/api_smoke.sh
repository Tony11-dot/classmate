#!/usr/bin/env bash
set -euo pipefail

echo "== API smoke =="

BASE="http://localhost:3000"
ADMIN_TOKEN="$(services/pilot_api/scripts/get_admin_token.sh)"

# 1) health
curl -sS "$BASE/api/health" | jq -e '.ok==true and .db=="ok"' >/dev/null
echo "✅ health ok"

# 2) me
curl -sS "$BASE/api/me" -H "Authorization: Bearer $ADMIN_TOKEN" \
  | jq -e '.user.id!=null and (.roles|type=="array")' >/dev/null
echo "✅ me ok"

# 3) classrooms list -> array
curl -sS "$BASE/api/classrooms" -H "Authorization: Bearer $ADMIN_TOKEN" \
  | jq -e 'type=="array"' >/dev/null
echo "✅ classrooms array"

# 4) notifications list -> array
curl -sS "$BASE/api/notifications" -H "Authorization: Bearer $ADMIN_TOKEN" \
  | jq -e 'type=="array"' >/dev/null
echo "✅ notifications array"

# 5) assignments without classroomId -> 400 + json
code="$(curl -sS -o /tmp/assignments_400.json -w "%{http_code}" \
  "$BASE/api/assignments" -H "Authorization: Bearer $ADMIN_TOKEN")"
[ "$code" = "400" ] || (echo "❌ assignments expected 400 got $code"; cat /tmp/assignments_400.json; exit 1)
jq -e '.error=="classroomId_required"' /tmp/assignments_400.json >/dev/null
echo "✅ assignments missing classroomId -> 400 json"

# 6) unknown route -> 404 json
code="$(curl -sS -o /tmp/notfound.json -w "%{http_code}" "$BASE/api/definitely-not-real")"
[ "$code" = "404" ] || (echo "❌ expected 404 got $code"; cat /tmp/notfound.json; exit 1)
jq -e '.error=="not_found"' /tmp/notfound.json >/dev/null
echo "✅ unknown route -> 404 json"

echo "🎉 API smoke passed"
