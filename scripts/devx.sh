#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-help}"

API_PORT="${API_PORT:-3000}"
API_BASE="${API_BASE:-http://127.0.0.1:${API_PORT}}"
LOG="${LOG:-/tmp/classmate-api.log}"

die () { echo "❌ $*" >&2; exit 1; }

need () { command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"; }

stop_port () {
  local port="$1"
  local pids
  pids="$(lsof -ti "tcp:${port}" 2>/dev/null || true)"
  if [[ -n "${pids}" ]]; then
    echo "🛑 killing port ${port}: ${pids}"
    echo "${pids}" | xargs -r kill -9
  else
    echo "✅ port ${port} already free"
  fi
}

ps_api () {
  echo "🔎 processes (api/dev):"
  pgrep -fl "Dev/classmate/services/api|pnpm --dir services/api dev|nest.js start --watch|services/api/dist/src/main" || true
  echo "🔎 port ${API_PORT}:"
  lsof -nP -iTCP:${API_PORT} -sTCP:LISTEN || true
}

clean_api () {
  # 1) kill by port (most reliable)
  stop_port "${API_PORT}"

  # 2) kill any leftover watchers (best-effort, scoped to services/api)
  pgrep -f "Dev/classmate/services/api" | xargs -r kill -9 || true
  pgrep -f "pnpm --dir services/api dev" | xargs -r kill -9 || true
  pgrep -f "nest.js start --watch" | xargs -r kill -9 || true
  pgrep -f "services/api/dist/src/main" | xargs -r kill -9 || true
}

wait_health () {
  local url="$1"
  echo "⏳ waiting for ${url}/api/health"
  for _ in $(seq 1 200); do
    if curl -fsS --connect-timeout 1 --max-time 1 2>/dev/null "${url}/api/health" | grep -q '"ok":true'; then
      echo "✅ health ok"
      return 0
    fi
    sleep 0.2
  done
  die "api health never became ok"
}

start_api () {
  rm -f "${LOG}"
  echo "🚀 starting api (log: ${LOG})"
  nohup pnpm --dir services/api dev >"${LOG}" 2>&1 & disown || true
  wait_health "${API_BASE}"
}


# --- devx db helpers (docker postgres) ---
DB_CONTAINER_NAME="${DB_CONTAINER_NAME:-classmate-postgres}"
DB_PORT="${DB_PORT:-5433}"
DB_USER="${DB_USER:-classmate}"
DB_PASS="${DB_PASS:-classmate}"
DB_NAME="${DB_NAME:-classmate}"

api_db_url () {
  echo "postgresql://${DB_USER}:${DB_PASS}@localhost:${DB_PORT}/${DB_NAME}?schema=public"
}

db_running() {
  docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "${DB_CONTAINER_NAME}"
}

db_exists() {
  docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "${DB_CONTAINER_NAME}"
}

db_start() {
  need docker

  if db_running; then
    echo "✅ postgres already running (${DB_CONTAINER_NAME})"
    return 0
  fi

  if db_exists; then
    echo "🚀 starting postgres container: ${DB_CONTAINER_NAME}"
    docker start "${DB_CONTAINER_NAME}" >/dev/null
  else
    echo "🚀 creating postgres container: ${DB_CONTAINER_NAME} (port ${DB_PORT}->5432)"
    docker run -d --name "${DB_CONTAINER_NAME}" \
      -e POSTGRES_USER="${DB_USER}" \
      -e POSTGRES_PASSWORD="${DB_PASS}" \
      -e POSTGRES_DB="${DB_NAME}" \
      -p "${DB_PORT}:5432" \
      postgres:16 >/dev/null
  fi

  echo "⏳ waiting for postgres..."
  for _ in $(seq 1 60); do
    if docker exec "${DB_CONTAINER_NAME}" pg_isready -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; then
      echo "✅ postgres ready"
      return 0
    fi
    sleep 1
  done

  echo "❌ postgres not ready in time"
  docker logs --tail 80 "${DB_CONTAINER_NAME}" || true
  return 1
}

ensure_api_env() {
  local env_file="services/api/.env"
  local example_file="services/api/.env.example"

  if [[ -f "${env_file}" ]]; then
    return 0
  fi

  if [[ -f "${example_file}" ]]; then
    echo "📝 creating ${env_file} from ${example_file}"
    cp "${example_file}" "${env_file}"
    return 0
  fi

  die "missing ${env_file} and ${example_file}. Create one with DATABASE_URL."
}

db_migrate() {
  echo "🧩 prisma migrate deploy (api)"
  export DATABASE_URL="${DATABASE_URL:-$(api_db_url)}"
  ensure_api_env
  pnpm --filter ./services/api exec prisma migrate deploy
}

case "${cmd}" in
  ps)
    ps_api
    ;;
  clean)
    clean_api
    ps_api
    ;;

  stop)
    stop_port "${API_PORT}"
    ;;
  start)
    clean_api
    start_api
    ;;
  logs)
    tail -n 120 "${LOG}" || true
    ;;
  test)
    need jq
    clean_api
    start_api
    echo "🧪 running repo e2e"
    API_BASE="${API_BASE}" pnpm -s test:e2e
    echo "🧪 running parent-web playwright"
    (cd apps/parent-web && API_BASE="${API_BASE}" pnpm exec playwright test --reporter=line)
    echo "✅ all tests passed"
    ;;

  up)
    db_start
    db_migrate
    pnpm -s devx:test
    ;;

  doctor)
    echo "🩺 devx doctor"
    echo
    echo "== versions =="
    pnpm -v || true
    node -v || true
    docker -v || true
    echo
    echo "== env =="
    echo "API_PORT=${API_PORT:-3000}"
    echo "API_BASE=${API_BASE:-http://127.0.0.1:${API_PORT:-3000}}"
    echo "DB_CONTAINER_NAME=${DB_CONTAINER_NAME:-classmate-postgres}"
    echo "DB_PORT=${DB_PORT:-5433}"
    echo
    echo "== docker db =="
    docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null | (command -v rg >/dev/null && rg -n 'classmate-postgres|postgres|5433|5432' || cat) || true
    echo
    echo "== port listener =="
    lsof -nP -iTCP:${API_PORT:-3000} -sTCP:LISTEN || true
    echo
    echo "== api logs (tail) =="
    tail -n 120 "${LOG:-/tmp/classmate-api.log}" || true
    ;;


  help|*)
    cat <<EOF
Usage: scripts/devx.sh <command>

Commands:
  start   Stop API port and start api (background)
  stop    Kill whatever listens on API port (${API_PORT})
  ps      Show api-related processes + port listener
  clean   Kill port + stray api watchers (pnpm/nest/node)
  logs    Tail api log
  test    Start api + run full e2e + parent-web tests
  doctor  Print env, db status, port status, and tail api logs
  up      Start postgres (docker), migrate, then run tests

Env:
  API_PORT=3000
  API_BASE=http://127.0.0.1:3000
  LOG=/tmp/classmate-api.log
EOF
    ;;

esac
