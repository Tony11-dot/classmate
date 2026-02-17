#!/usr/bin/env bash
set -euo pipefail

echo "== Auth smoke =="

BASE="http://localhost:3000"
ADMIN_TOKEN="$(services/pilot_api/scripts/get_admin_token.sh)"

# 1) invalid token smoke (tampered token)
BAD_TOKEN="${ADMIN_TOKEN}x"

code="$(curl -sS -o /tmp/bad_token.json -w "%{http_code}" \
  "$BASE/api/me" -H "Authorization: Bearer $BAD_TOKEN")"

if [ "$code" != "401" ] && [ "$code" != "403" ]; then
  echo "❌ expected 401/403 for bad token, got $code"
  cat /tmp/bad_token.json || true
  exit 1
fi
jq -e '.error' /tmp/bad_token.json >/dev/null
echo "✅ invalid token returns json error ($code)"

# 2) role downgrade test:
# - read my id
ME_ID="$(curl -sS "$BASE/api/me" -H "Authorization: Bearer $ADMIN_TOKEN" | jq -r '.user.id')"
[ -n "$ME_ID" ] || (echo "❌ could not read user id"; exit 1)

# - ensure admin ping works now (should be 200)
code="$(curl -sS -o /tmp/admin_ping.json -w "%{http_code}" \
  "$BASE/api/admin/ping" -H "Authorization: Bearer $ADMIN_TOKEN")"
[ "$code" = "200" ] || (echo "❌ expected admin ping 200 got $code"; cat /tmp/admin_ping.json; exit 1)
echo "✅ admin ping ok (pre-downgrade)"

# - downgrade to student only
curl -sS -X PUT "$BASE/api/admin/users/$ME_ID/roles" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"roles":["student"]}' \
  | jq -e '.ok==true or (.roles|length>0)' >/dev/null
echo "✅ downgraded roles to student"

# - now admin ping should be forbidden (403)
code="$(curl -sS -o /tmp/admin_ping2.json -w "%{http_code}" \
  "$BASE/api/admin/ping" -H "Authorization: Bearer $ADMIN_TOKEN")"
[ "$code" = "403" ] || (echo "❌ expected admin ping 403 after downgrade got $code"; cat /tmp/admin_ping2.json; exit 1)
jq -e '.error' /tmp/admin_ping2.json >/dev/null
echo "✅ admin ping blocked after downgrade"

# - restore roles (admin + teacher)
curl -sS -X PUT "$BASE/api/admin/users/$ME_ID/roles" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"roles":["admin","teacher"]}' \
  | jq -e '.ok==true or (.roles|length>0)' >/dev/null
echo "✅ restored roles"

# 3) rate-limit smoke (probe)
# We don't assume a 429 exists; we just verify headers exist and don't crash.
rm -f /tmp/rl_headers.txt
for i in $(seq 1 20); do
  curl -sS -D - -o /dev/null "$BASE/api/health" >> /tmp/rl_headers.txt
done
grep -qi '^X-RateLimit-' /tmp/rl_headers.txt && echo "✅ rate-limit headers present" || echo "ℹ️ no rate-limit headers detected (ok if not configured)"

echo "🎉 Auth smoke passed"
