#!/usr/bin/env sh
set -eu

BASE="${BASE:-http://localhost:3000}"
DB="${DB:-docker compose exec -T db psql -U classmate -d classmate}"

./scripts/wait-api.sh "$BASE/api/health"

token() {
  email="$1"
  pass="$2"
  t="$(
    curl -fsS --connect-timeout 2 --max-time 10 --retry 5 --retry-delay 1 --retry-all-errors -X POST "$BASE/api/auth/login" \
      -H 'Content-Type: application/json' \
      -d "{\"email\":\"$email\",\"password\":\"$pass\"}" \
    | jq -r '.token // empty'
  )"
  [ -n "$t" ] || { echo "login failed for $email" >&2; exit 1; }
  printf "%s" "$t"
}

TOKEN_DEV="$(token admin@classmate.dev Admin123!)"

# --- baseline unread (before inserting NEW_ID) ---
BASE_UNREAD="$(curl -fsS --connect-timeout 2 --max-time 10 \
  "$BASE/api/parent/notifications/unread-count" \
  -H "Authorization: Bearer $TOKEN_DEV" \
  | jq -r '.unread // 0')"
echo "baseline_unread=$BASE_UNREAD"

ensure_local_parent() {
  # create admin@classmate.local with password Admin123! and PARENT role (idempotent)
  docker compose exec -T api node - <<'NODE'
const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcrypt");
(async () => {
  const prisma = new PrismaClient();
  const email = "admin@classmate.local";
  const hash = await bcrypt.hash("Admin123!", 10);

  const u = await prisma.user.upsert({
    where: { email },
    update: { password: hash, name: "Admin Local" },
    create: { email, password: hash, name: "Admin Local" },
    select: { id: true, email: true },
  });

  // ensure PARENT role
  await prisma.userRole.upsert({
    where: { userId_role: { userId: u.id, role: "PARENT" } },
    update: {},
    create: { id: crypto.randomUUID(), userId: u.id, role: "PARENT" },
  });

  console.log("ensured local parent:", u.email);
  await prisma.$disconnect();
})().catch((e) => { console.error(e); process.exit(1); });
NODE
}

ensure_local_parent
TOKEN_LOCAL="$(token admin@classmate.local Admin123!)"


PARENT_DEV_ID="$($DB -Atc "SELECT id FROM \"User\" WHERE email='admin@classmate.dev' LIMIT 1;" | tr -d '[:space:]')"
[ -n "$PARENT_DEV_ID" ] || { echo "missing dev parent user" >&2; exit 1; }

STUDENT_ID="$($DB -Atc "SELECT \"userId\" FROM \"UserRole\" WHERE role='STUDENT' LIMIT 1;" | tr -d '[:space:]')"
if [ -z "$STUDENT_ID" ]; then
  echo "missing STUDENT user (role=STUDENT) in DB — creating dummy student..." >&2
  STUDENT_ID="$($DB -Atqtc "WITH u AS (
    INSERT INTO \"User\" (id, email, password, name)
    VALUES (gen_random_uuid(), 'student+smoke@classmate.dev', 'x', 'Smoke Student')
    RETURNING id
  )
  INSERT INTO \"UserRole\" (id, \"userId\", role)
  SELECT gen_random_uuid(), id, 'STUDENT' FROM u
  RETURNING \"userId\";" | tr -d '[:space:]')"
fi
[ -n "$STUDENT_ID" ] || { echo "failed to create STUDENT user" >&2; exit 1; }

# keep smoke idempotent + keep unread stable: close old unseen (except fixed smoke id)
$DB -Atqtc "UPDATE \"ParentNotification\"
SET \"seenAt\" = now()
WHERE \"parentId\" = '$PARENT_DEV_ID'
  AND \"seenAt\" IS NULL
  AND id <> '00000000-0000-4000-8000-000000000001';" >/dev/null

NEW_ID="${NEW_ID:-$(uuidgen | tr "[:upper:]" "[:lower:]")}"
$DB -Atqtc "INSERT INTO \"ParentNotification\" (id, \"parentId\", \"studentId\", type, title, message, data, \"seenAt\")
VALUES ('$NEW_ID', '$PARENT_DEV_ID', '$STUDENT_ID', 'TEST', 'smoke-owner', 'x', '{}'::jsonb, null)
ON CONFLICT (id) DO UPDATE
SET \"parentId\"=EXCLUDED.\"parentId\",
    \"studentId\"=EXCLUDED.\"studentId\",
    type=EXCLUDED.type,
    title=EXCLUDED.title,
    message=EXCLUDED.message,
    data=EXCLUDED.data,
    \"createdAt\"=now(),
    \"seenAt\"=null;" >/dev/null


echo "NEW_ID=$NEW_ID"
$DB -c "SELECT id, \"parentId\", \"seenAt\" FROM \"ParentNotification\" WHERE id='$NEW_ID';" >/dev/null

echo "== list (dev) =="
curl -fsS --connect-timeout 2 --max-time 10 --retry 5 --retry-delay 1 --retry-all-errors "$BASE/api/parent/notifications?limit=5&unseenOnly=true" \
  -H "Authorization: Bearer $TOKEN_DEV" \
  | jq .

if [ "$SMOKE_MARK_SEEN" = "1" ]; then
  echo "== wrong owner mark (local) should be updated:0 =="
  curl -fsS --connect-timeout 2 --max-time 10 --retry 5 --retry-delay 1 --retry-all-errors -X PATCH "$BASE/api/parent/notifications/mark-seen" \
    -H "Authorization: Bearer $TOKEN_LOCAL" \
    -H "Content-Type: application/json" \
    --data-binary "{\"ids\":[\"$NEW_ID\"]}" \
    | jq .

  $DB -c "SELECT id, \"parentId\", \"seenAt\" FROM \"ParentNotification\" WHERE id='$NEW_ID';"

  echo "== correct owner mark (dev) should be updated:1 =="
  curl -fsS --connect-timeout 2 --max-time 10 --retry 5 --retry-delay 1 --retry-all-errors -X PATCH "$BASE/api/parent/notifications/mark-seen" \
    -H "Authorization: Bearer $TOKEN_DEV" \
    -H "Content-Type: application/json" \
    --data-binary "{\"ids\":[\"$NEW_ID\"]}" \
    | jq .

  $DB -c "SELECT id, \"parentId\", \"seenAt\" FROM \"ParentNotification\" WHERE id='$NEW_ID';"
fi

echo "== unread-count (dev) =="
unread="$(curl -fsS --connect-timeout 2 --max-time 10 \
  "$BASE/api/parent/notifications/unread-count" \
  -H "Authorization: Bearer $TOKEN_DEV" \
  | jq -r '.unread // 0')"

# --- delta-based unread assertion ---
EXPECTED_UNREAD="$BASE_UNREAD"
if [ "${SMOKE_MARK_SEEN:-1}" = "0" ]; then
  EXPECTED_UNREAD="$((BASE_UNREAD + 1))"
fi

echo "unread=$unread"
if [ "$unread" != "$EXPECTED_UNREAD" ]; then
  echo "❌ expected unread=$EXPECTED_UNREAD (baseline=$BASE_UNREAD) after SMOKE_MARK_SEEN=${SMOKE_MARK_SEEN:-1}" >&2
  exit 1
fi

echo "OK"
