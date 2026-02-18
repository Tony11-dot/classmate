#!/usr/bin/env bash
set -euo pipefail
if [[ -f /tmp/cm_backend_pid ]]; then
  PID="$(cat /tmp/cm_backend_pid || true)"
  if [[ -n "${PID:-}" ]]; then
    kill -9 "$PID" >/dev/null 2>&1 || true
    rm -f /tmp/cm_backend_pid
    echo "✅ stopped next dev (pid=$PID)"
    exit 0
  fi
fi
pkill -f "next dev" >/dev/null 2>&1 || true
echo "✅ stopped next dev (pkill fallback)"
