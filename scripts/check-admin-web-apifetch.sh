#!/usr/bin/env bash
set -euo pipefail
FILE="apps/admin-web/src/lib/api.ts"
rg -n "export async function apiFetch" "$FILE" >/dev/null
rg -n "let p = path;" "$FILE" >/dev/null
rg -n "const url = p\.startsWith" "$FILE" >/dev/null
if rg -n "const url = path\.startsWith" "$FILE" >/dev/null; then
  echo "❌ apiFetch is using path in url builder"
  exit 1
fi
echo "✅ apiFetch url builder OK"
