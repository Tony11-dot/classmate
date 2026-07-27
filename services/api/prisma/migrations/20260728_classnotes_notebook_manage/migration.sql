-- Managing the ClassNotes library from inside ClassMate: reorder, rename,
-- re-shelve and delete notebooks that were created on the iPad.
--
-- `sortIndex`      manual drag order (null = never arranged; sorts after the
--                  arranged ones, newest first).
-- `deletedAt`      tombstone. The native app pushes its ENTIRE library on every
--                  launch, so a hard delete here would be undone a minute later.
--                  The row survives as a marker until the app has pulled the
--                  deletion, removed its local copy and acknowledged it.
-- `remoteEditedAt` marks a notebook edited from ClassMate, so the app's own push
--                  can't clobber the newer title/shelf before it pulls it.
ALTER TABLE "ClassNotesNotebook" ADD COLUMN IF NOT EXISTS "sortIndex" INTEGER;
ALTER TABLE "ClassNotesNotebook" ADD COLUMN IF NOT EXISTS "deletedAt" TIMESTAMP(3);
ALTER TABLE "ClassNotesNotebook" ADD COLUMN IF NOT EXISTS "remoteEditedAt" TIMESTAMP(3);

CREATE INDEX IF NOT EXISTS "ClassNotesNotebook_userId_deletedAt_idx"
  ON "ClassNotesNotebook"("userId", "deletedAt");
