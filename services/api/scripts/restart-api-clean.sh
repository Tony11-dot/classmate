#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-3001}"
LOG_FILE="${LOG_FILE:-/tmp/classmate-api-3001.log}"
BASE_URL="${BASE_URL:-http://127.0.0.1:${PORT}}"

kill -9 "$(lsof -tiTCP:${PORT} -sTCP:LISTEN)" 2>/dev/null || true
sleep 2
rm -f ""
rm -rf dist

PORT="$PORT" pnpm -s start:dev >"$LOG_FILE" 2>&1 &
sleep 10

curl -sS "${BASE_URL}/health" && echo
