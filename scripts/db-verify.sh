#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "❌ db-verify failed at line $LINENO: $BASH_COMMAND" >&2' ERR

cd "$(dirname "$0")/.."

echo "== db up =="
docker compose up -d db

echo "== db wait =="
docker exec -i classmate-db-1 sh -lc '
  set -euo pipefail
  U="${POSTGRES_USER:-classmate}"
  D="${POSTGRES_DB:-classmate}"
  for i in $(seq 1 60); do
    if pg_isready -h localhost -U "$U" -d "$D" >/dev/null 2>&1; then
      echo "db: ready"
      exit 0
    fi
    sleep 1
  done
  echo "db: NOT ready" >&2
  exit 1
'

echo "== db ping =="
docker exec -i classmate-db-1 sh -lc '
  set -euo pipefail
  U="${POSTGRES_USER:-classmate}"
  D="${POSTGRES_DB:-classmate}"
  psql -h localhost -U "$U" -d "$D" -c "select 1;" >/dev/null
'
echo "db: ok"

echo "== basic invariants =="
docker exec -i classmate-db-1 sh -lc '
  set -euo pipefail
  U="${POSTGRES_USER:-classmate}"
  D="${POSTGRES_DB:-classmate}"
  psql -h localhost -U "$U" -d "$D" -c "select count(*) from \"User\";" >/dev/null
  psql -h localhost -U "$U" -d "$D" -c "select count(*) from \"ParentNotification\";" >/dev/null
'

echo "✅ db invariants ok"
