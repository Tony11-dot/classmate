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
  echo "🔎 port :"
  lsof -nP -iTCP: -sTCP:LISTEN || true
}

clean_api () {
  # 1) kill by port (most reliable)
  stop_port ""

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

Env:
  API_PORT=3000
  API_BASE=http://127.0.0.1:3000
  LOG=/tmp/classmate-api.log
EOF
    ;;
esac
