#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE:-http://localhost:3000}"

if [[ -z "${STUDENT_TOKEN:-}" ]]; then
  echo "Missing STUDENT_TOKEN"
  exit 1
fi

echo "== week"
curl -s "$BASE/schedule/week" -H "Authorization: Bearer $STUDENT_TOKEN" | head -c 200 && echo -e "\n"

echo "== week-grid"
curl -s "$BASE/schedule/week-grid" -H "Authorization: Bearer $STUDENT_TOKEN" | head -c 200 && echo -e "\n"

echo "== today"
curl -s "$BASE/schedule/today" -H "Authorization: Bearer $STUDENT_TOKEN" | head -c 200 && echo -e "\n"

echo "✅ smoke ok"
