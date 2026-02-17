#!/usr/bin/env bash
set -euo pipefail

LAN_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1)

ADMIN_EMAIL="admin_nbs_1771100040@example.com"
ADMIN_PASS="Test1234!"
STUDENT_EMAIL="nbs_g10_elec3_1771101384@example.com"
STUDENT_PASS="Test1234!"
CLASSROOM_ID="cmlmr8htm000moo01lgtt7b8r"

echo "LAN_IP=$LAN_IP"

ADMIN_RESP=$(curl -sS -X POST "http://$LAN_IP:3010/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASS\"}")

ADMIN_TOKEN=$(echo "$ADMIN_RESP" | jq -r '.token')
echo "ADMIN_TOKEN_LEN=${#ADMIN_TOKEN}"

STUDENT_RESP=$(curl -sS -X POST "http://$LAN_IP:3010/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"$STUDENT_PASS\"}")

STUDENT_TOKEN=$(echo "$STUDENT_RESP" | jq -r '.token')
STUDENT_ID=$(echo "$STUDENT_RESP" | jq -r '.user.id')
echo "STUDENT_TOKEN_LEN=${#STUDENT_TOKEN}"
echo "STUDENT_ID=$STUDENT_ID"

# ensure membership
docker exec classmate-db-1 sh -lc "psql -U classmate -d classmate -c \"
insert into \\\"ClassroomMember\\\" (id, \\\"classroomId\\\", \\\"userId\\\", role, \\\"createdAt\\\")
values (concat('cm_', substr(md5(random()::text),1,12)), '$CLASSROOM_ID', '$STUDENT_ID', 'student', now())
on conflict (\\\"classroomId\\\",\\\"userId\\\") do update set role='student';
\""

# create assignment
A_RESP=$(curl -sS -X POST "http://$LAN_IP:3010/api/assignments" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"classroomId\":\"$CLASSROOM_ID\",\"title\":\"Smoke HW\",\"details\":\"smoke\",\"dueAt\":\"2026-02-20T18:00:00.000Z\"}")

A_ID=$(echo "$A_RESP" | jq -r '.id')
echo "ASSIGNMENT_ID=$A_ID"

# student submit
S_RESP=$(curl -sS -X POST "http://$LAN_IP:3010/api/assignments/$A_ID/submissions" \
  -H "Authorization: Bearer $STUDENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"text\":\"smoke submit\"}")

SUB_ID=$(echo "$S_RESP" | jq -r '.id')
echo "SUBMISSION_ID=$SUB_ID"

# teacher view
curl -sS -H "Authorization: Bearer $ADMIN_TOKEN" \
  "http://$LAN_IP:3010/api/assignments/$A_ID/submissions" | jq .
echo "✅ SMOKE PASSED"
