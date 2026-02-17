#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../../.."
export ADMIN_TOKEN="$(services/pilot_api/scripts/get_admin_token.sh)"

echo "== Notifications smoke =="

# list should be JSON array
curl -sS http://localhost:3000/api/notifications \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq -e 'type=="array"' >/dev/null
echo "✅ list returns array"

# seed one notification
NOTIF_ID="$(
  docker compose -f docker-compose.pilot.yml exec -T pilot_api node - <<'NODE'
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
(async () => {
  const admin = await prisma.user.findUnique({ where: { email: "admin@demo.com" }, select: { id: true }});
  const created = await prisma.notification.create({
    data: { userId: admin.id, title: "Smoke notif", body: "hello", kind: "info" },
    select: { id: true }
  });
  console.log(created.id);
  await prisma.$disconnect();
})();
NODE
)"
echo "✅ seeded $NOTIF_ID"

# mark read should be JSON 200
curl -sS -X POST "http://localhost:3000/api/notifications/$NOTIF_ID/read" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq -e '(.id != null) and (.seenAt != null)' >/dev/null
echo "✅ mark read ok"

# fake id should be JSON 404 (not HTML)
code="$(curl -s -o /tmp/notif_err.json -w "%{http_code}" \
  -X POST "http://localhost:3000/api/notifications/notif_does_not_exist_$(date +%s)/read" \
  -H "Authorization: Bearer $ADMIN_TOKEN")"
[ "$code" = "404" ] || (echo "❌ expected 404 got $code"; cat /tmp/notif_err.json; exit 1)
jq -e '.error' /tmp/notif_err.json >/dev/null
echo "✅ fake id returns JSON 404"

echo "🎉 Notifications smoke passed"
