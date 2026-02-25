# Dev DB Notes (Prisma)

If `pnpm prisma migrate dev` fails with **P3014** (cannot create shadow database),
use `db push` in DEV to sync schema without a shadow DB:

pnpm -s prisma db push
pnpm -s prisma generate

If Prisma warns about drift / destructive changes in DEV:

pnpm -s prisma db push --accept-data-loss
pnpm -s prisma generate

Reason: local DB user may not have permission to `CREATE DATABASE`, which Prisma
needs for the shadow database used by `migrate dev`.
