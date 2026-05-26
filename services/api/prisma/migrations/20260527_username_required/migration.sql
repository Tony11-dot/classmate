-- Username is the app's primary login identifier and must exist on every
-- user. /auth/register and a few legacy dev-token paths previously created
-- users with NULL username, so this migration:
--   1. Backfills any NULL username by deriving from the email local-part
--      (or "user" if neither email nor name are usable), with a numeric
--      suffix on collision.
--   2. Adds the NOT NULL constraint after the backfill.
--
-- The collision-handling pass uses row_number() partitioned by the derived
-- candidate so siblings deterministically get suffixed (john, john2, john3).

BEGIN;

-- Step 1: derive a candidate column for every NULL row so we can detect
-- collisions in a single pass. We lowercase + strip non-[a-z0-9] from
-- the email local-part, fall back to lowered name, then "user".
WITH candidates AS (
  SELECT
    u.id,
    COALESCE(
      NULLIF(regexp_replace(lower(split_part(u.email, '@', 1)), '[^a-z0-9]', '', 'g'), ''),
      NULLIF(regexp_replace(lower(u.name),                       '[^a-z0-9]', '', 'g'), ''),
      'user'
    ) AS candidate
  FROM "User" u
  WHERE u.username IS NULL
),
-- Step 2: number the rows that share a candidate so each row gets a
-- distinct suffix. Also include rows whose candidate matches an EXISTING
-- (non-null) username so we don't collide with already-claimed values.
ranked AS (
  SELECT
    c.id,
    c.candidate,
    -- offset by 1 + the count of already-taken matches so suffix starts
    -- past the existing ones (john exists → first new becomes john2)
    row_number() OVER (PARTITION BY c.candidate ORDER BY c.id) +
      (SELECT count(*) FROM "User" u2 WHERE u2.username = c.candidate) AS rn
  FROM candidates c
)
UPDATE "User" u
SET    username = CASE WHEN r.rn = 1 AND NOT EXISTS (
                          SELECT 1 FROM "User" u2 WHERE u2.username = r.candidate
                        )
                        THEN r.candidate
                        ELSE r.candidate || r.rn::text
                   END
FROM   ranked r
WHERE  u.id = r.id;

-- Step 3: enforce NOT NULL now that every row has a value.
ALTER TABLE "User"
  ALTER COLUMN "username" SET NOT NULL;

COMMIT;
