#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   SOURCE="2022 summer" ./scripts/solutions-clean.sh
#   SOURCE="2022 summer" APPLY=1 ./scripts/solutions-clean.sh
#   SOURCE="2022 summer" AUTHOR_EMAIL="admin+123@classmate.local" APPLY=1 ./scripts/solutions-clean.sh
#
# Notes:
# - default is dry-run (counts)
# - set APPLY=1 to actually delete

SOURCE="${SOURCE:-}"
AUTHOR_EMAIL="${AUTHOR_EMAIL:-}"
APPLY="${APPLY:-0}"
ALLOW_ALL="${ALLOW_ALL:-0}"
CONFIRM="${CONFIRM:-}"
MAX_DELETE="${MAX_DELETE:-500}"

if [[ -z "$SOURCE" && -z "$AUTHOR_EMAIL" && "$ALLOW_ALL" != "1" ]]; then
  echo "ERROR: provide SOURCE and/or AUTHOR_EMAIL (or set ALLOW_ALL=1)"
  echo "  SOURCE=\"2022 summer\" APPLY=1 ./scripts/solutions-clean.sh"
  echo "  AUTHOR_EMAIL=\"admin+...@classmate.local\" APPLY=1 ./scripts/solutions-clean.sh"
  echo "  ALLOW_ALL=1 APPLY=1 ./scripts/solutions-clean.sh"
  exit 1
fi

where_sql="TRUE"
if [[ -n "$SOURCE" ]]; then
  where_sql="$where_sql AND s.\"sourceName\" = '$(printf "%s" "$SOURCE" | sed "s/'/''/g")'"
fi
if [[ -n "$AUTHOR_EMAIL" ]]; then
  where_sql="$where_sql AND u.email = '$(printf "%s" "$AUTHOR_EMAIL" | sed "s/'/''/g")'"
fi

echo "Filter:"
[[ -n "$SOURCE" ]] && echo "  SOURCE=$SOURCE"
[[ -n "$AUTHOR_EMAIL" ]] && echo "  AUTHOR_EMAIL=$AUTHOR_EMAIL"
echo "APPLY=$APPLY"
[[ "$ALLOW_ALL" == "1" ]] && echo "ALLOW_ALL=1"
echo "MAX_DELETE=$MAX_DELETE"
echo

echo "[dry-run] matching solutions:"
count_solutions="$(
  docker compose exec -T db psql -U classmate -d classmate -t -A -v ON_ERROR_STOP=1 <<SQL
SELECT count(*)::int
FROM \"Solution\" s
LEFT JOIN \"User\" u ON u.id = s.\"authorId\"
WHERE $where_sql;
SQL
)"
echo "solutions=$count_solutions"

echo
echo "[dry-run] sample (latest 10):"
docker compose exec -T db psql -U classmate -d classmate -v ON_ERROR_STOP=1 -c "
SELECT s.id, s.subject, s.\"sourceName\", s.page, s.\"questionNumber\", u.email AS author_email, s.\"createdAt\"
FROM \"Solution\" s
LEFT JOIN \"User\" u ON u.id = s.\"authorId\"
WHERE $where_sql
ORDER BY s.\"createdAt\" DESC
LIMIT 10;
"

if [[ "$APPLY" == "1" && "$ALLOW_ALL" == "1" && "$CONFIRM" != "YES" ]]; then
  echo
  echo "ERROR: refusing to delete everything without explicit confirmation."
  echo "Run: ALLOW_ALL=1 APPLY=1 CONFIRM=YES ./scripts/solutions-clean.sh"
  exit 1
fi

if [[ "$APPLY" == "1" ]] && (( count_solutions > MAX_DELETE )); then
  echo
  echo "ERROR: refusing to delete $count_solutions solutions (MAX_DELETE=$MAX_DELETE)."
  echo "If intentional, rerun with MAX_DELETE=$count_solutions (or higher)."
  exit 1
fi

if [[ "$APPLY" != "1" ]]; then
  echo
  echo "Dry-run only. To delete, run with APPLY=1"
  exit 0
fi

echo
echo "[apply] deleting images first (safe if no cascade)..."
docker compose exec -T db psql -U classmate -d classmate -v ON_ERROR_STOP=1 -c "
DELETE FROM \"SolutionImage\" si
USING \"Solution\" s
LEFT JOIN \"User\" u ON u.id = s.\"authorId\"
WHERE si.\"solutionId\" = s.id
  AND $where_sql;
"

echo
echo "[apply] deleting solutions..."
docker compose exec -T db psql -U classmate -d classmate -v ON_ERROR_STOP=1 -c "
DELETE FROM \"Solution\" s
USING \"User\" u
WHERE u.id = s.\"authorId\"
  AND $where_sql;
"

echo
echo "Done."
