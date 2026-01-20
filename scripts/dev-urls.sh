#!/usr/bin/env bash
set -euo pipefail

echo "Seeding (admin-web)..."
curl -s -X POST http://localhost:3000/api/test/seed/admin-web >/dev/null || true

echo ""
echo "Open:"
echo "  Admin Web : http://localhost:3001"
echo "  Parent Web: http://localhost:3004"
echo ""
echo "Parent dev creds:"
echo "  email: parent1@classmate.app"
echo "  pass : dev"
