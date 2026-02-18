#!/usr/bin/env bash
set -euo pipefail

[[ -f .env ]] || { echo "❌ .env missing"; exit 1; }

req=(DATABASE_URL JWT_SECRET)
for k in "${req[@]}"; do
  if ! rg -q "^${k}=" .env; then
    echo "❌ ${k} missing in .env"
    exit 1
  fi
done

echo "✅ env ok"
