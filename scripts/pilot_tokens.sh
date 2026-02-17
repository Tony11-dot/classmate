#!/usr/bin/env bash
set -euo pipefail
BASE="${BASE:-http://127.0.0.1:3010}"

ADMIN_EMAIL="${ADMIN_EMAIL:-admin_nbs_1771100040@example.com}"
ADMIN_PASS="${ADMIN_PASS:-Test1234!}"
STUDENT_EMAIL="${STUDENT_EMAIL:-nbs_g10_elec3_1771101384@example.com}"
STUDENT_PASS="${STUDENT_PASS:-Test1234!}"

ADMIN_RESP=$(curl -sS -X POST "$BASE/api/auth/login" -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASS\"}")
export TOKEN=$(echo "$ADMIN_RESP" | jq -r '.token // empty')

STUDENT_RESP=$(curl -sS -X POST "$BASE/api/auth/login" -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"$STUDENT_PASS\"}")
export STUDENT_TOKEN=$(echo "$STUDENT_RESP" | jq -r '.token // empty')

echo "TOKEN_LEN=${#TOKEN}"
echo "STUDENT_TOKEN_LEN=${#STUDENT_TOKEN}"
