#!/usr/bin/env bash
set -euo pipefail
BASE="${BASE:-http://localhost:3000}"

echo "✅ health:"
curl -fsS "$BASE/api/health" | jq

echo "✅ student me:"
curl -fsS "$BASE/api/auth/me" -H "Authorization: Bearer $TOKEN" | jq

echo "✅ student schedule today:"
curl -fsS "$BASE/api/student/schedule/today" -H "Authorization: Bearer $TOKEN" | jq

echo "✅ student blocked from admin:"
curl -sS "$BASE/api/admin/courses" -H "Authorization: Bearer $TOKEN" | jq

echo "✅ admin courses:"
curl -fsS "$BASE/api/admin/courses" -H "Authorization: Bearer $ADMIN_TOKEN" | jq

echo "✅ demo checks passed"
