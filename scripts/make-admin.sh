#!/usr/bin/env bash
set -euo pipefail
ORIGIN="${ORIGIN:-http://localhost:3001}"

EMAIL="${EMAIL:-admin1+$(date +%s)@classmate.local}"
PASS="${PASS:-Passw0rd!123}"
NAME="${NAME:-Admin One}"

BODY="$(EMAIL="$EMAIL" PASS="$PASS" NAME="$NAME" python3 - <<'PY'
import os, json
print(json.dumps({
  "email": os.environ["EMAIL"],
  "password": os.environ["PASS"],
  "name": os.environ["NAME"],
}))
PY
)"

curl -fsS http://localhost:3000/api/auth/register \
  -H "Origin: $ORIGIN" \
  -H "Content-Type: application/json" \
  -d "$BODY" >/dev/null

TOKEN="$(curl -fsS http://localhost:3000/api/auth/login \
  -H "Origin: $ORIGIN" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" \
| python3 -c 'import sys,json; print(json.load(sys.stdin)["token"])')"

docker compose exec -T db psql -U classmate -d classmate -v ON_ERROR_STOP=1 -c \
"INSERT INTO \"UserRole\" (id, \"userId\", role)
 SELECT md5(random()::text || clock_timestamp()::text), u.id, 'ADMIN'::\"Role\"
 FROM \"User\" u
 WHERE u.email = '$EMAIL'
 ON CONFLICT (\"userId\", role) DO NOTHING;"

echo "EMAIL=$EMAIL"
echo "PASS=$PASS"
echo "TOKEN=$TOKEN"
echo
curl -fsS http://localhost:3000/api/auth/me \
  -H "Origin: $ORIGIN" \
  -H "Authorization: Bearer $TOKEN" ; echo
