#!/usr/bin/env sh
set -eu

BASE="${BASE:-http://localhost:3000}"
DB="${DB:-docker compose exec -T db psql -U classmate -d classmate}"

./scripts/wait-api.sh "$BASE/api/health"

token() {
  email="$1"
  pass="$2"
  curl -fsS -X POST "$BASE/api/auth/login" \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"$email\",\"password\":\"$pass\"}" \
    | node -p 'JSON.parse(fs.readFileSync(0,"utf8")).token'
}

TOKEN_DEV="$(token admin@classmate.dev Admin123!)"
TOKEN_LOCAL="$(token admin@classmate.local Admin123!)"

PARENT_DEV_ID="$($DB -Atc "SELECT id FROM \"User\" WHERE email='admin@classmate.dev' LIMIT 1;" | tr -d '[:space:]')"
STUDENT_ID="$($DB -Atc "SELECT \"userId\" FROM \"UserRole\" WHERE role='STUDENT' LIMIT 1;" | tr -d '[:space:]')"

NEW_ID="$($DB -Atqtc "INSERT INTO \"ParentNotification\" (id, \"parentId\", \"studentId\", type, title, message, data)
 VALUES (gen_random_uuid(), '$PARENT_DEV_ID', '$STUDENT_ID', 'TEST', 'smoke-owner', 'x', '{}'::jsonb)
 RETURNING id;" | tr -d '[:space:]')"

echo "NEW_ID=$NEW_ID"
$DB -c "SELECT id, \"parentId\", \"seenAt\" FROM \"ParentNotification\" WHERE id='$NEW_ID';" >/dev/null

echo "== list (dev) =="
curl -fsS "$BASE/api/parent/notifications?limit=5&unseenOnly=true" \
  -H "Authorization: Bearer $TOKEN_DEV" \
  | node -p 'JSON.stringify(JSON.parse(fs.readFileSync(0,"utf8")), null, 2)'

echo "== wrong owner mark (local) should be updated:0 =="
curl -fsS -X PATCH "$BASE/api/parent/notifications/mark-seen" \
  -H "Authorization: Bearer $TOKEN_LOCAL" \
  -H "Content-Type: application/json" \
  --data-binary "{\"ids\":[\"$NEW_ID\"]}" \
  | node -p 'JSON.stringify(JSON.parse(fs.readFileSync(0,"utf8")), null, 2)'

$DB -c "SELECT id, \"parentId\", \"seenAt\" FROM \"ParentNotification\" WHERE id='$NEW_ID';"

echo "== correct owner mark (dev) should be updated:1 =="
curl -fsS -X PATCH "$BASE/api/parent/notifications/mark-seen" \
  -H "Authorization: Bearer $TOKEN_DEV" \
  -H "Content-Type: application/json" \
  --data-binary "{\"ids\":[\"$NEW_ID\"]}" \
  | node -p 'JSON.stringify(JSON.parse(fs.readFileSync(0,"utf8")), null, 2)'

$DB -c "SELECT id, \"parentId\", \"seenAt\" FROM \"ParentNotification\" WHERE id='$NEW_ID';"

echo "== unread-count (dev) =="
curl -fsS "$BASE/api/parent/notifications/unread-count" \
  -H "Authorization: Bearer $TOKEN_DEV" \
  | node -p 'JSON.stringify(JSON.parse(fs.readFileSync(0,"utf8")), null, 2)'

echo "OK"
