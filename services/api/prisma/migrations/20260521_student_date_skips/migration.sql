-- Adds the studentDateSkips column referenced by the schedule resolver
-- (per-student per-date suppression for Once overrides). The column was
-- introduced in the schema with `prisma db push` but never had a
-- migration file, so production deploys via `prisma migrate deploy`
-- never picked it up. Without this column the rich slot select fails
-- and the resolver falls back to a shape that drops materials — which
-- is why period tiles render without attachment pills even when the
-- teacher attached materials.

ALTER TABLE "ScheduleSlot"
  ADD COLUMN IF NOT EXISTS "studentDateSkips" TEXT[] NOT NULL DEFAULT '{}';
