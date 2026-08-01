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
#   demo.student2 / DemoStudent2026!  STUDENT g10 (Demo Class 10-A) — chat testing
#   demo.parent   / DemoParent2026!   PARENT   (linked to demo.student)
#
# IDEMPOTENT-ish: safe to re-run. An already-existing school/user is reported
# and SKIPPED (no crash) rather than aborting. It won't re-link skipped users
# (usernames aren't returned by the list API), so for a fully clean rebuild,
# delete the school first (Manager console → Schools → delete) and re-run.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail   # NOT -e: we handle "already exists" ourselves instead of aborting
API="https://pacific-enchantment-production-7a80.up.railway.app"

read -r -p "Owner email [aboudtony22@gmail.com]: " OWNER_EMAIL
OWNER_EMAIL=${OWNER_EMAIL:-aboudtony22@gmail.com}
read -r -s -p "Owner (manager) password: " OWNER_PASS; echo

token() { python3 -c "import sys,json;print(json.load(sys.stdin).get('token',''))" 2>/dev/null; }
uid()   { python3 -c "import sys,json;print(json.load(sys.stdin).get('user',{}).get('id',''))" 2>/dev/null; }

# Fixed demo credentials (isolated TESTING school; change any in-app later).
ADMIN_U=demo.admin;            ADMIN_P='DemoAdmin2026!'
TEACH_U=demo.teacher;          TEACH_P='DemoTeacher2026!'
STU_U=demo.student;            STU_P='DemoStudent2026!'
STU2_U=demo.student2;          STU2_P='DemoStudent2026!'
PAR_U=demo.parent;             PAR_P='DemoParent2026!'
APPLE_U=apple-review-student;  APPLE_P='AppleReview2026!'

echo "→ health"; curl -sf "$API/health" >/dev/null && echo "  ok"

echo "→ owner login"
OWNER_TOKEN=$(curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"$OWNER_EMAIL\",\"password\":\"$OWNER_PASS\"}" | token)
if [ -z "$OWNER_TOKEN" ]; then
  echo "✗ Owner login failed (bad password, or 5-attempts/15-min lockout). Reset it and retry."; exit 1
fi
echo "  ok"

echo "→ create demo school + admin (skipped if it already exists)"
curl -s -X POST "$API/manager/schools" -H "Authorization: Bearer $OWNER_TOKEN" -H 'Content-Type: application/json' \
  -d "{\"schoolName\":\"ClassMate Demo School\",\"minGrade\":7,\"maxGrade\":12,\"adminName\":\"Demo Admin\",\"adminUsername\":\"$ADMIN_U\",\"adminPassword\":\"$ADMIN_P\"}" \
  | head -c 160 | grep -q '"id"' && echo "  created" || echo "  (already exists — continuing as $ADMIN_U)"

echo "→ admin login"
ADMIN_TOKEN=$(curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"$ADMIN_U\",\"password\":\"$ADMIN_P\"}" | token)
if [ -z "$ADMIN_TOKEN" ]; then
  echo "✗ Admin login failed. If the school pre-exists with a different admin password, delete it and re-run."; exit 1
fi
AUTH=(-H "Authorization: Bearer $ADMIN_TOKEN" -H 'Content-Type: application/json')
echo "  ok"

echo "→ cohort Demo Class 10-A"
COHORT_ID=$(curl -s -X POST "$API/admin/cohorts" "${AUTH[@]}" -d '{"name":"Demo Class 10-A","grade":10}' \
  | python3 -c "import sys,json;print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
echo "  ${COHORT_ID:-(exists or failed — cohort steps may be skipped)}"

# Create a user; on success echo its id, on 409/any-error echo "" and warn.
mkuser() { # role name username password extra-json
  local resp id
  resp=$(curl -s -X POST "$API/admin/users" "${AUTH[@]}" \
    -d "{\"role\":\"$1\",\"name\":\"$2\",\"username\":\"$3\",\"password\":\"$4\"$5}")
  id=$(echo "$resp" | uid)
  if [ -n "$id" ]; then echo "$id";
  else echo ""; echo "    ⚠ '$3' skipped: $(echo "$resp" | head -c 100)" >&2; fi
}

echo "→ users (existing ones are skipped)"
APPLE_ID=$(mkuser STUDENT "Apple Review"    "$APPLE_U" "$APPLE_P" ",\"grade\":10"); echo "  apple    ${APPLE_ID:+ok}"
TEACH_ID=$(mkuser TEACHER "Demo Teacher"    "$TEACH_U" "$TEACH_P" "");             echo "  teacher  ${TEACH_ID:+ok}"
STU_ID=$(mkuser   STUDENT "Demo Student"    "$STU_U"   "$STU_P"   ",\"grade\":10"); echo "  student  ${STU_ID:+ok}"
STU2_ID=$(mkuser  STUDENT "Demo Student Two" "$STU2_U" "$STU2_P"  ",\"grade\":10"); echo "  student2 ${STU2_ID:+ok}"
PAR_ID=$(mkuser   PARENT  "Demo Parent"     "$PAR_U"   "$PAR_P"   "");             echo "  parent   ${PAR_ID:+ok}"

# Only wire up members/links that were freshly created this run.
if [ -n "$COHORT_ID" ]; then
  IDS=$(printf '%s\n' "$APPLE_ID" "$STU_ID" "$STU2_ID" | grep -v '^$' | paste -sd, -)
  if [ -n "$IDS" ]; then
    JSON=$(printf '%s' "$IDS" | python3 -c "import sys;print('[\"'+'\",\"'.join(sys.stdin.read().split(','))+'\"]')")
    curl -s -X POST "$API/admin/cohorts/$COHORT_ID/students" "${AUTH[@]}" -d "{\"studentIds\":$JSON}" -o /dev/null -w "  cohort add: HTTP %{http_code}\n"
  fi
fi
if [ -n "$PAR_ID" ] && [ -n "$STU_ID" ]; then
  curl -s -X POST "$API/admin/parent-links" "${AUTH[@]}" -d "{\"parentId\":\"$PAR_ID\",\"studentId\":\"$STU_ID\"}" -o /dev/null -w "  parent link: HTTP %{http_code}\n"
fi

echo "→ verify Apple reviewer login"
APPLE_TOKEN=$(curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"$APPLE_U\",\"password\":\"$APPLE_P\"}" | token)
[ -n "$APPLE_TOKEN" ] && echo "  ok — Apple can sign in ✅" || echo "  ✗ apple-review-student can't log in with the expected password"

echo
echo "════════════════════════════════════════════════════════════════════"
echo "ACCOUNTS (School: ClassMate Demo School)"
echo "════════════════════════════════════════════════════════════════════"
printf "  %-22s %-20s %s\n" "APPLE REVIEW"  "$APPLE_U"  "$APPLE_P"
printf "  %-22s %-20s %s\n" "ADMIN"         "$ADMIN_U"  "$ADMIN_P"
printf "  %-22s %-20s %s\n" "TEACHER"       "$TEACH_U"  "$TEACH_P"
printf "  %-22s %-20s %s\n" "STUDENT"       "$STU_U"    "$STU_P"
printf "  %-22s %-20s %s\n" "STUDENT 2"     "$STU2_U"   "$STU2_P"
printf "  %-22s %-20s %s\n" "PARENT"        "$PAR_U"    "$PAR_P"
echo "════════════════════════════════════════════════════════════════════"
