#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# ClassMate — one-command QA environment setup (run from anywhere):
#   bash docs/qa/setup-qa-school.sh
#
# Creates on PRODUCTION:
#   • School  "ClassMate QA School (TESTING ONLY)"  (grades 7–12)
#   • Admin   qa.admin.cm        ← handed to testers (they create more users in-app)
#   • Teacher qa.teacher.cm
#   • Student qa.student1.cm + qa.student2.cm  (grade 10, both in "QA Class 10-A")
#   • Parent  qa.parent.cm       (linked to student1)
# then verifies logins and writes the credential sheet to
#   docs/qa/QA-CREDENTIALS.txt   (gitignored — paste it to testers yourself)
#
# Safe to re-run only after deleting the QA school (usernames are globally
# unique). To tear down: Manager console → Schools → delete the QA school.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
API="https://pacific-enchantment-production-7a80.up.railway.app"
DIR="$(cd "$(dirname "$0")" && pwd)"
CRED_FILE="$DIR/QA-CREDENTIALS.txt"

read -r -p "Owner email [aboudtony22@gmail.com]: " OWNER_EMAIL
OWNER_EMAIL=${OWNER_EMAIL:-aboudtony22@gmail.com}
read -r -s -p "Owner (manager) password: " OWNER_PASS; echo

token() { python3 -c "import sys,json;print(json.load(sys.stdin)['token'])"; }
jget()  { python3 -c "import sys,json;d=json.load(sys.stdin);print(d$1)"; }

echo "→ health"; curl -sf "$API/health" >/dev/null && echo "  ok"

echo "→ owner login"
LOGIN_RESP=$(curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"$OWNER_EMAIL\",\"password\":\"$OWNER_PASS\"}")
OWNER_TOKEN=$(echo "$LOGIN_RESP" | token 2>/dev/null || true)
if [ -z "${OWNER_TOKEN:-}" ]; then
  echo "✗ Owner login failed. Response was:"; echo "$LOGIN_RESP" | head -c 400; echo
  echo "  (Note: /auth/login allows 5 attempts per 15 min per IP.)"; exit 1
fi
echo "  ok"

# Random suffix so QA passwords aren't guessable even though usernames are fixed.
SUF="$(openssl rand -hex 2)"
ADMIN_PASS="QaAdmin!${SUF}9";  TEACH_PASS="QaTeach!${SUF}9"
STU1_PASS="QaStud1!${SUF}9";   STU2_PASS="QaStud2!${SUF}9";  PAR_PASS="QaParent!${SUF}9"

echo "→ create QA school + admin"
SCHOOL=$(curl -sf -X POST "$API/manager/schools" -H "Authorization: Bearer $OWNER_TOKEN" -H 'Content-Type: application/json' \
  -d "{\"schoolName\":\"ClassMate QA School (TESTING ONLY)\",\"minGrade\":7,\"maxGrade\":12,\"adminName\":\"QA Admin\",\"adminUsername\":\"qa.admin.cm\",\"adminPassword\":\"$ADMIN_PASS\"}")
echo "  ok: $(echo "$SCHOOL" | head -c 160)"

echo "→ admin login"
ADMIN_TOKEN=$(curl -sf -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"qa.admin.cm\",\"password\":\"$ADMIN_PASS\"}" | token)
AUTH=(-H "Authorization: Bearer $ADMIN_TOKEN" -H 'Content-Type: application/json')
echo "  ok"

echo "→ cohort QA Class 10-A"
COHORT_ID=$(curl -sf -X POST "$API/admin/cohorts" "${AUTH[@]}" -d '{"name":"QA Class 10-A","grade":10}' | jget "['id']")
echo "  ok ($COHORT_ID)"

mkuser() { curl -sf -X POST "$API/admin/users" "${AUTH[@]}" \
  -d "{\"role\":\"$1\",\"name\":\"$2\",\"username\":\"$3\",\"password\":\"$4\"$5}" | jget "['user']['id']"; }

echo "→ users"
TEACH_ID=$(mkuser TEACHER "QA Teacher"      qa.teacher.cm  "$TEACH_PASS" "");            echo "  teacher  ok"
STU1_ID=$(mkuser STUDENT  "QA Student One"  qa.student1.cm "$STU1_PASS" ",\"grade\":10"); echo "  student1 ok"
STU2_ID=$(mkuser STUDENT  "QA Student Two"  qa.student2.cm "$STU2_PASS" ",\"grade\":10"); echo "  student2 ok"
PAR_ID=$(mkuser PARENT    "QA Parent"       qa.parent.cm   "$PAR_PASS" "");              echo "  parent   ok"

# Apple App Review demo account — FIXED credentials that match what is entered
# in App Store Connect → App Review Information → Sign-In. A student account is
# used because it exposes the richest surface (NOVA AI tutor, chat, grades,
# schedule, ClassNotes, practice). Put it in the same class so the reviewer sees
# a populated, non-empty experience.
APPLE_PASS="AppleReview2026!"
APPLE_ID=$(mkuser STUDENT "Apple Review"  apple-review-student "$APPLE_PASS" ",\"grade\":10"); echo "  apple    ok"

echo "→ cohort membership + parent link"
curl -sf -X POST "$API/admin/cohorts/$COHORT_ID/students" "${AUTH[@]}" -d "{\"studentIds\":[\"$STU1_ID\",\"$STU2_ID\",\"$APPLE_ID\"]}" >/dev/null
curl -sf -X POST "$API/admin/parent-links" "${AUTH[@]}" -d "{\"parentId\":\"$PAR_ID\",\"studentId\":\"$STU1_ID\"}" >/dev/null
echo "  ok"

echo "→ verify student login"
STU_TOKEN=$(curl -sf -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"qa.student1.cm\",\"password\":\"$STU1_PASS\"}" | token)
curl -sf "$API/auth/me" -H "Authorization: Bearer $STU_TOKEN" >/dev/null && echo "  ok"

echo "→ verify Apple reviewer login"
APPLE_TOKEN=$(curl -sf -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"apple-review-student\",\"password\":\"$APPLE_PASS\"}" | token)
curl -sf "$API/auth/me" -H "Authorization: Bearer $APPLE_TOKEN" >/dev/null && echo "  ok — Apple can sign in"

cat > "$CRED_FILE" <<EOF
ClassMate QA School (TESTING ONLY) — tester credentials
Generated: $(date '+%Y-%m-%d %H:%M')
Log in with USERNAME (not email), in the normal app login screen.

APPLE REVIEW  apple-review-student  $APPLE_PASS  (grade 10, in QA Class 10-A) ← paste into App Store Connect
ADMIN     qa.admin.cm     $ADMIN_PASS    (can create more users in-app)
TEACHER   qa.teacher.cm   $TEACH_PASS    (class: QA Class 10-A)
STUDENT1  qa.student1.cm  $STU1_PASS     (grade 10, in QA Class 10-A)
STUDENT2  qa.student2.cm  $STU2_PASS     (grade 10, in QA Class 10-A)
PARENT    qa.parent.cm    $PAR_PASS      (parent of Student One)
EOF
echo
echo "✅ DONE — credentials written to $CRED_FILE (gitignored). Paste them to testers."
