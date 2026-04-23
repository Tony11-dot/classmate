#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-/tmp/classmate-api-3001.log}"

printf '\n=== PRACTICE LOG SUMMARY ===\n'

if [ ! -f "$LOG_FILE" ]; then
  echo "missing log file: $LOG_FILE"
  exit 1
fi

tail -n 500 "$LOG_FILE" | rg -a -n \
  'practice\.generate|practice\.verify|generation_strict_local_fallback|generation_topic_first_fallback|generation_failed|reject_summary|reject index=|topic_drift|topic_anchor_missing_from_body|missing_topic_match_note|difficulty_too_easy_for_hard|invalid question set|EADDRINUSE' \
  -S || true

generation_strict_local_fallback_count="$(rg -a -c '"event":"generation_strict_local_fallback"|generation_strict_local_fallback' "$LOG_FILE" 2>/dev/null || echo 0)"
generation_topic_first_fallback_count="$(rg -a -c '"event":"generation_topic_first_fallback"|generation_topic_first_fallback' "$LOG_FILE" 2>/dev/null || echo 0)"
generation_failed_count="$(rg -a -c '"event":"generation_failed"|generation_failed' "$LOG_FILE" 2>/dev/null || echo 0)"
reject_summary_count="$(rg -a -c 'reject_summary' "$LOG_FILE" 2>/dev/null || echo 0)"
reject_index_count="$(rg -a -c 'reject index=' "$LOG_FILE" 2>/dev/null || echo 0)"
topic_drift_count="$(rg -a -c 'reason=topic_drift|"topic_drift":' "$LOG_FILE" 2>/dev/null || echo 0)"
topic_anchor_missing_from_body_count="$(rg -a -c 'reason=topic_anchor_missing_from_body|"topic_anchor_missing_from_body":' "$LOG_FILE" 2>/dev/null || echo 0)"
missing_topic_match_note_count="$(rg -a -c 'reason=missing_topic_match_note|"missing_topic_match_note":' "$LOG_FILE" 2>/dev/null || echo 0)"
difficulty_too_easy_for_hard_count="$(rg -a -c 'reason=difficulty_too_easy_for_hard|"difficulty_too_easy_for_hard":' "$LOG_FILE" 2>/dev/null || echo 0)"
invalid_set_count="$(rg -a -c 'invalid question set' "$LOG_FILE" 2>/dev/null || echo 0)"
eaddrinuse_count="$(rg -a -c 'EADDRINUSE' "$LOG_FILE" 2>/dev/null || echo 0)"

generation_strict_local_fallback_count="${generation_strict_local_fallback_count:-0}"
generation_topic_first_fallback_count="${generation_topic_first_fallback_count:-0}"
generation_failed_count="${generation_failed_count:-0}"
reject_summary_count="${reject_summary_count:-0}"
reject_index_count="${reject_index_count:-0}"
topic_drift_count="${topic_drift_count:-0}"
topic_anchor_missing_from_body_count="${topic_anchor_missing_from_body_count:-0}"
missing_topic_match_note_count="${missing_topic_match_note_count:-0}"
difficulty_too_easy_for_hard_count="${difficulty_too_easy_for_hard_count:-0}"
invalid_set_count="${invalid_set_count:-0}"
eaddrinuse_count="${eaddrinuse_count:-0}"

printf '\n=== COUNTS ===\n'
echo "generation_strict_local_fallback=${generation_strict_local_fallback_count}"
echo "generation_topic_first_fallback=${generation_topic_first_fallback_count}"
echo "generation_failed=${generation_failed_count}"
echo "reject_summary=${reject_summary_count}"
echo "reject_index=${reject_index_count}"
echo "topic_drift=${topic_drift_count}"
echo "topic_anchor_missing_from_body=${topic_anchor_missing_from_body_count}"
echo "missing_topic_match_note=${missing_topic_match_note_count}"
echo "difficulty_too_easy_for_hard=${difficulty_too_easy_for_hard_count}"
echo "invalid_question_set=${invalid_set_count}"
echo "EADDRINUSE=${eaddrinuse_count}"

printf '\n=== HARD FAIL ON PORT COLLISION ===\n'
if [ "$eaddrinuse_count" -gt 0 ]; then
  echo 'FAIL_EADDRINUSE'
  exit 1
fi

echo 'log-summary-ok'
