-- Backfills every ScheduleSlot column that was declared in schema.prisma
-- but never shipped with a migration file. These were added locally
-- via `prisma db push` (which doesn't write migration files), so
-- Railway's `prisma migrate deploy` never picked them up — every slot
-- select that touched them threw "column does not exist", the resolver
-- returned an empty array, and the student schedule was empty even
-- though admin (which uses different queries) showed the slots fine.
--
-- All ADD COLUMN IF NOT EXISTS so this is safe to re-run on
-- environments where some columns are already present.

ALTER TABLE "ScheduleSlot"
  ADD COLUMN IF NOT EXISTS "studentDateSkips" TEXT[]  NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS "skipDates"        TEXT[]  NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS "audienceGrade"    INTEGER,
  ADD COLUMN IF NOT EXISTS "caption"          TEXT,
  ADD COLUMN IF NOT EXISTS "color"            TEXT,
  ADD COLUMN IF NOT EXISTS "startDate"        TEXT;
