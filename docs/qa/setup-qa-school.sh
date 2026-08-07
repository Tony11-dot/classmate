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
#   • Apple review student  apple-review-student  (reused if it already exists)
# then writes the credential sheet to
#   docs/qa/QA-CREDENTIALS.txt   (gitignored — paste it to testers yourself)
#
# IDEMPOTENT: on each run it first deletes any existing "ClassMate QA School
# (TESTING ONLY)" (which cascades its users) and recreates everything fresh, so
# it is safe to re-run. Usernames are globally unique, hence the teardown.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail   # NOT -e: best-effort steps handle their own errors below
API="https://pacific-enchantment-production-7a80.up.railway.app"
DIR="$(cd "$(dirname "$0")" && pwd)"
CRED_FILE="$DIR/QA-CREDENTIALS.txt"

read -r -p "Owner email [aboudtony22@gmail.com]: " OWNER_EMAIL
OWNER_EMAIL=${OWNER_EMAIL:-aboudtony22@gmail.com}
read -r -s -p "Owner (manager) password: " OWNER_PASS; echo

token() { python3 -c "import sys,json;print(json.load(sys.stdin)['token'])" 2>/dev/null; }
jget()  { python3 -c "import sys,json;d=json.load(sys.stdin);print(d$1)" 2>/dev/null; }

echo "→ health"; curl -sf "$API/health" >/dev/null && echo "  ok" || { echo "  ✗ API down"; exit 1; }

echo "→ owner login"
LOGIN_RESP=$(curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"$OWNER_EMAIL\",\"password\":\"$OWNER_PASS\"}")
OWNER_TOKEN=$(echo "$LOGIN_RESP" | token || true)
if [ -z "${OWNER_TOKEN:-}" ]; then
  echo "✗ Owner login failed. Response was:"; echo "$LOGIN_RESP" | head -c 400; echo
  echo "  (Note: /auth/login allows 5 attempts per 15 min per IP.)"; exit 1
fi
echo "  ok"

# ── Idempotent teardown: delete any pre-existing QA school (cascades its users)
echo "→ tearing down any existing QA school"
SCHOOLS_JSON=$(curl -s "$API/manager/schools" -H "Authorization: Bearer $OWNER_TOKEN")
OLD_IDS=$(echo "$SCHOOLS_JSON" | python3 -c "
import sys,json
try: d=json.load(sys.stdin)
except Exception: d=None
schools = d.get('schools') if isinstance(d, dict) else (d if isinstance(d, list) else [])
for s in (schools or []):
    if isinstance(s, dict) and 'QA School (TESTING ONLY)' in (s.get('name') or ''): print(s['id'])
" 2>/dev/null)
if [ -n "$OLD_IDS" ]; then
  while read -r sid; do
    [ -z "$sid" ] && continue
    curl -sf -X DELETE "$API/manager/schools/$sid" -H "Authorization: Bearer $OWNER_TOKEN" >/dev/null \
      && echo "  deleted old QA school $sid" || echo "  (could not delete $sid — continuing)"
  done <<< "$OLD_IDS"
else
  echo "  none found (clean)"
fi

# Random suffix so QA passwords aren't guessable even though usernames are fixed.
SUF="$(openssl rand -hex 2)"
ADMIN_PASS="QaAdmin!${SUF}9";  TEACH_PASS="QaTeach!${SUF}9"
STU1_PASS="QaStud1!${SUF}9";   STU2_PASS="QaStud2!${SUF}9";  PAR_PASS="QaParent!${SUF}9"

echo "→ create QA school + admin"
SCHOOL=$(curl -sf -X POST "$API/manager/schools" -H "Authorization: Bearer $OWNER_TOKEN" -H 'Content-Type: application/json' \
  -d "{\"schoolName\":\"ClassMate QA School (TESTING ONLY)\",\"minGrade\":7,\"maxGrade\":12,\"adminName\":\"QA Admin\",\"adminUsername\":\"qa.admin.cm\",\"adminPassword\":\"$ADMIN_PASS\"}")
if [ -z "$SCHOOL" ]; then echo "  ✗ school create failed"; exit 1; fi
echo "  ok: $(echo "$SCHOOL" | head -c 120)"

echo "→ admin login"
ADMIN_TOKEN=$(curl -sf -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifier\":\"qa.admin.cm\",\"password\":\"$ADMIN_PASS\"}" | token)
if [ -z "${ADMIN_TOKEN:-}" ]; then echo "  ✗ admin login failed"; exit 1; fi
AUTH=(-H "Authorization: Bearer $ADMIN_TOKEN" -H 'Content-Type: application/json')
echo "  ok"

# NOTE: Cohort.name is GLOBALLY @unique and deleteSchool does NOT cascade
# cohorts, so a re-run would 409 on a plain "QA Class 10-A" left orphaned by the
# previous school's teardown. Suffix the name to keep re-runs idempotent.
COHORT_NAME="QA Class 10-A ${SUF}"
echo "→ cohort $COHORT_NAME"
COHORT_ID=$(curl -sf -X POST "$API/admin/cohorts" "${AUTH[@]}" -d "{\"name\":\"$COHORT_NAME\",\"grade\":10}" | jget "['id']")
echo "  ok (${COHORT_ID:-?})"

# Create a user; echoes the new id, or empty on failure (best-effort).
mkuser() {
  local resp; resp=$(curl -s -X POST "$API/admin/users" "${AUTH[@]}" \
    -d "{\"role\":\"$1\",\"name\":\"$2\",\"username\":\"$3\",\"password\":\"$4\"$5}")
  echo "$resp" | jget "['user']['id']"
}

echo "→ users"
TEACH_ID=$(mkuser TEACHER "QA Teacher"      qa.teacher.cm  "$TEACH_PASS" "");             echo "  teacher  ${TEACH_ID:+ok}${TEACH_ID:-FAILED}"
STU1_ID=$(mkuser STUDENT  "QA Student One"  qa.student1.cm "$STU1_PASS" ",\"grade\":10"); echo "  student1 ${STU1_ID:+ok}${STU1_ID:-FAILED}"
STU2_ID=$(mkuser STUDENT  "QA Student Two"  qa.student2.cm "$STU2_PASS" ",\"grade\":10"); echo "  student2 ${STU2_ID:+ok}${STU2_ID:-FAILED}"
PAR_ID=$(mkuser PARENT    "QA Parent"       qa.parent.cm   "$PAR_PASS" "");               echo "  parent   ${PAR_ID:+ok}${PAR_ID:-FAILED}"

# Apple App Review demo account — FIXED credentials matching App Store Connect →
# App Review Information → Sign-In. Reused if it already exists (its username is
# global and may have been created by setup-review-accounts.sh).
APPLE_PASS="AppleReview2026!"
APPLE_ID=$(mkuser STUDENT "Apple Review" apple-review-student "$APPLE_PASS" ",\"grade\":10")
if [ -n "$APPLE_ID" ]; then echo "  apple    ok (new)"; else echo "  apple    reused (already existed; pw=$APPLE_PASS)"; fi

echo "→ cohort membership + parent link"
IDS="\"$STU1_ID\",\"$STU2_ID\""; [ -n "$APPLE_ID" ] && IDS="$IDS,\"$APPLE_ID\""
curl -sf -X POST "$API/admin/cohorts/$COHORT_ID/students" "${AUTH[@]}" -d "{\"studentIds\":[$IDS]}" >/dev/null \
  && echo "  cohort ok" || echo "  (cohort add skipped)"
curl -sf -X POST "$API/admin/parent-links" "${AUTH[@]}" -d "{\"parentId\":\"$PAR_ID\",\"studentId\":\"$STU1_ID\"}" >/dev/null \
  && echo "  parent-link ok" || echo "  (parent link skipped)"

# Write credentials NOW (before verifies) so nothing later can lose them.
cat > "$CRED_FILE" <<EOF
ClassMate QA School (TESTING ONLY) — tester credentials
Generated: $(date '+%Y-%m-%d %H:%M')
Log in with USERNAME (not email), in the normal app login screen.

APPLE REVIEW  apple-review-student  $APPLE_PASS  (grade 10) ← paste into App Store Connect
ADMIN     qa.admin.cm     $ADMIN_PASS    (can create more users in-app)
TEACHER   qa.teacher.cm   $TEACH_PASS    (class: $COHORT_NAME)
STUDENT1  qa.student1.cm  $STU1_PASS     (grade 10, in $COHORT_NAME)
STUDENT2  qa.student2.cm  $STU2_PASS     (grade 10, in $COHORT_NAME)
PARENT    qa.parent.cm    $PAR_PASS      (parent of Student One)
EOF
echo "  credentials written → $CRED_FILE"

echo "→ verify logins"
for u in "qa.student1.cm:$STU1_PASS" "apple-review-student:$APPLE_PASS"; do
  un="${u%%:*}"; pw="${u#*:}"
  tk=$(curl -sf -X POST "$API/auth/login" -H 'Content-Type: application/json' \
    -d "{\"identifier\":\"$un\",\"password\":\"$pw\"}" | token)
  if [ -n "${tk:-}" ] && curl -sf "$API/auth/me" -H "Authorization: Bearer $tk" >/dev/null; then
    echo "  $un ok"
  else
    echo "  ⚠ $un could NOT log in — check this account"
  fi
done

echo
echo "✅ DONE — credentials in $CRED_FILE (gitignored). Paste them to testers."
