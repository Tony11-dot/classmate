#!/usr/bin/env bash
set -euo pipefail

API="${API:-http://localhost:3002}"

login () {
  local email="$1" pw="$2"
  curl -fsS "$API/api/auth/login" -H 'content-type: application/json' \
    -d "{\"schoolId\":\"demo\",\"email\":\"$email\",\"password\":\"$pw\"}" | jq -r .token
}

curl -fsS "$API/api/health" | jq

ADMIN_TOKEN="$(login admin@demo.com admin123)"
TEACHER_TOKEN="$(login teacher@demo.com teacher123)"
PARENT_TOKEN="$(login parent@demo.com parent123)"

echo "ADMIN_TOKEN=${#ADMIN_TOKEN} TEACHER_TOKEN=${#TEACHER_TOKEN} PARENT_TOKEN=${#PARENT_TOKEN}"

curl -fsS "$API/api/admin/users"   -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.users|length'
curl -fsS "$API/api/admin/classes" -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.classes|length'

curl -fsS "$API/api/teacher/classes" -H "Authorization: Bearer $TEACHER_TOKEN" | jq
CID="$(curl -fsS "$API/api/teacher/classes" -H "Authorization: Bearer $TEACHER_TOKEN" | jq -r '.classes[0].id')"
curl -fsS "$API/api/teacher/classes/$CID/roster" -H "Authorization: Bearer $TEACHER_TOKEN" | jq

curl -fsS "$API/api/parent/children" -H "Authorization: Bearer $PARENT_TOKEN" | jq
