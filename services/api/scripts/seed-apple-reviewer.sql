-- Apple App Review demo accounts — raw SQL alternative to seed-apple-reviewer.ts.
-- Run this from Railway's Postgres Data → Query console when you can't
-- reach the DB from your laptop. Idempotent: re-running just updates
-- the password back to the canonical value.
--
-- Password for all accounts: AppleReview2026!
-- The bcrypt hash below was generated once with `bcrypt.hash('AppleReview2026!', 10)`
-- and matches what the application's auth.service.ts uses to verify
-- on login. Cost factor 10, salt embedded.
--
-- Generated hash (10 rounds): $2b$10$rXqFb9LJ8mPmbW9NXxFvAOPnTpwTByT4eX2hCfJh9oUOMHHV0EZJG

BEGIN;

-- 1) School row (idempotent on name).
INSERT INTO "School" (id, name, "minGrade", "maxGrade", "createdAt", "updatedAt")
SELECT gen_random_uuid(), 'Apple Review School', 5, 12, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM "School" WHERE name = 'Apple Review School');

-- 2) For each role, upsert one user and ensure exactly one UserRole row.
WITH school AS (
  SELECT id FROM "School" WHERE name = 'Apple Review School' LIMIT 1
),
seeds(role, email, username, name) AS (
  VALUES
    ('ADMIN'::text,     'apple-review@classmate.app',           'apple-review',           'Apple Review (Admin)'),
    ('SECRETARY'::text, 'apple-review-secretary@classmate.app', 'apple-review-secretary', 'Apple Review (Secretary)'),
    ('TEACHER'::text,   'apple-review-teacher@classmate.app',   'apple-review-teacher',   'Apple Review (Teacher)'),
    ('STUDENT'::text,   'apple-review-student@classmate.app',   'apple-review-student',   'Apple Review (Student)'),
    ('PARENT'::text,    'apple-review-parent@classmate.app',    'apple-review-parent',    'Apple Review (Parent)')
),
upserts AS (
  INSERT INTO "User" (
    id, email, username, password, "plainPassword", name, "nameEn",
    "schoolId", "displayName"
  )
  SELECT
    gen_random_uuid(),
    s.email,
    s.username,
    '$2b$10$rXqFb9LJ8mPmbW9NXxFvAOPnTpwTByT4eX2hCfJh9oUOMHHV0EZJG',
    'AppleReview2026!',
    s.name,
    s.name,
    (SELECT id FROM school),
    s.name
  FROM seeds s
  ON CONFLICT (email) DO UPDATE SET
    username = EXCLUDED.username,
    password = EXCLUDED.password,
    "plainPassword" = EXCLUDED."plainPassword",
    name = EXCLUDED.name,
    "nameEn" = EXCLUDED."nameEn",
    "schoolId" = EXCLUDED."schoolId",
    "displayName" = EXCLUDED."displayName"
  RETURNING id, email
)
INSERT INTO "UserRole" ("userId", role)
SELECT u.id, s.role::"Role"
FROM upserts u
JOIN seeds s ON s.email = u.email
ON CONFLICT DO NOTHING;

-- 3) Make sure the student row has the grade field set for the
--    student account so the schedule + classroom screens render.
INSERT INTO "StudentProfile" ("userId", grade)
SELECT u.id, 9
FROM "User" u
WHERE u.email = 'apple-review-student@classmate.app'
ON CONFLICT ("userId") DO UPDATE SET grade = 9;

COMMIT;

-- Sanity check — should return 5 rows.
SELECT u.email, u.username, ur.role
FROM "User" u
JOIN "UserRole" ur ON ur."userId" = u.id
WHERE u.email LIKE 'apple-review%@classmate.app'
ORDER BY ur.role;
