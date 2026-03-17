#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-/tmp/classmate-api-3001.log}"

printf '\n=== PRACTICE LOG SUMMARY ===\n'

if [ ! -f "$LOG_FILE" ]; then
  echo "missing log file: $LOG_FILE"
  exit 1
fi

tail -n 500 "$LOG_FILE" | rg -n \
  'practice\.generate|practice\.verify|verifier_fallback_using_local_valid|reject_summary|reject index=|invalid question set|EADDRINUSE' \
  -S || true

fallback_count="$(rg -c 'verifier_fallback_using_local_valid' "$LOG_FILE" || true)"
reject_summary_count="$(rg -c 'reject_summary' "$LOG_FILE" || true)"
reject_index_count="$(rg -c 'reject index=' "$LOG_FILE" || true)"
invalid_set_count="$(rg -c 'invalid question set' "$LOG_FILE" || true)"
eaddrinuse_count="$(rg -c 'EADDRINUSE' "$LOG_FILE" || true)"

printf '\n=== COUNTS ===\n'
echo "verifier_fallback_using_local_valid=${fallback_count}"
echo "reject_summary=${reject_summary_count}"
echo "reject_index=${reject_index_count}"
echo "invalid_question_set=${invalid_set_count}"
echo "EADDRINUSE=${eaddrinuse_count}"

printf '\n=== HARD FAIL ON PORT COLLISION ===\n'
if [ "${eaddrinuse_count}" -gt 0 ]; then
  echo 'FAIL_EADDRINUSE'
  exit 1
fi

echo 'log-summary-ok'
