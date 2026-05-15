-- Add JSONB column for multi-language subject names. Backfill from the
-- existing `subjects` String[] (each entry becomes { nameEn: <s> }).
ALTER TABLE "SchoolGradeSubjectDefault"
  ADD COLUMN IF NOT EXISTS "subjectsI18n" JSONB NOT NULL DEFAULT '[]';

UPDATE "SchoolGradeSubjectDefault"
SET "subjectsI18n" = COALESCE(
  (
    SELECT jsonb_agg(jsonb_build_object('nameEn', s))
    FROM unnest("subjects") s
  ),
  '[]'::jsonb
)
WHERE "subjectsI18n" = '[]'::jsonb;
