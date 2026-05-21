-- Adds the multi-language name columns to User. These were declared in
-- schema.prisma but never had a migration file shipped — they were
-- presumably added locally via `prisma db push` which doesn't write a
-- migration. Railway's `prisma migrate deploy` never picked them up, so
-- on production these columns don't exist.
--
-- The schedule resolver's slot select now reads these (so the period
-- tile can show the teacher's curated display name with proper
-- displayName → nameEn → name fallback). Without these columns, every
-- slot select threw "column does not exist", the resolver returned an
-- empty array, and students saw an empty schedule even though admin
-- could see the slots fine.

ALTER TABLE "User"
  ADD COLUMN IF NOT EXISTS "nameEn"          TEXT,
  ADD COLUMN IF NOT EXISTS "nameAr"          TEXT,
  ADD COLUMN IF NOT EXISTS "nameHe"          TEXT,
  ADD COLUMN IF NOT EXISTS "nameFr"          TEXT,
  ADD COLUMN IF NOT EXISTS "nameRu"          TEXT,
  ADD COLUMN IF NOT EXISTS "displayNameLang" TEXT;
