#!/usr/bin/env bash
set -euo pipefail

ARG="${1:-}"
if [[ -z "$ARG" ]]; then
  echo "usage: $0 test/<name>.e2e-spec.ts  OR  $0 <name>" >&2
  exit 2
fi

FILE="$ARG"
if [[ "$FILE" != *".ts" ]]; then
  FILE="test/${FILE}.e2e-spec.ts"
fi

if [[ ! -f "$FILE" ]]; then
  echo "file not found: $FILE" >&2
  exit 2
fi

NODE_ENV=test pnpm exec jest -c test/jest-e2e.json --runInBand --runTestsByPath "$FILE"
