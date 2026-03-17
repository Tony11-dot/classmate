#!/usr/bin/env bash
set -euo pipefail

export BASE_URL="${BASE_URL:-http://127.0.0.1:3001}"
export TOKEN="${TOKEN:-dev-token-student1@classmate.app}"
export LOG_FILE="${LOG_FILE:-/tmp/classmate-api-3001.log}"

printf '\n=== CLEAN RESTART ===\n'
./scripts/restart-api-clean.sh

printf '\n=== BLOCKER SMOKE ===\n'
./scripts/smoke-practice-blockers.sh

printf '\n=== LIVE FULL CANARY ===\n'
./scripts/smoke-practice-live-full.sh

printf '\n=== DETERMINISTIC REGRESSION ===\n'
./scripts/smoke-practice-all-deterministic.sh >/tmp/practice-golden-deterministic.out
tail -n 40 /tmp/practice-golden-deterministic.out

printf '\n=== LOG SUMMARY ===\n'
./scripts/practice-log-summary.sh ""

# FAIL_EADDRINUSE is enforced by practice-log-summary.sh

echo 'practice-golden-ok'
