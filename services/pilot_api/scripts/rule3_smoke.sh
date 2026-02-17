#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../../.."

DC="docker compose -f docker-compose.pilot.yml"

# strict dexec helper
dexec() {
  : "${1:?usage: dexec VAR=value ... -- cmd}"
  local args=()
  while [ "$1" != "--" ]; do
    case "$1" in
      *=*)
        local k="${1%%=*}"
        local v="${1#*=}"
        if [ -z "$v" ]; then
          echo "❌ dexec: $k is empty" >&2
          exit 2
        fi
        args+=(-e "$1")
        ;;
      *)
        echo "❌ dexec: expected KEY=value, got: $1" >&2
        exit 2
        ;;
    esac
    shift
  done
  shift
  $DC exec -T "${args[@]}" pilot_api "$@"
}

ADMIN_TOKEN="$(services/pilot_api/scripts/get_admin_token.sh)"
CLASSROOM_ID="${1:-cmlprjpnf000ooq01ee1bjkns}"

echo "== Rule-3 smoke =="
echo "CLASSROOM_ID=$CLASSROOM_ID"

echo "-> ensure membership"
dexec CLASSROOM_ID="$CLASSROOM_ID" -- node - <<'NODE'
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
(async () => {
  const admin = await prisma.user.findUnique({ where: { email: "admin@demo.com" }, select: { id: true }});
  const classroomId = process.env.CLASSROOM_ID;
  await prisma.classroomMember.upsert({
    where: { classroomId_userId: { classroomId, userId: admin.id } },
    update: { role: "teacher" },
    create: { classroomId, userId: admin.id, role: "teacher" },
  });
  console.log("✅ ensured membership", classroomId);
  await prisma.$disconnect();
})();
NODE

echo "-> expect 200 when member (assignments)"
code="$(curl -s -o /dev/null -w "%{http_code}" \
  "http://localhost:3000/api/assignments?classroomId=$CLASSROOM_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")"
[ "$code" = "200" ] && echo "✅ assignments 200" || (echo "❌ assignments expected 200 got $code" && exit 1)

echo "-> expect 200 when member (grades)"
code="$(curl -s -o /dev/null -w "%{http_code}" \
  "http://localhost:3000/api/grades?classroomId=$CLASSROOM_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")"
[ "$code" = "200" ] && echo "✅ grades 200" || (echo "❌ grades expected 200 got $code" && exit 1)

echo "-> remove membership"
dexec CLASSROOM_ID="$CLASSROOM_ID" -- node - <<'NODE'
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
(async () => {
  const admin = await prisma.user.findUnique({ where: { email: "admin@demo.com" }, select: { id: true }});
  const classroomId = process.env.CLASSROOM_ID;
  const del = await prisma.classroomMember.deleteMany({ where: { userId: admin.id, classroomId }});
  console.log("✅ removed membership count=", del.count, classroomId);
  await prisma.$disconnect();
})();
NODE

echo "-> expect 403 when NOT member (assignments)"
code="$(curl -s -o /dev/null -w "%{http_code}" \
  "http://localhost:3000/api/assignments?classroomId=$CLASSROOM_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")"
[ "$code" = "403" ] && echo "✅ assignments 403" || (echo "❌ assignments expected 403 got $code" && exit 1)

echo "-> expect 403 when NOT member (grades)"
code="$(curl -s -o /dev/null -w "%{http_code}" \
  "http://localhost:3000/api/grades?classroomId=$CLASSROOM_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")"
[ "$code" = "403" ] && echo "✅ grades 403" || (echo "❌ grades expected 403 got $code" && exit 1)

echo "-> restore membership (leave system usable)"
dexec CLASSROOM_ID="$CLASSROOM_ID" -- node - <<'NODE'
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
(async () => {
  const admin = await prisma.user.findUnique({ where: { email: "admin@demo.com" }, select: { id: true }});
  const classroomId = process.env.CLASSROOM_ID;
  await prisma.classroomMember.upsert({
    where: { classroomId_userId: { classroomId, userId: admin.id } },
    update: { role: "teacher" },
    create: { classroomId, userId: admin.id, role: "teacher" },
  });
  console.log("✅ restored membership", classroomId);
  await prisma.$disconnect();
})();
NODE

echo "🎉 Rule-3 smoke passed"
