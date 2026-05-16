-- Multi-grade cohort support. A single cohort can now span multiple grades
-- (e.g. a combined 4th+5th grade class). Adds an Int[] `grades` column and
-- backfills it from the existing single-value `grade` so every existing row
-- has grades = ARRAY[grade]. The legacy `grade` column stays — it now mirrors
-- grades[0] so all the read sites that still consume it keep working.

ALTER TABLE "Cohort"
  ADD COLUMN IF NOT EXISTS "grades" INTEGER[] NOT NULL DEFAULT '{}';

UPDATE "Cohort"
SET "grades" = ARRAY["grade"]
WHERE "grades" = '{}'::int[];
