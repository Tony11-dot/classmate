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
