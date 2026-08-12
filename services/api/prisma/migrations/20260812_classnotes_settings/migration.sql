-- How one user has the ClassNotes app set up: their pens and how each is tuned,
-- the eraser, tape, text boxes, beautification, what the Apple Pencil's squeeze
-- and double-tap do, and their theme.
--
-- One row per user. Signing in on a second device reads this and comes up
-- configured the way the first device is, instead of factory-fresh.
--
-- `payload` is JSONB and deliberately OPAQUE: it is the client's own settings
-- value. The backend never reads inside it, so every slider the app grows is a
-- client release rather than a migration here.
--
-- `revision` is the client's own counter and is what arbitrates between two
-- devices that both edited. A wall clock cannot do that job — devices disagree
-- about the time, and a phone running an hour behind would quietly write its
-- stale copy over the iPad's on every launch.
CREATE TABLE IF NOT EXISTS "ClassNotesSettings" (
    "userId" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "revision" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ClassNotesSettings_pkey" PRIMARY KEY ("userId")
);

ALTER TABLE "ClassNotesSettings"
    DROP CONSTRAINT IF EXISTS "ClassNotesSettings_userId_fkey";

ALTER TABLE "ClassNotesSettings"
    ADD CONSTRAINT "ClassNotesSettings_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
