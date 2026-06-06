#!/usr/bin/env bash
# Upload Flutter debug symbols (native .so + Dart split-debug-info) to Sentry
# so production crashes show real file/function/line instead of <unknown>.
#
# Run AFTER a release build that used:
#   flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
#   flutter build ipa       --release --obfuscate --split-debug-info=build/symbols
#
# Auth: reads SENTRY_AUTH_TOKEN from the env, or falls back to the local
# (git-ignored) file ~/.classmate_sentry_token. NEVER commit the token.
#
# The chunked upload is resumable — sentry-cli dedups already-uploaded chunks —
# so we retry a few times to ride out flaky networks until it converges.
set -uo pipefail

cd "$(dirname "$0")/../apps/classmate_mobile" || exit 1

: "${SENTRY_AUTH_TOKEN:=$(cat "$HOME/.classmate_sentry_token" 2>/dev/null || true)}"
if [ -z "${SENTRY_AUTH_TOKEN:-}" ]; then
  echo "ERROR: SENTRY_AUTH_TOKEN not set and ~/.classmate_sentry_token missing." >&2
  exit 1
fi
export SENTRY_AUTH_TOKEN
export SENTRY_HTTP_MAX_RETRIES=10

for i in $(seq 1 6); do
  echo "── symbol upload attempt $i ──"
  out="$(dart run sentry_dart_plugin 2>&1 || true)"
  echo "$out" | grep -iE "UPLOADED|Nothing to upload|Found [0-9]+ debug|error: API" | tail -4
  if echo "$out" | grep -qi "Nothing to upload, all files are on the server"; then
    echo "✓ All symbols uploaded to Sentry."
    exit 0
  fi
done

echo "⚠ Upload did not fully converge — just run this script again (it resumes)." >&2
exit 1
