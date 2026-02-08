#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE:-http://localhost:3000}"

echo "🔎 Health..."
curl -fsS "$BASE/api/health" | cat
echo

EMAIL="smoke+$(date +%s)@classmate.app"
PASS="Passw0rd!"
NAME="Smoke Test"

echo "🧪 Register: $EMAIL"
REG_JSON="$(curl -fsS -X POST "$BASE/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\",\"name\":\"$NAME\"}")"

echo "$REG_JSON" | cat
echo

TOKEN="$(node -e 'process.stdout.write(JSON.parse(process.env.REG_JSON).token)' REG_JSON="$REG_JSON")"

echo "🔐 /me"
curl -fsS "$BASE/api/auth/me" \
  -H "Authorization: Bearer $TOKEN" | cat
echo

echo "✅ Smoke passed."
