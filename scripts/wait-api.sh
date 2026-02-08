#!/usr/bin/env sh
set -eu

URL="${1:-http://localhost:3000/api/health}"
TIMEOUT_SEC="${TIMEOUT_SEC:-30}"

start="$(date +%s)"
while :; do
  if curl -fsS "$URL" >/dev/null 2>&1; then
    exit 0
  fi
  now="$(date +%s)"
  if [ $((now - start)) -ge "$TIMEOUT_SEC" ]; then
    echo "Timed out waiting for API: $URL" >&2
    exit 1
  fi
  sleep 0.3
done
