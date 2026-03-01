DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public'
      AND indexname = 'TutorCharacter_global_subject_name_key'
  ) THEN
    EXECUTE 'CREATE UNIQUE INDEX "TutorCharacter_global_subject_name_key"
             ON "TutorCharacter" ("subject","name")
             WHERE "cohortId" IS NULL;';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public'
      AND indexname = 'TutorCharacter_scoped_cohort_subject_name_key'
  ) THEN
    EXECUTE 'CREATE UNIQUE INDEX "TutorCharacter_scoped_cohort_subject_name_key"
             ON "TutorCharacter" ("cohortId","subject","name")
             WHERE "cohortId" IS NOT NULL;';
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'TutorCharacter_cohortId_subject_name_key') THEN
    EXECUTE 'ALTER TABLE "TutorCharacter" DROP CONSTRAINT "TutorCharacter_cohortId_subject_name_key";';
  END IF;
END $$;

WITH ranked AS (
  SELECT
    id,
    "subject",
    "name",
    row_number() OVER (
      PARTITION BY "subject","name"
      ORDER BY "updatedAt" DESC, "createdAt" DESC
    ) AS rn
  FROM "TutorCharacter"
  WHERE "cohortId" IS NULL
)
DELETE FROM "TutorCharacter" t
USING ranked r
WHERE t.id = r.id
  AND r.rn > 1;

INSERT INTO "TutorCharacter"
("id","createdAt","updatedAt","cohortId","subject","name","tone","verbosity","explainStyle","curriculum","maxGrade","language","systemNotes","createdById","isPublic")
VALUES
(gen_random_uuid(), now(), now(), NULL, 'GENERAL', 'Coach Nova', 'supportive', 6, 'step-by-step', 'Bagrut', 12, 'en', 'General study coach. Ask clarifying questions. Keep it Bagrut-level.', NULL, true),
(gen_random_uuid(), now(), now(), NULL, 'MATH', 'Math Beast', 'direct', 6, 'worked-examples', 'Bagrut', 12, 'en', 'Focus on methods, not magic. Verify steps. Quick checks.', NULL, true),
(gen_random_uuid(), now(), now(), NULL, 'PHYSICS', 'Dr. Vector', 'calm', 6, 'concept-first', 'Bagrut', 12, 'en', 'Stay within standard curriculum. No air resistance unless asked.', NULL, true),
(gen_random_uuid(), now(), now(), NULL, 'CS', 'Algo Coach', 'energetic', 6, 'intuition+proof', 'Bagrut', 12, 'en', 'Explain like to a 4th grader, then formalize. Use small examples.', NULL, true),
(gen_random_uuid(), now(), now(), NULL, 'ENGLISH', 'Essay Architect', 'friendly', 6, 'structure-first', 'Bagrut', 12, 'en', 'Help with writing structure, clarity, and vocabulary. Encourage practice.', NULL, true)
ON CONFLICT ("subject","name") WHERE "cohortId" IS NULL DO UPDATE
SET
  "updatedAt" = EXCLUDED."updatedAt",
  "tone" = EXCLUDED."tone",
  "verbosity" = EXCLUDED."verbosity",
  "explainStyle" = EXCLUDED."explainStyle",
  "curriculum" = EXCLUDED."curriculum",
  "maxGrade" = EXCLUDED."maxGrade",
  "language" = EXCLUDED."language",
  "systemNotes" = EXCLUDED."systemNotes",
  "isPublic" = EXCLUDED."isPublic";
