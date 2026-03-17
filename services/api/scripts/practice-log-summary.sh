#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-/tmp/classmate-api-3001.log}"

printf '\n=== PRACTICE LOG SUMMARY ===\n'

if [ ! -f "$LOG_FILE" ]; then
  echo "missing log file: $LOG_FILE"
  exit 1
fi

tail -n 500 "$LOG_FILE" | rg -a -n \
  'practice\.generate|practice\.verify|verifier_fallback_using_local_valid|reject_summary|reject index=|invalid question set|EADDRINUSE' \
  -S || true

fallback_count="$(rg -a -c 'verifier_fallback_using_local_valid' "$LOG_FILE" 2>/dev/null || echo 0)"
reject_summary_count="$(rg -a -c 'reject_summary' "$LOG_FILE" 2>/dev/null || echo 0)"
reject_index_count="$(rg -a -c 'reject index=' "$LOG_FILE" 2>/dev/null || echo 0)"
invalid_set_count="$(rg -a -c 'invalid question set' "$LOG_FILE" 2>/dev/null || echo 0)"
eaddrinuse_count="$(rg -a -c 'EADDRINUSE' "$LOG_FILE" 2>/dev/null || echo 0)"

fallback_count="${fallback_count:-0}"
reject_summary_count="${reject_summary_count:-0}"
reject_index_count="${reject_index_count:-0}"
invalid_set_count="${invalid_set_count:-0}"
eaddrinuse_count="${eaddrinuse_count:-0}"

printf '\n=== COUNTS ===\n'
echo "verifier_fallback_using_local_valid=${fallback_count}"
echo "reject_summary=${reject_summary_count}"
echo "reject_index=${reject_index_count}"
echo "invalid_question_set=${invalid_set_count}"
echo "EADDRINUSE=${eaddrinuse_count}"

printf '\n=== HARD FAIL ON PORT COLLISION ===\n'
if [ "$eaddrinuse_count" -gt 0 ]; then
  echo 'FAIL_EADDRINUSE'
  exit 1
fi

echo 'log-summary-ok'
