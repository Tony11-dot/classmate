#!/usr/bin/env bash
set -euo pipefail

API="${API:-http://localhost:3002}"

login () {
  local email="$1" pass="$2"
  curl -s "$API/api/auth/login" -H 'content-type: application/json' \
    -d "{\"schoolId\":\"demo\",\"email\":\"$email\",\"password\":\"$pass\"}" | jq -r .token
}

ADMIN_TOKEN="$(login admin@demo.com admin123)"
TEACHER_TOKEN="$(login teacher@demo.com teacher123)"
STUDENT_TOKEN="$(login student@demo.com student123)"

curl -s "$API/api/student/assessments" -H "Authorization: Bearer $STUDENT_TOKEN" | jq -e .assessments >/dev/null
curl -s "$API/api/student/term-average" -H "Authorization: Bearer $STUDENT_TOKEN" | jq -e .terms >/dev/null
curl -s "$API/api/student/gpa" -H "Authorization: Bearer $STUDENT_TOKEN" | jq -e .gpa >/dev/null

curl -s "$API/api/teacher/assessments" -H "Authorization: Bearer $TEACHER_TOKEN" | jq -e .assessments >/dev/null
curl -s "$API/api/teacher/class-analytics" -H "Authorization: Bearer $TEACHER_TOKEN" | jq -e .classes >/dev/null
curl -s "$API/api/teacher/term-analytics" -H "Authorization: Bearer $TEACHER_TOKEN" | jq -e .terms >/dev/null

curl -s "$API/api/admin/school-analytics" -H "Authorization: Bearer $ADMIN_TOKEN" | jq -e .classes >/dev/null

echo "analytics_smoke: OK"
