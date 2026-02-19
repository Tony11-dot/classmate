#!/usr/bin/env bash
set -euo pipefail
BASE="${BASE:-http://localhost:3000}"
EMAIL="${EMAIL:-admin@demo.com}"
PASSWORD="${PASSWORD:-Password123!}"
curl -sS -X POST "$BASE/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" \
| python3 -c 'import sys,json; print(json.load(sys.stdin)["token"])'
