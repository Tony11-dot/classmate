#!/usr/bin/env sh
set -eu

URL="${1:-http://localhost:3001/health}"
TIMEOUT_SEC="${TIMEOUT_SEC:-30}"

normalize_alt_url() {
  case "$1" in
    */api/health)
      printf '%s\n' "${1%/api/health}/health"
      ;;
    */health)
      printf '%s\n' "${1%/health}/api/health"
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

ALT_URL="$(normalize_alt_url "$URL")"

start="$(date +%s)"
while :; do
  if curl -fsS "$URL" >/dev/null 2>&1; then
    exit 0
  fi
  if [ "$ALT_URL" != "$URL" ] && curl -fsS "$ALT_URL" >/dev/null 2>&1; then
    exit 0
  fi
  now="$(date +%s)"
  if [ $((now - start)) -ge "$TIMEOUT_SEC" ]; then
    echo "Timed out waiting for API: $URL or $ALT_URL" >&2
    exit 1
  fi
  sleep 0.3
done
