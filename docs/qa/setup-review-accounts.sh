#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# ClassMate — create the DEMO school + Apple-review + tester accounts on PROD.
# One command; asks for the owner (manager) password at a HIDDEN prompt so it
# never lands in your shell history or any chat transcript.
#
#   bash docs/qa/setup-review-accounts.sh
#
# Creates (all passwords FIXED + known, all changeable in-app afterwards):
#   School  "ClassMate Demo School" (grades 7–12)
#   apple-review-student / AppleReview2026!  STUDENT g10  ← Apple App Review
#   demo.admin    / DemoAdmin2026!    ADMIN    (can make more users in-app)
#   demo.teacher  / DemoTeacher2026!  TEACHER  (Demo Class 10-A)
#   demo.student  / DemoStudent2026!  STUDENT g10 (Demo Class 10-A)
#   demo.parent   / DemoParent2026!   PARENT   (linked to demo.student)
#
# Re-runnable only after deleting the school (usernames are globally unique):
#   Manager console → Schools → delete "ClassMate Demo School".
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
API="https://pacific-enchantment-production-7a80.up.railway.app"

read -r -p "Owner email [aboudtony22@gmail.com]: " OWNER_EMAIL
OWNER_EMAIL=${OWNER_EMAIL:-aboudtony22@gmail.com}
read -r -s -p "Owner (manager) password: " OWNER_PASS; echo

token() { python3 -c "import sys,json;print(json.load(sys.stdin)['token'])"; }
jget()  { python3 -c "import sys,json;d=json.load(sys.stdin);print(d$1)"; }

# Fixed demo credentials (isolated TESTING school; change any in-app later).
ADMIN_U=demo.admin;            ADMIN_P='DemoAdmin2026!'
TEACH_U=demo.teacher;          TEACH_P='DemoTeacher2026!'
STU_U=demo.student;            STU_P='DemoStudent2026!'
PAR_U=demo.parent;             PAR_P='DemoParent2026!'
APPLE_U=apple-review-student;  APPLE_P='AppleReview2026!'

echo "→ health"; curl -sf "$API/health" >/dev/null && echo "  ok"

echo "→ owner login"
LOGIN_RESP=$(curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"$OWNER_EMAIL\",\"password\":\"$OWNER_PASS\"}")
OWNER_TOKEN=$(echo "$LOGIN_RESP" | token 2>/dev/null || true)
if [ -z "${OWNER_TOKEN:-}" ]; then
  echo "✗ Owner login failed. Response:"; echo "$LOGIN_RESP" | head -c 400; echo
  echo "  (/auth/login allows 5 attempts per 15 min per IP — reset the owner password if needed.)"; exit 1
fi
echo "  ok"

echo "→ create demo school + admin"
SCHOOL=$(curl -sf -X POST "$API/manager/schools" -H "Authorization: Bearer $OWNER_TOKEN" -H 'Content-Type: application/json' \
  -d "{\"schoolName\":\"ClassMate Demo School\",\"minGrade\":7,\"maxGrade\":12,\"adminName\":\"Demo Admin\",\"adminUsername\":\"$ADMIN_U\",\"adminPassword\":\"$ADMIN_P\"}")
echo "  ok: $(echo "$SCHOOL" | head -c 160)"

echo "→ admin login"
ADMIN_TOKEN=$(curl -sf -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"$ADMIN_U\",\"password\":\"$ADMIN_P\"}" | token)
AUTH=(-H "Authorization: Bearer $ADMIN_TOKEN" -H 'Content-Type: application/json')
echo "  ok"

echo "→ cohort Demo Class 10-A"
COHORT_ID=$(curl -sf -X POST "$API/admin/cohorts" "${AUTH[@]}" -d '{"name":"Demo Class 10-A","grade":10}' | jget "['id']")
echo "  ok ($COHORT_ID)"

mkuser() { curl -sf -X POST "$API/admin/users" "${AUTH[@]}" \
  -d "{\"role\":\"$1\",\"name\":\"$2\",\"username\":\"$3\",\"password\":\"$4\"$5}" | jget "['user']['id']"; }

echo "→ users"
APPLE_ID=$(mkuser STUDENT "Apple Review"  "$APPLE_U" "$APPLE_P" ",\"grade\":10"); echo "  apple    ok"
TEACH_ID=$(mkuser TEACHER "Demo Teacher"  "$TEACH_U" "$TEACH_P" "");             echo "  teacher  ok"
STU_ID=$(mkuser STUDENT   "Demo Student"  "$STU_U"   "$STU_P"   ",\"grade\":10"); echo "  student  ok"
PAR_ID=$(mkuser PARENT    "Demo Parent"   "$PAR_U"   "$PAR_P"   "");             echo "  parent   ok"

echo "→ cohort membership + parent link"
curl -sf -X POST "$API/admin/cohorts/$COHORT_ID/students" "${AUTH[@]}" -d "{\"studentIds\":[\"$APPLE_ID\",\"$STU_ID\"]}" >/dev/null
curl -sf -X POST "$API/admin/parent-links" "${AUTH[@]}" -d "{\"parentId\":\"$PAR_ID\",\"studentId\":\"$STU_ID\"}" >/dev/null
echo "  ok"

echo "→ verify Apple reviewer login"
APPLE_TOKEN=$(curl -sf -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"$APPLE_U\",\"password\":\"$APPLE_P\"}" | token)
curl -sf "$API/auth/me" -H "Authorization: Bearer $APPLE_TOKEN" >/dev/null && echo "  ok — Apple can sign in ✅"

echo
echo "════════════════════════════════════════════════════════════════════"
echo "ALL ACCOUNTS CREATED — School: ClassMate Demo School"
echo "════════════════════════════════════════════════════════════════════"
printf "  %-22s %-20s %s\n" "APPLE REVIEW"  "$APPLE_U"  "$APPLE_P"
printf "  %-22s %-20s %s\n" "ADMIN"         "$ADMIN_U"  "$ADMIN_P"
printf "  %-22s %-20s %s\n" "TEACHER"       "$TEACH_U"  "$TEACH_P"
printf "  %-22s %-20s %s\n" "STUDENT"       "$STU_U"    "$STU_P"
printf "  %-22s %-20s %s\n" "PARENT"        "$PAR_U"    "$PAR_P"
echo "════════════════════════════════════════════════════════════════════"
