set -e

echo "== GIT =="
git status -sb || true
git log -1 --oneline --decorate || true
echo
echo "== DIFFSTAT =="
git diff --stat || true
echo
echo "== COUNTS =="
echo -n "TS/TSX files: "; find . -type f \( -name "*.ts" -o -name "*.tsx" \) | wc -l
echo -n "API endpoints (@Get/@Post/@Patch/@Delete): "; rg -n "@(Get|Post|Patch|Delete)\\b" services/api/src -S | wc -l || true
echo -n "Prisma models: "; rg -n "^model\\s+" services/api/prisma/schema.prisma 2>/dev/null | wc -l || true
echo -n "Prisma migrations: "; ls -1 services/api/prisma/migrations 2>/dev/null | wc -l || true
echo
echo "== TODO/FIXME/WIP =="
rg -n "TODO|FIXME|WIP|HACK|TEMP|placeholder" -S . | head -n 80 || true
echo
echo "== BUILD (monorepo) =="
pnpm -r -w run build || true
echo
echo "== E2E tutor (workers=1) =="
pnpm --dir apps/admin-web exec playwright test e2e --grep tutor --workers=1 --reporter=line || true
echo
echo "== E2E tutor (workers=5) =="
pnpm --dir apps/admin-web exec playwright test e2e --grep tutor --workers=5 --reporter=line || true
