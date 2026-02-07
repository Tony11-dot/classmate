#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ db-verify failed at line $LINENO: $BASH_COMMAND" >&2' ERR

cd "$(dirname "$0")/.."

echo "== db up =="
docker compose up -d db
docker exec -i classmate-db-1 sh -lc 'psql -U "${POSTGRES_USER:-classmate}" -d "${POSTGRES_DB:-classmate}" -c "select 1;"' >/dev/null
echo "db: ok"

echo "== basic invariants =="
docker exec -i classmate-db-1 sh -lc 'psql -U "${POSTGRES_USER:-classmate}" -d "${POSTGRES_DB:-classmate}" -c "select count(*) from \"User\";"' >/dev/null
docker exec -i classmate-db-1 sh -lc 'psql -U "${POSTGRES_USER:-classmate}" -d "${POSTGRES_DB:-classmate}" -c "select count(*) from \"ParentNotification\";"' >/dev/null

echo "✅ db invariants ok"
