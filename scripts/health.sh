#!/usr/bin/env bash
set -euo pipefail

echo "▶ API tests (CI)"
pnpm -C services/api test

echo "✅ ALL SYSTEMS GREEN" --runInBand --detectOpenHandles --testLocationInResults --verbose
