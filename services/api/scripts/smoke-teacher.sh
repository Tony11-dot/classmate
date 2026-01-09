#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE:-http://localhost:3000}"

if [[ -z "${TEACHER_EMAIL:-}" || -z "${TEACHER_PASSWORD:-}" ]]; then
  echo "Set TEACHER_EMAIL and TEACHER_PASSWORD"
  exit 1
fi

echo "== login"
TOKEN="$(curl -sS "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEACHER_EMAIL\",\"password\":\"$TEACHER_PASSWORD\"}" \
  | python3 -c "import sys,json; t=sys.stdin.read().strip(); j=json.loads(t) if t else {}; print(j.get('token') or j.get('accessToken') or j.get('access_token') or j.get('jwt') or (j.get('data') or {}).get('token') or (j.get('data') or {}).get('accessToken') or (j.get('data') or {}).get('access_token') or '')")"

if [[ -z "$TOKEN" ]]; then
  echo "Login failed (no token)"
  exit 1
fi

echo "== teacher schedule today"
TODAY="$(curl -s "$BASE/teacher/schedule/today" -H "Authorization: Bearer $TOKEN")"
echo "$TODAY" | head -c 400 && echo -e "\n"

# Optional: force a specific date for attendance test (YYYY-MM-DD)
# Example:
#   DATE=2026-01-08 PERIOD=1 COHORT_ID=... ./scripts/smoke-teacher.sh
if [[ -n "${DATE:-}" ]]; then
  if [[ -z "${COHORT_ID:-}" ]]; then
    echo "Set COHORT_ID when using DATE=..."
    exit 1
  fi
  PERIOD="${PERIOD:-1}"

  echo "== attendance session (forced date=$DATE cohortId=$COHORT_ID period=$PERIOD)"
  curl -s "$BASE/teacher/attendance/session?cohortId=$COHORT_ID&date=$DATE&period=$PERIOD" \
    -H "Authorization: Bearer $TOKEN" | head -c 800 && echo -e "\n"

  
# --- optional: mark + bulk + verify (SMOKE_MARK=1) ---
# knobs:
#   MARK_STATUS=ABSENT|PRESENT|LATE|EXCUSED
#   MARK_NOTE="text"
#   MARK_TOGGLE=1        # toggles PRESENT<->ABSENT based on current value
#   MARK_RESET=1         # restores original status/note after verify
#   STUDENT_ID=...       # override selection
if [[ "${SMOKE_MARK:-}" == "1" ]]; then
  echo "== fetch attendance session (for mark/bulk/verify)"
  SESSION_JSON="$(curl -sS "$BASE/teacher/attendance/session?cohortId=$COHORT_ID&date=$DATE&period=$PERIOD" -H "Authorization: Bearer $TOKEN")"
  echo "$SESSION_JSON" | head -c 800 && echo -e "
"

  # pick student
  PICKED_ID="${STUDENT_ID:-}"
  if [[ -z "$PICKED_ID" ]]; then
    PICKED_ID="$(echo "$SESSION_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); ss=d.get('students') or []; print((ss[0].get('studentId') if ss else '') or '')" 2>/dev/null || true)"
  fi
  if [[ -z "$PICKED_ID" ]]; then
    echo "No students found in session; skipping mark/bulk/verify."
    exit 0
  fi

  # read current status/note
  CUR_STATUS="$(echo "$SESSION_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); sid='$PICKED_ID'; out='';
for x in (d.get('students') or []):
  if x.get('studentId')==sid:
    out=x.get('status') or ''
print(out)" 2>/dev/null || true)"
  CUR_NOTE="$(echo "$SESSION_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); sid='$PICKED_ID'; out='';
for x in (d.get('students') or []):
  if x.get('studentId')==sid:
    out=x.get('note') or ''
print(out)" 2>/dev/null || true)"

  # decide mark status
  TARGET_STATUS="${MARK_STATUS:-LATE}"
  TARGET_NOTE="${MARK_NOTE:-smoke}"

  if [[ "${MARK_TOGGLE:-}" == "1" ]]; then
    if [[ "$CUR_STATUS" == "PRESENT" ]]; then
      TARGET_STATUS="ABSENT"
      TARGET_NOTE="${MARK_NOTE:-toggle}"
    else
      TARGET_STATUS="PRESENT"
      TARGET_NOTE="${MARK_NOTE:-toggle}"
    fi
  fi

  echo "== mark attendance (studentId=$PICKED_ID => $TARGET_STATUS)"
  MARK_RES="$(curl -sS "$BASE/teacher/attendance/mark" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"cohortId\":\"$COHORT_ID\",\"date\":\"$DATE\",\"period\":$PERIOD,\"studentId\":\"$PICKED_ID\",\"status\":\"$TARGET_STATUS\",\"note\":\"$TARGET_NOTE\"}")"
  echo "$MARK_RES" | head -c 400 && echo -e "
"

  echo "== verify mark (expect $TARGET_STATUS/$TARGET_NOTE)"
  VERIFY1="$(curl -sS "$BASE/teacher/attendance/session?cohortId=$COHORT_ID&date=$DATE&period=$PERIOD" -H "Authorization: Bearer $TOKEN")"
  STATUS1="$(echo "$VERIFY1" | python3 -c "import sys,json; d=json.load(sys.stdin); sid='$PICKED_ID'; out='';
for x in (d.get('students') or []):
  if x.get('studentId')==sid:
    out=x.get('status') or ''
print(out)" 2>/dev/null || true)"
  NOTE1="$(echo "$VERIFY1" | python3 -c "import sys,json; d=json.load(sys.stdin); sid='$PICKED_ID'; out='';
for x in (d.get('students') or []):
  if x.get('studentId')==sid:
    out=x.get('note') or ''
print(out)" 2>/dev/null || true)"
  if [[ "$STATUS1" != "$TARGET_STATUS" || "$NOTE1" != "$TARGET_NOTE" ]]; then
    echo "❌ mark verify failed: expected $TARGET_STATUS/$TARGET_NOTE, got '$STATUS1'/'$NOTE1'"
    exit 1
  fi
  echo "✅ mark verify ok"

  echo "== bulk attendance (studentId=$PICKED_ID => PRESENT/bulk)"
  BULK_RES="$(curl -sS "$BASE/teacher/attendance/bulk" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"cohortId\":\"$COHORT_ID\",\"date\":\"$DATE\",\"period\":$PERIOD,\"records\":[{\"studentId\":\"$PICKED_ID\",\"status\":\"PRESENT\",\"note\":\"bulk\"}]}")"
  echo "$BULK_RES" | head -c 500 && echo -e "
"

  echo "== verify bulk (expect PRESENT/bulk)"
  VERIFY2="$(curl -sS "$BASE/teacher/attendance/session?cohortId=$COHORT_ID&date=$DATE&period=$PERIOD" -H "Authorization: Bearer $TOKEN")"
  STATUS2="$(echo "$VERIFY2" | python3 -c "import sys,json; d=json.load(sys.stdin); sid='$PICKED_ID'; out='';
for x in (d.get('students') or []):
  if x.get('studentId')==sid:
    out=x.get('status') or ''
print(out)" 2>/dev/null || true)"
  NOTE2="$(echo "$VERIFY2" | python3 -c "import sys,json; d=json.load(sys.stdin); sid='$PICKED_ID'; out='';
for x in (d.get('students') or []):
  if x.get('studentId')==sid:
    out=x.get('note') or ''
print(out)" 2>/dev/null || true)"
  if [[ "$STATUS2" != "PRESENT" || "$NOTE2" != "bulk" ]]; then
    echo "❌ bulk verify failed: expected PRESENT/bulk, got '$STATUS2'/'$NOTE2'"
    exit 1
  fi
  echo "✅ bulk verify ok"

  if [[ "${MARK_RESET:-}" == "1" && -n "$CUR_STATUS" ]]; then
    echo "== reset back to original ($CUR_STATUS/$CUR_NOTE)"
    curl -sS "$BASE/teacher/attendance/mark" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"cohortId\":\"$COHORT_ID\",\"date\":\"$DATE\",\"period\":$PERIOD,\"studentId\":\"$PICKED_ID\",\"status\":\"$CUR_STATUS\",\"note\":\"$CUR_NOTE\"}" \
      | head -c 300 && echo -e "
"
    echo "✅ reset ok"
  fi
fi
fi

echo "✅ teacher smoke ok"
  exit 0
fi


# Try to extract cohortId + period from payload if present
INFER_COHORT_ID="$(echo "$TODAY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cohortId') or d.get('cohort',{}).get('id') or '')" 2>/dev/null || true)"
COHORT_ID="${COHORT_ID:-$INFER_COHORT_ID}"
PERIOD="$(echo "$TODAY" | python3 -c "import sys,json; d=json.load(sys.stdin); slots=(d.get('slots') or d.get('day',{}).get('slots') or []); 
p=None
for x in slots:
  if x.get('course') is not None:
    p=x.get('period'); break
print(p or '')" 2>/dev/null || true)"

if [[ -z "$COHORT_ID" ]]; then
  echo "Could not infer cohortId from today payload. Set COHORT_ID env var and rerun."
  exit 0
fi

if [[ -z "$PERIOD" ]]; then
  echo "No scheduled lessons today (no slot with a course)."
echo "↪ trying yesterday for attendance session…"

YESTERDAY="$(python3 -c "import datetime as d; print((d.date.today()-d.timedelta(days=1)).isoformat())")"
PERIOD="${PERIOD:-1}"

echo "== attendance session (auto date=$YESTERDAY cohortId=$COHORT_ID period=$PERIOD)"
curl -s "$BASE/teacher/attendance/session?cohortId=$COHORT_ID&date=$YESTERDAY&period=$PERIOD" \
  -H "Authorization: Bearer $TOKEN" | head -c 800 && echo -e "\n"

echo "✅ teacher smoke ok"
exit 0
fi

echo "== attendance session (cohortId=$COHORT_ID period=$PERIOD)"
curl -s "$BASE/teacher/attendance/session?cohortId=$COHORT_ID&period=$PERIOD" \
  -H "Authorization: Bearer $TOKEN" | head -c 600 && echo -e "\n"

echo "✅ teacher smoke ok"
