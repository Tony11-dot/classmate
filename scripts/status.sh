#!/usr/bin/env bash
set -euo pipefail
echo "== docker ps =="
docker compose ps

echo
echo "== api health =="
curl -fsS http://localhost:3000/api/health && echo

echo
echo "== db counts =="
docker compose exec -T db psql -U classmate -d classmate -c "
SELECT
 (SELECT count(*) FROM \"User\") AS users,
 (SELECT count(*) FROM \"UserRole\") AS roles,
 (SELECT count(*) FROM \"Cohort\") AS cohorts,
 (SELECT count(*) FROM \"Course\") AS courses,
 (SELECT count(*) FROM \"ScheduleSlot\") AS slots,
 (SELECT count(*) FROM \"Announcement\") AS announcements;
"
